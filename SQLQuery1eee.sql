	SELECT 
    SPECIFIC_NAME AS 'Nombre_Procedimiento',
    ROUTINE_TYPE AS 'Tipo'
FROM 
    INFORMATION_SCHEMA.ROUTINES
WHERE 
    ROUTINE_TYPE = 'PROCEDURE'
    AND SPECIFIC_NAME LIKE '%PA_CONSULTA_INFORMACION_INDIVIDUAL_CARTERA_CREDITO';

use REPORTES_SES

PA_CONSULTA_INFORMACION_INDIVIDUAL_CARTERA_CREDITO '2020/01/01'

