-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS hadm_check; CREATE TABLE hadm_check AS 
-- begin query that extracts the data
SELECT
  subject_id,
  hadm_id
FROM mimic_hosp.labevents le
;
