with 

source as (

    select * from {{ source('ecom', 'raw_products') }}

),

renamed as (

    select
        -- Primary Key
        sku as product_id,

        -- Details
        nullif(trim(name), '') as product_name,
        nullif(trim(type), '') as product_type,
        nullif(trim(description), '') as product_description, 

        {# A basic example for a project-wide macro to cast a column uniformly #}
{% macro cents_to_dollars(column_name) -%}
    {{ return(adapter.dispatch("cents_to_dollars")(column_name)) }}
{%- endmacro %}

{% macro default__cents_to_dollars(column_name) -%}
    coalesce(({{ column_name }} / 100)::numeric(16, 2), 0)
{%- endmacro %}

        -- Boolean
        coalesce(lower(type) = 'jaffle', false) as is_food_item,
        coalesce(lower(type) = 'beverage', false) as is_drink_item

    from source

)

select * from renamed