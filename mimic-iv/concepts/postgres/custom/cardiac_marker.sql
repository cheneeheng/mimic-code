-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS cardiac_marker; CREATE TABLE cardiac_marker AS 
-- begin query that extracts the data
SELECT
    MAX(subject_id) AS subject_id
  , MAX(hadm_id) AS hadm_id
  , MAX(charttime) AS charttime
  , le.specimen_id
  -- convert from itemid into a meaningful column
  , MAX(CASE WHEN itemid = 51002 THEN value ELSE NULL END) AS troponin_i
  , MAX(CASE WHEN itemid = 51003 THEN value ELSE NULL END) AS troponin_t
  , MAX(CASE WHEN itemid = 50911 THEN valuenum ELSE NULL END) AS ck_mb
  , MAX(CASE WHEN itemid = 51002 THEN valueuom ELSE NULL END) AS troponin_i_unit
  , MAX(CASE WHEN itemid = 51003 THEN valueuom ELSE NULL END) AS troponin_t_unit
  , MAX(CASE WHEN itemid = 50911 THEN valueuom ELSE NULL END) AS ck_mb_unit
  , MAX(CASE WHEN itemid = 51002 THEN ref_range_lower ELSE NULL END) AS troponin_i_lower
  , MAX(CASE WHEN itemid = 51003 THEN ref_range_lower ELSE NULL END) AS troponin_t_lower
  , MAX(CASE WHEN itemid = 50911 THEN ref_range_lower ELSE NULL END) AS ck_mb_lower
  , MAX(CASE WHEN itemid = 51002 THEN ref_range_upper ELSE NULL END) AS troponin_i_upper
  , MAX(CASE WHEN itemid = 51003 THEN ref_range_upper ELSE NULL END) AS troponin_t_upper
  , MAX(CASE WHEN itemid = 50911 THEN ref_range_upper ELSE NULL END) AS ck_mb_upper
FROM mimic_hosp.labevents le
WHERE le.itemid IN
(
    -- 51002, -- Troponin I (troponin-I is not measured in MIMIC-IV)
    -- 52598, -- Troponin I, point of care, rare/poor quality
    51003, -- Troponin T
    50911  -- Creatinine Kinase, MB isoenzyme
)
GROUP BY le.specimen_id
;
