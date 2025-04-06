{{ config(materialized='table') }}

WITH daily_transactions AS (
    SELECT 
      DATE(block_timestamp) AS date,
      COUNT(*) AS transaction_count,
      SUM(output_value)/POW(10,8) AS total_transfer_volume,
      AVG(output_value)/POW(10,8) AS mean_transfer_volume,
      MAX(output_value)/POW(10,8) AS biggest_transfer_volume
    FROM {{ ref('stg_transactions') }}
    WHERE DATE(block_timestamp) <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY) AND is_coinbase IS false
    GROUP BY date
)

SELECT *
FROM daily_transactions
ORDER BY date