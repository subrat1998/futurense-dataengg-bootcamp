/*
Problem Statement 5:
The healthcare department suspects that some pharmacies prescribe more medicines than others in a 
single prescription, for them, generate a report that finds for each pharmacy the maximum, minimum and 
average number of  medicines prescribed in their prescriptions. 
*/

CREATE EXTERNAL TABLE pharmacy_quantity(
    pharmacyid INT,
    pharmacyname STRING,
    min_quantity INT,
    max_quantity INT,
    avg_quantity DOUBLE
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
LOCATION '/user/training/hive/Q5/';

INSERT OVERWRITE TABLE pharmacy_quantity
SELECT 
    a.pharmacyid, 
    a.pharmacyname, 
    MIN(a.quantity), 
    MAX(a.quantity), 
    AVG(a.quantity)
FROM (
    SELECT 
        ps.pharmacyid, 
        p.pharmacyname, 
        c.prescriptionid, 
        SUM(c.quantity) AS quantity
    FROM 
        pharmacy p 
        JOIN prescription ps ON p.pharmacyid = ps.pharmacyid
        JOIN contain c ON c.prescriptionid = ps.prescriptionid
    GROUP BY 
        ps.pharmacyid,p.pharmacyname,c.prescriptionid
)as a
GROUP BY 
    a.pharmacyid, 
    a.pharmacyname;


