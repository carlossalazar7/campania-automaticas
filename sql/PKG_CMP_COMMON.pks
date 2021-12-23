CREATE OR REPLACE package pkg_cmp_common as 


    G_STATUS_PROCESSING VARCHAR2(20) := 'PROCESSING';
    G_STATUS_COMPLETED VARCHAR2(20) := 'COMPLETED';
    G_STATUS_ERROR VARCHAR2(20) := 'ERROR';
    
    --TYPE tbl_varchar is TABLE OF varchar2(10);

    function get_email(p_customerid number, p_cardid varchar) return varchar2;
    
    function get_cellphone(p_customerid number) return varchar2;
    /*
    procedure insert_process(
        p_process_id    out   t_cmp_process.process_id%type,
        p_campaing_type in    t_cmp_process.campaign_type%type,
        p_id_setup      in    t_cmp_process.id_setup%type,
        p_status        in    t_cmp_process.status%type default null,
        p_starttime     in    t_cmp_process.exec_start_time%type default null,
        p_rowcount      in    t_cmp_process.rowcount%type default null,
        p_errormsg      in    t_cmp_process.errormsg%type default null
    );
    */
    
     procedure insert_process(
        p_process_id        out   t_cmp_process.process_id%type,
        p_campaing_type     in    t_cmp_process.campaign_type%type,
        p_status            in    t_cmp_process.status%type default null,
        p_data_range_start  in    t_cmp_process.data_range_start%type,
        p_data_range_end    in    t_cmp_process.data_range_end%type,
        p_days_range        in    t_cmp_process.days_range%type,
        p_exec_start_time   in    t_cmp_process.exec_start_time%type default systimestamp
    );
    
    
    procedure update_process(
        p_process_id    in    t_cmp_process.process_id%type,
        p_status        in    t_cmp_process.status%type,
        p_endtime       in    t_cmp_process.exec_end_time%type default systimestamp,
        p_errormsg      in    t_cmp_process.errormsg%type default null
    );
  
    procedure change_schema(
        p_schema    varchar2
    );
    
    
    function get_parameter_as_list(p_id varchar2) return arrayofstrings;
    
    function get_parameter_as_number(p_id varchar2) return number;
    
    function get_fecha_sunnel return date;
    
    function get_fecha_hora_sunnel return timestamp;
    

end pkg_cmp_common;

/