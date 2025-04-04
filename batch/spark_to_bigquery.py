#!/usr/bin/env python
# coding: utf-8

import argparse

import pyspark
from pyspark.sql import SparkSession
from pyspark.sql.functions import explode, col

parser = argparse.ArgumentParser()


parser.add_argument('--input_blocks', required=True)
parser.add_argument('--input_transactions', required=True)
parser.add_argument('--out_blocks', required=True)
parser.add_argument('--out_transactions', required=True)
parser.add_argument('--out_inputs', required=True)
parser.add_argument('--out_outputs', required=True)
parser.add_argument('--bucket', required=True)

args = parser.parse_args()

bucket = args.bucket
input_blocks = args.input_blocks
input_transactions = args.input_transactions
out_blocks = args.out_blocks
out_transactions = args.out_transactions
out_inputs = args.out_inputs
out_outputs = args.out_outputs

spark = SparkSession.builder \
    .appName('test') \
    .config("spark.jars", "gs://spark-lib/bigquery/spark-bigquery-with-dependencies_2.12-0.28.0.jar") \
    .getOrCreate()

# update the temp GCS bucket configuration with the bucket name generated by the Dataproc cluster
# spark.conf.set('temporaryGcsBucket', bucket)

# reading data as spark dataframes with previously 
df_blocks = spark.read.parquet(input_blocks)

df_transactions = spark.read.parquet(input_transactions)

# df_transactions has nested fields, flattened them input flated_input and flated_output
# Flatten the inputs and outputs
df_inputs_flat = df_transactions \
    .select("hash", explode("inputs").alias("input")) \
    .select("hash", "input.*")  # Flatten the fields inside 'inputs'

df_outputs_flat = df_transactions \
    .select("hash", explode("outputs").alias("output")) \
    .select("hash", "output.*")  # Flatten the fields inside 'outputs'

# keep only non-nested fields
df_transactions_non_nested = df_transactions.select(
    "hash", "size", "virtual_size", "version", "lock_time", 
    "block_hash", "block_number", "block_timestamp", "block_timestamp_month", "input_count", 
    "output_count", "input_value", "output_value", "is_coinbase", "fee"
)

df_blocks.write.format('bigquery') \
    .option("temporaryGcsBucket", args.bucket) \
    .mode('overwrite') \
    .save(out_blocks)

df_transactions_non_nested.write.format('bigquery') \
    .option("temporaryGcsBucket", args.bucket) \
    .mode('overwrite') \
    .save(out_transactions)

df_inputs_flat.write.format('bigquery') \
    .option("temporaryGcsBucket", args.bucket) \
    .mode('overwrite') \
    .save(out_inputs)

df_outputs_flat.write.format('bigquery') \
    .option("temporaryGcsBucket", args.bucket) \
    .mode('overwrite') \
    .save(out_outputs)
    