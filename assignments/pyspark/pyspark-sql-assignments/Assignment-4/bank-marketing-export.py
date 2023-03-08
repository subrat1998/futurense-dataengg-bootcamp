import subprocess
from pyspark.sql import SparkSession
from pyspark.sql.functions import *
from pyspark.sql.types import *

spark = SparkSession.builder.master("local[1]") \
                     .appName('pyspark-examples') \
                     .getOrCreate()

schema = StructType([
    StructField("age", IntegerType(), True),
    StructField("job", StringType(), True),
    StructField("marital", StringType(), True),
    StructField("education", StringType(), True),
    StructField("default", StringType(), True),
    StructField("balance", DoubleType(), True),
    StructField("housing", StringType(), True),
    StructField("loan", StringType(), True),
    StructField("contact", StringType(), True),
    StructField("day", IntegerType(), True),
    StructField("month", StringType(), True),
    StructField("duration", DoubleType(), True),
    StructField("campaign", DoubleType(), True),
    StructField("pdays", DoubleType(), True),
    StructField("previous", DoubleType(), True),
    StructField("poutcome", StringType(), True),
    StructField("y", StringType(), True)
])

try:

    df = spark.read.format("avro") \
    .option("Schema", schema.json()) \
    .load("hdfs://localhost:9000/user/training/bankmarketing/processed")

    df.write \
    .format("jdbc") \
    .option("url", "jdbc:mysql://localhost:3306/bankmarketing") \
    .option("driver", "com.mysql.jdbc.Driver") \
    .option("dbtable", "subscription_count") \
    .option("user", "pyspark") \
    .option("password", "pyspark") \
    .mode("overwrite") \
    .save()

    subprocess.run(["hadoop", "fs", "-mv" ,"hdfs://localhost:9000/user/training/bankmarketing/processed", "hdfs://localhost:9000/user/training/bankmarketing/raw/yyyymmdd/success"])

except Exception as e:

    subprocess.run(["hadoop", "fs", "-mv" ,"hdfs://localhost:9000/user/training/bankmarketing/processed", "hdfs://localhost:9000/user/training/bankmarketing/raw/yyyymmdd/error"])
    raise e
