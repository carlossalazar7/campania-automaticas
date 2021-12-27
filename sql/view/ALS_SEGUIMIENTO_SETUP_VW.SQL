/* Formatted on 21/12/2021 22:30:47 (QP5 v5.215.12089.38647) */
CREATE OR REPLACE FORCE VIEW SIMAC.ALS_SEGUIMIENTO_SETUP_VW
(
   ID_CAMPAING,
   ID_SETUP,
   COUNTRY,
   CHAIN,
   SEQUENCE,
   STAGE,
   STATUS,
   ENABLED
)
AS
   SELECT 1 id_campaing,
          1 id_setup,
          'SV' country,
          'Credisiman' Chain,
          1 Sequence,
          'EVALUATION' Frequency,
          'PROCESS' STATUS,
          'Y' Enabled
     FROM DUAL
   UNION ALL
   SELECT 1 id_campaing,
          2 id_setup,
          'SV' country,
          'Credisiman' Chain,
          2 Sequence,
          'AUTHORIZATION' Frequency,
          'APPROVED' STATUS,
          'Y' Enabled
     FROM DUAL
   UNION ALL
   SELECT 1 id_campaing,
          3 id_setup,
          'SV' country,
          'Credisiman' Chain,
          3 Sequence,
          'AUTHORIZATION' Frequency,
          'DECLINED' STATUS,
          'Y' Enabled
     FROM DUAL;
