CREATE OR REPLACE FUNCTION       FNC_CMP_NOT_DELIVERED_RUN
   RETURN VARCHAR2
IS
   v_cadena   VARCHAR2 (300);
BEGIN
   EXECUTE IMMEDIATE 'truncate table T_CMP_CARD_NOT_DELIVERED';

   pkg_cmp_card_not_delivered.MAIN;

   EXECUTE IMMEDIATE 'truncate table als_cmp_notif_approv_stg';

   INSERT INTO als_cmp_notif_approv_stg
      SELECT als_cmp_notif_approv_stg_seq.NEXTVAL notification_id,
             notification_campaign campaign_id,
             id_notification_aprov id_setup,
             tcr.aliasname,
             tcr.email,
             acn.notification_string,
             acn.NOTIFICATION_AUTHORIZATION,
             tcr.process_id,
             'P' status,
             SYSDATE,
             SYSDATE
        FROM ALS_CAMPAIGN_NOTIFIC_APROV acn,
             als_campaign ac,
             T_CMP_CARD_NOT_DELIVERED tcr
       WHERE     ac.id_campaign = acn.notification_campaign
             AND DECODE (tcr.productid, 10020, 'PRISMA MODA', 'CREDISIMAN') =
                    acn.notification_string
             AND tcr.AUTHORIZATION_COUNT_DAYS =
                    acn.NOTIFICATION_AUTHORIZATION;

   v_cadena := 'Procedimiento ejecutado satisfactoriamente';
   RETURN v_cadena;
END;

/