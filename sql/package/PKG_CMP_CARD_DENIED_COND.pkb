CREATE OR REPLACE package body PKG_CMP_CARD_DENIED_COND as

    procedure cards_denied(p_process_id number, p_status varchar2, p_days number) as
        CURSOR c_inputdata IS
            select 
                ap.applicationid,
                ap.laststatusdate,
                cus.customerid,
                cus.aliasname,
                (select card.cardid 
                    from t_gcard card 
                    where card.customerid = cus.customerid and closedind='F' and deliveredind='T' 
                    and lostcardind='F' and activationdate is not null
                    and card.productid in (select column_value from table(simac.pkg_cmp_common.get_parameter_as_list('CREDIT_PRODUCT_IDS')))
                    and rownum = 1
                ) as cardid,
                ap.productid,
                prod.description as product_desc
            from T_GAPPLICATION ap
            --join T_GCARD card on ap.cardid = card.cardid
            join T_GPRODUCT prod on prod.productid = ap.productid
            join T_GCUSTOMER cus on cus.customerid = ap.customerid
            where ap.laststatusdate = trunc(g_date - p_days)
            and ap.productid in (select column_value from table(pkg_cmp_common.get_parameter_as_list('CREDIT_PRODUCT_IDS')))
            and ap.status = p_status
            ;
        TYPE tbl_inputdata IS TABLE OF c_inputdata%ROWTYPE;
        row_inputdata tbl_inputdata;
        v_email varchar2(100);
        v_phone varchar2(100);
    begin
        dbms_output.put_line('---------------------- cards_denied - Status:'|| p_status ||' - Days:'|| p_days ||' -  start ----------------------');
        OPEN c_inputdata;
        FETCH c_inputdata BULK COLLECT INTO row_inputdata LIMIT 5000;
        FOR i IN 1 .. row_inputdata.COUNT 
        LOOP
            dbms_output.put_line(row_inputdata(i).applicationid || ' - ' || row_inputdata(i).aliasname);
            v_email := pkg_cmp_common.get_email(row_inputdata(i).customerid, null);
            if v_email is null then
                v_email := pkg_cmp_common.get_email(null, row_inputdata(i).cardid);
            end if;
            v_phone := pkg_cmp_common.get_cellphone(row_inputdata(i).customerid);
            INSERT INTO T_CMP_CARD_DENIED_COND (
                process_id,
                applicationid,
                laststatusdate,
                last_status_count_days,
                status,
                customerid,
                aliasname,
                email,
                phonenumber,
                productid,
                product_desc
            ) VALUES (
                p_process_id,
                row_inputdata(i).applicationid,
                row_inputdata(i).laststatusdate,
                p_days,
                p_status,
                row_inputdata(i).customerid,
                row_inputdata(i).aliasname,
                v_email,
                v_phone,
                row_inputdata(i).productid,
                row_inputdata(i).product_desc
            );
        END LOOP;
        commit;
        dbms_output.put_line('cards_denied - Status:'|| p_status ||' - Days:'|| p_days ||' - end');    
    end;
    
    
    
    
    
    procedure cards_conditioned(p_process_id number, p_days number) as
        CURSOR c_inputdata IS
            select 
                ap.applicationid,
                rj.CONDITIONDATE,
                cus.customerid,
                cus.aliasname,
                (select card.cardid 
                    from t_gcard card 
                    where card.customerid = cus.customerid and closedind='F' and deliveredind='T' 
                    and lostcardind='F' and activationdate is not null
                    and card.productid in (select column_value from table(simac.pkg_cmp_common.get_parameter_as_list('CREDIT_PRODUCT_IDS')))
                    and rownum = 1
                ) as cardid,
                ap.productid,
                prod.description as product_desc,
                ap.status,
                APV.DESCRIPTION as cond_reason
            from T_GAPPLICATION ap
            --join T_GCARD card on ap.cardid = card.cardid
            join T_GPRODUCT prod on prod.productid = ap.productid
            join T_GCUSTOMER cus on cus.customerid = ap.customerid
            join T_GAPPLICATIONCONDITIONCODE rj on rj.APPLICATIONID = ap.APPLICATIONID
            join T_GAPPROVALCONDREASONCODE apv on APV.APPROVALCONDREASONCODEID = RJ.APPROVALCONDREASONCODEID            
            where rj.CONDITIONDATE = trunc(g_date - p_days)
            and ap.productid in (select column_value from table(pkg_cmp_common.get_parameter_as_list('CREDIT_PRODUCT_IDS')))
            and ap.status not in ('I','D')
            and exists(
                select 1 from T_GPERSONALCARDAPPLICATION ap2 where ap2.applicationid = ap.applicationid and conditionind='T'
                union all
                select 1 from T_GPROTECTEDCARDAPPLICATION ap2 where ap2.applicationid = ap.applicationid and conditionind='T'
                union all
                select 1 from T_GCORPORATECARDAPPLICATION ap2 where ap2.applicationid = ap.applicationid and conditionind='T'
            )
            ;
        TYPE tbl_inputdata IS TABLE OF c_inputdata%ROWTYPE;
        row_inputdata tbl_inputdata;
        v_email varchar2(100);
        v_phone varchar2(100);
    begin
        dbms_output.put_line('---------------------- cards_conditioned - Days:'|| p_days ||' -  start ----------------------');
        OPEN c_inputdata;
        FETCH c_inputdata BULK COLLECT INTO row_inputdata LIMIT 5000;
        FOR i IN 1 .. row_inputdata.COUNT 
        LOOP
            dbms_output.put_line(row_inputdata(i).applicationid || ' - ' || row_inputdata(i).aliasname);
            v_email := pkg_cmp_common.get_email(row_inputdata(i).customerid, null);
            if v_email is null then
                v_email := pkg_cmp_common.get_email(null, row_inputdata(i).cardid);
            end if;
            v_phone := pkg_cmp_common.get_cellphone(row_inputdata(i).customerid);
            INSERT INTO T_CMP_CARD_DENIED_COND (
                process_id,
                applicationid,
                laststatusdate,
                last_status_count_days,
                status,
                customerid,
                aliasname,
                email,
                phonenumber,
                productid,
                product_desc,
                cond_reason
            ) VALUES (
                p_process_id,
                row_inputdata(i).applicationid,
                row_inputdata(i).CONDITIONDATE,
                p_days,
                'C',
                row_inputdata(i).customerid,
                row_inputdata(i).aliasname,
                v_email,
                v_phone,
                row_inputdata(i).productid,
                row_inputdata(i).product_desc,
                row_inputdata(i).cond_reason
            );
        END LOOP;
        commit;
        dbms_output.put_line('cards_conditioned - Days:'|| p_days ||' - end');    
    end;
    
    
    
    
    
    procedure load_params as
    begin
        G_DAYS_RANGE_PARAM := pkg_cmp_common.get_parameter_as_number('DAYS_RANGE_CARD_DENIED_COND');
        g_date := pkg_cmp_common.get_fecha_sunnel() - G_DAYS_RANGE_PARAM;
        dbms_output.put_line('load_params - g_date = ' || g_date);
    end;
    
    
    
    
    
    procedure main as
        cursor c_config is
            SELECT id_notification_aprov, notification_authorization 
            FROM ALS_CAMPAIGN_NOTIFIC_APROV 
            WHERE notification_string = 'CREDISIMAN' and notification_enable = 'S'; 
        TYPE tbl_config IS TABLE OF c_config%ROWTYPE;
        row_config tbl_config;
        process_id number;
    begin
        load_params();
        --OPEN c_config;
        --FETCH c_config BULK COLLECT INTO row_config;
        --FOR i IN 1 .. row_config.COUNT 
        --LOOP
        --    BEGIN
                pkg_cmp_common.insert_process(process_id, 
                      g_campaign_type, 
                      pkg_cmp_common.G_STATUS_PROCESSING,
                      g_date,
                      g_date,
                      G_DAYS_RANGE_PARAM);
                cards_denied(process_id, 'D', 1);
                cards_conditioned(process_id, 1);
                cards_conditioned(process_id, 8);
                cards_conditioned(process_id, 15);
                pkg_cmp_common.update_process(process_id, pkg_cmp_common.G_STATUS_COMPLETED);
                commit;
        --    END;
        --END LOOP;
    end main;

end PKG_CMP_CARD_DENIED_COND;

/