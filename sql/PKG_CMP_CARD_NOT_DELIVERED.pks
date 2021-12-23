CREATE OR REPLACE PACKAGE       PKG_CMP_CARD_NOT_DELIVERED AS 

    G_DAYS_RANGE_PARAM      number(12,0)    := 0;
    
    G_CAMPAIGN_TYPE         varchar2(50)    := 'AprobadaNoEntregada';    
    
    g_date                  date;

    procedure main;

END PKG_CMP_CARD_NOT_DELIVERED;

/