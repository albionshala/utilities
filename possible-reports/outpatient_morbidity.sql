-- Parameters
SET @start_date = '2014-09-01';
SET @end_date = '2014-09-30';

-- Query
SELECT diagnosis.full_name, diagnosis.code, concept_mapping.term_name AS group_name,
SUM(CASE WHEN person.gender = 'F' THEN 1 ELSE 0 END) AS female,
SUM(CASE WHEN person.gender = 'M' THEN 1 ELSE 0 END) AS male
FROM diagnosis_icd10_mapping AS diagnosis
LEFT OUTER JOIN concept_mapping ON concept_mapping.concept_id = diagnosis.concept_id
			AND concept_mapping.source_name = 'ICD 10 - WHO' AND concept_mapping.map_type = 'NARROWER-THAN'
LEFT OUTER JOIN	patient_diagnosis ON patient_diagnosis.diagnois_concept_id = diagnosis.concept_id 
	AND patient_diagnosis.certainity = 'Confirmed'
	AND (patient_diagnosis.status IS NULL OR patient_diagnosis.status != 'Ruled Out Diagnosis')
	AND (patient_diagnosis.obs_datetime BETWEEN @start_date AND @end_date)
LEFT OUTER JOIN person ON patient_diagnosis.person_id = person.person_id
GROUP BY diagnosis.concept_id, diagnosis.full_name, diagnosis.code, concept_mapping.term_name
ORDER BY full_name desc;