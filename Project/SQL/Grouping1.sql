-- Active: 1671769371715@@127.0.0.1@3308@healthcare
/*
Problem Statement 1: 
The healthcare department wants a pharmacy report on the percentage of hospital-exclusive medicine prescribed in the year 2022.
Assist the healthcare department to view for each pharmacy, the pharmacy id, pharmacy name, total quantity of medicine prescribed in 2022, 
total quantity of hospital-exclusive medicine prescribed by the pharmacy in 2022, and the percentage of hospital-exclusive medicine to the 
total medicine prescribed in 2022. Order the result in descending order of the percentage found. 
*/

SELECT p.`pharmacyID`,p.`pharmacyName`,sum(c.quantity),SUM(CASE WHEN m.hospitalExclusive='S' THEN 1 END) 
FROM pharmacy p JOIN prescription pr ON p.`pharmacyID`=pr.`pharmacyID`
JOIN treatment t on t.`treatmentID`=pr.`treatmentID`
JOIN contain c ON pr.`prescriptionID` = c.`prescriptionID`
JOIN medicine m ON m.`medicineID`=c.`medicineID`
WHERE year(t.`date`)=2022
GROUP BY p.`pharmacyID`;

/*
Problem Statement 2:  
Sarah, from the healthcare department, has noticed many people do not claim insurance for their treatment. 
She has requested a state-wise report of the percentage of treatments that took place without claiming insurance. 
Assist Sarah by creating a report as per her requirement.
*/

WITH Cte as(
SELECT a.state,COUNT(t.treatmentID) treatmentID_Count,COUNT(c.claimID) claim_count
from treatment t LEFT JOIN claim c on t.`claimID`=c.`claimID`
                 JOIN prescription pr on pr.`treatmentID`=t.`treatmentID`
                 JOIN pharmacy p on p.`pharmacyID`=pr.`pharmacyID`
                 JOIN address a on p.`addressID`=a.`addressID`
GROUP BY a.state
)
SELECT state,((treatmentID_Count-claim_count)/treatmentID_Count)*100 as '% of treatment without claiming' FROM cte ORDER BY state;


/*
Problem Statement 3:  
Sarah, from the healthcare department, is trying to understand if some diseases are spreading in a particular region. 
Assist Sarah by creating a report which shows for each state, the number of the most and least treated diseases by the patients of that state in the year 2022. 
*/

WITH cte AS (
    SELECT state, `diseaseName`,COUNT(`treatmentID`) 'noOftreatments'
    FROM address a
    INNER JOIN person p on p.`addressID`=a.`addressID`
    INNER JOIN treatment t ON p.`personID`=t.`patientID`
    INNER JOIN disease d on d.`diseaseID`=t.`diseaseID`
    WHERE YEAR(`date`)=2022
    GROUP BY state,`diseaseName`
    ORDER BY state,noOftreatments DESC
)
SELECT DISTINCT state, FIRST_VALUE(`diseaseName`) OVER(PARTITION BY state) 'MinDisease',
LAST_VALUE(`diseaseName`) OVER(PARTITION BY state) 'MaxDisease'
FROM cte;




/*
Problem Statement 4: 
Manish, from the healthcare department, wants to know how many registered people are registered as patients as well, in each city. 
Generate a report that shows each city that has 10 or more registered people belonging to it and the number of patients from that city 
as well as the percentage of the patient with respect to the registered people.
*/

WITH cte as(
select a.city,count(p.`personID`) person,COUNT(pt.patientID) patient from person p
LEFT JOIN patient pt on p.`personID`=pt.`patientID`
JOIN address a on p.`addressID`=a.`addressID`
GROUP BY a.city
HAVING COUNT(p.`personID`)>=10
)
SELECT *,(patient/person)*100 as '%patient-people' FROM cte;


/*
Problem Statement 5:  
It is suspected by healthcare research department that the substance “ranitidine” might be causing some side effects. 
Find the top 3 companies using the substance in their medicine so that they can be informed about it.
*/


SELECT DISTINCT `companyName`
FROM medicine
WHERE `substanceName` LIKE '%ranitidina%'
