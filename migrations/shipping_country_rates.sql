create table shipping_country_rates(
    id serial,
    shipping_country text,
    shipping_country_base_rate int
)
;

insert into shipping_country_rates (shipping_country, shipping_country_base_rate)
select distinct 
    shipping_country,
    shipping_country_base_rate
from shipping
;
