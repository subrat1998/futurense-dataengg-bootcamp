sqoop export \
--connect jdbc:mysql://localhost:3306/analysis \
--username sqoop \
--password sqoop \
--table pharmacy_quantity \
--export-dir /user/training/hive/Q5/000000_0 \
--input-fields-terminated-by ',';