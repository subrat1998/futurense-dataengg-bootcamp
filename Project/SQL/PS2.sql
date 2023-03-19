-- Active: 1671769371715@@127.0.0.1@3308@healthcare
/*
Problem Statement 1:
A company needs to set up 3 new pharmacies, they have come up with an idea that the pharmacy can be set up in cities 
where the pharmacy-to-prescription ratio is the lowest and the number of prescriptions should exceed 100. 
Assist the company to identify those cities where the pharmacy can be set up.
*/

select city,COUNT(pharmacy.`pharmacyID`),COUNT(prescription.`prescriptionID`) from address
NATURAL JOIN pharmacy
LEFT JOIN prescription on pharmacy.pharmacyID=prescription.pharmacyID
GROUP BY city;


/*
Problem Statement 2: 
The State of Alabama (AL) is trying to manage its healthcare resources more efficiently. 
For each city in their state, they need to identify the disease for which the maximum number of patients have gone for treatment. 
Assist the state for this purpose.
Note: The state of Alabama is represented as AL in Address Table.
*/

with cte_table as 
(select  a.`city` as 'City', d.`diseaseID` as 'disease_Id', count(t.`patientID`) as "Number of patients" from disease d 
                        join treatment t on d.`diseaseID` = t.`diseaseID` 
                        join prescription p on t.`treatmentID` = p.`treatmentID`
                        join pharmacy ph on ph.`pharmacyID` = p.`pharmacyID`
                        join `address` a on a.`addressID` = ph.`addressID`
where a.state like "%AL%"
group by a.`city`, d.`diseaseID`)
select * from cte_table c1
where `Number of patients` = (select max(`Number of patients`) from cte_table c2 where c1.`city` = c2.`city`);


/*
Problem Statement 3: 
The healthcare department needs a report about insurance plans. 
The report is required to include the insurance plan, which was claimed the most and least for each disease.  Assist to create such a report.
*/

with cte as
(select d.diseaseName,i.planName,count(*) as cnt
from treatment t join claim c on t.claimID=c.claimID
join insurancePlan i on c.uin=i.uin
join disease d on t.diseaseID=d.diseaseID
group by d.diseaseName,i.planName
order by d.diseaseName,count(*) desc)

select diseaseName,planName,cnt
from cte c1
where cnt in (select min(cnt) from cte c2 where c1.diseaseName=c2.diseaseName) 
or
cnt in (select max(cnt) from cte c2 where c1.diseaseName=c2.diseaseName) 
;
/*
Problem Statement 4: 
The Healthcare department wants to know which disease is most likely to infect multiple people in the same household. 
For each disease find the number of households that has more than one patient with the same disease. 
Note: 2 people are considered to be in the same household if they have the same address.
*/

select d.`diseaseID`, pe.`addressID` , count(p.`patientID`) as "Number of Patients with same disease in same address" 
       from `disease` d join `treatment` t on d.`diseaseID` = t.`diseaseID` 
                        join `Patient` p on p.`patientID` = t.`patientID`
                        join `person` pe on pe.`personID` = p.`patientID`
group by d.`diseaseID`, pe.`addressID`
having(count(p.`patientID`) > 1);


/*
Problem Statement 5:
 An Insurance company wants a state wise report of the treatments to claim ratio between 1st April 2021 and 31st March 2022 (days both included). 
 Assist them to create such a report.
*/

WITH CTE AS
(
SELECT  a.state,
        COUNT(t.treatmentID) as 'Number Of Treatments',
        COUNT(c.claimID) as 'Number Of Claims'
        FROM address a NATURAL JOIN person p
                       LEFT JOIN treatment t ON p.`personID`=t.`patientID`
                       LEFT JOIN claim c on t.`claimID` = c.`claimID`
                       WHERE t.`date` BETWEEN '2021-04-01' AND '2022-03-31'
        GROUP BY a.state
)
SELECT state,`Number Of Treatments`/`Number Of Claims` AS 'Treatment-Claim Ratio' FROM CTE;