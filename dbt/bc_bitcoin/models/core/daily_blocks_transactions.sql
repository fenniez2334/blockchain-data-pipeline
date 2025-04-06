{{ config(materialized='table') }}

WITH blocks_per_day AS (
    SELECT 
        DATE(timestamp) AS date,
        COUNT(DISTINCT block_hash) AS blocks_count -- Count distinct blocks per day
    FROM {{ ref('stg_blocks') }} -- Use the appropriate table that contains block information
    GROUP BY date
),

daily_transactions AS (
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


SELECT 
    b.date AS block_date,  -- Specify alias for date from blocks_per_day
    b.blocks_count,
    t.transaction_count,
    t.total_transfer_volume,
    t.mean_transfer_volume,
    t.biggest_transfer_volume
FROM blocks_per_day AS b
JOIN daily_transactions AS t
ON b.date = t.date
ORDER BY b.date