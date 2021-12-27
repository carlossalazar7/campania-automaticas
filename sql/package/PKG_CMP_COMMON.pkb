CREATE OR REPLACE package body pkg_cmp_common as
    
    function get_email(p_customerid number, p_cardid varchar) return varchar2 AS
        r_email varchar2(100);
    begin
       SELECT b.EMAIL INTO r_email
         FROM T_GCARDEMAILADDRESS aa 
         INNER JOIN T_GEMAILADDRESS b ON b.CUSTOMERID=aa.CUSTOMERID 
                                     AND b.ADDRESSID=aa.ADDRESSID 
         WHERE aa.CARDID = p_cardid
           AND aa.CARDEMAILADDRESSID=(SELECT MAX(c.CARDEMAILADDRESSID) 
                                      FROM T_GCARDEMAILADDRESS c 
                                      WHERE c.CARDID=aa.CARDID);
       return r_email;               
    exception when no_data_found then
        begin
           SELECT aa.EMAIL INTO r_email
             FROM T_GEMAILADDRESS aa 
            WHERE aa.CUSTOMERID = p_customerid
              AND aa.ADDRESSID=(SELECT MAX(b.addressid) 
                                 FROM T_GEMAILADDRESS b 
                                 WHERE b.CUSTOMERID=aa.CUSTOMERID); 
            return r_email;
        exception when no_data_found then
            r_email := null;
            return r_email; 
        end;
    end;
    
    
    
    function get_cellphone(p_customerid number) return varchar2 as
        r_phone varchar2(30);
    begin
        select phonenumber into r_phone
        from (
            select ph.phonenumber, row_number() over (order by baph.phoneid desc) as rn
            from T_GBUILDINGADDRESS ba, T_GBUILDINGADDRESSPHONE baph, T_GPHONE ph
            where baph.addressid = ba.addressid and baph.customerid = ba.customerid
            and ph.phoneid = baph.phoneid and ph.phonetype = 'MOBILE'
            and ba.addresstype = 'HOME' and ba.customerid = p_customerid
        )
        where rn = 1;
        return r_phone;
    exception when no_data_found then
        r_phone := null;
        return r_phone;
    end;
    
        
    
    procedure insert_process(
        p_process_id        out   t_cmp_process.process_id%type,
        p_campaing_type     in    t_cmp_process.campaign_type%type,
        p_status            in    t_cmp_process.status%type default null,
        p_data_range_start  in    t_cmp_process.data_range_start%type,
        p_data_range_end    in    t_cmp_process.data_range_end%type,
        p_days_range        in    t_cmp_process.days_range%type,
        p_exec_start_time   in    t_cmp_process.exec_start_time%type default systimestamp
    ) as
        v_id_campaign   varchar2(50);
        --v_starttime     timestamp;
    begin
        SELECT SQ_CMP_PROCESS.nextval INTO p_process_id FROM dual;
        SELECT id_campaign INTO v_id_campaign FROM ALS_CAMPAIGN WHERE campaign_type = p_campaing_type;
        /*IF p_exec_start_time is null THEN
            v_starttime := get_fecha_hora_sunnel();
        ELSE 
            v_starttime := p_exec_start_time;
        END IF;*/
        INSERT INTO t_cmp_process (
            process_id,
            id_campaign,
            campaign_type,
            status,
            exec_start_time,
            data_range_start,
            data_range_end,
            sunnel_date,
            days_range
        ) VALUES (
            p_process_id,
            v_id_campaign,
            p_campaing_type,
            p_status,
            p_exec_start_time,
            p_data_range_start,
            p_data_range_end,
            get_fecha_sunnel(),
            p_days_range
        );
        commit;
    end;
    
    procedure update_process(
        p_process_id  in  t_cmp_process.process_id%type,
        p_status      in  t_cmp_process.status%type,
        p_endtime   in    t_cmp_process.exec_end_time%type default systimestamp,
        p_errormsg    in  t_cmp_process.errormsg%type default null
    ) is
        --v_endtime     timestamp;
    begin
        /*IF p_endtime is null THEN
            v_endtime := get_fecha_hora_sunnel();
        ELSE 
            v_endtime := p_endtime;
        END IF;*/
        UPDATE t_cmp_process
        SET status = p_status, errormsg = p_errormsg, exec_end_time = p_endtime
        WHERE process_id = p_process_id;
    end;
    
    
    procedure change_schema(
        p_schema    varchar2
    ) as
    begin
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURRENT_SCHEMA = '||p_schema ;
    end;
    
    
    function get_parameter_as_list(p_id varchar2) return arrayofstrings is
        --cursor c_paramdata is
            
        r_value arrayofstrings := arrayofstrings();
    begin
        /*OPEN c_paramdata;
        FETCH c_paramdata BULK COLLECT INTO r_value;
        CLOSE c_paramdata;*/
        select distinct regexp_substr (
                   value,
                   '[^,]+',
                   1,
                   level
                 ) str  BULK COLLECT INTO r_value
          from   t_cmp_params
          where  id = p_id
          connect by level <= 
            length ( value ) - 
            length ( replace ( value, ',' ) ) + 1;
        RETURN r_value;
    end;
    
    
    function get_parameter_as_number(p_id varchar2) return number is
        r_value number(12,0);
    begin
        select to_number(value) into r_value
        from t_cmp_params
        where  id = p_id;
        return r_value;
    end;
    
    
    function get_fecha_sunnel return date is
        v_fecha_sunnel date;
    begin
        select currentdate into v_fecha_sunnel from t_ginitsetupparameter;
        return v_fecha_sunnel;
    exception when no_data_found then
        return null;
    end;
    
    
    
    function get_fecha_hora_sunnel return timestamp is
        v_fecha_sunnel date;
    begin
        select to_timestamp(to_char(currentdate, 'YYYY-MM-DD') || to_char(systimestamp, ' HH24:MI:SS.FF'), 'YYYY-MM-DD HH24:MI:SS.FF') into v_fecha_sunnel from t_ginitsetupparameter;
        return v_fecha_sunnel;
    exception when no_data_found then
        return null;
    end;
    
    /*
    procedure calculate_date_range(
        p_campaign_type     in      varchar2, 
        p_time_from         out     timestamp, 
        p_time_to           out     timestamp
    ) is
        v_prev_starttime       timestamp       := null;
    begin
        -- usar la fecha hora de ultima ejecucion como filtro inicial de fecha
        SELECT starttime INTO v_prev_starttime 
        FROM (SELECT starttime, row_number()over(order by starttime desc) as rn FROM t_cmp_process WHERE campaign_type = p_CAMPAIGN_TYPE)
        WHERE rn=1;
        
        p_time_from := v_prev_starttime - G_DAYS_RANGE_PARAM;
        p_time_to   := pkg_cmp_common.get_fecha_hora_sunnel() - p_DAYS_RANGE_PARAM;
        dbms_output.put_line('load_params - in starttime - ' || g_time_from || ' to ' || g_time_to);
    exception when no_data_found then
        p_time_from := pkg_cmp_common.get_fecha_sunnel() - G_DAYS_RANGE_PARAM;
        p_time_to   := pkg_cmp_common.get_fecha_hora_sunnel() - G_DAYS_RANGE_PARAM;
        dbms_output.put_line('load_params - in exception - ' || g_time_from || ' to ' || g_time_to);
    end;
    */
end pkg_cmp_common;

/