-- Questions

-- 1. Write a SQL query to retrieve all patients who have been diagnosed with COVID-19
-- 2. Write a SQL query to retrieve the number of visits made by each patient, ordered by the number of visits in descending order.
-- 3. Write a SQL query to calculate the average age of patients who have been diagnosed with Pneumonia.
-- 4. Write a SQL query to retrieve the top 3 most common symptoms among all visits.
-- 5. Write a SQL query to retrieve the patient who has the highest number of different symptoms reported.
-- 6. Write a SQL query to calculate the percentage of patients who have been diagnosed with COVID-19 out of the total number of patients.
-- 7. Write a SQL query to retrieve the top 5 cities with the highest number of visits, along with the count of visits in each city.
-- 8. Write a SQL query to find the patient who has the highest number of visits in a single day, along with the corresponding visit date.
-- 9. Write a SQL query to retrieve the average age of patients for each diagnosis, ordered by the average age in descending order.
-- 10. Write a SQL query to calculate the cumulative count of visits over time, ordered by the visit date.

-- 1. Write a SQL query to retrieve all patients who have been diagnosed with COVID-19
SELECT p.patient_id, p.patient_name, d.diagnosis_name
FROM patients p
JOIN visits v USING(patient_id)
JOIN diagnoses d USING(diagnosis_id)
WHERE d.diagnosis_name = 'COVID-19';

-- 2. Write a SQL query to retrieve the number of visits made by each patient, ordered by the number of visits in descending order.
SELECT patient_id, patient_name, COUNT(patient_id) AS number_of_visits 
FROM visits
JOIN patients USING(patient_id)
GROUP BY patient_id
ORDER BY number_of_visits DESC;

-- 3. Write a SQL query to calculate the average age of patients who have been diagnosed with Pneumonia.
SELECT d.diagnosis_name, ROUND(AVG(p.age)) AS avg_age
FROM patients p
JOIN visits v USING(patient_id)
JOIN diagnoses d USING(diagnosis_id)
WHERE d.diagnosis_name = 'Pneumonia';

-- 4. Write a SQL query to retrieve the top 3 most common symptoms among all visits.
SELECT s.symptom_name, COUNT(v.patient_id) AS symptom_counts
FROM visits v
JOIN symptoms s USING(symptom_id)
GROUP BY s.symptom_id
ORDER BY symptom_counts DESC
LIMIT 3;

-- 5. Write a SQL query to retrieve the patient who has the highest number of different symptoms reported.
SELECT patient_id, patient_name, unique_symptom_count
FROM (
	SELECT p.patient_id, p.patient_name, COUNT(DISTINCT(v.symptom_id)) unique_symptom_count,
    DENSE_RANK() OVER(ORDER BY COUNT(DISTINCT(v.symptom_id)) DESC) rn
	FROM patients p
	JOIN visits v USING(patient_id)
	GROUP BY p.patient_id, p.patient_name
) symptom_count
WHERE rn <= 1;

-- 6. Write a SQL query to calculate the percentage of patients who have been diagnosed with COVID-19 out of the total number of patients.
WITH patient_distribution AS (
	SELECT 
		COUNT(CASE WHEN d.diagnosis_name = 'COVID-19' THEN p.patient_id END) AS covid_patient,
		COUNT(DISTINCT(p.patient_id)) AS total_patients
	FROM diagnoses d
	JOIN visits v USING(diagnosis_id)
	JOIN patients p USING(patient_id)
)
SELECT covid_patient, total_patients,
	ROUND((covid_patient * 100) / total_patients, 1) AS percentage_of_covid_patients
FROM patient_distribution;

-- 7. Write a SQL query to retrieve the top 5 cities with the highest number of visits, along with the count of visits in each city.
SELECT p.city, COUNT(v.visit_id) AS total_visits
FROM visits v
LEFT JOIN patients p USING(patient_id)
GROUP BY p.city;

-- 8. Write a SQL query to find the patient who has the highest number of visits in a single day, along with the corresponding visit date.
SELECT p.patient_id, p.patient_name, v.visit_date, COUNT(v.visit_id) AS total_visit
FROM visits v
LEFT JOIN patients p USING(patient_id)
GROUP BY p.patient_id, v.visit_date
ORDER BY total_visit DESC
LIMIT 1;

-- 9. Write a SQL query to retrieve the average age of patients for each diagnosis, ordered by the average age in descending order.
SELECT d.diagnosis_id, d.diagnosis_name, ROUND(AVG(p.age)) AS avg_age
FROM patients p
JOIN visits v USING(patient_id)
JOIN diagnoses d USING(diagnosis_id)
GROUP BY d.diagnosis_id, d.diagnosis_name
ORDER BY avg_age DESC;

-- 10. Write a SQL query to calculate the cumulative count of visits over time, ordered by the visit date.
SELECT visit_date, COUNT(visit_id) AS visit_count,
	SUM(COUNT(*)) OVER (ORDER BY visit_date) AS cumulative_visit_count
FROM visits
GROUP BY visit_date
ORDER BY visit_date;
