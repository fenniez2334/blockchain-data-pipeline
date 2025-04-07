{{ config(materialized='view') }}

with source as (
    select * 
    from {{ source('staging', 'inputs') }}
    where `hash` is not null
),

renamed as (
    select
        `hash` as transaction_hash,
        index,
        spent_transaction_hash,
        spent_output_index,
        script_asm,
        script_hex,
        sequence,
        required_signatures,
        type,
        addresses,
        value
    from source
)

select * 
from renamed


