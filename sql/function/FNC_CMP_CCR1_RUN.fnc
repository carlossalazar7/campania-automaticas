CREATE OR REPLACE FUNCTION       FNC_CMP_CCR1_RUN
RETURN VARCHAR2
IS
v_cadena VARCHAR2(300);


BEGIN
    
       execute immediate 'truncate table T_CMP_INACTIVITY_INITIAL';
    PKG_CMP_INACTIVITY_INITIAL.MAIN;  
    execute immediate 'truncate table als_cmp_invative_ccr1_stg';-- solo para pruebas 
    insert into als_cmp_invative_ccr1_stg
    select als_cmp_notif_approv_stg_seq.nextval notification_id,
     notification_campaign campaign_id, id_notification id_setup, 
     tcr.aliasname,tcr.email,acn.notification_string,tcr.process_id, 'P' status, sysdate,sysdate
    from ALS_CAMPAIGN_NOTIFIC_INAC_ONE  acn, als_campaign ac, T_CMP_INACTIVITY_INITIAL tcr
    where ac.id_campaign = acn.notification_campaign
    and decode(tcr.productid,10020,'PRISMA MODA','CREDISIMAN') = acn.notification_string
    and tcr.inactive_count_days = acn.notification_date_buy;
      
    v_cadena := 'Procedimiento ejecutado satisfactoriamente';
    RETURN v_cadena;
 


END;

/