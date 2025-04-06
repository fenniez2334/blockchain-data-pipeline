{{ config(materialized='view') }}

with source as (
    select * 
    from {{ source('staging', 'transactions') }}
    where `hash` is not null
),

renamed as (
    select
        `hash` as transaction_hash,
        size,
        virtual_size,
        version,
        lock_time,
        block_hash,
        block_number,
        block_timestamp,
        block_timestamp_month,
        input_count,
        output_count,
        input_value,
        output_value,
        is_coinbase,
        fee
    from source
)

select * 
from renamed


