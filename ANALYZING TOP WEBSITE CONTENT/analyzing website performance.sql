--- Temorary table 
--- Analysing top website pages and entry

SELECT 
PAGEVIEW_URL,
COUNT(DISTINCT WEBSITE_PAGEVIEW_ID) AS PVS

FROM WEBSITE_PAGEVIEWS
WHERE WEBSITE_PAGEVIEW_ID <1000
GROUP BY 1
ORDER BY 2
;


CREATE TEMPORARY TABLE first_pageview AS 
SELECT 
WEBSITE_SESSION_ID,
MIN(WEBSITE_PAGEVIEW_ID) AS MIN_PV_ID
FROM WEBSITE_PAGEVIEWS
WHERE WEBSITE_PAGEVIEW_ID<1000
GROUP BY 1;

SELECT 

WEBSITE_PAGEVIEWS.PAGEVIEW_URL AS LANDING_PAGE,
COUNT(DISTINCT FIRST_PAGEVIEW.WEBSITE_SESSION_ID) AS SESSION_HITTING_THIS_LANDER

FROM first_pageview
LEFT JOIN WEBSITE_PAGEVIEWS
ON first_pageview.MIN_PV_ID = WEBSITE_PAGEVIEWS.WEBSITE_PAGEVIEW_ID
GROUP BY 1;


SELECT WEBSITE_PAGEVIEWS. PAGEVIEW_URL,COUNT(DISTINCT WEBSITE_PAGEVIEWS.WEBSITE_PAGEVIEW_ID ) AS SESSION 
FROM WEBSITE_PAGEVIEWS
WHERE CREATED_AT < '2012-06-09' 
GROUP BY 1
ORDER BY 2 DESC ;

--- LIST OF TOP ENTRY PAGES, PULL ALL ENTRY PAGES AND RANK THEM ON ENTRY VOLUMNS
CREATE TEMPORARY TABLE first_pv_per_sess AS 
SELECT 
WEBSITE_SESSION_ID,
MIN(WEBSITE_PAGEVIEW_ID) AS FIRST_PV
FROM WEBSITE_PAGEVIEWS
WHERE CREATED_AT < '2012-06-12'
GROUP BY WEBSITE_SESSION_ID
;



SELECT
WEBSITE_PAGEVIEWS.pageview_url as landing_page_url,
count(distinct first_pv_per_sess.website_session_id ) as session_hitting_page
FROM first_pv_per_sess
LEFT JOIN WEBSITE_PAGEVIEWS
ON first_pv_per_sess.first_pv =  WEBSITE_PAGEVIEWS.website_pageview_id
group by 1
;

---BUSAINESS CONTEX
-- STEP 1 : Find the first website_pageview_id for relevant session
-- STEP2 : Identify the landing page of each session
-- Step3 : Counting pageviews for each session, to identify 'bounce'
-- Step4 : summarizing the total session and bounced session , by LP

--- finding the minimum website pageview id associated with each session we care about
create temporary table first_page_view_demo as 
SELECT 
WEBSITE_PAGEVIEWS.WEBSITE_SESSION_ID,
MIN(website_pageviews.WEBSITE_PAGEVIEW_ID) AS min_pageview_id
from website_pageviews
inner join website_session
on website_session.website_session_id = WEBSITE_PAGEVIEWS.website_session_id
AND website_session.CREATED_AT BETWEEN '2014-01-01' AND '2014-02-01'
GROUP BY 
WEBSITE_PAGEVIEWS.WEBSITE_SESSION_ID;

CREATE TEMPORARY TABLE SESSION_W_LANDING_PAGE_DEMO AS 
SELECT 
    first_page_view_demo.website_session_id,
    website_pageviews.pageview_url as landing_page
from first_page_view_demo
    left join website_pageviews
        on website_pageviews.website_pageview_id =first_page_view_demo.min_pageview_id

;

CREATE TEMPORARY TABLE bounced_session_only as 
SELECT 
SESSION_W_LANDING_PAGE_DEMO.website_session_id,
SESSION_W_LANDING_PAGE_DEMO.landing_page,
count(WEBSITE_PAGEVIEWS.website_pageview_id) as count_of_pages_viewed
FROM SESSION_W_LANDING_PAGE_DEMO
LEFT JOIN WEBSITE_PAGEVIEWS
on WEBSITE_PAGEVIEWS.website_session_id = SESSION_W_LANDING_PAGE_DEMO.website_session_id
group by 
SESSION_W_LANDING_PAGE_DEMO.website_session_id,
SESSION_W_LANDING_PAGE_DEMO.landing_page
having 
count(WEBSITE_PAGEVIEWS.website_pageview_id)=1
;


select * from bounced_session_only;

SELECT 
SESSION_W_LANDING_PAGE_DEMO.landing_page,
count(distinct SESSION_W_LANDING_PAGE_DEMO.website_session_id) as sessions,
count(distinct bounced_session_only.website_session_id) as bounced_sessions
from SESSION_W_LANDING_PAGE_DEMO
left join bounced_session_only
on SESSION_W_LANDING_PAGE_DEMO.website_session_id=bounced_session_only.website_session_id
group by SESSION_W_LANDING_PAGE_DEMO.landing_page;


-----------------------------------------------------------------------

select * from WEBSITE_PAGEVIEWS;

SELECT * FROM WEBSITE_SESSION;

CREATE TEMPORARY TABLE first_page_review1 as 
select 
WEBSITE_SESSION_ID,
MIN(WEBSITE_PAGEVIEW_ID) AS min_pageview_id
from WEBSITE_PAGEVIEWS

WHERE WEBSITE_PAGEVIEWS.CREATED_AT<'2012-06-12'
GROUP BY 
WEBSITE_SESSION_ID;



CREATE TEMPORARY TABLE SESSION_W_LANDING_PAGE1 AS 
SELECT 
    first_page_review1.website_session_id,
    website_pageviews.pageview_url as landing_page
from first_page_review1
    left join website_pageviews
        on website_pageviews.website_pageview_id =first_page_review1.min_pageview_id
    where website_pageviews.pageview_url = 'home'

;




CREATE TEMPORARY TABLE bounced_session1 as 
SELECT 
SESSION_W_LANDING_PAGE1.website_session_id,
SESSION_W_LANDING_PAGE1.landing_page,
count(WEBSITE_PAGEVIEWS.website_pageview_id) as count_of_pages_viewed
FROM SESSION_W_LANDING_PAGE1
LEFT JOIN WEBSITE_PAGEVIEWS
on WEBSITE_PAGEVIEWS.website_session_id = SESSION_W_LANDING_PAGE1.website_session_id
group by 
SESSION_W_LANDING_PAGE1.website_session_id,
SESSION_W_LANDING_PAGE1.landing_page
having 
count(WEBSITE_PAGEVIEWS.website_pageview_id)=1
;

select * from bounced_session1;

SELECT 
count(distinct SESSION_W_LANDING_PAGE1.website_session_id) as session ,
count(distinct bounced_session1.website_session_id) as bounced_website_session_id,
count(distinct bounced_session1.website_session_id)/count(distinct SESSION_W_LANDING_PAGE1.website_session_id) as bounce_rate
from SESSION_W_LANDING_PAGE1
left join bounced_session1
on SESSION_W_LANDING_PAGE1.website_session_id=bounced_session1.website_session_id
order by SESSION_W_LANDING_PAGE1.website_session_id;




-----------------------------------------------------------------------------------------------------

-- step 1 : finding out when the new page/lander launched
-- STEP 2 : Find the first website_pageview_id for relevant session
-- STEP 3 : Identify the landing page of each session
-- Step 4 : Counting pageviews for each session, to identify 'bounce'
-- Step 5 : summarizing the total session and bounced session , by LP

SELECT 
MIN(CREATED_AT) AS first_created_at,
MIN(website_pageview_id) as first_page_view_id
from website_pageviews
where pageview_url = 'lander-1'
and created_at is not null;

create temporary table first_page_view2 as 
SELECT 
website_pageviews.website_session_id,
min(website_pageviews.website_pageview_id) as min_pageview_id
FROM WEBSITE_PAGEVIEWS
INNER JOIN WEBSITE_SESSION
ON WEBSITE_SESSION.WEBSITE_SESSION_ID = WEBSITE_PAGEVIEWS.WEBSITE_SESSION_ID
and WEBSITE_SESSION.created_at < '2012-07-28'
and website_pageviews.WEBSITE_PAGEVIEW_ID >23504
and utm_source = 'gsearch'
and utm_campaign = 'nonbrand'
group by 
website_pageviews.website_session_id;

create temporary table nonbrand_test_session_w_landing_page as 
SELECT 
    first_page_view2.website_session_id,
    website_pageviews.pageview_url as landing_page
from first_page_view2
    left join website_pageviews
        on website_pageviews.website_pageview_id =first_page_view2.min_pageview_id
    where website_pageviews.pageview_url IN ('home','lander-1');

select * from nonbrand_test_session_w_landing_page;


CREATE TEMPORARY TABLE non_brand_test_bounced_sessions as 
SELECT 
nonbrand_test_session_w_landing_page.website_session_id,
nonbrand_test_session_w_landing_page.landing_page,
count(WEBSITE_PAGEVIEWS.website_pageview_id) as count_of_pages_viewed
FROM nonbrand_test_session_w_landing_page
LEFT JOIN WEBSITE_PAGEVIEWS
on WEBSITE_PAGEVIEWS.website_session_id = nonbrand_test_session_w_landing_page.website_session_id
group by 
nonbrand_test_session_w_landing_page.website_session_id,
nonbrand_test_session_w_landing_page.landing_page
having 
count(WEBSITE_PAGEVIEWS.website_pageview_id)=1
;
select * from  non_brand_test_bounced_sessions;


SELECT 
nonbrand_test_session_w_landing_page.LANDING_PAGE,
count(distinct nonbrand_test_session_w_landing_page.website_session_id) as session,
count( distinct non_brand_test_bounced_sessions.WEBSITE_SESSION_ID) as bounced_sessin_id,
count( distinct non_brand_test_bounced_sessions.WEBSITE_SESSION_ID)/count(distinct nonbrand_test_session_w_landing_page.website_session_id) as bounce_rate
FROM nonbrand_test_session_w_landing_page
left join non_brand_test_bounced_sessions
on nonbrand_test_session_w_landing_page.website_session_id=non_brand_test_bounced_sessions.website_session_id
group by 
nonbrand_test_session_w_landing_page.LANDING_PAGE;

-------------------------------------------------------------------------



--create temporary table session_w_min_pv_id_and_view_count2 as 
SELECT 
website_session.website_session_id,
min(website_pageviews.website_pageview_id) as min_pageview_id,
count(website_pageviews.website_pageview_id) as count_pageviews

FROM WEBSITE_PAGEVIEWS
left JOIN WEBSITE_SESSION
        ON WEBSITE_SESSION.WEBSITE_SESSION_ID = WEBSITE_PAGEVIEWS.WEBSITE_SESSION_ID     
        and WEBSITE_SESSION.created_at > '2012-06-01'
        and WEBSITE_SESSION.created_at< '2012-08-31'
        and WEBSITE_SESSION.utm_source = 'gsearch'
        and WEBSITE_SESSION.utm_campaign = 'nonbrand'
group by 
website_session.website_session_id;



SELECT * FROM session_w_min_pv_id_and_view_count2;

create temporary table session_w_counts_lander_and_created_at1 as  
SELECT 
session_w_min_pv_id_and_view_count2.website_session_id,
session_w_min_pv_id_and_view_count2.MIN_PAGEVIEW_ID,
session_w_min_pv_id_and_view_count2.COUNT_PAGEVIEWS,
website_pageviews.pageview_url as landing_page,
website_pageviews.created_at as session_created_at

FROM session_w_min_pv_id_and_view_count2
left join website_pageviews
on session_w_min_pv_id_and_view_count2.MIN_PAGEVIEW_ID=website_pageviews.website_pageview_id;


select * from session_w_counts_lander_and_created_at1;


select 
min(session_created_at) as week_start_date,
---count(distinct case when count_pageviews=1 then website_session_id else null end)*1.0/
--count(distinct website_session_id) as bounc_rate ,
count(distinct case when landing_page = 'home' then website_session_id else null end ) as home_session
--count(distinct case when landing_page = 'lander-1' then website_session_id else null end ) as lander_session

from session_w_counts_lander_and_created_at
group by 
yearofweek(session_created_at);


--- ********************************************************************** ----

SELECT * FROM WEBSITE_SESSION;
SELECT distinct(PAGEVIEW_URL) FROM WEBSITE_PAGEVIEWS;

SELECT 
WEBSITE_SESSION.WEBSITE_SESSION_ID,
WEBSITE_PAGEVIEWS.pageview_url,
WEBSITE_PAGEVIEWS.created_at as pageview_created_at,
case when pageview_url = 'products' then 1 else 0 end as product_page,
case when pageview_url = 'the-original-mr-fuzzy' then 1 else 0 end as mrfuzy_page,
case when pageview_url = 'cart' then 1 else 0 end as cart_page
FROM WEBSITE_SESSION
LEFT JOIN WEBSITE_PAGEVIEWS
    ON WEBSITE_SESSION.WEBSITE_SESSION_ID = WEBSITE_PAGEVIEWS.WEBSITE_SESSION_ID
  WHERE WEBSITE_SESSION.CREATED_AT BETWEEN '2014-01-01' AND '2014-02-01'
  AND WEBSITE_PAGEVIEWS.PAGEVIEW_URL IN ('lander-2','products','the-original-mr-fuzzy','cart')
  order by 
  WEBSITE_SESSION.WEBSITE_SESSION_ID,
 WEBSITE_PAGEVIEWS.created_at 
;


CREATE TEMPORARY TABLE  session_level_made_it_flag_demo as 
SELECT 

website_session_id,
max(product_page) as product_made_it,
max(mrfuzy_page) as mrfuzy_made_it,
max(cart_page) as cart_made_it
FROM (

SELECT 
WEBSITE_SESSION.WEBSITE_SESSION_ID,
WEBSITE_PAGEVIEWS.pageview_url,
WEBSITE_PAGEVIEWS.created_at as pageview_created_at,
case when pageview_url = 'products' then 1 else 0 end as product_page,
case when pageview_url = 'the-original-mr-fuzzy' then 1 else 0 end as mrfuzy_page,
case when pageview_url = 'cart' then 1 else 0 end as cart_page
FROM WEBSITE_SESSION
LEFT JOIN WEBSITE_PAGEVIEWS
    ON WEBSITE_SESSION.WEBSITE_SESSION_ID = WEBSITE_PAGEVIEWS.WEBSITE_SESSION_ID
  WHERE WEBSITE_SESSION.CREATED_AT BETWEEN '2014-01-01' AND '2014-02-01'
  AND WEBSITE_PAGEVIEWS.PAGEVIEW_URL IN ('lander-2','products','the-original-mr-fuzzy','cart')
  order by 
  WEBSITE_SESSION.WEBSITE_SESSION_ID,
 WEBSITE_PAGEVIEWS.created_at 
)
group by website_session_id
;


select * from session_level_made_it_flag_demo;

select 
count(distinct website_session_id) as sessions,
count(distinct case when PRODUCT_MADE_IT = 1 then website_session_id else null end ) as to_products,
count(distinct case when MRFUZY_MADE_IT = 1 then website_session_id else null end ) as to_MRFUZY_MADE_IT,
count(distinct case when CART_MADE_IT = 1 then website_session_id else null end ) as to_CART_MADE_IT
from session_level_made_it_flag_demo;


select 
count(distinct website_session_id) as sessions,
count(distinct case when PRODUCT_MADE_IT = 1 then website_session_id else null end ) 
/ count(distinct website_session_id) as to_products_rate,
count(distinct case when MRFUZY_MADE_IT = 1 then website_session_id else null end ) 
/ count(distinct case when PRODUCT_MADE_IT = 1 then website_session_id else null end ) as to_MRFUZY_MADE_IT_rate,
count(distinct case when CART_MADE_IT = 1 then website_session_id else null end ) 
/ count(distinct case when MRFUZY_MADE_IT = 1 then website_session_id else null end ) as to_CART_MADE_IT_rate
from session_level_made_it_flag_demo;




------------------------------------- assignment--------------------

create temporary table session_level_made as 
SELECT 
website_session_id,
max(product_page) as product_made_it,
max(mrfuzy_page) as mrfuzy_made_it,
max(cart_page) as cart_made_it,
max(shipping_page) as shipping_it,
max(billing_page) as bill_it,
max(thankU_page) as thanku_it
FROM (
SELECT 
WEBSITE_SESSION.WEBSITE_SESSION_ID,
WEBSITE_PAGEVIEWS.pageview_url,
WEBSITE_PAGEVIEWS.created_at as pageview_created_at,
case when pageview_url = 'products' then 1 else 0 end as product_page,
case when pageview_url = 'the-original-mr-fuzzy' then 1 else 0 end as mrfuzy_page,
case when pageview_url = 'cart' then 1 else 0 end as cart_page,
case when pageview_url = 'shipping' then 1 else 0 end as shipping_page,
case when pageview_url = 'billing' then 1 else 0 end as billing_page,
case when pageview_url = 'thank-you-for-your-order' then 1 else 0 end as thankU_page
FROM WEBSITE_SESSION
LEFT JOIN WEBSITE_PAGEVIEWS
    ON WEBSITE_SESSION.WEBSITE_SESSION_ID = WEBSITE_PAGEVIEWS.WEBSITE_SESSION_ID
  WHERE 
         WEBSITE_SESSION.created_at > '2012-08-05'
        and WEBSITE_SESSION.created_at< '2012-09-05'
        and WEBSITE_SESSION.utm_source = 'gsearch'
        and WEBSITE_SESSION.utm_campaign = 'nonbrand'
 ORDER BY
  WEBSITE_SESSION.WEBSITE_SESSION_ID,
 WEBSITE_PAGEVIEWS.created_at 
) as session_level_group_as_pagwview
group by 
website_session_id
;


select 
count(distinct website_session_id) as sessions,
count(distinct case when PRODUCT_MADE_IT = 1 then website_session_id else null end ) as to_products,
count(distinct case when MRFUZY_MADE_IT = 1 then website_session_id else null end ) as to_MRFUZY_MADE_IT,
count(distinct case when CART_MADE_IT = 1 then website_session_id else null end ) as to_CART_MADE_IT,
count(distinct case when SHIPPING_IT = 1 then website_session_id else null end ) as to_shipping,
count(distinct case when BILL_IT = 1 then website_session_id else null end ) as to_billing,
count(distinct case when THANKU_IT = 1 then website_session_id else null end ) as to_thank_u
from session_level_made;


select 
count(distinct website_session_id) as sessions,
count(distinct case when PRODUCT_MADE_IT = 1 then website_session_id else null end )/count(distinct website_session_id)
as to_products_rate,
count(distinct case when MRFUZY_MADE_IT = 1 then website_session_id else null end )
/count(distinct case when PRODUCT_MADE_IT = 1 then website_session_id else null end ) as to_MRFUZY_MADE_IT_rate,
count(distinct case when CART_MADE_IT = 1 then website_session_id else null end )
/count(distinct case when MRFUZY_MADE_IT = 1 then website_session_id else null end ) as to_CART_MADE_IT,
count(distinct case when SHIPPING_IT = 1 then website_session_id else null end ) 
/count(distinct case when CART_MADE_IT = 1 then website_session_id else null end ) as to_shipping,
count(distinct case when BILL_IT = 1 then website_session_id else null end ) 
/count(distinct case when SHIPPING_IT = 1 then website_session_id else null end ) as to_billing,
count(distinct case when THANKU_IT = 1 then website_session_id else null end )
/count(distinct case when BILL_IT = 1 then website_session_id else null end )  as to_thank_u
from session_level_made;

-------------------------------------------------------------

SELECT 
    MIN(website_pageviews.website_pageview_id) as first_pv_id
    from website_pageviews
    where pageview_url = 'billing-2';
    
    ---- first_pv_id = 53550
    
 SELECT 
 BILLING_VERSION_SEEN,
 count(distinct website_session_id) as session,
 count(distinct order_id) as orders,
 count(distinct order_id)/count(distinct website_session_id) as billing_to_order
 From(
SELECT 
    WEBSITE_PAGEVIEWS.WEBSITE_SESSION_ID,
    WEBSITE_PAGEVIEWS.PAGEVIEW_URL AS BILLING_VERSION_SEEN,
    ORDERS.ORDER_ID
 FROM WEBSITE_PAGEVIEWS
 LEFT JOIN ORDERS
 ON ORDERS.WEBSITE_SESSION_ID = WEBSITE_PAGEVIEWS.WEBSITE_SESSION_ID
 WHERE WEBSITE_PAGEVIEWS.WEBSITE_PAGEVIEW_ID >= 53550
 AND WEBSITE_PAGEVIEWS.CREATED_AT < '2012-11-10'
 AND WEBSITE_PAGEVIEWS.PAGEVIEW_URL IN ('billing','billing-2')

) as billing_sessions_w_orders
group by
BILLING_VERSION_SEEN;

