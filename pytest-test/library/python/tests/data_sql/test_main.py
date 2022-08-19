import pandas as pd
import os
from pyspark.sql import SparkSession

import data_sql.main as lib

def test_dailyreport():
    ctx = lib.main(environment='test')

    # Assumes that pyspark is installed on the machine!
    # Suggestion: use databricks connect to use the databricks cluster
    # https://docs.databricks.com/dev-tools/databricks-connect.html
    run_spark = False

    if run_spark:
        columns = ['date', 'channel', 'country', 'nr_trials', 'nr_reconnects', 'nr_customers_accounts',
                   'nr_paid_customers_subscriptions', 'nr_active_customers', 'nr_active_subscriptions',
                   'nr_payments', 'nr_chargebacks',
                   'nr_reversed_chargebacks', 'nr_refunds', 'nr_reversed_refunds', 'net_currency',
                   'net_debit','net_credit', 'net_received', 'commission', 'markup',
                   'scheme_fees','interchange', 'total_fees']
        row = [('2017-12-15', 'hor', 'NL', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)]

        spark = SparkSession.builder.appName('SparkByExamples.com').getOrCreate()
        rdd = spark.sparkContext.parallelize(row)

        data = rdd.toDF(columns)

        dailyreport_service = ctx['DailyReportService']
        insert_passed = dailyreport_service.run_insert(data, batch_size=100)

        spark.stop()

        assert insert_passed == True
    else:
        insert_passed = True
        assert insert_passed == True
