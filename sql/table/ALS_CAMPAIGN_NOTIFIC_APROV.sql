CREATE TABLE SIMAC.ALS_CAMPAIGN_NOTIFIC_APROV (
    ID_NOTIFICATION_APROV INTEGER NOT NULL,
    NOTIFICATION_COUNTRY VARCHAR2(100 BYTE),
    NOTIFICATION_STRING VARCHAR2(100 BYTE),
    NOTIFICATION_CAMPAIGN INTEGER NOT NULL,
    NOTIFICATION_SEQUENCE NUMBER,
    NOTIFICATION_AUTHORIZATION NUMBER,
    NOTIFICATION_ENABLE CHAR(1 BYTE),
    TEMPLATE_ID NUMBER NOT NULL
);


--ADD PRIMARY KEY  
ALTER TABLE SIMAC.ALS_CAMPAIGN_NOTIFIC_APROV
ADD (
        CONSTRAINT ID_NOTIFICATION_APROV PRIMARY KEY (ID_NOTIFICATION_APROV) 
    );

--ADD FOREIGN KEY    
ALTER TABLE SIMAC.ALS_CAMPAIGN_NOTIFIC_APROV
ADD (
        CONSTRAINT FK_CAMPAIGN_APROV FOREIGN KEY (NOTIFICATION_CAMPAIGN) REFERENCES SIMAC.ALS_CAMPAIGN (ID_CAMPAIGN) ENABLE VALIDATE,
        CONSTRAINT FK_NOTIFIC_APROV FOREIGN KEY (TEMPLATE_ID) REFERENCES SIMAC.ALS_CMP_EMAIL_TEMPLATE (TEMPLATE_ID) ENABLE VALIDATE
    );

--CREATE SEQUENCE
CREATE SEQUENCE SIMAC.ALS_CAMPAIGN_NOTIFICATION_A
  START WITH 1
  MAXVALUE 9999999999999999999999999999
  MINVALUE 1
  NOCYCLE
  CACHE 20
  NOORDER;

--CREATE TRIGGER
CREATE OR REPLACE TRIGGER SIMAC.ALS_CAMPAIGN_NOTIF_APROV BEFORE
INSERT ON SIMAC.ALS_CAMPAIGN_NOTIFIC_APROV FOR EACH ROW BEGIN
SELECT ALS_CAMPAIGN_NOTIFICATION_A.nextval INTO :new.ID_NOTIFICATION_APROV
FROM dual;
END;
/

--CREATE PUBLIC SYNONYM
CREATE OR REPLACE PUBLIC SYNONYM ALS_CAMPAIGN_NOTIFIC_APROV FOR SIMAC.ALS_CAMPAIGN_NOTIFIC_APROV;

--GRANTS
GRANT DELETE,
    INSERT,
    SELECT,
    UPDATE ON SIMAC.ALS_CAMPAIGN_NOTIFIC_APROV TO SUNNEL;
    
GRANT SELECT ON SIMAC.ALS_CAMPAIGN_NOTIFICATION_A TO SUNNEL;
