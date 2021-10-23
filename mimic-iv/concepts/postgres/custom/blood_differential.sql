-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS blood_differential; CREATE TABLE blood_differential AS 
-- For reference, some common unit conversions:
-- 10^9/L == K/uL == 10^3/uL
WITH blood_diff AS
(
SELECT
    MAX(subject_id) AS subject_id
  , MAX(hadm_id) AS hadm_id
  , MAX(charttime) AS charttime
  , le.specimen_id
  -- create one set of columns for percentages, and one set of columns for counts
  -- we harmonize all count units into K/uL == 10^9/L
  -- counts have an "_abs" suffix, percentages do not

  -- absolute counts
  , MAX(CASE WHEN itemid in (51300, 51301, 51755) THEN valuenum ELSE NULL END) AS wbc
  , MAX(CASE WHEN itemid = 52069 THEN valuenum ELSE NULL END) AS basophils_abs
  -- 52073 in K/uL, 51199 in #/uL
  , MAX(CASE WHEN itemid = 52073 THEN valuenum WHEN itemid = 51199 THEN valuenum / 1000.0 ELSE NULL END) AS eosinophils_abs
  -- 51133 in K/uL, 52769 in #/uL
  , MAX(CASE WHEN itemid = 51133 THEN valuenum WHEN itemid = 52769 THEN valuenum / 1000.0 ELSE NULL END) AS lymphocytes_abs
  -- 52074 in K/uL, 51253 in #/uL
  , MAX(CASE WHEN itemid = 52074 THEN valuenum WHEN itemid = 51253 THEN valuenum / 1000.0 ELSE NULL END) AS monocytes_abs
  , MAX(CASE WHEN itemid = 52075 THEN valuenum ELSE NULL END) AS neutrophils_abs
  -- convert from #/uL to K/uL
  , MAX(CASE WHEN itemid = 51218 THEN valuenum / 1000.0 ELSE NULL END) AS granulocytes_abs

  -- percentages, equal to cell count / white blood cell count
  , MAX(CASE WHEN itemid = 51146 THEN valuenum ELSE NULL END) AS basophils
  , MAX(CASE WHEN itemid = 51200 THEN valuenum ELSE NULL END) AS eosinophils
  , MAX(CASE WHEN itemid in (51244, 51245) THEN valuenum ELSE NULL END) AS lymphocytes
  , MAX(CASE WHEN itemid = 51254 THEN valuenum ELSE NULL END) AS monocytes
  , MAX(CASE WHEN itemid = 51256 THEN valuenum ELSE NULL END) AS neutrophils

  -- other cell count percentages
  , MAX(CASE WHEN itemid = 51143 THEN valuenum ELSE NULL END) AS atypical_lymphocytes
  , MAX(CASE WHEN itemid = 51144 THEN valuenum ELSE NULL END) AS bands
  , MAX(CASE WHEN itemid = 52135 THEN valuenum ELSE NULL END) AS immature_granulocytes
  , MAX(CASE WHEN itemid = 51251 THEN valuenum ELSE NULL END) AS metamyelocytes
  , MAX(CASE WHEN itemid = 51257 THEN valuenum ELSE NULL END) AS nrbc

  -- utility flags which determine whether imputation is possible
  , CASE
    -- WBC is available
    WHEN MAX(CASE WHEN itemid in (51300, 51301, 51755) THEN valuenum ELSE NULL END) > 0
    -- and we have at least one percentage from the diff
    -- sometimes the entire diff is 0%, which looks like bad data
    AND SUM(CASE WHEN itemid IN (51146, 51200, 51244, 51245, 51254, 51256) THEN valuenum ELSE NULL END) > 0
    THEN 1 ELSE 0 END AS impute_abs


  -- absolute counts
  , MAX(CASE WHEN itemid in (51300, 51301, 51755) THEN valueuom ELSE NULL END) AS wbc_unit
  , MAX(CASE WHEN itemid = 52069 THEN valueuom ELSE NULL END) AS basophils_abs_unit
  -- 52073 in K/uL, 51199 in #/uL
  , MAX(CASE WHEN itemid = 52073 THEN valueuom WHEN itemid = 51199 THEN 'K/uL' ELSE NULL END) AS eosinophils_abs_unit
  -- 51133 in K/uL, 52769 in #/uL
  , MAX(CASE WHEN itemid = 51133 THEN valueuom WHEN itemid = 52769 THEN 'K/uL' ELSE NULL END) AS lymphocytes_abs_unit
  -- 52074 in K/uL, 51253 in #/uL
  , MAX(CASE WHEN itemid = 52074 THEN valueuom WHEN itemid = 51253 THEN 'K/uL' ELSE NULL END) AS monocytes_abs_unit
  , MAX(CASE WHEN itemid = 52075 THEN valueuom ELSE NULL END) AS neutrophils_abs_unit
  -- convert from #/uL to K/uL
  , MAX(CASE WHEN itemid = 51218 THEN 'K/uL' ELSE NULL END) AS granulocytes_abs_unit

  -- percentages, equal to cell count / white blood cell count
  , MAX(CASE WHEN itemid = 51146 THEN valueuom ELSE NULL END) AS basophils_unit
  , MAX(CASE WHEN itemid = 51200 THEN valueuom ELSE NULL END) AS eosinophils_unit
  , MAX(CASE WHEN itemid in (51244, 51245) THEN valueuom ELSE NULL END) AS lymphocytes_unit
  , MAX(CASE WHEN itemid = 51254 THEN valueuom ELSE NULL END) AS monocytes_unit
  , MAX(CASE WHEN itemid = 51256 THEN valueuom ELSE NULL END) AS neutrophils_unit

  -- other cell count percentages
  , MAX(CASE WHEN itemid = 51143 THEN valueuom ELSE NULL END) AS atypical_lymphocytes_unit
  , MAX(CASE WHEN itemid = 51144 THEN valueuom ELSE NULL END) AS bands_unit
  , MAX(CASE WHEN itemid = 52135 THEN valueuom ELSE NULL END) AS immature_granulocytes_unit
  , MAX(CASE WHEN itemid = 51251 THEN valueuom ELSE NULL END) AS metamyelocytes_unit
  , MAX(CASE WHEN itemid = 51257 THEN valueuom ELSE NULL END) AS nrbc_unit


  -- absolute counts
  , MAX(CASE WHEN itemid in (51300, 51301, 51755) THEN ref_range_lower ELSE NULL END) AS wbc_lower
  , MAX(CASE WHEN itemid = 52069 THEN ref_range_lower ELSE NULL END) AS basophils_abs_lower
  -- 52073 in K/uL, 51199 in #/uL
  , MAX(CASE WHEN itemid = 52073 THEN ref_range_lower WHEN itemid = 51199 THEN ref_range_lower / 1000.0 ELSE NULL END) AS eosinophils_abs_lower
  -- 51133 in K/uL, 52769 in #/uL
  , MAX(CASE WHEN itemid = 51133 THEN ref_range_lower WHEN itemid = 52769 THEN ref_range_lower / 1000.0 ELSE NULL END) AS lymphocytes_abs_lower
  -- 52074 in K/uL, 51253 in #/uL
  , MAX(CASE WHEN itemid = 52074 THEN ref_range_lower WHEN itemid = 51253 THEN ref_range_lower / 1000.0 ELSE NULL END) AS monocytes_abs_lower
  , MAX(CASE WHEN itemid = 52075 THEN ref_range_lower ELSE NULL END) AS neutrophils_abs_lower
  -- convert from #/uL to K/uL
  , MAX(CASE WHEN itemid = 51218 THEN ref_range_lower / 1000.0 ELSE NULL END) AS granulocytes_abs_lower

  -- percentages, equal to cell count / white blood cell count
  , MAX(CASE WHEN itemid = 51146 THEN ref_range_lower ELSE NULL END) AS basophils_lower
  , MAX(CASE WHEN itemid = 51200 THEN ref_range_lower ELSE NULL END) AS eosinophils_lower
  , MAX(CASE WHEN itemid in (51244, 51245) THEN ref_range_lower ELSE NULL END) AS lymphocytes_lower
  , MAX(CASE WHEN itemid = 51254 THEN ref_range_lower ELSE NULL END) AS monocytes_lower
  , MAX(CASE WHEN itemid = 51256 THEN ref_range_lower ELSE NULL END) AS neutrophils_lower

  -- other cell count percentages
  , MAX(CASE WHEN itemid = 51143 THEN ref_range_lower ELSE NULL END) AS atypical_lymphocytes_lower
  , MAX(CASE WHEN itemid = 51144 THEN ref_range_lower ELSE NULL END) AS bands_lower
  , MAX(CASE WHEN itemid = 52135 THEN ref_range_lower ELSE NULL END) AS immature_granulocytes_lower
  , MAX(CASE WHEN itemid = 51251 THEN ref_range_lower ELSE NULL END) AS metamyelocytes_lower
  , MAX(CASE WHEN itemid = 51257 THEN ref_range_lower ELSE NULL END) AS nrbc_lower


  -- absolute counts
  , MAX(CASE WHEN itemid in (51300, 51301, 51755) THEN ref_range_upper ELSE NULL END) AS wbc_upper
  , MAX(CASE WHEN itemid = 52069 THEN ref_range_upper ELSE NULL END) AS basophils_abs_upper
  -- 52073 in K/uL, 51199 in #/uL
  , MAX(CASE WHEN itemid = 52073 THEN ref_range_upper WHEN itemid = 51199 THEN ref_range_upper / 1000.0 ELSE NULL END) AS eosinophils_abs_upper
  -- 51133 in K/uL, 52769 in #/uL
  , MAX(CASE WHEN itemid = 51133 THEN ref_range_upper WHEN itemid = 52769 THEN ref_range_upper / 1000.0 ELSE NULL END) AS lymphocytes_abs_upper
  -- 52074 in K/uL, 51253 in #/uL
  , MAX(CASE WHEN itemid = 52074 THEN ref_range_upper WHEN itemid = 51253 THEN ref_range_upper / 1000.0 ELSE NULL END) AS monocytes_abs_upper
  , MAX(CASE WHEN itemid = 52075 THEN ref_range_upper ELSE NULL END) AS neutrophils_abs_upper
  -- convert from #/uL to K/uL
  , MAX(CASE WHEN itemid = 51218 THEN ref_range_upper / 1000.0 ELSE NULL END) AS granulocytes_abs_upper

  -- percentages, equal to cell count / white blood cell count
  , MAX(CASE WHEN itemid = 51146 THEN ref_range_upper ELSE NULL END) AS basophils_upper
  , MAX(CASE WHEN itemid = 51200 THEN ref_range_upper ELSE NULL END) AS eosinophils_upper
  , MAX(CASE WHEN itemid in (51244, 51245) THEN ref_range_upper ELSE NULL END) AS lymphocytes_upper
  , MAX(CASE WHEN itemid = 51254 THEN ref_range_upper ELSE NULL END) AS monocytes_upper
  , MAX(CASE WHEN itemid = 51256 THEN ref_range_upper ELSE NULL END) AS neutrophils_upper

  -- other cell count percentages
  , MAX(CASE WHEN itemid = 51143 THEN ref_range_upper ELSE NULL END) AS atypical_lymphocytes_upper
  , MAX(CASE WHEN itemid = 51144 THEN ref_range_upper ELSE NULL END) AS bands_upper
  , MAX(CASE WHEN itemid = 52135 THEN ref_range_upper ELSE NULL END) AS immature_granulocytes_upper
  , MAX(CASE WHEN itemid = 51251 THEN ref_range_upper ELSE NULL END) AS metamyelocytes_upper
  , MAX(CASE WHEN itemid = 51257 THEN ref_range_upper ELSE NULL END) AS nrbc_upper


FROM mimic_hosp.labevents le
WHERE le.itemid IN
(
    51146, -- basophils
    52069, -- Absolute basophil count
    51199, -- Eosinophil Count
    51200, -- Eosinophils
    52073, -- Absolute Eosinophil count
    51244, -- Lymphocytes
    51245, -- Lymphocytes, Percent
    51133, -- Absolute Lymphocyte Count
    52769, -- Absolute Lymphocyte Count
    51253, -- Monocyte Count
    51254, -- Monocytes
    52074, -- Absolute Monocyte Count
    51256, -- Neutrophils
    52075, -- Absolute Neutrophil Count
    51143, -- Atypical lymphocytes
    51144, -- Bands (%)
    51218, -- Granulocyte Count
    52135, -- Immature granulocytes (%)
    51251, -- Metamyelocytes
    51257,  -- Nucleated Red Cells

    -- wbc totals measured in K/uL
    51300, 51301, 51755
    -- 52220 (wbcp) is percentage

    -- below are point of care tests which are extremely infrequent and usually low quality
    -- 51697, -- Neutrophils (mmol/L)

    -- below itemid do not have data as of MIMIC-IV v1.0
    -- 51536, -- Absolute Lymphocyte Count
    -- 51537, -- Absolute Neutrophil
    -- 51690, -- Lymphocytes
    -- 52151, -- NRBC
)
AND valuenum IS NOT NULL
-- differential values cannot be negative
AND valuenum >= 0
GROUP BY le.specimen_id
)
SELECT 
subject_id, hadm_id, charttime, specimen_id

, wbc
, wbc_unit
, wbc_lower
, wbc_upper
-- impute absolute count if percentage & WBC is available
, ROUND( CAST( CASE
    WHEN basophils_abs IS NULL AND basophils IS NOT NULL AND impute_abs = 1
        THEN basophils * wbc
    ELSE basophils_abs
END as numeric),4) AS basophils_abs
, basophils_abs_unit
, basophils_abs_lower
, basophils_abs_upper
, ROUND( CAST( CASE
    WHEN eosinophils_abs IS NULL AND eosinophils IS NOT NULL AND impute_abs = 1
        THEN eosinophils * wbc
    ELSE eosinophils_abs
END as numeric),4) AS eosinophils_abs
, eosinophils_abs_unit
, eosinophils_abs_lower
, eosinophils_abs_upper
, ROUND( CAST( CASE
    WHEN lymphocytes_abs IS NULL AND lymphocytes IS NOT NULL AND impute_abs = 1
        THEN lymphocytes * wbc
    ELSE lymphocytes_abs
END as numeric),4) AS lymphocytes_abs
, lymphocytes_abs_unit
, lymphocytes_abs_lower
, lymphocytes_abs_upper
, ROUND( CAST( CASE
    WHEN monocytes_abs IS NULL AND monocytes IS NOT NULL AND impute_abs = 1
        THEN monocytes * wbc
    ELSE monocytes_abs
END as numeric),4) AS monocytes_abs
, monocytes_abs_unit
, monocytes_abs_lower
, monocytes_abs_upper
, ROUND( CAST( CASE
    WHEN neutrophils_abs IS NULL AND neutrophils IS NOT NULL AND impute_abs = 1
        THEN neutrophils * wbc
    ELSE neutrophils_abs
END as numeric),4) AS neutrophils_abs
, neutrophils_abs_unit
, neutrophils_abs_lower
, neutrophils_abs_upper

, basophils
, basophils_unit
, basophils_lower
, basophils_upper
, eosinophils
, eosinophils_unit
, eosinophils_lower
, eosinophils_upper
, lymphocytes
, lymphocytes_unit
, lymphocytes_lower
, lymphocytes_upper
, monocytes
, monocytes_unit
, monocytes_lower
, monocytes_upper
, neutrophils
, neutrophils_unit
, neutrophils_lower
, neutrophils_upper

-- impute bands/blasts?
, atypical_lymphocytes
, atypical_lymphocytes_unit
, atypical_lymphocytes_lower
, atypical_lymphocytes_upper
, bands
, bands_unit
, bands_lower
, bands_upper
, immature_granulocytes
, immature_granulocytes_unit
, immature_granulocytes_lower
, immature_granulocytes_upper
, metamyelocytes
, metamyelocytes_unit
, metamyelocytes_lower
, metamyelocytes_upper
, nrbc
, nrbc_unit
, nrbc_lower
, nrbc_upper
FROM blood_diff
;
