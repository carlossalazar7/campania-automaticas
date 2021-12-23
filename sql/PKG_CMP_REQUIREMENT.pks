CREATE OR REPLACE PACKAGE PKG_CMP_REQUIREMENT AS 

    G_ID_CAMPAIGN           number(12,0)    := 1;
    G_DAYS_RANGE_PARAM      number(12,0)    := 0;
    G_CAMPAIGN_TYPE         varchar2(50)    := 'SEGUIMIENTO';
    
    g_time_from             timestamp       := null;
    g_time_to               timestamp       := null;

    procedure main;

END PKG_CMP_REQUIREMENT;

/