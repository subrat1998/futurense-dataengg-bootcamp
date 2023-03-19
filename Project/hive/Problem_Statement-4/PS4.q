/*
Problem Statement 4: 
The Healthcare department wants a report about the inventory of pharmacies. 
Generate a report on their behalf that shows how many units of medicine each pharmacy has in their inventory,
the total maximum retail price of those medicines, and the total price of all the medicines after discount. 
Note: discount field in keep signifies the percentage of discount on the maximum price.
*/

CREATE EXTERNAL TABLE pharmacy_summary (
    pharmacy_id INT,
    pharmacy_name STRING,
    total_stock INT,
    total_maxprice FLOAT,
    discounted_price FLOAT
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
LOCATION '/user/training/hive/Q4';

INSERT OVERWRITE TABLE pharmacy_summary
SELECT 
    p.pharmacyid, 
    p.pharmacyname, 
    SUM(k.quantity) AS `Total_stock`, 
    SUM(m.maxprice) AS `Total_maxprice`, 
    ROUND(SUM(m.maxprice*(k.discount/100)),2) AS `Discounted_Price`
FROM 
    pharmacy p 
    JOIN keep k ON p.pharmacyid = k.pharmacyid
    JOIN medicine m ON m.medicineid = k.medicineid
GROUP BY 
    p.pharmacyid, 
    p.pharmacyname;
