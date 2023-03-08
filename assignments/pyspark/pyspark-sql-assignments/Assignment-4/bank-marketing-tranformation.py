import subprocess
from pyspark.sql import SparkSession
from pyspark.sql.functions import *

spark = SparkSession.builder.master("local[1]") \
                     .appName('pyspark-examples') \
                     .getOrCreate()

try:

    df = spark.read.load("hdfs://localhost:9000/user/training/bankmarketing/validated", format = "parquet")

    df.createOrReplaceTempView("Banking_Filter")

    age_group_count = spark.sql("SELECT age, count(y) as count from Banking_Filter group by age")
 
    age_group_count_gt_2000 = spark.sql("SELECT age, count(y) from Banking_Filter group by age having count(y) > 2000").show()
 
    age_group_count.write.mode('overwrite').format('avro').save('hdfs://localhost:9000/user/training/bankmarketing/processed')
 
    subprocess.run(["hadoop", "fs", "-mv" ,"hdfs://localhost:9000/user/training/bankmarketing/validated", "hdfs://localhost:9000/user/training/bankmarketing/raw/yyyymmdd/success"])

except Exception as e:

    subprocess.run(["hadoop", "fs", "-mv" ,"hdfs://localhost:9000/user/training/bankmarketing/validated", "hdfs://localhost:9000/user/training/bankmarketing/raw/yyyymmdd/error"])
    raise e