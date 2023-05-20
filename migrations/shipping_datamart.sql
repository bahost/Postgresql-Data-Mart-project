create or replace view shipping_datamart as
with shipping_finish as(
    select distinct
        shipping_id
    from (
        select shipping_id
            , status
            , row_number() over(partition by shipping_id order by state_datetime desc) as rn
        from shipping_info
    )as t1
    where 1=1
        and t1.rn = 1
        and t1.status = 'finished'
)
select 
    t1.shipping_id as shipping_id,
    t1.vendor_id as vendor_id,
    t2.transfer_type as transfer_type,
    date_part(’day’, age(t3.shipping_start_fact_datetime, t3.shipping_end_fact_datetime))               as full_day_at_shipping,
    if(t3.shipping_end_fact_datetime > t1.shipping_plan_datetime, 1, 0)                                 as is_delay,
    if(t4.shipping_id is not null, 1, 0)                                                         as is_shipping_finish,
    t3.shipping_end_fact_datetime - t1.shipping_plan_datetime                                           as delay_day_at_shipping,
    t1.payment_amount as payment_amount,
    t1.payment_amount * (t5.shipping_country_base_rate + t6.agreement_rate + t2.shipping_transfer_rate) as vat,
    t1.payment_amount * t6.agreement_commission                                                         as profit
from shipping_info as t1
left join shipping_transfer as t2
    on t1.shipping_transfer_id = t2.id
left join shipping_status as t3
    on t1.id = t3.shipping_id
left join shipping_finish as t4
    on t1.shipping_id = t4.shipping_id
left join shipping_country_rates as t5
    on t1.shipping_country_rate_id = t5.id
left join shipping_agreement as t6
    on t1.shipping_agreement_id = t6.agreement_id
;

