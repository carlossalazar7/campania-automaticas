/* Formatted on 17/3/2022 18:10:56 (QP5 v5.215.12089.38647) */
CREATE OR REPLACE FUNCTION SIMAC.FNC_CMP_SEGUIMIENTO_RUN
   RETURN VARCHAR2
IS
   v_cadena   VARCHAR2 (300);
BEGIN
   EXECUTE IMMEDIATE 'truncate table t_cmp_requirement';

   PKG_CMP_REQUIREMENT.MAIN;

   --EXECUTE IMMEDIATE 'truncate table als_seguimiento_stg'; -- solo para pruebas

   INSERT INTO als_seguimiento_stg
      SELECT notification_campaign campaign_id,
             id_notification,
             tcr.aliasname,
             tcr.email,
             tcr.customerrequirementid,
             acn.notification_string,
             DECODE (tcr.status,
                     'PROCESS', 'En Proceso',
                     'APPROVED', 'Aprobado',
                     'DECLINED', 'Denegado')
                status,
             tcr.stage,
             als_seguimiento_stg_seq.NEXTVAL notification_id,
             tcr.process_id,
             'P' status,
             SYSDATE,
             SYSDATE
        FROM ALS_CAMPAIGN_NOTIFICATION acn,
             (SELECT 'I' frequency, 'EVALUATION' STAGE, 'PROCESS' STATUS
                FROM DUAL
              UNION ALL
              SELECT 'C' frequency, 'AUTHORIZATION' STAGE, 'APPROVED' STATUS
                FROM DUAL
              UNION ALL
              SELECT 'C' frequency, 'AUTHORIZATION' STAGE, 'DECLINED' STATUS
                FROM DUAL) frq,
             als_campaign ac,
             t_cmp_requirement tcr
       WHERE     acn.notification_frequency = frq.frequency
             AND ac.id_campaign = acn.notification_campaign
             AND DECODE (tcr.productid, 10020, 'PRISMA MODA', 'CREDISIMAN') =
                    acn.notification_string
             AND tcr.stage = frq.stage
             AND tcr.status = frq.status;

   v_cadena := 'Procedimiento ejecutado satisfactoriamente';
   RETURN v_cadena;
END;
/