-- Active: 1671769371715@@127.0.0.1@3308@healthcare

/*
Problem Statement 1: 
Insurance companies want to know if a disease is claimed higher or lower than average.  Write a stored procedure that returns 
“claimed higher than average” or “claimed lower than average” when the diseaseID is passed to it. 
Hint: Find average number of insurance claims for all the diseases.  If the number of claims for the passed disease is higher 
than the average return “claimed higher than average” otherwise “claimed lower than average”.
*/

DELIMITER $

CREATE PROCEDURE ClaimedDisease(IN dId INT)
BEGIN
    
    DECLARE avgClaim NUMERIC(12,2);
    DECLARE avgDisClaim NUMERIC(12,2);

    SELECT AVG(`claimID`) INTO avgClaim
    FROM claim;

    SELECT AVG(`claimID`) INTO avgDisClaim
    FROM claim
    INNER JOIN treatment USING(`claimID`)
    INNER JOIN disease USING(`diseaseID`)
    WHERE `diseaseID`=dId;

    IF (avgDisClaim > avgClaim) THEN
        SELECT dId AS 'disease Id','Claimed Higher than Average' AS 'Claimed';
    ELSE
        SELECT dId AS 'disease Id','Claimed Lower than Average' AS 'Claimed';
    END IF;
END $
DELIMITER;
CALL ClaimedDisease(39);


/*
Problem Statement 2:  
Joseph from Healthcare department has requested for an application which helps him get genderwise report for any disease. 
Write a stored procedure when passed a disease_id returns 4 columns,
disease_name, number_of_male_treated, number_of_female_treated, more_treated_gender
Where, more_treated_gender is either ‘male’ or ‘female’ based on which gender underwent more often for the disease, 
if the number is same for both the genders, the value should be ‘same’.
*/

DELIMITER $

CREATE PROCEDURE Report(IN disId INT)
BEGIN
    DECLARE Males INT;
    DECLARE Females INT;
    DECLARE dName VARCHAR(45);

    SELECT d.diseaseName, SUM(IF(p.gender = 'male',1,0)),
                SUM(if(p.gender = 'female',1,0)) INTO dName,Males,Females
    FROM disease d 
    INNER JOIN treatment t on t.`diseaseID` = d.`diseaseID`
    INNER JOIN person p on p.`personID` = t.`patientID`
    WHERE d.`diseaseID`=disId
    GROUP BY diseaseName;

    SELECT dName,Males,Females, IF(Males>Females,'Male','Female') AS 'Gender';
END $

DELIMITER ;

CALL Report(1);


/*
 Problem Statement 3:  
 The insurance companies want a report on the claims of different insurance plans. 
 Write a query that finds the top 3 most and top 3 least claimed insurance plans.
 The query is expected to return the insurance plan name, the insurance company name which has that plan, 
 and whether the plan is the most claimed or least claimed. 
*/

WITH cte AS (
    SELECT `companyName`,`planName`,COUNT(`claimID`) AS noOfClaims,
    DENSE_RANK() OVER(ORDER BY COUNT(`claimID`) DESC) AS 'dRank'
    FROM insuranceplan
    INNER JOIN claim USING(uin)
    INNER JOIN insurancecompany USING(`companyID`)
    GROUP BY `companyName`,`planName`
)
(SELECT `companyName`,`planName`, 'Least Claimed' FROM cte ORDER BY dRank DESC LIMIT 3) 
UNION
SELECT `companyName`,`planName`,'Most Claimed' FROM cte WHERE dRank<4;



/*
Problem Statement 4: 
The healthcare department wants to know which category of patients is being affected the most by each disease.
Assist the department in creating a report regarding this.
Provided the healthcare department has categorized the patients into the following category.

YoungMale: Born on or after 1st Jan  2005  and gender male.
YoungFemale: Born on or after 1st Jan  2005  and gender female.
AdultMale: Born before 1st Jan 2005 but on or after 1st Jan 1985 and gender male.
AdultFemale: Born before 1st Jan 2005 but on or after 1st Jan 1985 and gender female.
MidAgeMale: Born before 1st Jan 1985 but on or after 1st Jan 1970 and gender male.
MidAgeFemale: Born before 1st Jan 1985 but on or after 1st Jan 1970 and gender female.
ElderMale: Born before 1st Jan 1970, and gender male.
ElderFemale: Born before 1st Jan 1970, and gender female.
*/

DELIMITER //
CREATE FUNCTION AgeCategory( gender VARCHAR(10),dob date )
RETURNS varchar(20)
DETERMINISTIC
BEGIN
   DECLARE cat varchar(20);

    IF dob >= '2005-01-01' THEN
        SET cat = 'Young';
    -- Born before 1st Jan 2005 but on or after 1st Jan 1985
    ELSEIF dob <'2005-01-01'  AND dob >= '1985-01-01' THEN
        SET cat = 'Adult';
    ELSEIF dob <'1985-01-01'  AND dob >= '1970-01-01' THEN
        SET cat = 'MidAge';
    ELSE
        SET cat = 'Elder';
    END IF;

    SET cat = CONCAT(cat,gender);
    RETURN cat;

END//

DELIMITER ;

WITH cte AS (
SELECT `diseaseName`,AgeCategory(gender,dob) AS 'Category', COUNT(`diseaseID`) 'cnt',
DENSE_RANK() OVER(PARTITION BY `diseaseName` ORDER BY `diseaseName`,COUNT(`diseaseID`) DESC) AS 'rnk'
FROM patient
INNER JOIN treatment USING(`patientID`)
INNER JOIN disease USING(`diseaseID`)
INNER JOIN person ON person.`personID`=`patient`.`patientID`
GROUP BY `diseaseName`,Category
ORDER BY `diseaseName`,cnt DESC
)
SELECT `diseaseName`,cnt,Category FROM cte
WHERE rnk =1;


/*
Problem Statement 5:  
Anna wants a report on the pricing of the medicine. She wants a list of the most expensive and most affordable medicines only. 
Assist anna by creating a report of all the medicines which are pricey and affordable, listing the companyName, productName, 
description, maxPrice, and the price category of each. Sort the list in descending order of the maxPrice.
Note: A medicine is considered to be “pricey” if the max price exceeds 1000 and “affordable” if the price is under 5. 
*/
SELECT `companyName`,`productName`,description,`maxPrice`,
    CASE
        WHEN `maxPrice`>1000 THEN 'Pricy'
        WHEN `maxPrice`<5 THEN 'Affordable'
        ELSE 'Medium'
    END AS 'category'
FROM medicine
HAVING category IN ('Pricy','Affordable')
ORDER BY `maxPrice` DESC;