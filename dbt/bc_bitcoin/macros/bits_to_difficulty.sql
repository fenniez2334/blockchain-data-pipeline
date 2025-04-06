{% macro bits_to_difficulty(bits) %}
    (
        0x00000000FFFF0000000000000000000000000000000000000000000000000000 /
        {{ bits_to_target(bits) }}
    )
{% endmacro %}