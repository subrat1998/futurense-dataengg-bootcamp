-- Active: 1671769371715@@127.0.0.1@3308@healthcare

--1
SELECT m.medicineID,m.productName,
CASE m.productType
                WHEN 1 THEN 'Generic' 
                WHEN 2 THEN 'Patent'
                WHEN 3 THEN 'Reference'
                WHEN 4 THEN 'Similar' 
                WHEN 5 THEN  'New'
                WHEN 6 THEN  'Specific'
END
FROM medicine m LEFT JOIN keep k ON m.`medicineID`=k.`medicineID`
LEFT JOIN pharmacy p on p.`pharmacyID`=k.`pharmacyID`
WHERE p.pharmacyName='HealthDirect' AND m.taxCriteria="I" AND m.productType in (1,2,3) OR 
      p.pharmacyName='HealthDirect' AND m.taxCriteria="II" AND m.productType in (4,5,6);


--2

WITH CTE AS(
SELECT c.prescriptionID,sum(c.quantity) as 'quantity' FROM contain c
                LEFT JOIN prescription pr ON c.`prescriptionID`=pr.`prescriptionID`
                LEFT JOIN pharmacy p ON p.`pharmacyID`=pr.`pharmacyID`
                WHERE p.`pharmacyName`='Ally Scripts'
GROUP BY `prescriptionID`
)
SELECT *,
CASE
WHEN CTE.quantity < 20 THEN "Low Qauantity"
WHEN CTE.quantity BETWEEN 20 AND 49 THEN "Medium Qauantity"
WHEN CTE.quantity >= 50 THEN "High Qauantity"
END
FROM cte;

--3
WITH CTE AS
(
    SELECT medicineID,quantity,
        CASE
            WHEN quantity=7500 THEN "High Quantity"
            WHEN quantity<1000 THEN "Low Quantity"
        END Quantity_Type,
        CASE
            WHEN discount>=30 THEN "High"
            WHEN discount=0 THEN  "None"
        END Discount_Type
        FROM keep NATURAL JOIN pharmacy
        WHERE `pharmacyName`='Spot Rx'
)
SELECT * FROM CTE WHERE Quantity_Type='High Quantity' and Discount_Type='None' OR Quantity_Type='Low Quantity' and Discount_Type='High';

--4

with cte as
(select m.medicineID,m.productName,m.maxPrice,(select round(avg(maxPrice),2) from medicine) as avgPrice
from medicine m join keep k on k.medicineID=m.medicineID
join pharmacy p on k.pharmacyID=p.pharmacyID
where hospitalExclusive = 'S' and p.pharmacyName='HealthDirect'),
cte1 as
(select productName,
case 
	when maxPrice<(0.5*avgPrice) then 'Affordable'
    when maxPrice>(2*avgPrice) then 'Costly'
end as Affordability
from cte)
select productName,affordability
from cte1
where affordability is not null;

--5

SELECT p.personName,p.gender,pt.dob,
CASE
WHEN pt.dob>='2005-01-01' AND p.gender='male' THEN 'YoungMale'
WHEN pt.dob>='2005-01-01' AND p.gender='female' THEN 'YoungFemale'
WHEN pt.dob<'2005-01-01' AND pt.dob>='1985-01-01' AND p.gender='male' THEN 'AdultMale'
WHEN pt.dob<'2005-01-01' AND pt.dob>='1985-01-01' AND p.gender='female' THEN 'AdultFemale'
WHEN pt.dob<'1985-01-01' AND pt.dob>='1970-01-01' AND p.gender='male' THEN 'AdultMale'
WHEN pt.dob<'1985-01-01' AND pt.dob>='1970-01-01' AND p.gender='female' THEN 'AdultFemale'
WHEN pt.dob<'1970-01-01' AND p.gender='male' THEN 'ElderMale'
WHEN pt.dob<'1970-01-01' AND p.gender='female' THEN 'ElderFemale'
END 'Category'
FROM person p RIGHT JOIN patient pt
ON p.`personID`=pt.`patientID`
;




