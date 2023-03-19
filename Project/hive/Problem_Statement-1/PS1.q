/*
Problem Statement 1:
 An Insurance company wants a state wise report of the treatments to claim ratio between 1st April 2021 and 31st March 2022 (days both included). 
 Assist them to create such a report.
*/

CREATE EXTERNAL TABLE state_tc_ratio(
    state STRING ,
    ratio FLOAT
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
LOCATION '/user/training/hive/Q1';

INSERT OVERWRITE TABLE state_tc_ratio
SELECT a.state, COUNT(t.treatmentID)/COUNT(c.claimID) AS `Treatment-Claim_Ratio`
FROM address a
JOIN person p ON p.addressID = a.addressID
LEFT JOIN treatment t ON p.personID = t.patientID
LEFT JOIN claim c ON t.claimID = c.claimID
WHERE t.`date` BETWEEN '2021-04-01' AND '2022-03-31'
GROUP BY a.state;
