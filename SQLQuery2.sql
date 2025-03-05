 select new_ptrnl,*
 from cavcrm.cavipetrol.[dbo].[API_DYNAMICS]


 select top 10* from FYCBOG.DBO.ASPECTO_OPERACION_VALOR AOV

 select  
 SUBSTRING(
			B.Numero_de_transaccion,
			CHARINDEX('-', B.Numero_de_transaccion) + 1, 
			CHARINDEX('-', B.Numero_de_transaccion, CHARINDEX('-', B.Numero_de_transaccion) + 1) - CHARINDEX('-', B.Numero_de_transaccion) - 1
		),
		 RIGHT(
			B.Numero_de_transaccion,
			LEN(B.Numero_de_transaccion) - CHARINDEX('-', B.Numero_de_transaccion, CHARINDEX('-', B.Numero_de_transaccion) + 1)
		),* 
 from REPOSITORY_GMf.dbo.Transacciones_con_cobro_GMF B


SELECT *
FROM  FYCBOG.DBO.ASPECTO_OPERACION_VALOR AOV
INNER JOIN FYCBOG.DBO.VINCULO_OPERACIONES V 
	ON AOV.AOV_Operaci�nConsecutivo = V.VOP_DestinoConsecutivo
INNER JOIN FYCBOG.dbo.MOVIMIENTO_CUENTA_PARALELA MCP 
	ON AOV.AOV_Operaci�nConsecutivo=MCP_Operaci�nConsecutivo 
	AND AOV.AOV_Valor=MCP_Valor
	AND AOV_Operaci�nTipo=MCP_Operaci�nTipo
INNER JOIN FYCBOG.DBO.OPERACION OP 
  ON OP.OPR_Consecutivo=AOV_Operaci�nConsecutivo
  AND OP.OPR_Tipo=AOV.AOV_Operaci�nTipo
 
WHERE 
AOV.AOV_Operaci�nTipo = 'GMF_FAI'
AND AOV.AOV_ItemNombre = 'VrGMF'
AND V.VOP_OrigenTipo LIKE ('RETIRO%') 
AND AOV.AOV_Valor>0q



SELECT TOP 10* FROM FYCBOG.DBO.OPERACION ORDER BY OPR_Fecha DESC

SELECT * FROM FYCBOG.DBO.VINCULO_OPERACIONES_HIST V 


SELECT * FROM FYCBOG.DBO.VINCULO_OPERACIONES

select * from FYCBOG.dbo.MOVIMIENTO_CUENTA_PARALELA
where MCP_DocumentoTipo='Afai'
AND MCP_DocumentoN�mero='100005893'
AND MCP_N�meroT�rmino=1
ORDER BY MCP_Operaci�nConsecutivo DESC

SELECT TOP 10* FROM FYC.DBO.ROL_PERSONA_DOCUMENTO
WHERE RPD_DocumentoN�mero


    ------------FYCBOG------------
	SELECT '2' AS Tipo_de_Registro 
			--Se valida el tipo de documento y se asigna un digito segun lo indica TransUnion en el documento "Manual de usuario GMF Batch"
			,CASE WHEN VA.New_Tipodedocumento = 'CC' THEN '1'
					WHEN VA.New_Tipodedocumento = 'NIT' THEN '2' 
					WHEN VA.New_Tipodedocumento = 'CE' THEN '3'
					WHEN VA.New_Tipodedocumento = 'TI' THEN '4'
					--NO EXISTEN HASTA EL MOMENTO----
					WHEN VA.New_Tipodedocumento = 'PASAPORTE' THEN '5'
					WHEN VA.New_Tipodedocumento = 'TARJETA DEL SEGURO SOCIAL EXTRANJERO' THEN '6'
					WHEN VA.New_Tipodedocumento = 'SOCIEDAD EXTRANJERA SIN NIT EN COLOMBIA' THEN '7'
					WHEN VA.New_Tipodedocumento = 'FIDEICOMISO' THEN '8'
					WHEN VA.New_Tipodedocumento = 'REGISTRO CIVIL' THEN '9'
					WHEN VA.New_Tipodedocumento = 'CARNET DIPLOM�TICO' THEN '10'
					WHEN VA.New_Tipodedocumento = 'PATRIMONIO AUT�NOMO' THEN '11'
					WHEN VA.New_Tipodedocumento = 'PERMISO ESPECIAL DE PERMANENCIA - PEP' THEN '12'
					ELSE '13'
			END AS Tipo_de_identificacion_del_titular 
			,VA.NIT AS Numero_de_identificacion_del_titular 
			,'' AS Digito_de_verificacion 
			--Se concatea el tipo de documento con el numero unico, con el fin de crear un registro unico
			,UPPER(CONVERT(NVARCHAR(20),CONCAT(D.DCT_Tipo ,'-' ,D.DCT_NumeroUnico))) AS Numero_de_producto 
			,'1' AS Tipo_de_producto 
			--Se genera el numero de transaccion
			,UPPER(CONVERT(NVARCHAR(100),CONCAT(O.OPR_Centro, '-', O.OPR_Tipo ,'-' ,O.OPR_Consecutivo))) AS Numero_de_transaccion 
			,'1' AS Tipo_transaccion 
			,'0' AS Indicador_transaccion_parcial 
			,CONVERT(DECIMAL(17,2),A.AOV_Valor) AS Monto_aplicable_GMF 
			,CONVERT(DECIMAL(17,2),A.AOV_Valor) AS Monto_total_transaccion 
			,UPPER(CONVERT(NVARCHAR(200),A.AOV_Operaci�nTipo)) AS Descripcion_de_la_transaccion 
			,CONCAT(CONVERT(NVARCHAR, OPR_Fecha, 112) ,REPLACE(CONVERT(NVARCHAR, OPR_Fecha, 8), ':', '')) AS Fecha_y_hora_transaccion 
			,CONCAT(CONVERT(NVARCHAR, OPR_Fecha, 112) ,REPLACE(CONVERT(NVARCHAR, OPR_Fecha, 8), ':', '')) AS Fecha_y_hora_utilizacion 
			,O.OPR_Consecutivo AS Codigo_transaccion_original
			,CONCAT(CONVERT(NVARCHAR, OPR_Fecha, 112) ,REPLACE(CONVERT(NVARCHAR, OPR_Fecha, 8), ':', '')) AS Fecha_y_hora_transacci�n_original
			,D.DCT_Tipo AS DCT_Tipo 
			,D.DCT_NumeroUnico AS DCT_NumeroUnico
			,O.OPR_Centro AS OPR_Centro
			,O.OPR_Tipo AS OPR_Tipo
			,O.OPR_Consecutivo AS OPR_Consecutivo
			,O.OPR_Soporte
			,O.OPR_ConsecutivoSoporte
	FROM MERCURIO.FYCBOG.DBO.OPERACION O
		INNER JOIN MERCURIO.FYCBOG.DBO.ASPECTO_OPERACION_VALOR A ON A.AOV_Operaci�nConsecutivo = O.OPR_Consecutivo AND A.AOV_Operaci�nTipo = O.OPR_Tipo
		INNER JOIN MERCURIO.FYCBOG.DBO.ROL_PERSONA_DOCUMENTO R ON R.RPD_DocumentoN�mero = O.OPR_DocumentoN�mero AND R.RPD_DocumentoTipo = O.OPR_DocumentoTipo
		INNER JOIN MERCURIO.FYCBOG.DBO.ITEM_LIQUIDA_SECUENCIA L ON O.OPR_Tipo = L.ILS_Operaci�nOrigen AND A.AOV_ItemNombre = L.ILS_Factor
		INNER JOIN CAVCRM.CAVIPETROL.dbo.VISTA_AFILIADOS VA ON VA.Nit COLLATE Modern_Spanish_CI_AS = R.RPD_IdNit
		INNER JOIN MERCURIO.FYCBOG.DBO.DOCUMENTO D ON D.DCT_N�mero = O.OPR_DocumentoN�mero AND D.DCT_Tipo = O.OPR_DocumentoTipo
		INNER JOIN MERCURIO.FYCBOG.DBO.PRODUCTO P ON P.PRO_AcuerdoTipo = O.OPR_DocumentoTipo
	WHERE --CONVERT(DATE,O.OPR_Fecha) = CONVERT(DATE,GETDATE()-1)
			CONVERT(DATE,O.OPR_Fecha) = CONVERT(DATE,GETDATE()-32)
			--Se filtran las transacciones correspondientes a la cuenta AFAI
			 AND P.PRO_Nombre = 'CavFai' 
			 --Se indican las transacciones que son Operativas
			 AND O.OPR_UsoConsecutivo = 'O' 
			 AND A.AOV_Valor > 0
			 --Se discriminan estos dos tipos de transacciones a las cuales se le aplica GMF
			 AND L.ILS_Operaci�nDestino NOT IN ('GMF_FAICheque', 'GMF_FAIPlanEduCh') 
	GROUP BY VA.NIT ,D.DCT_NumeroUnico ,D.DCT_Tipo ,O.OPR_Consecutivo ,O.OPR_Tipo ,O.OPR_Centro ,A.AOV_Valor ,A.AOV_Operaci�nTipo ,O.OPR_Fecha ,O.OPR_Consecutivo ,VA.New_Tipodedocumento 
			,D.DCT_N�mero ,O.OPR_Soporte ,O.OPR_ConsecutivoSoporte
	order by Fecha_y_hora_transaccion ASC

	SELECT * FROM FYCBOG.FYC.DBO.VINCULO_OPERACIONES

SELECT TOP 100* FROM FYCBOG.FYC.DBO.OPERACION O


SELECT *FROM FYCBOG.DBO.OPERACION O
INNER JOIN FYCBOG.DBO.VINCULO_OPERACIONES A ON  A.VOP_OrigenTipo=OPR_Tipo
AND A.VOP_OrigenConsecutivo=O.OPR_Consecutivo
 ORDER BY OPR_Fecha DESC

WHERE OPR_Consecutivo='100001436'
AND OPR_Tipo='PagoPSEVis'
 ORDER BY OPR_Fecha DESC




INSERT INTO MERCURIO.FYCBOG.DBO.VINCULO_OPERACIONES (VOP_OrigenTipo,VOP_OrigenConsecutivo,VOP_DestinoTipo,VOP_DestinoConsecutivo,VOP_Clase)
SELECT VOP_OrigenTipo,VOP_OrigenConsecutivo,VOP_DestinoTipo,VOP_DestinoConsecutivo,VOP_Clase
FROM  FYCBOG.FYC.DBO.VINCULO_OPERACIONES

SELECT * FROM  MERCURIO.FYCBOG.DBO.ASPECTO_OPERACION_VALOR AOV
	INNER JOIN MERCURIO.FYCBOG.DBO.VINCULO_OPERACIONES V 
		ON AOV.AOV_Operaci�nConsecutivo = V.VOP_DestinoConsecutivo

		SELECT TOP 10* FROM	FYCBOG.FYC.DBO.VINCULO_OPERACIONES V 
		WHERE VOP_OrigenConsecutivo='100001436'

SELECT  TOP 10* 
FROM  FYCBOG.DBO.ASPECTO_OPERACION_VALOR AOV
WHERE AOV_Operaci�nConsecutivo='100091207'
AND AOV_Operaci�nTipo LIKE '%RETIROACH%'

AOV_Operaci�nTipo	AOV_Operaci�nConsecutivo	AOV_ItemNombre	AOV_Valor
RetiroACH	100091207	VrRetiro	10000000


		Tipo_de_Registro	Tipo_de_identificacion_del_titular	Numero_de_identificacion_del_titular	Digito_de_verificacion	Numero_de_producto	Tipo_de_producto	Numero_de_transaccion	Tipo_transaccion	Indicador_transaccion_parcial	Monto_aplicable_GMF	Monto_total_transaccion	Descripcion_de_la_transaccion	Fecha_y_hora_transaccion	Fecha_y_hora_utilizacion	Codigo_transaccion_original	Fecha_y_hora_transacci�n_original
2	1	37748071		AFAI-200008041	1	BOGOTA-RETIROACH-100091207	1	0	10000000.00	10000000.00	RETIROACH	20250223211100	20250223211100	100091207	20250223211100