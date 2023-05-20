create table shipping_status(
    shipping_id int primary key,
    status varchar,
    state varchar,
    shipping_start_fact_datetime timestamp,
    shipping_end_fact_datetime timestamp
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
