/* Formatted on 17/3/2022 18:09:06 (QP5 v5.215.12089.38647) */
CREATE OR REPLACE FUNCTION SIMAC.FNC_CMP_DEN_COND_RUN
   RETURN VARCHAR2
IS
   v_cadena   VARCHAR2 (300);
BEGIN
   EXECUTE IMMEDIATE 'truncate table T_CMP_CARD_DENIED_COND';

   PKG_CMP_CARD_DENIED_COND.MAIN;

   --execute immediate 'truncate table ALS_DENIED_COND_STG '; --Solo para pruebas
   INSERT INTO ALS_DENIED_COND_STG
      SELECT notification_campaign campaign_id,
             id_notification,
             tcr.aliasname,
             tcr.email,
             tcr.applicationid,
             acn.notification_string,
             tcr.COND_REASON,
             DECODE (tcr.status, 'D', 'Denegada', 'Condicionada') status,
             NULL stage,
             als_seguimiento_stg_seq.NEXTVAL notification_id,
             tcr.process_id,
             'P' status,
             SYSDATE,
             SYSDATE
        FROM ALS_CAMPAIGN_DENE_COND acn,
             als_campaign ac,
             T_CMP_CARD_DENIED_COND tcr
       WHERE     ac.id_campaign = acn.notification_campaign
             AND DECODE (tcr.productid, 10020, 'PRISMA MODA', 'CREDISIMAN') =
                    acn.notification_string
             AND tcr.status = acn.status_indicator;

   v_cadena := 'Procedimiento ejecutado satisfactoriamente';
   RETURN v_cadena;
END;
/