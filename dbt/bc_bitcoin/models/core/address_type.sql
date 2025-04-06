{{ config(materialized='table') }}


WITH active_addresses AS (
   -- input addresses
   SELECT 
      DATE(stx.block_timestamp) AS date,
      type,
      'inputs' AS source  -- Add source column with 'input' for inputs
   FROM {{ ref('stg_inputs') }} AS inputs
   JOIN {{ ref('stg_transactions') }} AS stx
   ON inputs.transaction_hash = stx.transaction_hash

   UNION ALL

   -- output addresses
   SELECT 
      DATE(stx.block_timestamp) AS date,
      type,
      'outputs' AS source  -- Add source column with 'output' for outputs
   FROM {{ ref('stg_outputs') }} AS outputs
   JOIN {{ ref('stg_transactions') }} AS stx
   ON outputs.transaction_hash = stx.transaction_hash
),

active_addresses_group_by_date AS (
  SELECT 
    date, 
    type,
    source,  -- Include source column here
    count(*) AS address_type_count
  FROM active_addresses
  WHERE date <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
  GROUP BY date, source, type  -- Group by date and source
)

SELECT 
  date, 
  source,
  type AS address_type,
  address_type_count

FROM active_addresses_group_by_date
ORDER BY date, source
