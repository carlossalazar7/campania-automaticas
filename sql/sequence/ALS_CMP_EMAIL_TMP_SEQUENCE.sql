--DROP SEQUENCE SIMAC.ALS_CMP_EMAIL_TMP_SEQUENCE;

CREATE SEQUENCE SIMAC.ALS_CMP_EMAIL_TMP_SEQUENCE
  START WITH 121
  MAXVALUE 9999999999999999999999999999
  MINVALUE 1
  NOCYCLE
  CACHE 20
  NOORDER;


GRANT SELECT ON SIMAC.ALS_CMP_EMAIL_TMP_SEQUENCE TO SUNNEL;
