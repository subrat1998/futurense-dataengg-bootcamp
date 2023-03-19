sqoop export \
--connect jdbc:mysql://localhost:3306/analysis \
--username sqoop \
--password sqoop \
--table state_wise_treatment_claim \
--export-dir /user/training/hive/Q7 \
--input-fields-terminated-by ',';