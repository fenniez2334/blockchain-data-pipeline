{{ config(materialized='table') }}

WITH blocks_per_day AS (
    SELECT 
        DATE(timestamp) AS date,
        COUNT(DISTINCT block_hash) AS num_blocks -- Count distinct blocks per day
    FROM {{ ref('stg_blocks') }} -- Use the appropriate table that contains block information
    GROUP BY date
)

SELECT 
    date, 
    num_blocks
FROM blocks_per_day
ORDER BY date