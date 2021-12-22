--ALTER TABLE SIMAC.ALS_CMP_NOTIF_APPROV_STG
--DROP PRIMARY KEY CASCADE;
--DROP TABLE SIMAC.ALS_CMP_NOTIF_APPROV_STG CASCADE CONSTRAINTS;

CREATE TABLE SIMAC.ALS_CMP_NOTIF_APPROV_STG
(
  NOTIFICATION_ID          NUMBER,
  ID_CAMPAIGN              NUMBER,
  ID_SETUP                 NUMBER,
  CUSTOMER_NAME            VARCHAR2(100 BYTE),
  REMIT_TO                 VARCHAR2(100 BYTE),
  PRODUCT_NAME             VARCHAR2(60 BYTE),
  AUTORIZATHION_DAY_COUNT  NUMBER,
  PROCESS_ID               NUMBER,
  PROCESS_STATUS           VARCHAR2(1 BYTE)     DEFAULT 'P',
  CREATION_DATE            DATE                 DEFAULT sysdate,
  LAST_UPDATE_DATE         DATE                 DEFAULT sysdate
);

--  There is no statement for index SIMAC.SYS_C001927247.
--  The object is created when the parent object is created.

ALTER TABLE SIMAC.ALS_CMP_NOTIF_APPROV_STG ADD (
  PRIMARY KEY
  (NOTIFICATION_ID)
);
