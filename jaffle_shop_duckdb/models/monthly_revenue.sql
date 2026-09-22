-- models/monthly_revenue.sql
{{ config(materialized='view') }}

-- CTE로 먼저 필터링 : with orders as (...)에서 반품 먼저 걸러내고 아래에서 집계 
with orders as (
    select * from {{ref('orders')}}
    where status != 'returned'
)

select 
    date_trunc('month', order_date) as month,
    count(order_id) as order_count, -- 주문은 행마다 세고
    count(distinct customer_id) as customer_count, --고객은 한달에 여러번 주문해도 한 명으로 세어야 함
    sum(amount) as total_amount 
from orders 
group by 1 -- select 의 첫번째 커럼 (order_month)로 묶는다는 뜻 
order by 1 -- 보기 편하라고 넣은 것, 테이블로 저장될 때 정렬 순서가 보장 되지 않기 때문 