CREATE OR REPLACE package body       pkg_cmp_card_not_delivered as

    procedure cards_not_delivered(p_process_id number, p_days number) as
        CURSOR c_inputdata IS
               select 
                ap.applicationid,
                ap.authorizationdate,
                cus.customerid,
                cus.aliasname,
                card.cardid,
                card.productid,
                prod.description as product_desc
            from T_GAPPLICATION ap
            join T_GCARD card on ap.cardid = card.cardid
            join T_GPRODUCT prod on prod.productid = card.productid
            join T_GCARDACCOUNT acc on card.cardid = acc.cardid
            join T_GCREDITLINE cl on CL.CREDITLINEID=ACC.ACCOUNTID
            join T_GACCOUNT acu on acu.ACCOUNTID=CL.CREDITLINEID
            join T_GCUSTOMER cus on cus.customerid = card.customerid
            where ap.authorizationdate = trunc(g_date - p_days)
            and card.productid in (select column_value from table(pkg_cmp_common.get_parameter_as_list('CREDIT_PRODUCT_IDS')))
            and card.deliveredind = 'F'
            and card.deliveredtime is null
            and acu.STATEMENTDELIVERYMEDIA != 'COURRIER'
            ;
        TYPE tbl_inputdata IS TABLE OF c_inputdata%ROWTYPE;
        row_inputdata tbl_inputdata;
        v_email varchar2(100);
        v_phone varchar2(100);
    begin
        dbms_output.put_line('---------------------- cards_not_delivered - Days:'|| p_days ||' - start ----------------------');
        OPEN c_inputdata;
        FETCH c_inputdata BULK COLLECT INTO row_inputdata LIMIT 5000;
        FOR i IN 1 .. row_inputdata.COUNT 
        LOOP
            dbms_output.put_line(row_inputdata(i).applicationid || ' - ' || row_inputdata(i).aliasname);
            v_email := pkg_cmp_common.get_email(row_inputdata(i).customerid, row_inputdata(i).cardid);
            v_phone := pkg_cmp_common.get_cellphone(row_inputdata(i).customerid);
            INSERT INTO T_CMP_CARD_NOT_DELIVERED (
                process_id,
                applicationid,
                authorizationdate,
                authorization_count_days,
                customerid,
                aliasname,
                email,
                phonenumber,
                productid,
                product_desc
            ) VALUES (
                p_process_id,
                row_inputdata(i).applicationid,
                row_inputdata(i).authorizationdate,
                p_days,
                row_inputdata(i).customerid,
                row_inputdata(i).aliasname,
                v_email,
                v_phone,
                row_inputdata(i).productid,
                row_inputdata(i).product_desc
            );
        END LOOP;
        commit;
        dbms_output.put_line('cards_not_delivered - Days:'|| p_days ||' - end');    
    end;
    
    
    
    procedure load_params as
    begin
        G_DAYS_RANGE_PARAM := pkg_cmp_common.get_parameter_as_number('DAYS_RANGE_CARD_NOT_DELIVERED');
        g_date := pkg_cmp_common.get_fecha_sunnel() - G_DAYS_RANGE_PARAM;
        dbms_output.put_line('load_params - g_date = ' || g_date);
    end;
    
    
    procedure main as
        cursor c_config is
            SELECT distinct notification_authorization 
            FROM ALS_CAMPAIGN_NOTIFIC_APROV 
            WHERE notification_enable = 'S'; 
        TYPE tbl_config IS TABLE OF c_config%ROWTYPE;
        row_config tbl_config;
        process_id number;
    begin
        load_params;

        pkg_cmp_common.insert_process(process_id, 
                      g_campaign_type, 
                      pkg_cmp_common.G_STATUS_PROCESSING,
                      g_date,
                      g_date,
                      G_DAYS_RANGE_PARAM);
        
        OPEN c_config;
        FETCH c_config BULK COLLECT INTO row_config;
        FOR i IN 1 .. row_config.COUNT 
        LOOP
            BEGIN
                cards_not_delivered(process_id, row_config(i).notification_authorization);
            END;
        END LOOP;
        pkg_cmp_common.update_process(process_id, pkg_cmp_common.G_STATUS_COMPLETED);
        commit;
    end main;

end pkg_cmp_card_not_delivered;

/