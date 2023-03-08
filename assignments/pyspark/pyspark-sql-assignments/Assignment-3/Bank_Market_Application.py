from pyspark.sql import SparkSession
from pyspark.sql.types import StructField,StructType,IntegerType,StringType
spark = SparkSession.builder.appName('BankMarketApplication').getOrCreate()
from pyspark.sql.functions import *

df=spark.read.csv("/home/subrat/futurense_hadoop-pyspark/labs/dataset/bankmarket",sep=';',header=True,inferSchema=True)

age_expr = when(df.age.between(13, 19), "Teenagers") \
            .when(df.age.between(20, 40), "Youngsters") \
            .when(df.age.between(40, 60), "MiddleAgers") \
            .otherwise("Seniors")

age_count_df = df.filter(df.y == 'yes').groupby(age_expr.alias("age_group")).agg(count("y").alias("subscription_count"))
age_count_df.show()

# Write data to parquet file
age_count_df.write.mode("overwrite").parquet("age_subscription_count.parquet")

# Read data from parquet file
parquet_df = spark.read.parquet("/home/subrat/age_subscription_count.parquet")

# Show the data from parquet file
parquet_df.show()

filtered_df=parquet_df.filter(parquet_df.subscription_count>2000)

schema = StructType([
    StructField("age_group", StringType(), True),
    StructField("subscription_count", IntegerType(), True)
])
filtered_df.write.format("avro") \
    .option("Schema", schema.json()) \
    .mode("overwrite").save("filtered_age_count.avro")

# Load data from Avro file
avro_df = spark.read.format("avro") \
    .option("Schema", schema.json()) \
    .load("/home/subrat/filtered_age_count.avro")

# Show the data
avro_df.show()




