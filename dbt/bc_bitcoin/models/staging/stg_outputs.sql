{{ config(materialized='view') }}

with source as (
    select * 
    from {{ source('staging', 'outputs') }}
    where `hash` is not null
),

renamed as (
    select
        `hash` as transaction_hash,
        index,
        script_asm,
        script_hex,
        required_signatures,
        type,
        addresses,
        value
    from source
)

select * 
from renamed

{% if var('is_test_run', default=true) %}
limit 30
{% endif %}
