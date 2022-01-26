import pandas as pd
from pyspark.sql import SparkSession

def test_dfs_count():
    # Assumes that pyspark is installed on the machine!
    # Suggestion: use databricks connect to use the databricks cluster
    # https://docs.databricks.com/dev-tools/databricks-connect.html
    columns = ['date', 'channel', 'country', 'nr_trials']
    row = [('2017-12-15', 'hor', 'NL', 0)]

    spark = SparkSession.builder.appName('SparkByExamples.com').getOrCreate()
    rdd = spark.sparkContext.parallelize(row)

    data = rdd.toDF(columns)  

    assert data.count() == 1
    spark.stop()

def test_dfs_count2():
    # Assumes that pyspark is installed on the machine!
    # Suggestion: use databricks connect to use the databricks cluster
    # https://docs.databricks.com/dev-tools/databricks-connect.html
    columns = ['date', 'channel', 'country', 'nr_trials']
    row = [('2017-12-15', 'hor', 'NL', 0)
            ,('2018-12-15', 'hor', 'NL', 0)]

    spark = SparkSession.builder.appName('SparkByExamples.com').getOrCreate()
    rdd = spark.sparkContext.parallelize(row)

    data = rdd.toDF(columns)   


    assert data.count() != 1
    spark.stop()

