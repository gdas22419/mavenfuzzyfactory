CREATE DATABASE Maven_Fuzzy_Factory;

USE database Maven_Fuzzy_Factory;

DROP  TABLE WEBSITE_PAGEVIEWS
;
CREATE TABLE WEBSITE_PAGEVIEWS
(
website_pageview_id BIGINT AUTOINCREMENT  ,
  created_at DATE,
  website_session_id BIGINT  PRIMARY KEY ,
  pageview_url VARCHAR(255)
);


CREATE TABLE ORDERS
(
ORDER_ID BIGINT unique ,
  CREATE_AT DATE,
  WEBSITE_SESSION_ID BIGINT primary key ,
  USER_ID BIGINT ,
  PRIMARY_PRODUCT_ID INT unique ,
  ITEM_PURCHASED INT,
  PRICE_USED DECIMAL(6,2),
  COGS_USED DECIMAL(6,2)
);

CREATE TABLE WEBSITE_SESSION
(
WEBSITE_SESSION_ID BIGINT,
  CREATED_AT DATE,
  USER_ID BIGINT,
  IS_REPEATE_SESSION int,
  UTM_SOURCE VARCHAR(45),
  UTM_CAMPAIGN VARCHAR(45),
  UTM_CONTENT VARCHAR(45),
  DEVICE_TYPE VARCHAR(45),
  http_referer varchar(45),
  foreign key (WEBSITE_SESSION_ID) references WEBSITE_PAGEVIEWS (WEBSITE_SESSION_ID),
    foreign key(WEBSITE_SESSION_ID) references ORDERS(WEBSITE_SESSION_ID)
);

CREATE TABLE PRODUCTS
(
PRODUCT_ID INT unique,
  CREATED_AT DATE,
  PRODUCT_NAME VARCHAR(45),
  FOREIGN KEY (PRODUCT_ID) references ORDERS (PRIMARY_PRODUCT_ID)
);


CREATE TABLE ORDER_ITEMS 
(
order_item_id BIGINT unique primary key,
crated_at date,
order_id bigint,
  product_id int,
  is_primary_item int,
  price_used Decimal(6,2),
  cogs_used Decimal(6,2),
  FOREIGN KEY (PRODUCT_ID) references PRODUCTS (PRODUCT_ID),
    FOREIGN KEY (order_id) references ORDERS(order_id)

);


create table order_item_refund
(
order_id_item_refund_id bigint,
  created_at datetime,
  order_item_id bigint,
  order_id bigint,
  refund_amount_used decimal(6,2),
  FOREIGN KEY (order_item_id) references ORDER_ITEMS(order_item_id),
  FOREIGN KEY (order_id) references ORDERS(order_id)
)