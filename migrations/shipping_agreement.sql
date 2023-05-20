create table shipping_agreement(
    agreement_id int primary key,
    agreement_number int,
    agreement_rate int,
    agreement_commission int
)
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
