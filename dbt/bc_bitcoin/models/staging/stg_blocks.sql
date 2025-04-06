{{ config(materialized='view') }}

with source as (
    select * 
    from {{ source('staging', 'blocks') }}
    where `hash` is not null
),

renamed as (
    select
        `hash` as block_hash,
        size,
        stripped_size,
        weight,
        number as block_number,
        version,
        merkle_root,
        timestamp,
        timestamp_month,
        nonce,
        bits,
        coinbase_param,
        transaction_count
    from source
)

select * 
from renamed


