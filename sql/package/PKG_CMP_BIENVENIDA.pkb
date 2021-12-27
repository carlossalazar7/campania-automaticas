CREATE OR REPLACE package body PKG_CMP_BIENVENIDA as

    procedure bienvenida(p_process_id number) as
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
            and card.deliveredtime between g_time_from and g_time_to
            ;
        TYPE tbl_inputdata IS TABLE OF c_inputdata%ROWTYPE;
        row_inputdata tbl_inputdata;
        v_email varchar2(100);
        v_phone varchar2(100);
    begin
        dbms_output.put_line('---------------------- bienvenida - start ----------------------');
        OPEN c_inputdata;
        FETCH c_inputdata BULK COLLECT INTO row_inputdata LIMIT 5000;
        FOR i IN 1 .. row_inputdata.COUNT 
        LOOP
            dbms_output.put_line(row_inputdata(i).customerid || ' - ' || row_inputdata(i).aliasname);
            v_email := pkg_cmp_common.get_email(row_inputdata(i).customerid, row_inputdata(i).cardid);
            v_phone := pkg_cmp_common.get_cellphone(row_inputdata(i).customerid);
            INSERT INTO T_CMP_BIENVENIDA (
                process_id,
                customerid,
                deliveredtime,
                aliasname,
                email,
                phonenumber,
                productid,
                product_desc
            ) VALUES (
                p_process_id,
                row_inputdata(i).customerid,
                row_inputdata(i).deliveredtime,
                row_inputdata(i).aliasname,
                v_email,
                v_phone,
                row_inputdata(i).productid,
                row_inputdata(i).product_desc
            );
        END LOOP;
        commit;
        dbms_output.put_line('bienvenida - end');    
    end;
    
    
    procedure load_params as
        v_prev_starttime       timestamp       := null;
    begin
        G_DAYS_RANGE_PARAM := pkg_cmp_common.get_parameter_as_number('DAYS_RANGE_BIENVENIDA');
        begin
            -- usar la fecha hora de ultima ejecucion como filtro inicial de fecha
            SELECT data_range_end INTO v_prev_starttime 
            FROM (SELECT data_range_end, row_number()over(order by data_range_end desc) as rn FROM t_cmp_process WHERE campaign_type = G_CAMPAIGN_TYPE)
            WHERE rn=1;
            
            g_time_from := v_prev_starttime - G_DAYS_RANGE_PARAM;
            g_time_to   := pkg_cmp_common.get_fecha_hora_sunnel() - G_DAYS_RANGE_PARAM;
            dbms_output.put_line('load_params - in starttime - ' || g_time_from || ' to ' || g_time_to);
        exception when no_data_found then
            g_time_from := pkg_cmp_common.get_fecha_sunnel() - G_DAYS_RANGE_PARAM;
            g_time_to   := pkg_cmp_common.get_fecha_hora_sunnel() - G_DAYS_RANGE_PARAM;
            dbms_output.put_line('load_params - in exception - ' || g_time_from || ' to ' || g_time_to);
        end;
    end;
    
    
    procedure main as
        process_id number;
    begin
        load_params();
        pkg_cmp_common.insert_process(process_id, 
                              g_campaign_type, 
                              pkg_cmp_common.G_STATUS_PROCESSING,
                              g_time_from,
                              g_time_to,
                              G_DAYS_RANGE_PARAM);
        bienvenida(process_id);
        pkg_cmp_common.update_process(process_id, pkg_cmp_common.G_STATUS_COMPLETED);
    end main;

end PKG_CMP_BIENVENIDA;

/