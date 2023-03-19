-- Active: 1671769371715@@127.0.0.1@3308@healthcare
/*
Problem Statement 1:
Some complaints have been lodged by patients that they have been prescribed hospital-exclusive medicine that they can’t find elsewhere and 
facing problems due to that. Joshua, from the pharmacy management, wants to get a report of which pharmacies have prescribed hospital-exclusive 
medicines the most in the years 2021 and 2022. Assist Joshua to generate the report so that the pharmacies who prescribe hospital-exclusive medicine
more often are advised to avoid such practice if possible.
*/


SELECT p.pharmacyID,COUNT(m.hospitalExclusive) as 'Most Prescribed' FROM pharmacy p JOIN keep k on p.`pharmacyID`=k.pharmacyID
JOIN medicine m on m.`medicineID`=k.`medicineID`
JOIN prescription pr ON p.`pharmacyID`=pr.`pharmacyID`
JOIN treatment t ON pr.`treatmentID`=t.`treatmentID`
WHERE m.`hospitalExclusive`='s' and YEAR(t.`date`) IN ('2021','2022')
GROUP BY p.`pharmacyID` ORDER BY 2 desc;


/*
Problem Statement 2: 
Insurance companies want to assess the performance of their insurance plans. 
Generate a report that shows each insurance plan, the company that issues the plan, and the number of treatments the plan was claimed for.
*/

SELECT ip.UIN,ic.companyID,COUNT(t.`treatmentID`) as 'Total Claim' FROM insuranceplan ip 
NATURAL JOIN insurancecompany ic
LEFT JOIN claim c on c.uin=ip.uin
LEFT JOIN treatment t ON t.`claimID`=c.`claimID`
GROUP BY ip.uin;


/*
Problem Statement 3: 
Insurance companies want to assess the performance of their insurance plans. 
Generate a report that shows each insurance company's name with their most and least claimed insurance plans.
*/

with cte as(
select ic.`companyID`,ip.uin,COUNT(`claimID`)as 'cnt' FROM insurancecompany ic NATURAL JOIN insuranceplan ip
JOIN claim c on ip.uin=c.uin
GROUP BY ic.`companyID`,ip.uin
ORDER BY `companyID`
),
cte1 as(
SELECT `companyID`,CASE when cnt=(SELECT min(cnt) from cte WHERE c1.`companyID`=cte.`companyID` ) then uin end Least,
CASE when cnt=(SELECT max(cnt) from cte WHERE c1.`companyID`=cte.`companyID` ) then uin end High
FROM cte c1
)
select * from cte1 where least is not null or high is not null ORDER BY `companyID`;

/*
Problem Statement 4:  
The healthcare department wants a state-wise health report to assess which state requires more attention in the healthcare sector. 
Generate a report for them that shows the state name, number of registered people in the state, number of registered patients in the state, and 
the people-to-patient ratio. sort the data by people-to-patient ratio. 
*/

WITH CTE AS 
(
SELECT a.state,count(p.personID) as 'Registered_people',count(pt.patientID) as 'Registered_patients' FROM address a
left join person p on a.`addressID`=p.`addressID`
left JOIN patient pt on p.`personID`=pt.`patientID`
GROUP BY a.state
)
SELECT State,Registered_people,Registered_patients,Registered_people/Registered_patients as 'people-to-patient ratio'
FROM CTE
ORDER BY 4;

/*
Problem Statement 5: 
Jhonny, from the finance department of Arizona(AZ), has requested a report that lists the total quantity of medicine each pharmacy 
in his state has prescribed that falls under Tax criteria I for treatments that took place in 2021. Assist Jhonny in generating the report. 
*/


SELECT p.pharmacyID,sum(k.quantity) as 'Total Quantity' FROM pharmacy p
JOIN keep k ON p.pharmacyID = k.pharmacyID
JOIN address a on a.`addressID`=p.`addressID`
JOIN medicine m on m.medicineID=k.medicineID
JOIN prescription pr on pr.pharmacyID = p.pharmacyID
join treatment t on pr.treatmentID = t.treatmentID
where a.state='AZ' and year(t.date)=2021 and taxCriteria ='I'
GROUP BY p.pharmacyID;