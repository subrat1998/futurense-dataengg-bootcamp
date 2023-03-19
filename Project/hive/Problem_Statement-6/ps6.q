/*
Problem Statement 2: 
The Healthcare department wants to know which disease is most likely to infect multiple people in the same household. 
For each disease find the number of households that has more than one patient with the same disease. 
Note: 2 people are considered to be in the same household if they have the same address.
*/
CREATE TABLE address_part (
  addressid INT,
  address1 STRING,
  city STRING,
  zip INT)
PARTITIONED BY (state STRING) CLUSTERED BY (city) INTO 10 BUCKETS;

INSERT INTO TABLE address_part PARTITION (state) SELECT addressid,address1,city,zip,state FROM address;

CREATE EXTERNAL TABLE diseases_data_ext (
    disease string,
    address string,
    patientcount int
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
LOCATION '/user/training/hive/Q6EXT';

INSERT OVERWRITE TABLE diseases_data_ext
SELECT d.diseaseName, a.address1, COUNT(p.patientID) AS `Number of Patients with same disease in same address`
FROM disease d 
JOIN treatment t ON d.diseaseID = t.diseaseID 
JOIN Patient p ON p.patientID = t.patientID 
JOIN person pe ON pe.personID = p.patientID
JOIN address_part a ON a.addressID = pe.addressID
GROUP BY d.diseaseName, a.address1
HAVING COUNT(p.patientID) > 1;
