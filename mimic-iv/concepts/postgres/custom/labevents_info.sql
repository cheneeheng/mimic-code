-- DROP TABLE IF EXISTS labevents_info; CREATE TABLE labevents_info AS 
-- SELECT 
--     le.itemid
--   , count(DISTINCT(valueuom)) AS valueuom_count
--   , MAX(DISTINCT(valueuom)) AS valueuom
--   , count(DISTINCT(ref_range_lower)) AS ref_range_lower_count
--   , MAX(DISTINCT(ref_range_lower)) AS ref_range_lower
--   , count(DISTINCT(ref_range_upper)) AS ref_range_upper_count
--   , MAX(DISTINCT(ref_range_upper)) AS ref_range_upper
-- FROM mimic_hosp.labevents le
-- -- AND valueuom IS NOT NULL
-- GROUP BY le.itemid
-- ;

DROP TABLE IF EXISTS labevents_info; CREATE TABLE labevents_info AS 

WITH unique_rows AS
(
  SELECT 
    DISTINCT itemid, valueuom, ref_range_lower, ref_range_upper
  FROM mimic_hosp.labevents le
),
unique_counts AS
(
  SELECT 
      le.itemid
    , count(DISTINCT(valueuom)) AS valueuom_count
    , count(DISTINCT(ref_range_lower)) AS ref_range_lower_count
    , count(DISTINCT(ref_range_upper)) AS ref_range_upper_count
  FROM mimic_hosp.labevents le
  GROUP BY le.itemid
)
SELECT 
  unique_rows.itemid
  , unique_rows.valueuom
  , unique_counts.valueuom_count
  , unique_rows.ref_range_lower
  , unique_counts.ref_range_lower_count
  , unique_rows.ref_range_upper
  , unique_counts.ref_range_upper_count
FROM unique_rows
LEFT JOIN unique_counts
    ON unique_rows.itemid = unique_counts.itemid
