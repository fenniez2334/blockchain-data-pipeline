{{ config(materialized='table') }}

WITH miner_rewards AS (
   SELECT 
      DATE(tx.block_timestamp) AS date, 
      tx.is_coinbase, 
      tx.transaction_hash,
      outputs.transaction_hash, 
      (outputs.value) / 100000000 AS rewards
   FROM 
      {{ ref('stg_transactions') }} AS tx
   JOIN 
      {{ ref('stg_outputs') }} AS outputs
      ON tx.transaction_hash = outputs.transaction_hash
   WHERE 
      tx.is_coinbase IS true
      AND DATE(tx.block_timestamp) <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
),

miner_rewards_grouped_by_date AS (
    SELECT 
        date, 
        SUM(rewards) AS issuance
    FROM 
        miner_rewards
    WHERE 
        date <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY) 
    GROUP BY 
        date
), 

circulating_supply_grouped_by_date AS (
     SELECT 
        date, 
        issuance, 
        SUM(issuance) OVER (ORDER BY date) AS circulating_supply
     FROM 
        miner_rewards_grouped_by_date
     GROUP BY 
        date, issuance
), 

inflation_rate_grouped_by_date AS (
  SELECT 
        date,
        SAFE_MULTIPLY(SAFE_DIVIDE(issuance, circulating_supply), 100) AS inflation_rate,
        issuance,
        circulating_supply
  FROM 
        circulating_supply_grouped_by_date
  GROUP BY 
        date, issuance, circulating_supply
),

miner_fees AS (
    SELECT 
        DATE(block_timestamp) AS date, 
        (tx.fee) / 100000000 AS fees
    FROM 
        {{ ref('stg_transactions') }} AS tx
    WHERE 
        DATE(block_timestamp) <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY) 
),

miner_revenue AS (
    SELECT 
        date, 
        rewards AS total_revenue
    FROM 
        miner_rewards
    UNION ALL 
    SELECT 
        date, 
        fees AS total_revenue
    FROM 
        miner_fees
),  

miner_revenue_grouped_by_date AS (
    SELECT 
        date, 
        SUM(total_revenue) AS total_miner_revenue
    FROM 
        miner_revenue
    GROUP BY 
        date
),

miner_fees_grouped_by_date AS (
    SELECT 
        date, 
        SUM(fees) AS total_miner_fees
    FROM 
        miner_fees
    GROUP BY 
        date
), 

miner_grouped_by_date AS (
    SELECT 
        mr.date, 
        mr.total_miner_revenue, 
        mf.total_miner_fees, 
        SAFE_DIVIDE(mr.total_miner_revenue, mf.total_miner_fees) AS FRM
    FROM 
        miner_revenue_grouped_by_date AS mr
    JOIN 
        miner_fees_grouped_by_date AS mf
        ON mr.date = mf.date
)

SELECT 
    ifr.date AS date,
    ifr.issuance AS issuance,
    ifr.circulating_supply AS circulating_supply,
    ifr.inflation_rate AS inflation_rate,
    frm.total_miner_revenue AS total_miner_revenue,
    frm.total_miner_fees AS total_miner_fees,
    frm.FRM AS fee_ratio
FROM 
    inflation_rate_grouped_by_date AS ifr
JOIN 
    miner_grouped_by_date AS frm
    ON ifr.date = frm.date
ORDER BY 
    ifr.date
