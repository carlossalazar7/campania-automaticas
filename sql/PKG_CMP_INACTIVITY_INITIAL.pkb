CREATE OR REPLACE package body PKG_CMP_INACTIVITY_INITIAL as

    procedure inactivity_initial(p_process_id number, p_days number) as
        CURSOR c_inputdata IS
            select 
                cus.customerid,
                card.deliveredtime,
                cus.aliasname,
                card.cardid,
                card.productid,
                prod.description as product_desc
            from T_GCARD card 
            join T_GPRODUCT prod on prod.productid = card.productid
            join T_GCUSTOMER cus on cus.customerid = card.customerid
            where card.productid in (select column_value from table(pkg_cmp_common.get_parameter_as_list('CREDIT_PRODUCT_IDS')))
            and card.deliveredind = 'T'
            and card.deliveredtime between trunc(g_date - p_days - 7) and trunc(g_date - p_days)
            --and trim(to_char(card.deliveredtime, 'DAY')) = 'MONDAY'
            and not exists(
                select 1 
                from T_GDEBITOPERATION do
                where do.OPERATIONTYPEID in (select column_value from table(pkg_cmp_common.get_parameter_as_list('PURCHASE_OP_TYPES')))
                and do.cardid = card.cardid
            );
        TYPE tbl_inputdata IS TABLE OF c_inputdata%ROWTYPE;
        row_inputdata tbl_inputdata;
        v_email varchar2(100);
        v_phone varchar2(100);
    begin
        dbms_output.put_line('---------------------- inactivity_initial - Days:'||p_days||' - start ----------------------');
        OPEN c_inputdata;
        FETCH c_inputdata BULK COLLECT INTO row_inputdata LIMIT 5000;
        FOR i IN 1 .. row_inputdata.COUNT 
        LOOP
            dbms_output.put_line(row_inputdata(i).customerid || ' - ' || row_inputdata(i).aliasname);
            v_email := pkg_cmp_common.get_email(row_inputdata(i).customerid, row_inputdata(i).cardid);
            v_phone := pkg_cmp_common.get_cellphone(row_inputdata(i).customerid);
            INSERT INTO T_CMP_INACTIVITY_INITIAL (
                process_id,
                customerid,
                deliveredtime,
                inactive_count_days,
                aliasname,
                email,
                phonenumber,
                productid,
                product_desc
            ) VALUES (
                p_process_id,
                row_inputdata(i).customerid,
                row_inputdata(i).deliveredtime,
                p_days,
                row_inputdata(i).aliasname,
                v_email,
                v_phone,
                row_inputdata(i).productid,
                row_inputdata(i).product_desc
            );
        END LOOP;
        commit;
        dbms_output.put_line('inactivity_initial - Days:'||p_days||' - end');    
    end;
    
    
    procedure load_params as
    begin
        G_DAYS_RANGE_PARAM := pkg_cmp_common.get_parameter_as_number('DAYS_RANGE_INACTIVITY_INITIAL');
        g_date := pkg_cmp_common.get_fecha_sunnel() - G_DAYS_RANGE_PARAM;
        dbms_output.put_line('load_params - g_date = ' || g_date);
    end;
    
    
    procedure main as
        cursor c_config is
            SELECT id_notification, notification_date_buy 
            FROM als_campaign_notific_inac_one 
            WHERE notification_string = 'CREDISIMAN' and notification_enable = 'S'; 
        TYPE tbl_config IS TABLE OF c_config%ROWTYPE;
        row_config tbl_config;
        process_id number;
    begin
        load_params();
        OPEN c_config;
        FETCH c_config BULK COLLECT INTO row_config;
        FOR i IN 1 .. row_config.COUNT 
        LOOP
            BEGIN
                pkg_cmp_common.insert_process(process_id, 
                      g_campaign_type, 
                      pkg_cmp_common.G_STATUS_PROCESSING,
                      g_date,
                      g_date,
                      G_DAYS_RANGE_PARAM);
                inactivity_initial(process_id, row_config(1).notification_date_buy);
                pkg_cmp_common.update_process(process_id, pkg_cmp_common.G_STATUS_COMPLETED);
            END;
        END LOOP;
    end main;

end PKG_CMP_INACTIVITY_INITIAL;

/