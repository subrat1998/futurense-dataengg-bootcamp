/*
Problem Statement 1: 
Johansson is trying to prepare a report on patients who have gone through treatments more than once. 
Help Johansson prepare a report that shows the patient's name, the number of treatments they have undergone, and their age, 
Sort the data in a way that the patients who have undergone more treatments appear on top.
*/

SELECT personName,count(treatmentID) treatments,TIMESTAMPDIFF(YEAR,pt.dob,CURRENT_DATE) Age from person p
LEFT JOIN patient pt ON p.`personID`=pt.`patientID`
JOIN treatment t ON pt.`patientID`=t.`patientID`
GROUP BY `personName`,pt.`patientID`
HAVING treatments>1
ORDER BY treatments desc;


/*
Problem Statement 2:  
Bharat is researching the impact of gender on different diseases, He wants to analyze if a certain disease is more likely to infect a certain gender or not.
Help Bharat analyze this by creating a report showing for every disease how many males and females underwent treatment for each in the year 2021. 
It would also be helpful for Bharat if the male-to-female ratio is also shown
*/

WITH CTE AS (
SELECT d.diseaseName, sum(if(p.gender = 'male',1,0)) 'Males', sum(if(p.gender = 'female',1,0)) 'Females'
FROM disease d
    JOIN treatment t on t.`diseaseID` = d.`diseaseID`
    JOIN person p on p.`personID` = t.`patientID`
WHERE year(t.`date`) = 2021
GROUP BY d.`diseaseName`
)

select * ,Males/Females as 'Male To Female Ratio' from CTE;


/*
Problem Statement 3:  
Kelly, from the Fortis Hospital management, has requested a report that shows for each disease, the top 3 cities 
that had the most number treatment for that disease.Generate a report for Kelly’s requirement.
*/

WITH CTE AS
(
    SELECT d.`diseaseName`,a.city,count(distinct p.`personID`) cnt, DENSE_RANK() OVER(PARTITION BY d.`diseaseName` ORDER BY count(distinct p.`personID`) DESC ) rnk
    FROM disease d
        JOIN treatment t on t.`diseaseID` = d.`diseaseID`
        JOIN person p on p.`personID` = t.`patientID`
        JOIN address a on a.`addressID` = p.`addressID`
    GROUP BY d.`diseaseName`,a.city
    ORDER BY d.`diseaseName`, cnt desc
)
SELECT  diseaseName, city, cnt
FROM CTE WHERE rnk <=3;

/*
Problem Statement 4: 
Brooke is trying to figure out if patients with a particular disease are preferring some pharmacies over others or not, 
For this purpose, she has requested a detailed pharmacy report that shows each pharmacy name, and how many prescriptions 
they have prescribed for each disease in 2021 and 2022, She expects the number of prescriptions prescribed in 2021 and 2022 be displayed in two separate columns.
Write a query for Brooke’s requirement.
*/

SELECT p.`pharmacyName` ,d.`diseaseName`, 
        sum(if (year(t.date) = 2021,1,0)) 'Prescribed In 2021', 
        sum(if (year(t.date) = 2022,1,0)) 'Prescribed In 2022'
FROM pharmacy p
    JOIN prescription pr on pr.`pharmacyID` = p.`pharmacyID`
    JOIN treatment t on t.`treatmentID` = pr.`treatmentID`
    JOIN disease d on d.`diseaseID` = t.`diseaseID`
WHERE YEAR(t.`date`)  in (2021,2022)
GROUP BY p.`pharmacyName`, d.`diseaseName`


/*
Problem Statement 5:  
Walde, from Rock tower insurance, has sent a requirement for a report that presents which insurance company is targeting the patients of which state the most. 
Write a query for Walde that fulfills the requirement of Walde.
Note: We can assume that the insurance company is targeting a region more if the patients of that region are claiming more insurance of that company.
*/




