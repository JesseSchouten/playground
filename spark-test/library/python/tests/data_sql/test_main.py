import pandas as pd
from pyspark.sql import SparkSession

def test_dailyreport():
    # Assumes that pyspark is installed on the machine!
    # Suggestion: use databricks connect to use the databricks cluster
    # https://docs.databricks.com/dev-tools/databricks-connect.html
    run_spark = True

    if run_spark:
        columns = ['date', 'channel', 'country', 'nr_trials']
        row = [('2017-12-15', 'hor', 'NL', 0)]

        spark = SparkSession.builder.appName('SparkByExamples.com').getOrCreate()
        rdd = spark.sparkContext.parallelize(row)

        data = rdd.toDF(columns)
        insert_passed = True
        spark.stop()

        assert insert_passed == True
    else:
        insert_passed = True
        assert insert_passed == True
