DECLARE @sql NVARCHAR(MAX);

SET @sql = N'';

-- Generar script dinámico para verificar SP con "CIFIN" en su nombre en cada BD
SELECT @sql += '
USE [' + name + '];
IF EXISTS (
    SELECT 1
    FROM sys.procedures
    WHERE name LIKE ''%GENERA_GMF%''
)
BEGIN
    PRINT ''Stored procedure found in database: ' + name + ''';
    SELECT ''' + name + ''' AS DatabaseName,
           name         AS ProcedureName
    FROM sys.procedures
    WHERE name LIKE ''%GENERA_GMF%'';
END;
'
FROM sys.databases
WHERE state_desc = 'ONLINE'; -- Solo bases de datos en línea

-- Ejecuta el script generado dinámicamente
EXEC sp_executesql @sql;


SELECT * FROM FYC.DBO.ITEM_OPERACION_NULO WHERE ION_Nombre='GMFAsync'
SELECT * FROM FYC.DBO.ITEM_OPERACION_NULO WHERE ION_Nombre='ReintGMFAsync'

UPDATE FYCBOG.DBO.ITEM_OPERACION_NULO
SET ION_Tipo='GMF_SupTope'

SELECT * FROM FYC.DBO.ITEM_OPERACION_NULO 


INSERT INTO FYCBOG.DBO.ITEM_OPERACION_NULO (ION_Tipo, ION_Nombre, ION_Descripción)
SELECT ION_Tipo, ION_Nombre, ION_Descripción
FROM MIDAS.FYC.DBO.ITEM_OPERACION_NULO
WHERE ION_Nombre = 'GMFAsync';

INSERT INTO FYCBOG.DBO.ITEM_OPERACION_NULO (ION_Tipo, ION_Nombre, ION_Descripción)
SELECT ION_Tipo, ION_Nombre, ION_Descripción
FROM MIDAS.FYC.DBO.ITEM_OPERACION_NULO
WHERE ION_Nombre = 'ReintGMFAsync';

SELECT *  FROM MIDAS.FYC.DBO.OPERACION_TIPO WHERE OPT_Nombre LIKE '%GMF%'


INSERT INTO FYCBOG.DBO.OPERACION_TIPO(OPT_Nombre,OPT_Descripción,OPT_Soporte_Contable,OPT_Soporte_Contable_Inversa)
SELECT OPT_Nombre,OPT_Descripción,OPT_Soporte_Contable,OPT_Soporte_Contable_Inversa
FROM MIDAS.FYC.DBO.OPERACION_TIPO WHERE OPT_Nombre ='GMF_SupTope'

INSERT INTO FYCBOG.DBO.OPERACION_TIPO(OPT_Nombre,OPT_Descripción,OPT_Soporte_Contable,OPT_Soporte_Contable_Inversa)
SELECT OPT_Nombre,OPT_Descripción,OPT_Soporte_Contable,OPT_Soporte_Contable_Inversa
FROM MIDAS.FYC.DBO.OPERACION_TIPO WHERE OPT_Nombre ='NCReintegroGMF'


SELECT * FROM MERCURIO.FYCBOG.DBO.OPERACION_TIPO WHERE OPT_Nombre LIKE '%GMF%'

SELECT * FROM FYCBOG.DBO.LEGITIMIDAD_OPERACION WHERE LOP_Operación LIKE '%GMF%'
SELECT * FROM FYCBOG.DBO.ITEM_OPERACION_VALOR WHERE IOV_Tipo LIKE '%GMF%'
SELECT * FROM MIDAS.FYC.DBO.LEGITIMIDAD_OPERACION WHERE LOP_Operación LIKE '%GMF%'
SELECT * FROM MIDAS.FYC.DBO.ITEM_OPERACION_VALOR WHERE IOV_Tipo LIKE '%GMF%'
