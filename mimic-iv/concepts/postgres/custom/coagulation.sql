-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS coagulation; CREATE TABLE coagulation AS 
SELECT
    MAX(subject_id) AS subject_id
  , MAX(hadm_id) AS hadm_id
  , MAX(charttime) AS charttime
  , le.specimen_id
  -- convert from itemid into a meaningful column
  , MAX(CASE WHEN itemid = 51196 THEN valuenum ELSE NULL END) AS d_dimer
  , MAX(CASE WHEN itemid = 51214 THEN valuenum ELSE NULL END) AS fibrinogen
  , MAX(CASE WHEN itemid = 51297 THEN valuenum ELSE NULL END) AS thrombin
  , MAX(CASE WHEN itemid = 51237 THEN valuenum ELSE NULL END) AS inr
  , MAX(CASE WHEN itemid = 51274 THEN valuenum ELSE NULL END) AS pt
  , MAX(CASE WHEN itemid = 51275 THEN valuenum ELSE NULL END) AS ptt
  
  , MAX(CASE WHEN itemid = 51196 THEN valueuom ELSE NULL END) AS d_dimer_unit
  , MAX(CASE WHEN itemid = 51214 THEN valueuom ELSE NULL END) AS fibrinogen_unit
  , MAX(CASE WHEN itemid = 51297 THEN valueuom ELSE NULL END) AS thrombin_unit
  , MAX(CASE WHEN itemid = 51237 THEN valueuom ELSE NULL END) AS inr_unit
  , MAX(CASE WHEN itemid = 51274 THEN valueuom ELSE NULL END) AS pt_unit
  , MAX(CASE WHEN itemid = 51275 THEN valueuom ELSE NULL END) AS ptt_unit
  
  , MAX(CASE WHEN itemid = 51196 THEN ref_range_lower ELSE NULL END) AS d_dimer_lower
  , MAX(CASE WHEN itemid = 51214 THEN ref_range_lower ELSE NULL END) AS fibrinogen_lower
  , MAX(CASE WHEN itemid = 51297 THEN ref_range_lower ELSE NULL END) AS thrombin_lower
  , MAX(CASE WHEN itemid = 51237 THEN ref_range_lower ELSE NULL END) AS inr_lower
  , MAX(CASE WHEN itemid = 51274 THEN ref_range_lower ELSE NULL END) AS pt_lower
  , MAX(CASE WHEN itemid = 51275 THEN ref_range_lower ELSE NULL END) AS ptt_lower
  
  , MAX(CASE WHEN itemid = 51196 THEN ref_range_upper ELSE NULL END) AS d_dimer_upper
  , MAX(CASE WHEN itemid = 51214 THEN ref_range_upper ELSE NULL END) AS fibrinogen_upper
  , MAX(CASE WHEN itemid = 51297 THEN ref_range_upper ELSE NULL END) AS thrombin_upper
  , MAX(CASE WHEN itemid = 51237 THEN ref_range_upper ELSE NULL END) AS inr_upper
  , MAX(CASE WHEN itemid = 51274 THEN ref_range_upper ELSE NULL END) AS pt_upper
  , MAX(CASE WHEN itemid = 51275 THEN ref_range_upper ELSE NULL END) AS ptt_upper
FROM mimic_hosp.labevents le
WHERE le.itemid IN
(
    -- 51149, 52750, 52072, 52073 -- Bleeding Time, no data as of MIMIC-IV v0.4
    51196, -- D-Dimer
    51214, -- Fibrinogen
    -- 51280, 52893, -- Reptilase Time, no data as of MIMIC-IV v0.4
    -- 51281, 52161, -- Reptilase Time Control, no data as of MIMIC-IV v0.4
    51297, -- thrombin
    51237, -- INR
    51274, -- PT
    51275 -- PTT
)
AND valuenum IS NOT NULL
GROUP BY le.specimen_id
;
