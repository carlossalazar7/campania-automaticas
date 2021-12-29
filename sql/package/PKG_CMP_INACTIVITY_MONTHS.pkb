CREATE OR REPLACE package body       PKG_CMP_INACTIVITY_MONTHS as

    procedure inactivity_by_months(p_process_id number, p_months number) as
        CURSOR c_inputdata IS
            -- inserta duplicados
            select 
                cus.customerid,
                card.deliveredtime,
                do.operationdate as last_purchase_date,
                cus.aliasname,
                card.cardid,
                card.productid,
                prod.description as product_desc
            from T_GCARD card 
            join T_GPRODUCT prod on prod.productid = card.productid 
            join T_GCUSTOMER cus on cus.customerid = card.customerid
            join T_GACCOUNT acc on acc.cardid = card.cardid
            join T_GCREDITLINE cl on cl.creditlineid = acc.accountid
            join T_GDEBITOPERATION do on do.cardid = card.cardid and do.OPERATIONTYPEID in (select column_value+0 from table(simac.pkg_cmp_common.get_parameter_as_list('PURCHASE_OP_TYPES')))
                                      and do.operationdate between trunc(add_months(g_date, -p_months)-1) and trunc(add_months(g_date, -p_months)) --tuvo compras hace exactamente 6 meses, el -7 es para traer data de toda la semana pq el proceso corre solo los lunes
            where 1=1
            --and card.deliveredtime between trunc(sysdate - 365 - 15 - 7) and trunc(sysdate - 365 - 15)
            --and trim(to_char(card.deliveredtime, 'DAY')) = 'MONDAY'
            and card.deliveredind = 'T' 
            and card.closedind = 'F' 
            and card.lostcardind='F' 
            and card.riskconditionind='F'
            AND cl.ACCELERATEDBALANCEIND='F'
            AND cl.BADDEBTIND='F'
            AND cl.UNCOLLECTABLEIND='F'
            and card.productid in (select column_value+0 from table(simac.pkg_cmp_common.get_parameter_as_list('CREDIT_PRODUCT_IDS')))
            
            and not exists ( --no tiene compras desde hace 6 meses a la fecha
                select 1 
                from T_GDEBITOPERATION do2
                where do2.OPERATIONTYPEID in (select column_value+0 from table(simac.pkg_cmp_common.get_parameter_as_list('PURCHASE_OP_TYPES')))
                and do2.cardid = card.cardid
                and do2.operationdate between trunc(add_months(g_date, -p_months)) and trunc(g_date)
            )
            /*and do.operationdate = ( --no tiene compras desde hace 6 meses a la fecha
                select max(do2.operationdate)
                from T_GDEBITOPERATION do2
                where do2.OPERATIONTYPEID in (select column_value+0 from table(simac.pkg_cmp_common.get_parameter_as_list('PURCHASE_OP_TYPES')))
                and do2.cardid = card.cardid
                --and do2.creditlineid = cl.creditlineid
                and do2.operationdate between trunc(add_months(g_date, -p_months)-1) and trunc(g_date)
            )*/
            ;
        TYPE tbl_inputdata IS TABLE OF c_inputdata%ROWTYPE;
        row_inputdata tbl_inputdata;
        v_email varchar2(100);
        v_phone varchar2(100);
        v_already_exists number;
        v_count number := 0;
    begin
        dbms_output.put_line('---------------------- inactivity_by_months - Months:'||p_months||' - start process_id:'||p_process_id||' ----------------------');
        OPEN c_inputdata;
        FETCH c_inputdata BULK COLLECT INTO row_inputdata LIMIT 5000;
        FOR i IN 1 .. row_inputdata.COUNT 
        LOOP

            v_email := pkg_cmp_common.get_email(row_inputdata(i).customerid, row_inputdata(i).cardid);
            v_phone := pkg_cmp_common.get_cellphone(row_inputdata(i).customerid);

            SELECT (   
                SELECT 1 --INTO already_inserted
                FROM T_CMP_INACTIVITY_MONTHS a
                WHERE a.process_id = p_process_id
                AND a.customerid = row_inputdata(i).customerid
                AND a.productid = row_inputdata(i).productid
            ) INTO v_already_exists
            FROM DUAL;

            IF v_already_exists IS NULL THEN
                --dbms_output.put_line(row_inputdata(i).customerid || ' - ' || row_inputdata(i).aliasname);
                INSERT INTO T_CMP_INACTIVITY_MONTHS (
                    process_id,
                    customerid,
                    deliveredtime,
                    last_purchase_date,
                    inactive_count_months,
                    aliasname,
                    email,
                    phonenumber,
                    productid,
                    product_desc
                ) VALUES (
                    p_process_id,
                    row_inputdata(i).customerid,
                    row_inputdata(i).deliveredtime,
                    row_inputdata(i).last_purchase_date,
                    p_months,
                    row_inputdata(i).aliasname,
                    v_email,
                    v_phone,
                    row_inputdata(i).productid,
                    row_inputdata(i).product_desc
                );
                v_count := v_count + 1;
            END IF;    
        END LOOP;
        commit;
        dbms_output.put_line('inactivity_by_months - Months:'||p_months||' - end - '||v_count);    
    end;


    procedure load_params as
    begin
        G_DAYS_RANGE_PARAM := pkg_cmp_common.get_parameter_as_number('DAYS_RANGE_INACTIVITY_MONTHS');
        g_date := pkg_cmp_common.get_fecha_sunnel() - G_DAYS_RANGE_PARAM;
        dbms_output.put_line('load_params - g_date = ' || g_date);
    end;


    procedure main as
        cursor c_config is
            SELECT distinct notification_last_buy 
            FROM als_campaign_notific_inac_two
            WHERE  notification_enable = 'S'; 
        TYPE tbl_config IS TABLE OF c_config%ROWTYPE;
        row_config tbl_config;
        process_id number;
    begin
        load_params();

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
                inactivity_by_months(process_id, row_config(i).notification_last_buy);
            END;
        END LOOP;
        pkg_cmp_common.update_process(process_id, pkg_cmp_common.G_STATUS_COMPLETED);
        commit;
    end main;

end PKG_CMP_INACTIVITY_MONTHS;

/