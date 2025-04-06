{% macro bits_to_target(bits) %}
    (
        case
            when ({{ bits }} >> 24) <= 3 then
                BIT_SHIFT_RIGHT(BIT_AND({{ bits }}, 0x00ffffff), 8 * (3 - ({{ bits }} >> 24)))
            else
                BIT_SHIFT_LEFT(BIT_AND({{ bits }}, 0x00ffffff), 8 * (({{ bits }} >> 24) - 3))
        end
    )
{% endmacro %}