sqoop export \
--connect jdbc:mysql://localhost:3306/analysis \
--username sqoop \
--password sqoop \
--table disease_data \
--export-dir /user/training/hive/Q2/000000_0 \
--input-fields-terminated-by ',';