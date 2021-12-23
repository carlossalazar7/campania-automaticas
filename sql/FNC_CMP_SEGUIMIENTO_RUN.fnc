CREATE OR REPLACE FUNCTION       FNC_CMP_SEGUIMIENTO_RUN
RETURN VARCHAR2
IS
v_cadena VARCHAR2(300);


BEGIN
    
    execute immediate 'truncate table t_cmp_requirement';
    PKG_CMP_REQUIREMENT.MAIN;  
    insert into als_seguimiento_stg
    select 
     notification_campaign campaign_id, id_notification, 
     tcr.aliasname,tcr.email,tcr.customerrequirementid,acn.notification_string, DECODE(tcr.status,'PROCESS','En Proceso','APPROVED','Aprobado','DECLINED','Denegado') status, tcr.stage, als_seguimiento_stg_seq.nextval notification_id, tcr.process_id, 'P' status, sysdate,sysdate
    from ALS_CAMPAIGN_NOTIFICATION acn, (
    select 'I' frequency, 'EVALUATION' STAGE, 'PROCESS' STATUS from dual
    union all
    select 'C' frequency, 'AUTHORIZATION' STAGE, 'APPROVED' STATUS from dual
    union all
    select 'C' frequency, 'AUTHORIZATION' STAGE, 'DECLINED' STATUS from dual
    ) frq, als_campaign ac, t_cmp_requirement tcr
    where acn.notification_frequency = frq.frequency
    and ac.id_campaign = acn.notification_campaign
    and decode(tcr.productid,10020,'PRISMA MODA','CREDISIMAN') = acn.notification_string
    and tcr.stage = frq.stage
    and tcr.status = frq.status;  
    v_cadena := 'Procedimiento ejecutado satisfactoriamente';
    RETURN v_cadena;
 


END;

/