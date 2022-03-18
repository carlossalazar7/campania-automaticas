/* Formatted on 17/3/2022 18:07:21 (QP5 v5.215.12089.38647) */
CREATE OR REPLACE FUNCTION SIMAC.FNC_CMP_CCR1_RUN
   RETURN VARCHAR2
IS
   v_cadena   VARCHAR2 (300);
BEGIN
   EXECUTE IMMEDIATE 'truncate table T_CMP_INACTIVITY_INITIAL';

   PKG_CMP_INACTIVITY_INITIAL.MAIN;

   --execute immediate 'truncate table als_cmp_invative_ccr1_stg';-- solo para pruebas
   INSERT INTO als_cmp_invative_ccr1_stg
      SELECT als_cmp_notif_approv_stg_seq.NEXTVAL notification_id,
             notification_campaign campaign_id,
             id_notification id_setup,
             tcr.aliasname,
             tcr.email,
             acn.notification_string,
             tcr.process_id,
             'P' status,
             SYSDATE,
             SYSDATE
        FROM ALS_CAMPAIGN_NOTIFIC_INAC_ONE acn,
             als_campaign ac,
             T_CMP_INACTIVITY_INITIAL tcr
       WHERE     ac.id_campaign = acn.notification_campaign
             AND DECODE (tcr.productid, 10020, 'PRISMA MODA', 'CREDISIMAN') =
                    acn.notification_string
             AND tcr.inactive_count_days = acn.notification_date_buy;

   v_cadena := 'Procedimiento ejecutado satisfactoriamente';
   RETURN v_cadena;
END;
/