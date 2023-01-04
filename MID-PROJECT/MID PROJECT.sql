----GSEARCH SEEMS TO BE THE BIGGEST DRIVER OPF OUR BUSINESS .
--- PULL MONTHLY TERENDS THE GSEARCH SESSION AND ORDERS SO THAT WE CAN SHOWCASE THE GROWTH THERE. 

USE DATABASE Maven_Fuzzy_Factory;

SELECT 
YEAR(WEBSITE_SESSION.CREATED_AT) AS YEAR,
MONTHNAME(WEBSITE_SESSION.CREATED_AT) AS MONTH,
COUNT( DISTINCT WEBSITE_SESSION.WEBSITE_SESSION_ID),
COUNT(DISTINCT ORDERS.ORDER_ID)
FROM WEBSITE_SESSION
LEFT JOIN ORDERS
ON WEBSITE_SESSION.WEBSITE_SESSION_ID=ORDERS.WEBSITE_SESSION_ID
WHERE WEBSITE_SESSION.UTM_SOURCE='gsearch'
AND WEBSITE_SESSION.CREATED_AT <'2012-11-27'
GROUP BY 1,2       
;



----- MONTHLY TRENDS FOR GSEARCH BUT SPLIITING OUT NONBRAND AND BRAND CAMPAIGN SEPARATLY , IF BRAND IS PICKING UP 
SELECT 
YEAR(WEBSITE_SESSION.CREATED_AT) AS YEAR,
MONTHNAME(WEBSITE_SESSION.CREATED_AT) AS MONTH,
COUNT( CASE WHEN WEBSITE_SESSION.UTM_CAMPAIGN='nonbrand' THEN WEBSITE_SESSION.WEBSITE_SESSION_ID ELSE NULL END ) AS NONBRAND_SESSION,
COUNT( CASE WHEN WEBSITE_SESSION.UTM_CAMPAIGN='nonbrand' THEN ORDERS.ORDER_ID ELSE NULL END ) AS NONBRAND_ORDER,
COUNT( CASE WHEN WEBSITE_SESSION.UTM_CAMPAIGN='brand' THEN WEBSITE_SESSION.WEBSITE_SESSION_ID ELSE NULL END) AS BRAND_SESSION,
COUNT( CASE WHEN WEBSITE_SESSION.UTM_CAMPAIGN='brand' THEN ORDERS.ORDER_ID ELSE NULL END) AS BRAND_ORDERS 
FROM WEBSITE_SESSION
LEFT JOIN ORDERS
ON WEBSITE_SESSION.WEBSITE_SESSION_ID=ORDERS.WEBSITE_SESSION_ID
WHERE  WEBSITE_SESSION.UTM_SOURCE='gsearch'
AND WEBSITE_SESSION.CREATED_AT <'2012-11-27'
GROUP BY 1,2;




--- WHILE ON GSEARCH DIVE IN TO NONBRAND AND PULL MONTHLY SESSION MONTHLY SESSION AND ORDERS SPLITS BY DEVICE TYPE ALSO 
---SHOW THE TRAFFIC SOURCE]\
SELECT 
YEAR(WEBSITE_SESSION.CREATED_AT) AS YEAR,
MONTHNAME(WEBSITE_SESSION.CREATED_AT) AS MONTH,
COUNT(CASE WHEN WEBSITE_SESSION.DEVICE_TYPE='mobile' THEN  WEBSITE_SESSION.WEBSITE_SESSION_ID ELSE NULL END )  AS MOBIL_SESSION,
COUNT(CASE WHEN WEBSITE_SESSION.DEVICE_TYPE='mobile' THEN  ORDERS.ORDER_ID ELSE NULL END )  AS ORDER_SESSION,
COUNT(CASE WHEN WEBSITE_SESSION.DEVICE_TYPE='desktop' THEN  WEBSITE_SESSION.WEBSITE_SESSION_ID ELSE NULL END )  AS DESKTOP_SESSION,
COUNT(CASE WHEN WEBSITE_SESSION.DEVICE_TYPE='desktop' THEN  ORDERS.ORDER_ID ELSE NULL END )  AS DESKTOP_ORDER
FROM WEBSITE_SESSION
LEFT JOIN  ORDERS
on ORDERS.WEBSITE_SESSION_ID=WEBSITE_SESSION.WEBSITE_SESSION_ID
WHERE  WEBSITE_SESSION.UTM_SOURCE='gsearch'
AND WEBSITE_SESSION.CREATED_AT <'2012-11-27'
GROUP BY 
1,2;



SELECT UTM_SOURCE,count(WEBSITE_SESSION_ID) FROM WEBSITE_SESSION
WHERE  
 WEBSITE_SESSION.CREATED_AT <'2012-11-27'
group by UTM_SOURCE ;


--- MONTHLY TRENDS FOR GSEARCH AND ALONG SIDE MONTHLY TRENDS FOR EACH OF OUR OTHERE CHANEL
SELECT 
YEAR(WEBSITE_SESSION.CREATED_AT) AS YEAR,
MONTHNAME(WEBSITE_SESSION.CREATED_AT) AS MONTH,
COUNT(CASE WHEN WEBSITE_SESSION.UTM_SOURCE='gsearch' THEN  WEBSITE_SESSION.WEBSITE_SESSION_ID ELSE NULL END )  AS gsearch_SESSION,

COUNT(CASE WHEN WEBSITE_SESSION.UTM_SOURCE='bsearch' THEN  WEBSITE_SESSION.WEBSITE_SESSION_ID ELSE NULL END )  AS bseacrh_SESSION,


COUNT(CASE WHEN WEBSITE_SESSION.UTM_SOURCE is NULL and HTTP_REFERER IS NOT NULL THEN  WEBSITE_SESSION.WEBSITE_SESSION_ID ELSE NULL END )
AS DIRECT_null_SESSION,
COUNT(CASE WHEN WEBSITE_SESSION.UTM_SOURCE IS NULL AND HTTP_REFERER IS NULL THEN  ORDERS.ORDER_ID ELSE NULL END )  AS INDTRECT_null_ORDER
FROM WEBSITE_SESSION
LEFT JOIN  ORDERS
on ORDERS.WEBSITE_SESSION_ID=WEBSITE_SESSION.WEBSITE_SESSION_ID
WHERE  
 WEBSITE_SESSION.CREATED_AT <'2012-11-27'
GROUP BY 
1,2;


---SESSION TO ORDER CONVERSION , BY MONTH

SELECT 
YEAR(WEBSITE_SESSION.CREATED_AT) AS YEAR,
MONTHNAME(WEBSITE_SESSION.CREATED_AT) AS MONTH,
COUNT( DISTINCT WEBSITE_SESSION.WEBSITE_SESSION_ID)AS  SESSION,
COUNT(DISTINCT ORDERS.ORDER_ID) AS ORDERS,
COUNT(DISTINCT ORDERS.ORDER_ID)/COUNT( DISTINCT WEBSITE_SESSION.WEBSITE_SESSION_ID) AS CONVERSION_RATE
FROM WEBSITE_SESSION
LEFT JOIN ORDERS
ON WEBSITE_SESSION.WEBSITE_SESSION_ID=ORDERS.WEBSITE_SESSION_ID
WHERE WEBSITE_SESSION.UTM_SOURCE='gsearch'
AND WEBSITE_SESSION.CREATED_AT <'2012-11-27'
GROUP BY 1,2       
;


-----ESTIMATE THE REVENUE THAT TEST EARNED US (LOOK AT THE INCREASE IN CVR FROM JUNE 19 TO JUL28 ANSD USE NON BRAND SESSION AND 
---REVENUE SESSION  THEN TO CALCULATE THE INCREAMENTALL VALUE )

SELECT 
min(WEBSITE_PAGEVIEW_ID) as first_test_pv
FROM WEBSITE_PAGEVIEWS
WHERE PAGEVIEW_URL = 'lander-1';

--- 23504

--- for this step we'll find the first pageview_id
CREATE TEMPORARY TABLE first_test_pageviews AS 
SELECT 
WEBSITE_PAGEVIEWS.WEBSITE_SESSION_ID,
MIN(WEBSITE_PAGEVIEWS.WEBSITE_PAGEVIEW_ID) AS MIN_PAGEVIEW_ID
FROM WEBSITE_PAGEVIEWS
INNER JOIN WEBSITE_SESSION  
ON WEBSITE_PAGEVIEWS.WEBSITE_SESSION_ID=WEBSITE_SESSION.WEBSITE_SESSION_ID
AND WEBSITE_SESSION.CREATED_AT <'2012-07-28'
AND WEBSITE_PAGEVIEWS.WEBSITE_PAGEVIEW_ID>=23504
AND UTM_SOURCE = 'gsearch'
AND utm_campaign= 'nonbrand'
group by WEBSITE_PAGEVIEWS.WEBSITE_SESSION_ID;

CREATE TEMPORARY TABLE nonbrand_test_sessions_w_landing_pages as 
SELECT 
first_test_pageviews.website_session_id,
WEBSITE_PAGEVIEWS.pageview_url as landing_page
FROM first_test_pageviews
LEFT JOIN WEBSITE_PAGEVIEWS
ON WEBSITE_PAGEVIEWS.WEBSITE_PAGEVIEW_ID = first_test_pageviews.MIN_PAGEVIEW_ID
WHERE WEBSITE_PAGEVIEWS.PAGEVIEW_URL IN ('home','lander-1');

CREATE TEMPORARY TABLE  nonbrand_test_sessions_w_orders AS
SELECT 
nonbrand_test_sessions_w_landing_pages.website_session_id,
nonbrand_test_sessions_w_landing_pages.landing_page,
orders.order_id
FROM  nonbrand_test_sessions_w_landing_pages
left join orders 
on orders.website_session_id = nonbrand_test_sessions_w_landing_pages.website_session_id

;

SELECT 
landing_page,
COUNT(DISTINCT website_session_id ) AS SESSION,
COUNT(DISTINCT order_id) AS ORDERS,
COUNT(DISTINCT order_id)/COUNT(DISTINCT website_session_id ) AS CONV_RATE  
FROM nonbrand_test_sessions_w_orders
GROUP BY 1;

-- finding the most reent pageview for gsearch nonbrand where the traffic was sent to /home

SELECT 
MAX(WEBSITE_SESSION.website_session_id) AS most_recent_gsearch_nonbrand_home_pageview 
from WEBSITE_SESSION
LEFT JOIN WEBSITE_PAGEVIEWS
ON WEBSITE_SESSION.website_session_id = WEBSITE_PAGEVIEWS.website_session_id
WHERE utm_source = 'gsearch'
	AND utm_campaign = 'nonbrand'
    AND pageview_url = 'home'
    AND website_session.created_at < '2012-11-27'
;
-- max website_session_id = 17145

SELECT 
	COUNT(website_session_id) AS sessions_since_test
FROM website_session
WHERE created_at < '2012-11-27'
	AND website_session_id > 17145 -- last /home session
	AND utm_source = 'gsearch'
	AND utm_campaign = 'nonbrand'
;

-- 22,972 website sessions since the test

/*
7.	For the landing page test you analyzed previously, it would be great to show a full conversion funnel 
from each of the two pages to orders. You can use the same time period you analyzed last time (Jun 19 – Jul 28).
*/ 
CREATE TEMPORARY TABLE session_level_made_it_flagged as
SELECT
	website_session_id, 
    MAX(homepage) AS saw_homepage, 
    MAX(lander_page) AS saw_custom_lander,
    MAX(products_page) AS product_made_it, 
    MAX(mr_fuzzy_page) AS mrfuzzy_made_it, 
    MAX(cart_page) AS cart_made_it,
    MAX(shipping_page) AS shipping_made_it,
    MAX(billing_page) AS billing_made_it,
    MAX(tahnku_page) AS thankyou_made_it
FROM(
SELECT 
WEBSITE_SESSION.WEBSITE_SESSION_id ,
WEBSITE_PAGEVIEWS.PAGEVIEW_URL,
CASE WHEN PAGEVIEW_URL = 'home' THEN 1 ELSE 0  END AS HOMEPAGE,
CASE WHEN PAGEVIEW_URL = 'lander-1' THEN 1 ELSE 0  END AS lander_page,
CASE WHEN PAGEVIEW_URL = 'products' THEN 1 ELSE 0  END AS products_page,
CASE WHEN PAGEVIEW_URL = 'the-original-mr-fuzzy' THEN 1 ELSE 0  END AS mr_fuzzy_page,
CASE WHEN PAGEVIEW_URL = 'cart' THEN 1 ELSE 0  END AS cart_page,
CASE WHEN PAGEVIEW_URL = 'shipping' THEN 1 ELSE 0  END AS shipping_page,
CASE WHEN PAGEVIEW_URL = 'billing' THEN 1 ELSE 0  END AS billing_page,
CASE WHEN PAGEVIEW_URL = 'thank-you-for-your-order' THEN 1 ELSE 0  END AS tahnku_page
FROM WEBSITE_SESSION
LEFT JOIN WEBSITE_PAGEVIEWS
ON WEBSITE_SESSION.WEBSITE_SESSION_id=WEBSITE_PAGEVIEWS.WEBSITE_SESSION_id
WHERE WEBSITE_SESSION.UTM_SOURCE='gsearch'
AND WEBSITE_SESSION.UTM_CAMPAIGN ='nonbrand'
AND website_session.created_at < '2012-07-28'
AND website_session.created_at > '2012-06-19'
ORDER BY 
website_session.website_session_id,
    website_pageviews.created_at )AS pageview_level

GROUP BY 
	website_session_id
;


SELECT
	CASE 
		WHEN saw_homepage = 1 THEN 'saw_homepage'
        WHEN saw_custom_lander = 1 THEN 'saw_custom_lander'
        ELSE 'uh oh... check logic' 
	END AS segment, 
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END) AS to_products,
    COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) AS to_mrfuzzy,
    COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) AS to_cart,
    COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) AS to_shipping,
    COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) AS to_billing,
    COUNT(DISTINCT CASE WHEN thankyou_made_it = 1 THEN website_session_id ELSE NULL END) AS to_thankyou
FROM session_level_made_it_flagged 
GROUP BY 1
;


SELECT
	CASE 
		WHEN saw_homepage = 1 THEN 'saw_homepage'
        WHEN saw_custom_lander = 1 THEN 'saw_custom_lander'
        ELSE 'uh oh... check logic' 
	END AS segment, 
	COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id) AS lander_click_rt,
    COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END) AS products_click_rt,
    COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) AS mrfuzzy_click_rt,
    COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) AS cart_click_rt,
    COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) AS shipping_click_rt,
    COUNT(DISTINCT CASE WHEN thankyou_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) AS billing_click_rt
FROM session_level_made_it_flagged
GROUP BY 1
;



/*
8.	I’d love for you to quantify the impact of our billing test, as well. Please analyze the lift generated 
from the test (Sep 10 – Nov 10), in terms of revenue per billing page session, and then pull the number 
of billing page sessions for the past month to understand monthly impact.
*/ 
SELECT
	billing_version_seen, 
    COUNT(DISTINCT website_session_id) AS sessions, 
    SUM(price_used)/COUNT(DISTINCT website_session_id) AS revenue_per_billing_page_seen
 FROM( 
SELECT 
	website_pageviews.website_session_id, 
    website_pageviews.pageview_url AS billing_version_seen, 
    orders.order_id, 
    orders.price_used
FROM website_pageviews 
	LEFT JOIN orders
		ON orders.website_session_id = website_pageviews.website_session_id
WHERE website_pageviews.created_at > '2012-09-10' -- prescribed in assignment
	AND website_pageviews.created_at < '2012-11-10' -- prescribed in assignment
    AND website_pageviews.pageview_url IN ('billing','billing-2')
) AS billing_pageviews_and_order_data
GROUP BY 1
;

SELECT 
	COUNT(website_session_id) AS billing_sessions_past_month
FROM website_pageviews 
WHERE website_pageviews.pageview_url IN ('billing','billing-2') 
	AND created_at BETWEEN '2012-10-27' AND '2012-11-27';