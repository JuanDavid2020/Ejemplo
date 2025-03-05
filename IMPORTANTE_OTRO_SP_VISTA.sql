		
USE FYCBOG
go

USE REPOSITORY_GMF
GO


SELECT * 
FROM ITEM_OPERACION_NULO
WHERE ION_Nombre LIKE '%GMF%'


SELECT * 
FROM LEGITIMIDAD_OPERACION
WHERE ION_Nombre LIKE '%GMF%'

LEGITIMIDAD_OPERACION C ON A.TER_ReinaProducto=C.LOP_EstadoProducto
ITEM_OPERACION_NULO D ON C.LOP_Operación=D.ION_Tipo AND D.ION_Nombre='VencIntMora'



/*
SELECT * 
FROM fycbog.DBO.ROL_PERSONA_DOCUMENTO E
INNER JOIN   Transacciones_con_cobro_GMF A 
ON RIGHT(A.Numero_de_producto, LEN(A.Numero_de_producto) - CHARINDEX('-', A.Numero_de_producto)) =E.RPD_DocumentoNúmero 
AND LEFT(A.Numero_de_producto, CHARINDEX('-', A.Numero_de_producto) - 1)=E.RPD_DocumentoTipo
*/

WHERE RPD_DocumentoNúmero='100000001'
AND RPD_DocumentoTipo LIKE '%AFAI%'


select * FROM  fycbog.dbo.DOCUMENTO 
where DCT_Tipo like '%afai%'
and DCT_Número='100000001'


select * from  fycbog.dbo.LEGITIMIDAD_OPERACION where LOP_Operación like '%GMF%'
/*--@TipoPago--
OPT_Soporte_Contable	OPT_Nombre	OPT_Descripción	OPT_Soporte_Contable	OPT_Soporte_Contable_Inversa
NOTA CONTABLE	GMF_SupTope	Movimiento GMF FAI asincronico	NOTA CONTABLE	NOTA CONTABLE
NOTA CONTABLE	NCReintegroGMF	Reintegro de GMF asyncronico	NOTA CONTABLE	NOTA CONTABLE
*/
SELECT OPT_Soporte_Contable,* FROM FYCBOG.DBO.OPERACION_TIPO WHERE OPT_Nombre LIKE '%GMF_SupTope%' 



SELECT *
FROM Transacciones_con_cobro_GMF A 
WHERE RIGHT(A.Numero_de_producto, LEN(A.Numero_de_producto) - CHARINDEX('-', A.Numero_de_producto))='100000003'


SELECT TER_ReinaProducto,*
FROM Transacciones_con_cobro_GMF A
INNER JOIN fycbog.dbo.TERMINO B ON LEFT(A.Numero_de_producto, CHARINDEX('-', A.Numero_de_producto) - 1)=B.TER_DocumentoTipo
AND RIGHT(A.Numero_de_producto, LEN(A.Numero_de_producto) - CHARINDEX('-', A.Numero_de_producto))=B.TER_DocumentoNúmero



SELECT * 
FROM FYCBOG.DBO.ITEM_OPERACION_NULO
WHERE ION_Nombre LIKE '%GMF%'

select * from FYCBOG.DBO.OPERACION_TIPO where OPT_Nombre like '%gmf%'
	SELECT @TipoSoporte = OPT_Soporte_Contable 
		FROM FYCBOG.DBO.OPERACION_TIPO
		WHERE OPT_Nombre = @TipoPago;
----en aspecto documento nulll ver si tiene la marcacion
---Generar una vista materializada
---ACTULIZACION DE MARCACIONES  EN OTRO SP DEL ARCHIVO CON COBRO ITEM_NORMAL NULO  REGISTRO GMF CAVCRM
select * from fycbog.dbo.ITEM_DE_NORMA_NULO
select * from CAVIPETROL.dbo.Registro_GMF


SELECT  TOP 10 * FROM  FYCBOG.dbo.OPERACION WHERE OPR_Tipo='NCReintegroGMF'


--SELECT * FROM fycbog.DBO.LEGITIMIDAD_OPERACION C WHERE LOP_EstadoProducto='CavFai'
--SELECT * FROM  FYCBar.dbo.TERMINO B WHERE TER_DocumentoTipo LIKE '%AFAI%'

SELECT * FROM FYCBOG.DBO.CENTRO_CONTABLE

SELECT* 
FROM FYCBuc.dbo.DOCUMENTO
WHERE DCT_Tipo = 'AFAI' AND DCT_NumeroUnico = '100000001';

SELECT  isnull( max( CPS_Ciudad) , '')
FROM fycbog.fyc.dbo.CINTAS_POR_SUCURSAL_TABLA 
WHERE  cps_idTiponit =  'CC'
and  cps_idnit = '5763500'

SELECT  isnull(max( servidor ), '') 
FROM fyc.dbo.servidor 
WHERE ciudad = 'BUCARAMANGA'


SELECT  TOP 10* FROM fycbog.dbo.OPERACION
--The INSERT statement conflicted with the FOREIGN KEY constraint "OPR_ForKey_CEC". The conflict occurred in database "fycbog", table "dbo.CENTRO_CONTABLE", column 'CEC_Nombre'.


SELECT 
    LEFT(Numero_de_producto, CHARINDEX('-', Numero_de_producto) - 1),
    RIGHT(Numero_de_producto, LEN(Numero_de_producto) - CHARINDEX('-', Numero_de_producto)),
    valor_aplicado_asincronico,
    tipo_operacion_asincronica,
    CASE 
        WHEN Tipo_de_identificación_del_Titular = 1 THEN 'CC'
        WHEN Tipo_de_identificación_del_Titular = 2 THEN 'NIT'
        ELSE 'OTRO' -- Por si hay otros valores posibles
    END AS TipoIdentificacion,
    Número_de_identificación_del_Titular
FROM Transacciones_con_cobro_GMF A
INNER JOIN FYCBuc.dbo.DOCUMENTO B ON RIGHT(A.Numero_de_producto, LEN(A.Numero_de_producto) - CHARINDEX('-', A.Numero_de_producto))=B.DCT_NumeroUnico

SELECT * FROM Transacciones_con_cobro_GMF 


SELECT *
FROM fyc.dbo.CINTAS_POR_SUCURSAL_TABLA 
WHERE  cps_idTiponit =  'CC'
and  cps_idnit = '13879195'

SELECT *
FROM fycbog.fyc.dbo.servidor 
WHERE ciudad = 'Bucaramanga'

SELECT isnull(max( servidor ), '')
select * FROM fyc.dbo.servidor 
WHERE ciudad = 'CARTAGENA'

	SELECT isnull(max( servidor ), '') 
		FROM fyc.dbo.servidor 
		WHERE ciudad = 'FLORIDABLANCA'

300001677

(SELECT * FROM FYCCar.dbo.DOCUMENTO WHERE DCT_Tipo ='AFAI' AND DCT_NumeroUnico = '300001677' AND DCT_Ciudad)
			

INNER JOIN fycbog.dbo.TERMINO B ON LEFT(A.Numero_de_producto, CHARINDEX('-', A.Numero_de_producto) - 1)=B.TER_DocumentoTipo
AND RIGHT(A.Numero_de_producto, LEN(A.Numero_de_producto) - CHARINDEX('-', A.Numero_de_producto))=B.TER_DocumentoNúmero


  SELECT *
    FROM FYCBog.FYC.DBO.ROL_PERSONA_DOCUMENTO RPD
    JOIN FYCBog.FYC.DBO.TERMINO TER
        ON TER.TER_DocumentoTipo = RPD.RPD_DocumentoTipo
        AND TER.TER_DocumentoNúmero = RPD.RPD_DocumentoNúmero
    WHERE RPD.RPD_DocumentoTipo = 'AFAI'
      AND ISNULL(TER.TER_HASTA, DATEADD(DAY, 1, GETDATE())) >= DATEADD(DAY, 1, GETDATE())
      AND RPD.RPD_IdTipoNit = 'CC'
      AND RPD.RPD_IdNit = '10019183'

SELECT TOP 10* FROM FYCBog.FYC.DBO.ROL_PERSONA_DOCUMENTO WHERE RPD_DocumentoTipo LIKE '%FAI%' AND RPD_IdNit='10019183'
SELECT TOP 10* FROM FYCBog.FYC.DBO.TERMINO TER WHERE TER_DocumentoTipo LIKE '%AFAI%' AND TER_DocumentoNúmero='100011760'
	  
SELECT * FROM Transacciones_con_cobro_GMF 
SELECT * FROM Transacciones_sin_cobro_GMF
/****crear operacion GMF  DE TODO LA INSERCION DE LA OPERACION POR CONTROL EN EL BEGIN TRAN