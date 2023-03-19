sqoop export \
--connect jdbc:mysql://localhost:3306/analysis \
--username sqoop \
--password sqoop \
--table pharmacy_summary \
--export-dir /user/training/hive/Q4/000000_0 \
--input-fields-terminated-by ','