import subprocess
from pyspark.sql import SparkSession
from pyspark.sql.functions import *

input_file_path = "/home/subrat/futurense_hadoop-pyspark/labs/dataset/bankmarket/bankmarketdata.csv"
hdfs_raw_path = "/user/training/bankmarketing/raw/"

spark = SparkSession.builder.master("local[1]") \
                  .appName('BankMarketingDataLoading') \
                  .getOrCreate()


subprocess.run(["echo","Loading data from local system to HDFS"])

subprocess.run(["hadoop", "fs", "-put",  input_file_path, hdfs_raw_path])

subprocess.run(["echo","Data Loaded Successfully to HDFS"])

try:

      df = spark.read.load("hdfs://localhost:9000/user/training/bankmarketing/raw/bankmarketdata.csv",format = "csv", sep = ";", delimiter=';',header=True,inferSchema=True)

      df.write.mode('overwrite').format('parquet').save("hdfs://localhost:9000/user/training/bankmarketing/staging")

      subprocess.run(["hadoop", "fs", "-mv" ,"hdfs://localhost:9000/user/training/bankmarketing/raw/bankmarketdata.csv", "hdfs://localhost:9000/user/training/bankmarketing/raw/yyyymmdd/success"])

except Exception as e:

      subprocess.run(["hadoop", "fs", "-mv" ,"hdfs://localhost:9000/user/training/bankmarketing/raw/bankmarketdata.csv" ,"hdfs://localhost:9000/user/training/bankmarketing/raw/yyyymmdd/error"])
      raise e