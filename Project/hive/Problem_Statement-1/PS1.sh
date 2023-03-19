sqoop export \
--connect jdbc:mysql://localhost:3306/analysis \
--username sqoop \
--password sqoop \
--table state_tc_ratio \
--export-dir /user/training/hive/Q1/000000_0 \
--input-fields-terminated-by ',';