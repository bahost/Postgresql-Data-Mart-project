--CREATE
create table shipping_country_rates as(
    id SERIAL,
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
    shipping_id int,
    status varchar,
    state varchar,
    shipping_start_fact_datetime datetime,
    shipping_end_fact_datetime datetime
)
;

create table shipping_datamart as(
    shipping_id int,
    vendor_id int,
    transfer_type varchar,
    full_day_at_shipping int,
    is_delay boolean,
    is_shipping_finish boolean,
    delay_day_at_shipping date,
    vat numeric(14,3),
    profit numeric(14,3)
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
    cast(descr[1] as int) as agreement_id,
    cast(descr[2] as int) as agreement_number,
    cast(descr[3] as int) as agreement_rate,
    cast(descr[4] as int) as agreement_commission
from (
    select string_to_array(vendor_agreement_description, ':') AS descr, 
    from shipping
)
;

insert into shipping_transfer (transfer_type, transfer_model, shipping_transfer_rate)
select distinct
    cast(descr[1] as int) as transfer_type,
    cast(descr[2] as int) as transfer_model,
    cast(descr[3] as int) as shipping_transfer_rate
from (
    select string_to_array(shipping_transfer_description, ':') AS descr, 
    from shipping
)
;



