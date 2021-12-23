CREATE OR REPLACE FUNCTION       FNC_CMP_DEN_COND_RUN
RETURN VARCHAR2
IS
v_cadena VARCHAR2(300);


BEGIN
    
    execute immediate 'truncate table T_CMP_CARD_DENIED_COND';
    PKG_CMP_REQUIREMENT.MAIN;  
    execute immediate 'truncate table ALS_DENIED_COND_STG '; --Solo para pruebas
    insert into ALS_DENIED_COND_STG 
    select 
     notification_campaign campaign_id, id_notification, 
     tcr.aliasname,tcr.email,tcr.applicationid,acn.notification_string, DECODE(tcr.status,'D','Denegada','Condicionada') status,null stage,  als_seguimiento_stg_seq.nextval notification_id, tcr.process_id, 'P' status, sysdate,sysdate
    from ALS_CAMPAIGN_DENE_COND  acn, als_campaign ac, T_CMP_CARD_DENIED_COND tcr
    where ac.id_campaign = acn.notification_campaign
    and decode(tcr.productid,10020,'PRISMA MODA','CREDISIMAN') = acn.notification_string
    and tcr.status = decode(acn.status_indicator,'C','I',acn.status_indicator);  
    v_cadena := 'Procedimiento ejecutado satisfactoriamente';
    RETURN v_cadena;
 


END;

/