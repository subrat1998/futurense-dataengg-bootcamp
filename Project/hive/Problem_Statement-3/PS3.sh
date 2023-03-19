sqoop export \
--connect jdbc:mysql://localhost:3306/analysis \
--username sqoop \
--password sqoop \
--table treatment_claim_ratio \
--export-dir /user/training/hive/Q3/000000_0 \
--input-fields-terminated-by ','
