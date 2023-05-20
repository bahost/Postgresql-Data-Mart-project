create table shipping_info(
    shipping_id int primary key,
    vendor_id int,
    payment_amount numeric(14,3),
    shipping_plan_datetime timestamp,
    shipping_transfer_id int,
    shipping_agreement_id int,
    shipping_country_rate_id int,
    FOREIGN KEY (shipping_country_rate_id) REFERENCES shipping_country_rates(id),
    FOREIGN KEY (shipping_agreement_id) REFERENCES shipping_agreement(agreement_id),
    FOREIGN KEY (shipping_transfer_id) REFERENCES shipping_transfer(id)
)
;

insert into shipping_info (shipping_id, vendor_id, payment_amount, shipping_plan_datetime, shipping_transfer_id, shipping_agreement_id, shipping_country_rate_id)
select distinct
    t1.shipping_id, 
    t1.vendor_id, 
    t1.payment_amount, 
    t1.shipping_plan_datetime, 
    t2.id as shipping_transfer_id, 
    t1.agreement_id as shipping_agreement_id, 
    t3.id as shipping_country_rate_id
from(
    select 
        shipping_id, 
        vendor_id, 
        payment_amount, 
        shipping_plan_datetime,
        string_to_array(shipping_transfer_description, ':')[1] AS transfer_type,
        string_to_array(vendor_agreement_description, ':')[1] AS agreement_id
    from shipping
) as t1
left join shipping_transfer as t2
    on t1.transfer_type = t2.transfer_type
left join shipping_country_rates as t3
    on t1.shipping_country = t3.shipping_country
;
