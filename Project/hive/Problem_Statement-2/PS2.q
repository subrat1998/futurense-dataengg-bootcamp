/*
Problem Statement 2: 
The Healthcare department wants to know which disease is most likely to infect multiple people in the same household. 
For each disease find the number of households that has more than one patient with the same disease. 
Note: 2 people are considered to be in the same household if they have the same address.
*/

CREATE EXTERNAL TABLE disease_data (
    diseaseID int,
    addressID int,
    patientcount int
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
LOCATION '/user/training/hive/Q2';

INSERT OVERWRITE TABLE disease_data
SELECT d.diseaseID, pe.addressID, COUNT(p.patientID) AS `Number of Patients with same disease in same address`
FROM disease d 
JOIN treatment t ON d.diseaseID = t.diseaseID 
JOIN Patient p ON p.patientID = t.patientID 
JOIN person pe ON pe.personID = p.patientID
GROUP BY d.diseaseID, pe.addressID
HAVING COUNT(p.patientID) > 1;
