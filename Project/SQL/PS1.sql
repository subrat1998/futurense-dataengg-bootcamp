-- Active: 1671769371715@@127.0.0.1@3308@healthcare
/*
Problem Statement 1:
Jimmy, from the healthcare department, has requested a report that shows how the number of treatments each age category of patients has gone through in the year 2022. 
The age category is as follows, Children (00-14 years), Youth (15-24 years), Adults (25-64 years), and Seniors (65 years and over).
Assist Jimmy in generating the report. 
*/

WITH CTE AS (
    SELECT patientID,TIMESTAMPDIFF(YEAR,dob,NOW()) AS age FROM patient
)
    SELECT 
    CASE  
        WHEN age BETWEEN 0 AND 14 THEN 'Children'
        WHEN age BETWEEN 15 AND 24 THEN 'Youth'
        WHEN age BETWEEN 25 AND 64 THEN 'Adults'
        ELSE 'Senior'
    END AS "Category",COUNT(*) AS 'Number Of Treatment' FROM CTE
    NATURAL JOIN treatment t
    WHERE YEAR(t.date)=2022
    GROUP BY Category;

/*
Problem Statement 2:
Jimmy, from the healthcare department, wants to know which disease is infecting people of which gender more often.
Assist Jimmy with this purpose by generating a report that shows for each disease the male-to-female ratio. Sort the data in a way that is helpful for Jimmy.
*/

SELECT d.diseaseName ,SUM(CASE WHEN p.gender ="Male" THEN 1 ELSE 0 END)/SUM(CASE WHEN p.gender ="Female" THEN 1 ELSE 0 END)
FROM disease d 
JOIN treatment t ON d.`diseaseID`=t.`diseaseID`
JOIN person P ON t.`patientID`=p.`personID`
GROUP BY d.`diseaseName`;

/*
Problem Statement 3:
Jacob, from insurance management, has noticed that insurance claims are not made for all the treatments. 
He also wants to figure out if the gender of the patient has any impact on the insurance claim. 
Assist Jacob in this situation by generating a report that finds for each gender the number of treatments, number of claims, 
and treatment-to-claim ratio. And notice if there is a significant difference between the treatment-to-claim ratio of male and female patients.
*/

WITH CTE AS
(
SELECT  p.gender,
        COUNT(t.treatmentID) as 'Number Of Treatments',
        COUNT(c.claimID) as 'Number Of Claims'
        FROM person p JOIN treatment t ON p.`personID`=t.`patientID`
                      LEFT JOIN claim c on t.`claimID` = c.`claimID`
        GROUP BY p.gender
)
SELECT *,`Number Of Treatments`/`Number Of Claims` AS 'Treatment-Claim Ratio' FROM CTE;


/*
Problem Statement 4: 
The Healthcare department wants a report about the inventory of pharmacies. 
Generate a report on their behalf that shows how many units of medicine each pharmacy has in their inventory,
the total maximum retail price of those medicines, and the total price of all the medicines after discount. 
Note: discount field in keep signifies the percentage of discount on the maximum price.
*/

SELECT pharmacyID,COUNT(medicineID),ROUND(sum(maxPrice),2), ROUND(SUM(maxPrice-maxPrice*discount/100),2)
FROM pharmacy NATURAL JOIN keep
              NATURAL JOIN medicine
GROUP BY pharmacyID ORDER BY pharmacyID;


/*
Problem Statement 5:
The healthcare department suspects that some pharmacies prescribe more medicines than others in a 
single prescription, for them, generate a report that finds for each pharmacy the maximum, minimum and 
average number of  medicines prescribed in their prescriptions. 
*/

SELECT pharmacyID, 
       MAX(quantity) AS 'MAX Quantity',
       MIN(quantity) AS 'MIN Quantity',
       AVG(quantity) AS 'AVG Quantity'
FROM prescription
NATURAL JOIN contain
GROUP BY pharmacyID;