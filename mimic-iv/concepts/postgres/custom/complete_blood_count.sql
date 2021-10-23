-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS complete_blood_count; CREATE TABLE complete_blood_count AS 
-- begin query that extracts the data
SELECT
    MAX(subject_id) AS subject_id
  , MAX(hadm_id) AS hadm_id
  , MAX(charttime) AS charttime
  , le.specimen_id
  -- convert from itemid into a meaningful column
  , MAX(CASE WHEN itemid = 51221 THEN valuenum ELSE NULL END) AS hematocrit
  , MAX(CASE WHEN itemid = 51222 THEN valuenum ELSE NULL END) AS hemoglobin
  , MAX(CASE WHEN itemid = 51248 THEN valuenum ELSE NULL END) AS mch
  , MAX(CASE WHEN itemid = 51249 THEN valuenum ELSE NULL END) AS mchc
  , MAX(CASE WHEN itemid = 51250 THEN valuenum ELSE NULL END) AS mcv
  , MAX(CASE WHEN itemid = 51265 THEN valuenum ELSE NULL END) AS platelet
  , MAX(CASE WHEN itemid = 51279 THEN valuenum ELSE NULL END) AS rbc
  , MAX(CASE WHEN itemid = 51277 THEN valuenum ELSE NULL END) AS rdw
  , MAX(CASE WHEN itemid = 52159 THEN valuenum ELSE NULL END) AS rdwsd
  , MAX(CASE WHEN itemid = 51301 THEN valuenum ELSE NULL END) AS wbc
  
  , MAX(CASE WHEN itemid = 51221 THEN valueuom ELSE NULL END) AS hematocrit_unit
  , MAX(CASE WHEN itemid = 51222 THEN valueuom ELSE NULL END) AS hemoglobin_unit
  , MAX(CASE WHEN itemid = 51248 THEN valueuom ELSE NULL END) AS mch_unit
  , MAX(CASE WHEN itemid = 51249 THEN valueuom ELSE NULL END) AS mchc_unit
  , MAX(CASE WHEN itemid = 51250 THEN valueuom ELSE NULL END) AS mcv_unit
  , MAX(CASE WHEN itemid = 51265 THEN valueuom ELSE NULL END) AS platelet_unit
  , MAX(CASE WHEN itemid = 51279 THEN valueuom ELSE NULL END) AS rbc_unit
  , MAX(CASE WHEN itemid = 51277 THEN valueuom ELSE NULL END) AS rdw_unit
  , MAX(CASE WHEN itemid = 52159 THEN valueuom ELSE NULL END) AS rdwsd_unit
  , MAX(CASE WHEN itemid = 51301 THEN valueuom ELSE NULL END) AS wbc_unit
  
  , MAX(CASE WHEN itemid = 51221 THEN ref_range_lower ELSE NULL END) AS hematocrit_lower
  , MAX(CASE WHEN itemid = 51222 THEN ref_range_lower ELSE NULL END) AS hemoglobin_lower
  , MAX(CASE WHEN itemid = 51248 THEN ref_range_lower ELSE NULL END) AS mch_lower
  , MAX(CASE WHEN itemid = 51249 THEN ref_range_lower ELSE NULL END) AS mchc_lower
  , MAX(CASE WHEN itemid = 51250 THEN ref_range_lower ELSE NULL END) AS mcv_lower
  , MAX(CASE WHEN itemid = 51265 THEN ref_range_lower ELSE NULL END) AS platelet_lower
  , MAX(CASE WHEN itemid = 51279 THEN ref_range_lower ELSE NULL END) AS rbc_lower
  , MAX(CASE WHEN itemid = 51277 THEN ref_range_lower ELSE NULL END) AS rdw_lower
  , MAX(CASE WHEN itemid = 52159 THEN ref_range_lower ELSE NULL END) AS rdwsd_lower
  , MAX(CASE WHEN itemid = 51301 THEN ref_range_lower ELSE NULL END) AS wbc_lower
  
  , MAX(CASE WHEN itemid = 51221 THEN ref_range_upper ELSE NULL END) AS hematocrit_upper
  , MAX(CASE WHEN itemid = 51222 THEN ref_range_upper ELSE NULL END) AS hemoglobin_upper
  , MAX(CASE WHEN itemid = 51248 THEN ref_range_upper ELSE NULL END) AS mch_upper
  , MAX(CASE WHEN itemid = 51249 THEN ref_range_upper ELSE NULL END) AS mchc_upper
  , MAX(CASE WHEN itemid = 51250 THEN ref_range_upper ELSE NULL END) AS mcv_upper
  , MAX(CASE WHEN itemid = 51265 THEN ref_range_upper ELSE NULL END) AS platelet_upper
  , MAX(CASE WHEN itemid = 51279 THEN ref_range_upper ELSE NULL END) AS rbc_upper
  , MAX(CASE WHEN itemid = 51277 THEN ref_range_upper ELSE NULL END) AS rdw_upper
  , MAX(CASE WHEN itemid = 52159 THEN ref_range_upper ELSE NULL END) AS rdwsd_upper
  , MAX(CASE WHEN itemid = 51301 THEN ref_range_upper ELSE NULL END) AS wbc_upper
FROM mimic_hosp.labevents le
WHERE le.itemid IN
(
    51221, -- hematocrit
    51222, -- hemoglobin
    51248, -- MCH
    51249, -- MCHC
    51250, -- MCV
    51265, -- platelets
    51279, -- RBC
    51277, -- RDW
    52159, -- RDW SD
    51301  -- WBC

)
AND valuenum IS NOT NULL
-- lab values cannot be 0 and cannot be negative
AND valuenum > 0
GROUP BY le.specimen_id
;
