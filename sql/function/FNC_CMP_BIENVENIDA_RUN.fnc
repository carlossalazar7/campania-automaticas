CREATE OR REPLACE FUNCTION SIMAC.FNC_CMP_BIENVENIDA_RUN
RETURN VARCHAR2
IS
v_cadena VARCHAR2(300);


BEGIN
    
       execute immediate 'truncate table T_CMP_BIENVENIDA';
    PKG_CMP_BIENVENIDA.MAIN;  
    --execute immediate 'truncate table als_cmp_welcome_stg'; --solo para pruebas
    insert into als_cmp_welcome_stg
    select als_cmp_notif_approv_stg_seq.nextval notification_id,
     notification_campaign campaign_id, id_notification id_setup, 
     tcr.aliasname,tcr.email,acn.notification_string,tcr.process_id, 'P' status, sysdate,sysdate
    from ALS_CAMPAIGN_BIENVENIDA  acn, als_campaign ac, T_CMP_BIENVENIDA tcr
    where ac.id_campaign = acn.notification_campaign
    and decode(tcr.productid,10020,'PRISMA MODA','CREDISIMAN') = acn.notification_string;
      
    v_cadena := 'Procedimiento ejecutado satisfactoriamente';
    RETURN v_cadena;
 


END;
/