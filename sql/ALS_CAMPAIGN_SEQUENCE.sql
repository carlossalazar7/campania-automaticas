--DROP SEQUENCE SIMAC.ALS_CAMPAIGN_SEQUENCE;

CREATE SEQUENCE SIMAC.ALS_CAMPAIGN_SEQUENCE
  START WITH 1
  MAXVALUE 9999999999999999999999999999
  MINVALUE 1
  NOCYCLE
  CACHE 20
  NOORDER;


GRANT SELECT ON SIMAC.ALS_CAMPAIGN_SEQUENCE TO SUNNEL;