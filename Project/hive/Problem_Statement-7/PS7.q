/*
Problem Statement 1:
 An Insurance company wants a state wise report of the treatments to claim ratio between 1st April 2021 and 31st March 2022 (days both included). 
 Assist them to create such a report.
*/

CREATE TABLE treatment_part(
    treatmentID BIGINT,
    patientID BIGINT,
    date STRING,
    claimID BIGINT
)
PARTITIONED BY (diseaseID STRING)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ',';

insert overwrite table treatment_part partition(diseaseID)
select treatmentID, patientID, date, claimID,  diseaseID from treatment;

CREATE EXTERNAL TABLE state_wise_treatment_claim(
    state STRING,
    treatment_claim_ratio FLOAT
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
LOCATION '/user/training/hive/Q7';

INSERT OVERWRITE TABLE state_wise_treatment_claim
select a.state, count(t.`treatmentID`)/count(t.`claimID`) as ratio
from address_part a inner join person p on a.`addressID` = p.`addressID`
inner join patient pt on p.`personID` = pt.`patientID`
inner join treatment_part t on pt.`patientID` = t.`patientID`
where cast(t.date as date) between '2021-04-01' and '2022-03-31'
group by a.state;
