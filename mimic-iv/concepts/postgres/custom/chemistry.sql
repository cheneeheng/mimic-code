-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS chemistry; CREATE TABLE chemistry AS 
-- extract chemistry labs
-- excludes point of care tests (very rare)
-- blood gas measurements are *not* included in this query
-- instead they are in bg.sql
SELECT 
    MAX(subject_id) AS subject_id
  , MAX(hadm_id) AS hadm_id
  , MAX(charttime) AS charttime
  , le.specimen_id
  -- convert from itemid into a meaningful column
  , MAX(CASE WHEN itemid = 50862 AND valuenum <=    10 THEN valuenum ELSE NULL END) AS albumin
  , MAX(CASE WHEN itemid = 50930 AND valuenum <=    10 THEN valuenum ELSE NULL END) AS globulin
  , MAX(CASE WHEN itemid = 50976 AND valuenum <=    20 THEN valuenum ELSE NULL END) AS total_protein
  , MAX(CASE WHEN itemid = 50868 AND valuenum <= 10000 THEN valuenum ELSE NULL END) AS aniongap
  , MAX(CASE WHEN itemid = 50882 AND valuenum <= 10000 THEN valuenum ELSE NULL END) AS bicarbonate
  , MAX(CASE WHEN itemid = 51006 AND valuenum <=   300 THEN valuenum ELSE NULL END) AS bun
  , MAX(CASE WHEN itemid = 50893 AND valuenum <= 10000 THEN valuenum ELSE NULL END) AS calcium
  , MAX(CASE WHEN itemid = 50902 AND valuenum <= 10000 THEN valuenum ELSE NULL END) AS chloride
  , MAX(CASE WHEN itemid = 50912 AND valuenum <=   150 THEN valuenum ELSE NULL END) AS creatinine
  , MAX(CASE WHEN itemid = 50931 AND valuenum <= 10000 THEN valuenum ELSE NULL END) AS glucose
  , MAX(CASE WHEN itemid = 50983 AND valuenum <=   200 THEN valuenum ELSE NULL END) AS sodium
  , MAX(CASE WHEN itemid = 50971 AND valuenum <=    30 THEN valuenum ELSE NULL END) AS potassium
  
  , MAX(CASE WHEN itemid = 50862 AND valuenum <=    10 THEN valueuom ELSE NULL END) AS albumin_unit
  , MAX(CASE WHEN itemid = 50930 AND valuenum <=    10 THEN valueuom ELSE NULL END) AS globulin_unit
  , MAX(CASE WHEN itemid = 50976 AND valuenum <=    20 THEN valueuom ELSE NULL END) AS total_protein_unit
  , MAX(CASE WHEN itemid = 50868 AND valuenum <= 10000 THEN valueuom ELSE NULL END) AS aniongap_unit
  , MAX(CASE WHEN itemid = 50882 AND valuenum <= 10000 THEN valueuom ELSE NULL END) AS bicarbonate_unit
  , MAX(CASE WHEN itemid = 51006 AND valuenum <=   300 THEN valueuom ELSE NULL END) AS bun_unit
  , MAX(CASE WHEN itemid = 50893 AND valuenum <= 10000 THEN valueuom ELSE NULL END) AS calcium_unit
  , MAX(CASE WHEN itemid = 50902 AND valuenum <= 10000 THEN valueuom ELSE NULL END) AS chloride_unit
  , MAX(CASE WHEN itemid = 50912 AND valuenum <=   150 THEN valueuom ELSE NULL END) AS creatinine_unit
  , MAX(CASE WHEN itemid = 50931 AND valuenum <= 10000 THEN valueuom ELSE NULL END) AS glucose_unit
  , MAX(CASE WHEN itemid = 50983 AND valuenum <=   200 THEN valueuom ELSE NULL END) AS sodium_unit
  , MAX(CASE WHEN itemid = 50971 AND valuenum <=    30 THEN valueuom ELSE NULL END) AS potassium_unit

  , MAX(CASE WHEN itemid = 50862 AND valuenum <=    10 THEN ref_range_lower ELSE NULL END) AS albumin_lower
  , MAX(CASE WHEN itemid = 50930 AND valuenum <=    10 THEN ref_range_lower ELSE NULL END) AS globulin_lower
  , MAX(CASE WHEN itemid = 50976 AND valuenum <=    20 THEN ref_range_lower ELSE NULL END) AS total_protein_lower
  , MAX(CASE WHEN itemid = 50868 AND valuenum <= 10000 THEN ref_range_lower ELSE NULL END) AS aniongap_lower
  , MAX(CASE WHEN itemid = 50882 AND valuenum <= 10000 THEN ref_range_lower ELSE NULL END) AS bicarbonate_lower
  , MAX(CASE WHEN itemid = 51006 AND valuenum <=   300 THEN ref_range_lower ELSE NULL END) AS bun_lower
  , MAX(CASE WHEN itemid = 50893 AND valuenum <= 10000 THEN ref_range_lower ELSE NULL END) AS calcium_lower
  , MAX(CASE WHEN itemid = 50902 AND valuenum <= 10000 THEN ref_range_lower ELSE NULL END) AS chloride_lower
  , MAX(CASE WHEN itemid = 50912 AND valuenum <=   150 THEN ref_range_lower ELSE NULL END) AS creatinine_lower
  , MAX(CASE WHEN itemid = 50931 AND valuenum <= 10000 THEN ref_range_lower ELSE NULL END) AS glucose_lower
  , MAX(CASE WHEN itemid = 50983 AND valuenum <=   200 THEN ref_range_lower ELSE NULL END) AS sodium_lower
  , MAX(CASE WHEN itemid = 50971 AND valuenum <=    30 THEN ref_range_lower ELSE NULL END) AS potassium_lower
  
  , MAX(CASE WHEN itemid = 50862 AND valuenum <=    10 THEN ref_range_upper ELSE NULL END) AS albumin_upper
  , MAX(CASE WHEN itemid = 50930 AND valuenum <=    10 THEN ref_range_upper ELSE NULL END) AS globulin_upper
  , MAX(CASE WHEN itemid = 50976 AND valuenum <=    20 THEN ref_range_upper ELSE NULL END) AS total_protein_upper
  , MAX(CASE WHEN itemid = 50868 AND valuenum <= 10000 THEN ref_range_upper ELSE NULL END) AS aniongap_upper
  , MAX(CASE WHEN itemid = 50882 AND valuenum <= 10000 THEN ref_range_upper ELSE NULL END) AS bicarbonate_upper
  , MAX(CASE WHEN itemid = 51006 AND valuenum <=   300 THEN ref_range_upper ELSE NULL END) AS bun_upper
  , MAX(CASE WHEN itemid = 50893 AND valuenum <= 10000 THEN ref_range_upper ELSE NULL END) AS calcium_upper
  , MAX(CASE WHEN itemid = 50902 AND valuenum <= 10000 THEN ref_range_upper ELSE NULL END) AS chloride_upper
  , MAX(CASE WHEN itemid = 50912 AND valuenum <=   150 THEN ref_range_upper ELSE NULL END) AS creatinine_upper
  , MAX(CASE WHEN itemid = 50931 AND valuenum <= 10000 THEN ref_range_upper ELSE NULL END) AS glucose_upper
  , MAX(CASE WHEN itemid = 50983 AND valuenum <=   200 THEN ref_range_upper ELSE NULL END) AS sodium_upper
  , MAX(CASE WHEN itemid = 50971 AND valuenum <=    30 THEN ref_range_upper ELSE NULL END) AS potassium_upper
  
FROM mimic_hosp.labevents le
WHERE le.itemid IN
(
  -- comment is: LABEL | CATEGORY | FLUID | NUMBER OF ROWS IN LABEVENTS
  50862, -- ALBUMIN | CHEMISTRY | BLOOD | 146697
  50930, -- Globulin
  50976, -- Total protein
  50868, -- ANION GAP | CHEMISTRY | BLOOD | 769895
  -- 52456, -- Anion gap, point of care test
  50882, -- BICARBONATE | CHEMISTRY | BLOOD | 780733
  50893, -- Calcium
  50912, -- CREATININE | CHEMISTRY | BLOOD | 797476
  -- 52502, Creatinine, point of care
  50902, -- CHLORIDE | CHEMISTRY | BLOOD | 795568
  50931, -- GLUCOSE | CHEMISTRY | BLOOD | 748981
  -- 52525, Glucose, point of care
  50971, -- POTASSIUM | CHEMISTRY | BLOOD | 845825
  -- 52566, -- Potassium, point of care
  50983, -- SODIUM | CHEMISTRY | BLOOD | 808489
  -- 52579, -- Sodium, point of care
  51006  -- UREA NITROGEN | CHEMISTRY | BLOOD | 791925
  -- 52603, Urea, point of care
)
AND valuenum IS NOT NULL
-- lab values cannot be 0 and cannot be negative
-- .. except anion gap.
AND (valuenum > 0 OR itemid = 50868)
GROUP BY le.specimen_id
;