sqoop export \
--connect jdbc:mysql://localhost:3306/analysis \
--username sqoop \
--password sqoop \
--table diseases_data_ext \
--export-dir /user/training/hive/Q6EXT/000000_0 \
--input-fields-terminated-by ','