--DROP TABLE SIMAC.T_CMP_CARD_DENIED_COND CASCADE CONSTRAINTS;
CREATE TABLE SIMAC.T_CMP_CARD_DENIED_COND
(
  PROCESS_ID              NUMBER(12),
  APPLICATIONID           NUMBER(12),
  LASTSTATUSDATE          DATE,
  CUSTOMERID              NUMBER(12),
  ALIASNAME               VARCHAR2(100 BYTE),
  EMAIL                   VARCHAR2(100 BYTE),
  PHONENUMBER             VARCHAR2(30 BYTE),
  PRODUCTID               NUMBER(12),
  PRODUCT_DESC            VARCHAR2(100 BYTE),
  LAST_STATUS_COUNT_DAYS  NUMBER(12),
  STATUS                  VARCHAR2(1 BYTE),
  COND_REASON             VARCHAR2(200 BYTE)
);