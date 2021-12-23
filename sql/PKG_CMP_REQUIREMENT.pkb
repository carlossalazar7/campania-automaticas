CREATE OR REPLACE PACKAGE BODY PKG_CMP_REQUIREMENT AS


    ------------------------------------------------------------------------------------
    -- Extraer requerimientos de tipo CARD
    ------------------------------------------------------------------------------------
    procedure card_requirements(p_process_id number, p_stage varchar2, p_status varchar2) as
        CURSOR c_inputdata IS
            select /*+leading(r rc c)*/ 
                r.customerrequirementid,
                r.customerrequirementtypeid,
                rt.description as CUSTOMERREQUIREMENTTYPE_DESC,
                cus.customerid,
                cus.aliasname,
                card.cardid,
                card.productid,
                prod.description as product_desc
            from T_GCUSTOMERREQUIREMENT r
            join T_GCUSTOMERREQUIREMENTTYPE rt on rt.customerrequirementtypeid = r.customerrequirementtypeid
            join T_GCUSTOMERREQUIREMENTCARD rc on rc.customerrequirementid = r.customerrequirementid
            join T_GCARD card on card.cardid = rc.cardid
            join T_GCUSTOMER cus on cus.customerid = card.customerid
            join T_GPRODUCT prod on prod.productid = card.productid
            where r.STAGE = p_stage
            and r.STATUS = p_status
            and r.customerrequirementtypeid in (select column_value from table(pkg_cmp_common.get_parameter_as_list('CUST_REQ_TYPES')))
            and ((p_stage='EVALUATION' and r.CASEDATE between g_time_from and g_time_to) or
                 (p_stage='AUTHORIZATION' and r.SOLUTIONDATE between g_time_from and g_time_to))
            --and rownum<10
            ;
        TYPE tbl_inputdata IS TABLE OF c_inputdata%ROWTYPE;
        row_inputdata tbl_inputdata;
        v_email varchar2(100);
        v_phone varchar2(100);
    begin
        dbms_output.put_line('---------------------- card_requirements - start ----------------------');
        OPEN c_inputdata;
        FETCH c_inputdata BULK COLLECT INTO row_inputdata LIMIT 5000;
        FOR i IN 1 .. row_inputdata.COUNT 
        LOOP
            dbms_output.put_line(row_inputdata(i).customerrequirementid || ' - ' || row_inputdata(i).CUSTOMERREQUIREMENTTYPE_DESC);
            v_email := pkg_cmp_common.get_email(row_inputdata(i).customerid, row_inputdata(i).cardid);
            v_phone := pkg_cmp_common.get_cellphone(row_inputdata(i).customerid);
            INSERT INTO t_cmp_requirement (
                process_id,
                customerrequirementid,
                customerrequirementtypeid,
                customerrequirementtype_desc,
                status,
                stage,
                customerid,
                aliasname,
                email,
                phonenumber,
                productid,
                product_desc
            ) VALUES (
                p_process_id,
                row_inputdata(i).customerrequirementid,
                row_inputdata(i).customerrequirementtypeid,
                row_inputdata(i).customerrequirementtype_desc,
                p_status,
                p_stage,
                row_inputdata(i).customerid,
                row_inputdata(i).aliasname,
                v_email,
                v_phone,
                row_inputdata(i).productid,
                row_inputdata(i).product_desc
            );
        END LOOP;
        commit;
        dbms_output.put_line('card_requirements - end');
    end;




    ------------------------------------------------------------------------------------
    -- Extraer requerimientos de tipo CARD
    ------------------------------------------------------------------------------------
    procedure account_requirements(p_process_id number, p_stage varchar2, p_status varchar2) as
        CURSOR c_inputdata IS
            select /*+leading(r rc c)*/ 
                r.customerrequirementid,
                r.customerrequirementtypeid,
                rt.description as CUSTOMERREQUIREMENTTYPE_DESC,
                cus.customerid,
                cus.aliasname,
                card.cardid,
                card.productid,
                prod.description as product_desc
            from T_GCUSTOMERREQUIREMENT r
            join T_GCUSTOMERREQUIREMENTTYPE rt on rt.customerrequirementtypeid = r.customerrequirementtypeid
            join T_GCUSTOMERREQUIREMENTACCOUNT ra on ra.customerrequirementid = r.customerrequirementid
            join T_GACCOUNT acc on acc.accountid = ra.accountid
            join T_GCARD card on card.cardid = acc.cardid
            join T_GCUSTOMER cus on cus.customerid = card.customerid
            join T_GPRODUCT prod on prod.productid = card.productid
            where r.STAGE = p_stage
            and r.STATUS = p_status
            and r.customerrequirementtypeid in (select column_value from table(pkg_cmp_common.get_parameter_as_list('CUST_REQ_TYPES')))
            and ((p_stage='EVALUATION' and r.CASEDATE between g_time_from and g_time_to) or
                 (p_stage='AUTHORIZATION' and r.SOLUTIONDATE between g_time_from and g_time_to))
            --and rownum<10
            ;
        TYPE tbl_inputdata IS TABLE OF c_inputdata%ROWTYPE;
        row_inputdata tbl_inputdata;
        v_email varchar2(100);
        v_phone varchar2(100);
    begin
        dbms_output.put_line('---------------------- account_requirements - start ----------------------');
        OPEN c_inputdata;
        FETCH c_inputdata BULK COLLECT INTO row_inputdata LIMIT 5000;
        FOR i IN 1 .. row_inputdata.COUNT 
        LOOP
            dbms_output.put_line(row_inputdata(i).customerrequirementid || ' - ' || row_inputdata(i).CUSTOMERREQUIREMENTTYPE_DESC);
            v_email := pkg_cmp_common.get_email(row_inputdata(i).customerid, row_inputdata(i).cardid);
            v_phone := pkg_cmp_common.get_cellphone(row_inputdata(i).customerid);
            INSERT INTO t_cmp_requirement (
                process_id,
                customerrequirementid,
                customerrequirementtypeid,
                customerrequirementtype_desc,
                status,
                stage,
                customerid,
                aliasname,
                email,
                phonenumber,
                productid,
                product_desc
            ) VALUES (
                p_process_id,
                row_inputdata(i).customerrequirementid,
                row_inputdata(i).customerrequirementtypeid,
                row_inputdata(i).customerrequirementtype_desc,
                p_status,
                p_stage,
                row_inputdata(i).customerid,
                row_inputdata(i).aliasname,
                v_email,
                v_phone,
                row_inputdata(i).productid,
                row_inputdata(i).product_desc
            );
        END LOOP;
        commit;
        dbms_output.put_line('account_requirements - end');
    end;



    ------------------------------------------------------------------------------------
    -- Extraer requerimientos de tipo CUSTOMER
    ------------------------------------------------------------------------------------
    procedure customer_requirements(p_process_id number, p_stage varchar2, p_status varchar2) as
        CURSOR c_inputdata IS
            select /*+leading(r rc c)*/ 
                r.customerrequirementid,
                r.customerrequirementtypeid,
                rt.description as CUSTOMERREQUIREMENTTYPE_DESC,
                cus.customerid,
                cus.aliasname,
                card.cardid,
                card.productid,
                prod.description as product_desc
            from T_GCUSTOMERREQUIREMENT r
            join T_GCUSTOMERREQUIREMENTTYPE rt on rt.customerrequirementtypeid = r.customerrequirementtypeid
            join T_GCUSTOMERREQUIREMENTCUSTOMER rc on rc.customerrequirementid = r.customerrequirementid
            join T_GCUSTOMER cus on cus.customerid = rc.customerid
            --join T_GCARD card on cus.customerid = card.customerid and card.productid=case when r.customerrequirementtypeid=97 then 10001 when r.customerrequirementtypeid=95 then 10020 else 10001 end
            join T_GCARD card on cus.customerid = card.customerid and card.cardtype='M' and closedind='F'
                                                                  and card.productid in (case when r.customerrequirementtypeid=97 then 10001 when r.customerrequirementtypeid=95 then 10020 else 10001 end,
                                                                                         case when r.customerrequirementtypeid=97 then 10002 when r.customerrequirementtypeid=95 then 10020 else 10002 end,
                                                                                         case when r.customerrequirementtypeid=97 then 10003 when r.customerrequirementtypeid=95 then 10020 else 10003 end)
            join T_GPRODUCT prod on prod.productid = card.productid
            where r.STAGE = p_stage
            and r.STATUS = p_status
            and r.customerrequirementtypeid in (select column_value from table(pkg_cmp_common.get_parameter_as_list('CUST_REQ_TYPES')))
            and ((p_stage='EVALUATION' and r.CASEDATE between g_time_from and g_time_to) or
                 (p_stage='AUTHORIZATION' and r.SOLUTIONDATE between g_time_from and g_time_to))
            --and rownum<10
            ;
        TYPE tbl_inputdata IS TABLE OF c_inputdata%ROWTYPE;
        row_inputdata tbl_inputdata;
        v_email varchar2(100);
        v_phone varchar2(100);
    begin
        dbms_output.put_line('---------------------- customer_requirements - start ----------------------');
        OPEN c_inputdata;
        FETCH c_inputdata BULK COLLECT INTO row_inputdata LIMIT 5000;
        FOR i IN 1 .. row_inputdata.COUNT 
        LOOP
            dbms_output.put_line(row_inputdata(i).customerrequirementid || ' - ' || row_inputdata(i).CUSTOMERREQUIREMENTTYPE_DESC);
            v_email := pkg_cmp_common.get_email(row_inputdata(i).customerid, row_inputdata(i).cardid);
            v_phone := pkg_cmp_common.get_cellphone(row_inputdata(i).customerid);
            INSERT INTO t_cmp_requirement (
                process_id,
                customerrequirementid,
                customerrequirementtypeid,
                customerrequirementtype_desc,
                status,
                stage,
                customerid,
                aliasname,
                email,
                phonenumber,
                productid,
                product_desc
            ) VALUES (
                p_process_id,
                row_inputdata(i).customerrequirementid,
                row_inputdata(i).customerrequirementtypeid,
                row_inputdata(i).customerrequirementtype_desc,
                p_status,
                p_stage,
                row_inputdata(i).customerid,
                row_inputdata(i).aliasname,
                v_email,
                v_phone,
                row_inputdata(i).productid,
                row_inputdata(i).product_desc
            );
        END LOOP;
        commit;
        dbms_output.put_line('customer_requirements - end');
    end;




    procedure load_params as
        v_prev_starttime       timestamp       := null;
    begin
        G_DAYS_RANGE_PARAM := pkg_cmp_common.get_parameter_as_number('DAYS_RANGE_REQUIREMENT');
        dbms_output.put_line('load_params - ' || G_DAYS_RANGE_PARAM);
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
        cursor c_config is
            SELECT
                id_setup,
                stage,
                status
            FROM
                als_seguimiento_setup_vw
            WHERE id_campaing = G_ID_CAMPAIGN
            AND enabled = 'Y';
        TYPE tbl_config IS TABLE OF c_config%ROWTYPE;
        row_config tbl_config;
        process_id number;
        
    begin
        
        load_params();
        pkg_cmp_common.insert_process(process_id, 
                                      g_campaign_type, 
                                      pkg_cmp_common.G_STATUS_PROCESSING,
                                      g_time_from,
                                      g_time_to,
                                      G_DAYS_RANGE_PARAM);
        BEGIN
            OPEN c_config;
            FETCH c_config BULK COLLECT INTO row_config;
            FOR i IN 1 .. row_config.COUNT 
            LOOP
                dbms_output.put_line(row_config(i).status || ' - ' || row_config(i).stage);
                card_requirements(process_id, row_config(i).stage, row_config(i).status);
                account_requirements(process_id, row_config(i).stage, row_config(i).status);
                customer_requirements(process_id, row_config(i).stage, row_config(i).status);
            END LOOP;
            
            pkg_cmp_common.update_process(process_id, pkg_cmp_common.G_STATUS_COMPLETED);
            commit;
        EXCEPTION WHEN OTHERS THEN
            pkg_cmp_common.update_process(process_id, pkg_cmp_common.G_STATUS_ERROR); --TODO: guardar mensaje de error
        END;
        
    end;
    

END PKG_CMP_REQUIREMENT;

/