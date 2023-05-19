--CREATE
create table shipping_country_rates as(
    id serial,
    shipping_country text,
    shipping_country_base_rate int
)
;

create table shipping_agreement as(
    agreement_id int primary key,
    agreement_number int,
    agreement_rate int,
    agreement_commission int
)
;

create table shipping_transfer as(
    id SERIAL primary key,
    transfer_type varchar,
    transfer_model varchar,
    shipping_transfer_rate numeric(14,3)
)
;

create table shipping_info as(
    shipping_id int primary key,
    vendor_id int,
    payment_amount numeric(14,3),
    shipping_plan_datetime datetime,
    shipping_transfer_id int,
    shipping_agreement_id int,
    shipping_country_rate_id int,
    FOREIGN KEY (shipping_country_rate_id) REFERENCES shipping_country_rates(id),
    FOREIGN KEY (shipping_agreement_id) REFERENCES shipping_agreement(agreement_id),
    FOREIGN KEY (shipping_transfer_id) REFERENCES shipping_transfer(id)
)
;

create table shipping_status as(
    shipping_id int primary key,
    status varchar,
    state varchar,
    shipping_start_fact_datetime datetime,
    shipping_end_fact_datetime datetime
)
;


-- INSERT
insert into shipping_country_rates (shipping_country, shipping_country_base_rate)
select distinct 
    shipping_country,
    shipping_country_base_rate
from shipping
;

insert into shipping_agreement (agreement_id, agreement_number, agreement_rate, agreement_commission)
select distinct
    cast(descr[1] as int)           as agreement_id,
    cast(descr[2] as int)           as agreement_number,
    cast(descr[3] as int)           as agreement_rate,
    cast(descr[4] as int)           as agreement_commission
from (
    select string_to_array(vendor_agreement_description, ':') AS descr, 
    from shipping
)
;

insert into shipping_transfer (transfer_type, transfer_model, shipping_transfer_rate)
select distinct
    cast(descr[1] as int)           as transfer_type,
    cast(descr[2] as int)           as transfer_model,
    cast(descr[3] as int)           as shipping_transfer_rate
from (
    select string_to_array(shipping_transfer_description, ':') AS descr, 
    from shipping
)
;

insert into shipping_status (shipping_id, status, state, shipping_start_fact_datetime, shipping_end_fact_datetime)
select distinct
    a.shipping_id                   as shipping_id,
    b.status                        as status,
    b.state                         as state,
    a.shipping_start_fact_datetime  as shipping_start_fact_datetime,
    a.shipping_end_fact_datetime    as shipping_end_fact_datetime
from (
    select 
        shipping_id,
        min(case when state = 'booked' then state_datetime else null end)           as shipping_start_fact_datetime,
        max(case when state = 'recieved' then state_datetime else null end)         as shipping_end_fact_datetime
    from shipping
    group by 
        shipping_id
) as a
join shipping as b
on a.shipping_id = b.shipping_id
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


-- DATA MART
create or replace view shipping_datamart as
select 
    t1.shipping_id,
    t1.vendor_id,
    t2.transfer_type,
    date_part(’day’, age(shipping_start_fact_datetime, shipping_end_fact_datetime)) as full_day_at_shipping,
    is_delay,
    is_shipping_finish,
    shipping_end_fact_datetime - shipping_plan_datetime                                     as delay_day_at_shipping,
    t1.payment_amount,
    t1.payment_amount * (shipping_country_base_rate + agreement_rate + shipping_transfer_rate) as vat,
    t1.payment_amount * agreement_commission                                                   as profit
from shipping_info as t1
left join shipping_transfer as t2
    on t1.shipping_transfer_id = t2.id


