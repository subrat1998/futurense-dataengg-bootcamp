/*
Problem Statement 3:
Jacob, from insurance management, has noticed that insurance claims are not made for all the treatments. 
He also wants to figure out if the gender of the patient has any impact on the insurance claim. 
Assist Jacob in this situation by generating a report that finds for each gender the number of treatments, number of claims, 
and treatment-to-claim ratio. And notice if there is a significant difference between the treatment-to-claim ratio of male and female patients.
*/

CREATE EXTERNAL TABLE treatment_claim_ratio(
    Gender STRING,
    Treatment_Count INT,
    Claim_Count INT,
    Ratio FLOAT
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
LOCATION '/user/training/hive/Q3';

INSERT OVERWRITE TABLE treatment_claim_ratio
select *, treatments/claims as treatment_claim_ratio from
(select pr.gender, count(t.treatmentid) as treatments, count(t.claimid) as claims from treatment t 
left outer join claim c on t.claimid=c.claimid
join patient p on p.patientid = t.patientid
join person pr on pr.personid = p.patientid group by pr.gender)as temp
