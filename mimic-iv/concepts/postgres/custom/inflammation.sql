-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS inflammation; CREATE TABLE inflammation AS 
SELECT
    MAX(subject_id) AS subject_id
  , MAX(hadm_id) AS hadm_id
  , MAX(charttime) AS charttime
  , le.specimen_id
  -- convert from itemid into a meaningful column
  , MAX(CASE WHEN itemid = 50889 THEN valuenum ELSE NULL END) AS crp
  , MAX(CASE WHEN itemid = 50889 THEN valueuom ELSE NULL END) AS crp_unit
  , MAX(CASE WHEN itemid = 50889 THEN ref_range_lower ELSE NULL END) AS crp_lower
  , MAX(CASE WHEN itemid = 50889 THEN ref_range_upper ELSE NULL END) AS crp_upper
  -- , CAST(NULL AS NUMERIC) AS il6
  -- , CAST(NULL AS NUMERIC) AS procalcitonin
FROM mimic_hosp.labevents le
WHERE le.itemid IN
(
    50889 -- crp
    -- 51652 -- high sensitivity CRP
)
AND valuenum IS NOT NULL
-- lab values cannot be 0 and cannot be negative
AND valuenum > 0
GROUP BY le.specimen_id
;