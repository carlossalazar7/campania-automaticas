CREATE OR REPLACE PACKAGE       PKG_CMP_INACTIVITY_INITIAL AS 

    --G_ID_CAMPAIGN       number(12,0)    := 1;
    G_DAYS_RANGE_PARAM  number(12,0)    := 1;
    
    G_CAMPAIGN_TYPE         varchar2(50)    := 'AprobadaSinCompra';
    
    g_date                  date;

    procedure main;

END PKG_CMP_INACTIVITY_INITIAL;

/