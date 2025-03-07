USE [SICAV]
GO
/****** Object:  StoredProcedure [dbo].[PA_GENERA_GMF]    Script Date: 4/03/2025 3:16:52 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- GENERA_GMF '03/01/2018','05/31/2018', 5
-- =============================================
-- Author:		VIANETH LIZARAZO E
-- Create date: MAYO 7 2018
-- Description:	SP PARA GENERACIÓN GMF
-- =============================================
-- =============================================
-- Cambio No. 1 , PROYECTO ARANDa 26, RECONOCIMIENTOS INCENTIVOS 
-- Author:		VIANETH LIZARAZO E
-- Create date: MAYO 7 2018
-- Description:	SP PARA GENERACIÓN GMF
-- =============================================
-- ************************************************************************************************************
-- PROYECTO    : sicav
-- MODULO      : 
-- LENGUAJE    : T-SQL(SQLSERVER)  
-- NOMBRE      : PA_GENERA_GMF
-- DESCRIPCION : GENERA GMF
-- PARAMETROS  : N/A
-- AUTOR       : javier D 28/08/2018
-- MODIFICADO  :                                                                                                                    
--*************************************************************************************************************   
---PA_GENERA_GMF '2024-01-31','2024-02-01',1
ALTER PROCEDURE [dbo].[PA_GENERA_GMF]
	@fechaIni SMALLDATETIME, @fechaFin SMALLDATETIME, @BANDERA INT
AS
BEGIN

declare @Factor Float 
Declare @MaximoInsentivo  FLOAT 
select @Factor  = 0.004 -- declara y asigna el factor


-- pendiente verificar los excentos 
select @fechaIni = convert(varchar, @fechaIni , 106) 
select @fechaFin = dateadd(minute,-1,convert(varchar, dateadd(day, 1, @fechaFin)  , 106) ) 

IF @BANDERA = 1
BEGIN

select 'FYCBOG' Servidor,  ASI_Fecha , OPR_Fecha , asi_tipo, ASI_CentroCosto , ASI_Soporte , ASI_ConsecutivoSoporte ,  
       MVC_Línea , MVC_Cuenta , MVC_Valor_Débito , MVC_Valor_Crédito , 
       isnull( MVC_TerceroTipoNit , RPD_IdTipoNit )  as MVC_TerceroTipoNit , -- rpo_tipoNit as MVC_TerceroTipoNit , 
       isnull( MVC_TerceroNit, RPD_IdNit )  MVC_TerceroNit   , -- rpo_Nit as MVC_TerceroNit , 
       MVC_CentroCosto , 
	   OPR_EstadoProducto , OPR_UsoConsecutivo , opr_ciudad, opr_oficina, OPR_Usuario , 
	   ASI_OPERACION , ASI_OPERACION_CONSECUTIVO , 
           ( isnull(McpGmfPagaAfi.MCP_Valor ,0) + isnull(McpGmfPagacav.MCP_Valor ,0) ) / @Factor Base_Gravado ,   
           case when  abs(isnull( McpGmfBaseAfi.MCP_Valor ,0) + isnull(McpGmfBaseCav.MCP_Valor,0) ) > abs(( isnull(McpGmfPagaAfi.MCP_Valor ,0) + isnull(McpGmfPagacav.MCP_Valor ,0) ) / @Factor )  
                    then abs(isnull( McpGmfBaseAfi.MCP_Valor ,0) + isnull(McpGmfBaseCav.MCP_Valor,0) ) - abs(( isnull(McpGmfPagaAfi.MCP_Valor ,0) + isnull(McpGmfPagacav.MCP_Valor ,0) ) / @Factor )  
                    else 0 end * 
           case when ( isnull( McpGmfBaseAfi.MCP_Valor ,0) + isnull(McpGmfBaseCav.MCP_Valor,0) ) < 0 then -1 else 1 end 
           as Base_Excento  ,
	   -- case when round( isnull(McpGmfPagaAfi.MCP_Valor ,0) + isnull(McpGmfPagacav.MCP_Valor ,0),3 ) <> 0.0 then isnull( McpGmfBaseAfi.MCP_Valor ,0) + isnull(McpGmfBaseCav.MCP_Valor,0) else 0 end Base_Gravado , 
	   -- case when round( isnull(McpGmfPagaAfi.MCP_Valor ,0) + isnull(McpGmfPagacav.MCP_Valor ,0),3 ) <> 0.0 then 0 else isnull( McpGmfBaseAfi.MCP_Valor ,0) + isnull(McpGmfBaseCav.MCP_Valor,0) end Base_Excento ,   
	   isnull( McpGmfPagaAfi.MCP_Valor ,0) + isnull(McpGmfPagaCav.MCP_Valor,0)   ImpuestoGMF
from fycbog.fyc.dbo.OPERACION OpGMF  (nolock) 
left join fycbog.fyc.dbo.ASIENTO asi  (nolock)  on ( ASI_Fecha between @fechaIni and @fechaFin  and ASI_OPERACION = OpGMF.OPR_Tipo and ASI_OPERACION_CONSECUTIVO =  OpGMF.OPR_Consecutivo ) 
Left join fycbog.fyc.dbo.movimiento Mov  (nolock)  on ( asi.ASI_Tipo = MVC_AsientoTipo and asi.ASI_Consecutivo = MVC_AsientoConsecutivo  and isnull( MVC_Cuenta ,'2430' )   like '2430%') 
left join fycbog.fyc.dbo.MOVIMIENTO_CUENTA_PARALELA McpGmfBaseAfi   (nolock)  on ( OpGMF.OPR_Tipo = McpGmfBaseAfi.MCP_OperaciónTipo and OpGMF.OPR_Consecutivo = McpGmfBaseAfi.MCP_OperaciónConsecutivo and McpGmfBaseAfi.MCP_Cuenta = 'GMFControlND' ) 
left join fycbog.fyc.dbo.MOVIMIENTO_CUENTA_PARALELA McpGmfBaseCav   (nolock)  on ( OpGMF.OPR_Tipo = McpGmfBaseCav.MCP_OperaciónTipo and OpGMF.OPR_Consecutivo = McpGmfBaseCav.MCP_OperaciónConsecutivo and McpGmfBaseCav.MCP_Cuenta = 'GMFBasePagoCav' ) 
left join fycbog.fyc.dbo.MOVIMIENTO_CUENTA_PARALELA McpGmfPagaAfi   (nolock)  on ( OpGMF.OPR_Tipo = McpGmfPagaAfi.MCP_OperaciónTipo and OpGMF.OPR_Consecutivo = McpGmfPagaAfi.MCP_OperaciónConsecutivo and McpGmfPagaAfi.MCP_Cuenta = 'GMFVrImpuesto' ) 
left join fycbog.fyc.dbo.MOVIMIENTO_CUENTA_PARALELA McpGmfPagaCav   (nolock)  on ( OpGMF.OPR_Tipo = McpGmfPagaCav.MCP_OperaciónTipo and OpGMF.OPR_Consecutivo = McpGmfPagaCav.MCP_OperaciónConsecutivo and McpGmfPagaCav.MCP_Cuenta = 'GMFVrImpuestoCav') 
left join fycbog.fyc.dbo.SIGA_ROL_PERSONA_DOCUMENTO  rpd (nolock) on ( rpd.RPD_DocumentoTipo  = OpGMF.OPR_DocumentoTipo   and  rpd.RPD_DocumentoNúmero = OpGMF.OPR_DocumentoNúmero ) 
where OpGMF.OPR_Fecha   between @fechaIni and @fechaFin 
  and exists ( select * from fycbog.fyc.dbo.MOVIMIENTO_CUENTA_PARALELA mcpGMF  (nolock) 
               where OpGMF.OPR_Tipo = mcpGMF.MCP_OperaciónTipo and OpGMF.OPR_Consecutivo = mcpGMF.MCP_OperaciónConsecutivo 
			     and mcpGMF.MCP_Cuenta in ( select cdr.CDR_Nombre  from fycbog.fyc.dbo.CUENTA_DE_REGISTRO cdr  (nolock)  where cdr.CDR_Nombre like 'GMF%') )  
union
select 'FYCBAR' Servidor,  ASI_Fecha , OPR_Fecha , asi_tipo, ASI_CentroCosto , ASI_Soporte , ASI_ConsecutivoSoporte ,  
       MVC_Línea , MVC_Cuenta , MVC_Valor_Débito , MVC_Valor_Crédito , 
       isnull( MVC_TerceroTipoNit , RPD_IdTipoNit )  as MVC_TerceroTipoNit , -- rpo_tipoNit as MVC_TerceroTipoNit , 
       isnull( MVC_TerceroNit, RPD_IdNit )  MVC_TerceroNit   , -- rpo_Nit as MVC_TerceroNit , 
       MVC_CentroCosto , 
	   OPR_EstadoProducto , OPR_UsoConsecutivo , opr_ciudad, opr_oficina, OPR_Usuario , 
	   ASI_OPERACION , ASI_OPERACION_CONSECUTIVO , 
           ( isnull(McpGmfPagaAfi.MCP_Valor ,0) + isnull(McpGmfPagacav.MCP_Valor ,0) ) / @Factor Base_Gravado ,   
           case when  abs(isnull( McpGmfBaseAfi.MCP_Valor ,0) + isnull(McpGmfBaseCav.MCP_Valor,0) ) > abs(( isnull(McpGmfPagaAfi.MCP_Valor ,0) + isnull(McpGmfPagacav.MCP_Valor ,0) ) / @Factor )  
                    then abs(isnull( McpGmfBaseAfi.MCP_Valor ,0) + isnull(McpGmfBaseCav.MCP_Valor,0) ) - abs(( isnull(McpGmfPagaAfi.MCP_Valor ,0) + isnull(McpGmfPagacav.MCP_Valor ,0) ) / @Factor )  
                    else 0 end * 
           case when ( isnull( McpGmfBaseAfi.MCP_Valor ,0) + isnull(McpGmfBaseCav.MCP_Valor,0) ) < 0 then -1 else 1 end 
           as Base_Excento  ,
	   -- case when round( isnull(McpGmfPagaAfi.MCP_Valor ,0) + isnull(McpGmfPagacav.MCP_Valor ,0),3 ) <> 0.0 then isnull( McpGmfBaseAfi.MCP_Valor ,0) + isnull(McpGmfBaseCav.MCP_Valor,0) else 0 end Base_Gravado , 
	   -- case when round( isnull(McpGmfPagaAfi.MCP_Valor ,0) + isnull(McpGmfPagacav.MCP_Valor ,0),3 ) <> 0.0 then 0 else isnull( McpGmfBaseAfi.MCP_Valor ,0) + isnull(McpGmfBaseCav.MCP_Valor,0) end Base_Excento ,   
	   isnull( McpGmfPagaAfi.MCP_Valor ,0) + isnull(McpGmfPagaCav.MCP_Valor,0)   ImpuestoGMF
from fycbar.fyc.dbo.OPERACION OpGMF  (nolock) 
left join fycbar.fyc.dbo.ASIENTO asi  (nolock)  on ( ASI_Fecha between @fechaIni and @fechaFin  and ASI_OPERACION = OpGMF.OPR_Tipo and ASI_OPERACION_CONSECUTIVO =  OpGMF.OPR_Consecutivo ) 
Left join fycbar.fyc.dbo.movimiento Mov  (nolock)  on ( asi.ASI_Tipo = MVC_AsientoTipo and asi.ASI_Consecutivo = MVC_AsientoConsecutivo  and isnull( MVC_Cuenta ,'2430' )   like '2430%') 
left join fycbar.fyc.dbo.MOVIMIENTO_CUENTA_PARALELA McpGmfBaseAfi   (nolock)  on ( OpGMF.OPR_Tipo = McpGmfBaseAfi.MCP_OperaciónTipo and OpGMF.OPR_Consecutivo = McpGmfBaseAfi.MCP_OperaciónConsecutivo and McpGmfBaseAfi.MCP_Cuenta = 'GMFControlND' ) 
left join fycbar.fyc.dbo.MOVIMIENTO_CUENTA_PARALELA McpGmfBaseCav   (nolock)  on ( OpGMF.OPR_Tipo = McpGmfBaseCav.MCP_OperaciónTipo and OpGMF.OPR_Consecutivo = McpGmfBaseCav.MCP_OperaciónConsecutivo and McpGmfBaseCav.MCP_Cuenta = 'GMFBasePagoCav' ) 
left join fycbar.fyc.dbo.MOVIMIENTO_CUENTA_PARALELA McpGmfPagaAfi   (nolock)  on ( OpGMF.OPR_Tipo = McpGmfPagaAfi.MCP_OperaciónTipo and OpGMF.OPR_Consecutivo = McpGmfPagaAfi.MCP_OperaciónConsecutivo and McpGmfPagaAfi.MCP_Cuenta = 'GMFVrImpuesto' ) 
left join fycbar.fyc.dbo.MOVIMIENTO_CUENTA_PARALELA McpGmfPagaCav   (nolock)  on ( OpGMF.OPR_Tipo = McpGmfPagaCav.MCP_OperaciónTipo and OpGMF.OPR_Consecutivo = McpGmfPagaCav.MCP_OperaciónConsecutivo and McpGmfPagaCav.MCP_Cuenta = 'GMFVrImpuestoCav') 
left join fycbar.fyc.dbo.SIGA_ROL_PERSONA_DOCUMENTO  rpd (nolock) on ( rpd.RPD_DocumentoTipo  = OpGMF.OPR_DocumentoTipo   and  rpd.RPD_DocumentoNúmero = OpGMF.OPR_DocumentoNúmero ) 
where OpGMF.OPR_Fecha   between @fechaIni and @fechaFin 
  and exists ( select * from fycbar.fyc.dbo.MOVIMIENTO_CUENTA_PARALELA mcpGMF  (nolock) 
               where OpGMF.OPR_Tipo = mcpGMF.MCP_OperaciónTipo and OpGMF.OPR_Consecutivo = mcpGMF.MCP_OperaciónConsecutivo 
			     and mcpGMF.MCP_Cuenta in ( select cdr.CDR_Nombre  from fycbar.fyc.dbo.CUENTA_DE_REGISTRO cdr  (nolock)  where cdr.CDR_Nombre like 'GMF%') )  
union
select 'FYCBUC' Servidor,  ASI_Fecha , OPR_Fecha , asi_tipo, ASI_CentroCosto , ASI_Soporte , ASI_ConsecutivoSoporte ,  
       MVC_Línea , MVC_Cuenta , MVC_Valor_Débito , MVC_Valor_Crédito , 
       isnull( MVC_TerceroTipoNit , RPD_IdTipoNit )  as MVC_TerceroTipoNit , -- rpo_tipoNit as MVC_TerceroTipoNit , 
       isnull( MVC_TerceroNit, RPD_IdNit )  MVC_TerceroNit   , -- rpo_Nit as MVC_TerceroNit , 
       MVC_CentroCosto , 
	   OPR_EstadoProducto , OPR_UsoConsecutivo , opr_ciudad, opr_oficina, OPR_Usuario , 
	   ASI_OPERACION , ASI_OPERACION_CONSECUTIVO , 
           ( isnull(McpGmfPagaAfi.MCP_Valor ,0) + isnull(McpGmfPagacav.MCP_Valor ,0) ) / @Factor Base_Gravado ,   
           case when  abs(isnull( McpGmfBaseAfi.MCP_Valor ,0) + isnull(McpGmfBaseCav.MCP_Valor,0) ) > abs(( isnull(McpGmfPagaAfi.MCP_Valor ,0) + isnull(McpGmfPagacav.MCP_Valor ,0) ) / @Factor )  
                    then abs(isnull( McpGmfBaseAfi.MCP_Valor ,0) + isnull(McpGmfBaseCav.MCP_Valor,0) ) - abs(( isnull(McpGmfPagaAfi.MCP_Valor ,0) + isnull(McpGmfPagacav.MCP_Valor ,0) ) / @Factor )  
                    else 0 end * 
           case when ( isnull( McpGmfBaseAfi.MCP_Valor ,0) + isnull(McpGmfBaseCav.MCP_Valor,0) ) < 0 then -1 else 1 end 
           as Base_Excento  ,
	   -- case when round( isnull(McpGmfPagaAfi.MCP_Valor ,0) + isnull(McpGmfPagacav.MCP_Valor ,0),3 ) <> 0.0 then isnull( McpGmfBaseAfi.MCP_Valor ,0) + isnull(McpGmfBaseCav.MCP_Valor,0) else 0 end Base_Gravado , 
	   -- case when round( isnull(McpGmfPagaAfi.MCP_Valor ,0) + isnull(McpGmfPagacav.MCP_Valor ,0),3 ) <> 0.0 then 0 else isnull( McpGmfBaseAfi.MCP_Valor ,0) + isnull(McpGmfBaseCav.MCP_Valor,0) end Base_Excento ,   
	   isnull( McpGmfPagaAfi.MCP_Valor ,0) + isnull(McpGmfPagaCav.MCP_Valor,0)   ImpuestoGMF
from fycbuc.fyc.dbo.OPERACION OpGMF  (nolock) 
left join fycbuc.fyc.dbo.ASIENTO asi  (nolock)  on ( ASI_Fecha between @fechaIni and @fechaFin  and ASI_OPERACION = OpGMF.OPR_Tipo and ASI_OPERACION_CONSECUTIVO =  OpGMF.OPR_Consecutivo ) 
Left join fycbuc.fyc.dbo.movimiento Mov  (nolock)  on ( asi.ASI_Tipo = MVC_AsientoTipo and asi.ASI_Consecutivo = MVC_AsientoConsecutivo  and isnull( MVC_Cuenta ,'2430' )   like '2430%') 
left join fycbuc.fyc.dbo.MOVIMIENTO_CUENTA_PARALELA McpGmfBaseAfi   (nolock)  on ( OpGMF.OPR_Tipo = McpGmfBaseAfi.MCP_OperaciónTipo and OpGMF.OPR_Consecutivo = McpGmfBaseAfi.MCP_OperaciónConsecutivo and McpGmfBaseAfi.MCP_Cuenta = 'GMFControlND' ) 
left join fycbuc.fyc.dbo.MOVIMIENTO_CUENTA_PARALELA McpGmfBaseCav   (nolock)  on ( OpGMF.OPR_Tipo = McpGmfBaseCav.MCP_OperaciónTipo and OpGMF.OPR_Consecutivo = McpGmfBaseCav.MCP_OperaciónConsecutivo and McpGmfBaseCav.MCP_Cuenta = 'GMFBasePagoCav' ) 
left join fycbuc.fyc.dbo.MOVIMIENTO_CUENTA_PARALELA McpGmfPagaAfi   (nolock)  on ( OpGMF.OPR_Tipo = McpGmfPagaAfi.MCP_OperaciónTipo and OpGMF.OPR_Consecutivo = McpGmfPagaAfi.MCP_OperaciónConsecutivo and McpGmfPagaAfi.MCP_Cuenta = 'GMFVrImpuesto' ) 
left join fycbuc.fyc.dbo.MOVIMIENTO_CUENTA_PARALELA McpGmfPagaCav   (nolock)  on ( OpGMF.OPR_Tipo = McpGmfPagaCav.MCP_OperaciónTipo and OpGMF.OPR_Consecutivo = McpGmfPagaCav.MCP_OperaciónConsecutivo and McpGmfPagaCav.MCP_Cuenta = 'GMFVrImpuestoCav') 
left join fycbuc.fyc.dbo.SIGA_ROL_PERSONA_DOCUMENTO  rpd (nolock) on ( rpd.RPD_DocumentoTipo  = OpGMF.OPR_DocumentoTipo   and  rpd.RPD_DocumentoNúmero = OpGMF.OPR_DocumentoNúmero ) 
where OpGMF.OPR_Fecha   between @fechaIni and @fechaFin 
  and exists ( select * from fycbuc.fyc.dbo.MOVIMIENTO_CUENTA_PARALELA mcpGMF  (nolock) 
               where OpGMF.OPR_Tipo = mcpGMF.MCP_OperaciónTipo and OpGMF.OPR_Consecutivo = mcpGMF.MCP_OperaciónConsecutivo 
			     and mcpGMF.MCP_Cuenta in ( select cdr.CDR_Nombre  from fycbuc.fyc.dbo.CUENTA_DE_REGISTRO cdr  (nolock)  where cdr.CDR_Nombre like 'GMF%') )  
union
select 'FYCCAR' Servidor,  ASI_Fecha , OPR_Fecha , asi_tipo, ASI_CentroCosto , ASI_Soporte , ASI_ConsecutivoSoporte ,  
       MVC_Línea , MVC_Cuenta , MVC_Valor_Débito , MVC_Valor_Crédito , 
       isnull( MVC_TerceroTipoNit , RPD_IdTipoNit )  as MVC_TerceroTipoNit , -- rpo_tipoNit as MVC_TerceroTipoNit , 
       isnull( MVC_TerceroNit, RPD_IdNit )  MVC_TerceroNit   , -- rpo_Nit as MVC_TerceroNit , 
       MVC_CentroCosto , 
	   OPR_EstadoProducto , OPR_UsoConsecutivo , opr_ciudad, opr_oficina, OPR_Usuario , 
	   ASI_OPERACION , ASI_OPERACION_CONSECUTIVO , 
           ( isnull(McpGmfPagaAfi.MCP_Valor ,0) + isnull(McpGmfPagacav.MCP_Valor ,0) ) / @Factor Base_Gravado ,   
           case when  abs(isnull( McpGmfBaseAfi.MCP_Valor ,0) + isnull(McpGmfBaseCav.MCP_Valor,0) ) > abs(( isnull(McpGmfPagaAfi.MCP_Valor ,0) + isnull(McpGmfPagacav.MCP_Valor ,0) ) / @Factor )  
                    then abs(isnull( McpGmfBaseAfi.MCP_Valor ,0) + isnull(McpGmfBaseCav.MCP_Valor,0) ) - abs(( isnull(McpGmfPagaAfi.MCP_Valor ,0) + isnull(McpGmfPagacav.MCP_Valor ,0) ) / @Factor )  
                    else 0 end * 
           case when ( isnull( McpGmfBaseAfi.MCP_Valor ,0) + isnull(McpGmfBaseCav.MCP_Valor,0) ) < 0 then -1 else 1 end 
           as Base_Excento  ,
	   -- case when round( isnull(McpGmfPagaAfi.MCP_Valor ,0) + isnull(McpGmfPagacav.MCP_Valor ,0),3 ) <> 0.0 then isnull( McpGmfBaseAfi.MCP_Valor ,0) + isnull(McpGmfBaseCav.MCP_Valor,0) else 0 end Base_Gravado , 
	   -- case when round( isnull(McpGmfPagaAfi.MCP_Valor ,0) + isnull(McpGmfPagacav.MCP_Valor ,0),3 ) <> 0.0 then 0 else isnull( McpGmfBaseAfi.MCP_Valor ,0) + isnull(McpGmfBaseCav.MCP_Valor,0) end Base_Excento ,   
	   isnull( McpGmfPagaAfi.MCP_Valor ,0) + isnull(McpGmfPagaCav.MCP_Valor,0)   ImpuestoGMF
from fyccar.fyc.dbo.OPERACION OpGMF  (nolock) 
left join fyccar.fyc.dbo.ASIENTO asi  (nolock)  on ( ASI_Fecha between @fechaIni and @fechaFin  and ASI_OPERACION = OpGMF.OPR_Tipo and ASI_OPERACION_CONSECUTIVO =  OpGMF.OPR_Consecutivo ) 
Left join fyccar.fyc.dbo.movimiento Mov  (nolock)  on ( asi.ASI_Tipo = MVC_AsientoTipo and asi.ASI_Consecutivo = MVC_AsientoConsecutivo  and isnull( MVC_Cuenta ,'2430' )   like '2430%') 
left join fyccar.fyc.dbo.MOVIMIENTO_CUENTA_PARALELA McpGmfBaseAfi   (nolock)  on ( OpGMF.OPR_Tipo = McpGmfBaseAfi.MCP_OperaciónTipo and OpGMF.OPR_Consecutivo = McpGmfBaseAfi.MCP_OperaciónConsecutivo and McpGmfBaseAfi.MCP_Cuenta = 'GMFControlND' ) 
left join fyccar.fyc.dbo.MOVIMIENTO_CUENTA_PARALELA McpGmfBaseCav   (nolock)  on ( OpGMF.OPR_Tipo = McpGmfBaseCav.MCP_OperaciónTipo and OpGMF.OPR_Consecutivo = McpGmfBaseCav.MCP_OperaciónConsecutivo and McpGmfBaseCav.MCP_Cuenta = 'GMFBasePagoCav' ) 
left join fyccar.fyc.dbo.MOVIMIENTO_CUENTA_PARALELA McpGmfPagaAfi   (nolock)  on ( OpGMF.OPR_Tipo = McpGmfPagaAfi.MCP_OperaciónTipo and OpGMF.OPR_Consecutivo = McpGmfPagaAfi.MCP_OperaciónConsecutivo and McpGmfPagaAfi.MCP_Cuenta = 'GMFVrImpuesto' ) 
left join fyccar.fyc.dbo.MOVIMIENTO_CUENTA_PARALELA McpGmfPagaCav   (nolock)  on ( OpGMF.OPR_Tipo = McpGmfPagaCav.MCP_OperaciónTipo and OpGMF.OPR_Consecutivo = McpGmfPagaCav.MCP_OperaciónConsecutivo and McpGmfPagaCav.MCP_Cuenta = 'GMFVrImpuestoCav') 
left join fyccar.fyc.dbo.SIGA_ROL_PERSONA_DOCUMENTO  rpd (nolock) on ( rpd.RPD_DocumentoTipo  = OpGMF.OPR_DocumentoTipo   and  rpd.RPD_DocumentoNúmero = OpGMF.OPR_DocumentoNúmero ) 
where OpGMF.OPR_Fecha   between @fechaIni and @fechaFin 
  and exists ( select * from fyccar.fyc.dbo.MOVIMIENTO_CUENTA_PARALELA mcpGMF  (nolock) 
               where OpGMF.OPR_Tipo = mcpGMF.MCP_OperaciónTipo and OpGMF.OPR_Consecutivo = mcpGMF.MCP_OperaciónConsecutivo 
			     and mcpGMF.MCP_Cuenta in ( select cdr.CDR_Nombre  from fyccar.fyc.dbo.CUENTA_DE_REGISTRO cdr  (nolock)  where cdr.CDR_Nombre like 'GMF%') )  
union
select 'FYCOTROS' Servidor,  ASI_Fecha , OPR_Fecha , asi_tipo, ASI_CentroCosto , ASI_Soporte , ASI_ConsecutivoSoporte ,  
       MVC_Línea , MVC_Cuenta , MVC_Valor_Débito , MVC_Valor_Crédito , 
       isnull( MVC_TerceroTipoNit , RPD_IdTipoNit )  as MVC_TerceroTipoNit , -- rpo_tipoNit as MVC_TerceroTipoNit , 
       isnull( MVC_TerceroNit, RPD_IdNit )  MVC_TerceroNit   , -- rpo_Nit as MVC_TerceroNit , 
       MVC_CentroCosto , 
	   OPR_EstadoProducto , OPR_UsoConsecutivo , opr_ciudad, opr_oficina, OPR_Usuario , 
	   ASI_OPERACION , ASI_OPERACION_CONSECUTIVO , 
           ( isnull(McpGmfPagaAfi.MCP_Valor ,0) + isnull(McpGmfPagacav.MCP_Valor ,0) ) / @Factor Base_Gravado ,   
           case when  abs(isnull( McpGmfBaseAfi.MCP_Valor ,0) + isnull(McpGmfBaseCav.MCP_Valor,0) ) > abs(( isnull(McpGmfPagaAfi.MCP_Valor ,0) + isnull(McpGmfPagacav.MCP_Valor ,0) ) / @Factor )  
                    then abs(isnull( McpGmfBaseAfi.MCP_Valor ,0) + isnull(McpGmfBaseCav.MCP_Valor,0) ) - abs(( isnull(McpGmfPagaAfi.MCP_Valor ,0) + isnull(McpGmfPagacav.MCP_Valor ,0) ) / @Factor )  
                    else 0 end * 
           case when ( isnull( McpGmfBaseAfi.MCP_Valor ,0) + isnull(McpGmfBaseCav.MCP_Valor,0) ) < 0 then -1 else 1 end 
           as Base_Excento  ,
	   -- case when round( isnull(McpGmfPagaAfi.MCP_Valor ,0) + isnull(McpGmfPagacav.MCP_Valor ,0),3 ) <> 0.0 then isnull( McpGmfBaseAfi.MCP_Valor ,0) + isnull(McpGmfBaseCav.MCP_Valor,0) else 0 end Base_Gravado , 
	   -- case when round( isnull(McpGmfPagaAfi.MCP_Valor ,0) + isnull(McpGmfPagacav.MCP_Valor ,0),3 ) <> 0.0 then 0 else isnull( McpGmfBaseAfi.MCP_Valor ,0) + isnull(McpGmfBaseCav.MCP_Valor,0) end Base_Excento ,   
	   isnull( McpGmfPagaAfi.MCP_Valor ,0) + isnull(McpGmfPagaCav.MCP_Valor,0)   ImpuestoGMF
from fycotros.fyc.dbo.OPERACION OpGMF  (nolock) 
left join fycotros.fyc.dbo.ASIENTO asi  (nolock)  on ( ASI_Fecha between @fechaIni and @fechaFin  and ASI_OPERACION = OpGMF.OPR_Tipo and ASI_OPERACION_CONSECUTIVO =  OpGMF.OPR_Consecutivo ) 
Left join fycotros.fyc.dbo.movimiento Mov  (nolock)  on ( asi.ASI_Tipo = MVC_AsientoTipo and asi.ASI_Consecutivo = MVC_AsientoConsecutivo  and isnull( MVC_Cuenta ,'2430' )   like '2430%') 
left join fycotros.fyc.dbo.MOVIMIENTO_CUENTA_PARALELA McpGmfBaseAfi   (nolock)  on ( OpGMF.OPR_Tipo = McpGmfBaseAfi.MCP_OperaciónTipo and OpGMF.OPR_Consecutivo = McpGmfBaseAfi.MCP_OperaciónConsecutivo and McpGmfBaseAfi.MCP_Cuenta = 'GMFControlND' ) 
left join fycotros.fyc.dbo.MOVIMIENTO_CUENTA_PARALELA McpGmfBaseCav   (nolock)  on ( OpGMF.OPR_Tipo = McpGmfBaseCav.MCP_OperaciónTipo and OpGMF.OPR_Consecutivo = McpGmfBaseCav.MCP_OperaciónConsecutivo and McpGmfBaseCav.MCP_Cuenta = 'GMFBasePagoCav' ) 
left join fycotros.fyc.dbo.MOVIMIENTO_CUENTA_PARALELA McpGmfPagaAfi   (nolock)  on ( OpGMF.OPR_Tipo = McpGmfPagaAfi.MCP_OperaciónTipo and OpGMF.OPR_Consecutivo = McpGmfPagaAfi.MCP_OperaciónConsecutivo and McpGmfPagaAfi.MCP_Cuenta = 'GMFVrImpuesto' ) 
left join fycotros.fyc.dbo.MOVIMIENTO_CUENTA_PARALELA McpGmfPagaCav   (nolock)  on ( OpGMF.OPR_Tipo = McpGmfPagaCav.MCP_OperaciónTipo and OpGMF.OPR_Consecutivo = McpGmfPagaCav.MCP_OperaciónConsecutivo and McpGmfPagaCav.MCP_Cuenta = 'GMFVrImpuestoCav') 
left join fycotros.fyc.dbo.SIGA_ROL_PERSONA_DOCUMENTO  rpd (nolock) on ( rpd.RPD_DocumentoTipo  = OpGMF.OPR_DocumentoTipo   and  rpd.RPD_DocumentoNúmero = OpGMF.OPR_DocumentoNúmero ) 
where OpGMF.OPR_Fecha   between @fechaIni and @fechaFin 
  and exists ( select * from fycotros.fyc.dbo.MOVIMIENTO_CUENTA_PARALELA mcpGMF  (nolock) 
               where OpGMF.OPR_Tipo = mcpGMF.MCP_OperaciónTipo and OpGMF.OPR_Consecutivo = mcpGMF.MCP_OperaciónConsecutivo 
			     and mcpGMF.MCP_Cuenta in ( select cdr.CDR_Nombre  from fycotros.fyc.dbo.CUENTA_DE_REGISTRO cdr  (nolock)  where cdr.CDR_Nombre like 'GMF%') )  
END


--and OPR_Tipo like 'gmf%c%'
-- and OPR_Soporte = 'nota contable' 
-- and OPR_ConsecutivoSoporte =  7420484


IF @BANDERA = 2
BEGIN

-- cnsulta movimientos contables sin detalle cuentas de control 
select 'FYCBOG' Servidor, ASI_Fecha , OPR_Fecha ,  ASI_Tipo , ASI_CentroCosto , ASI_Soporte , ASI_ConsecutivoSoporte ,  
       MVC_Línea , MVC_Cuenta , MVC_Valor_Débito , MVC_Valor_Crédito , MVC_TerceroTipoNit , MVC_TerceroNit , MVC_CentroCosto , 
	   OPR_EstadoProducto , OPR_UsoConsecutivo , opr_ciudad, opr_oficina, OPR_Usuario , 
	   ASI_OPERACION , ASI_OPERACION_CONSECUTIVO , 
	   ( MVC_Valor_Crédito - MVC_Valor_Débito)/0.004  Base_Gravado , 
	   0  Base_Excento , 
--	   when isnull( McpGmfPagaAfi.MCP_OperaciónConsecutivo , -1) > 0 then  isnull(GMFControlND,0) + isnull(GMFBasePagoCav ,0)  else 0 end 
       ( MVC_Valor_Crédito - MVC_Valor_Débito) ImpuestoConta 
--	   , * 
  from fycbog.fyc.dbo.ASIENTO with ( nolock) 
  join fycbog.fyc.dbo.MOVIMIENTO with ( nolock) 
on ( ASI_Tipo = MVC_AsientoTipo and ASI_Consecutivo = MVC_AsientoConsecutivo ) 
left join fycbog.fyc.dbo.OPERACION OpGMF with (nolock)  on ( OpGMF.OPR_Tipo = ASI_OPERACION and OpGMF.OPR_Consecutivo = ASI_OPERACION_CONSECUTIVO ) 
left join fycbog.fyc.dbo.MOVIMIENTO_CUENTA_PARALELA McpGmfBaseAfi  with (nolock) on ( OpGMF.OPR_Tipo = McpGmfBaseAfi.MCP_OperaciónTipo and OpGMF.OPR_Consecutivo = McpGmfBaseAfi.MCP_OperaciónConsecutivo and McpGmfBaseAfi.MCP_Cuenta = 'GMFControlND' ) 
left join fycbog.fyc.dbo.MOVIMIENTO_CUENTA_PARALELA McpGmfBaseCav  with (nolock) on ( OpGMF.OPR_Tipo = McpGmfBaseCav.MCP_OperaciónTipo and OpGMF.OPR_Consecutivo = McpGmfBaseCav.MCP_OperaciónConsecutivo and McpGmfBaseCav.MCP_Cuenta = 'GMFBasePagoCav' ) 
where ASI_Fecha between @fechaIni and @fechaFin 
 and MVC_Cuenta   like '2430%'
 and isnull( McpGmfBaseAfi.MCP_OperaciónTipo , 'SinOperacion') = 'SinOperacion' 
 and isnull( McpGmfBaseCav.MCP_OperaciónTipo , 'SinOperacion') = 'SinOperacion'
union
select 'FYCBAR' Servidor, ASI_Fecha , OPR_Fecha ,  ASI_Tipo , ASI_CentroCosto , ASI_Soporte , ASI_ConsecutivoSoporte ,  
       MVC_Línea , MVC_Cuenta , MVC_Valor_Débito , MVC_Valor_Crédito , MVC_TerceroTipoNit , MVC_TerceroNit , MVC_CentroCosto , 
	   OPR_EstadoProducto , OPR_UsoConsecutivo , opr_ciudad, opr_oficina, OPR_Usuario , 
	   ASI_OPERACION , ASI_OPERACION_CONSECUTIVO , 
	   ( MVC_Valor_Crédito - MVC_Valor_Débito)/0.004  Base_Gravado , 
	   0  Base_Excento , 
--	   when isnull( McpGmfPagaAfi.MCP_OperaciónConsecutivo , -1) > 0 then  isnull(GMFControlND,0) + isnull(GMFBasePagoCav ,0)  else 0 end 
       ( MVC_Valor_Crédito - MVC_Valor_Débito) ImpuestoConta 
--	   , * 
  from fycbar.fyc.dbo.ASIENTO with ( nolock) 
  join fycbar.fyc.dbo.MOVIMIENTO with ( nolock) 
on ( ASI_Tipo = MVC_AsientoTipo and ASI_Consecutivo = MVC_AsientoConsecutivo ) 
left join fycbar.fyc.dbo.OPERACION OpGMF with (nolock)  on ( OpGMF.OPR_Tipo = ASI_OPERACION and OpGMF.OPR_Consecutivo = ASI_OPERACION_CONSECUTIVO ) 
left join fycbar.fyc.dbo.MOVIMIENTO_CUENTA_PARALELA McpGmfBaseAfi  with (nolock) on ( OpGMF.OPR_Tipo = McpGmfBaseAfi.MCP_OperaciónTipo and OpGMF.OPR_Consecutivo = McpGmfBaseAfi.MCP_OperaciónConsecutivo and McpGmfBaseAfi.MCP_Cuenta = 'GMFControlND' ) 
left join fycbar.fyc.dbo.MOVIMIENTO_CUENTA_PARALELA McpGmfBaseCav  with (nolock) on ( OpGMF.OPR_Tipo = McpGmfBaseCav.MCP_OperaciónTipo and OpGMF.OPR_Consecutivo = McpGmfBaseCav.MCP_OperaciónConsecutivo and McpGmfBaseCav.MCP_Cuenta = 'GMFBasePagoCav' ) 
where ASI_Fecha between @fechaIni and @fechaFin 
 and MVC_Cuenta   like '2430%'
 and isnull( McpGmfBaseAfi.MCP_OperaciónTipo , 'SinOperacion') = 'SinOperacion' 
 and isnull( McpGmfBaseCav.MCP_OperaciónTipo , 'SinOperacion') = 'SinOperacion'
 union
 select 'FYCBUC' Servidor, ASI_Fecha , OPR_Fecha ,  ASI_Tipo , ASI_CentroCosto , ASI_Soporte , ASI_ConsecutivoSoporte ,  
       MVC_Línea , MVC_Cuenta , MVC_Valor_Débito , MVC_Valor_Crédito , MVC_TerceroTipoNit , MVC_TerceroNit , MVC_CentroCosto , 
	   OPR_EstadoProducto , OPR_UsoConsecutivo , opr_ciudad, opr_oficina, OPR_Usuario , 
	   ASI_OPERACION , ASI_OPERACION_CONSECUTIVO , 
	   ( MVC_Valor_Crédito - MVC_Valor_Débito)/0.004  Base_Gravado , 
	   0  Base_Excento , 
--	   when isnull( McpGmfPagaAfi.MCP_OperaciónConsecutivo , -1) > 0 then  isnull(GMFControlND,0) + isnull(GMFBasePagoCav ,0)  else 0 end 
       ( MVC_Valor_Crédito - MVC_Valor_Débito) ImpuestoConta 
--	   , * 
  from fycbuc.fyc.dbo.ASIENTO with ( nolock) 
  join fycbuc.fyc.dbo.MOVIMIENTO with ( nolock) 
on ( ASI_Tipo = MVC_AsientoTipo and ASI_Consecutivo = MVC_AsientoConsecutivo ) 
left join fycbuc.fyc.dbo.OPERACION OpGMF with (nolock)  on ( OpGMF.OPR_Tipo = ASI_OPERACION and OpGMF.OPR_Consecutivo = ASI_OPERACION_CONSECUTIVO ) 
left join fycbuc.fyc.dbo.MOVIMIENTO_CUENTA_PARALELA McpGmfBaseAfi  with (nolock) on ( OpGMF.OPR_Tipo = McpGmfBaseAfi.MCP_OperaciónTipo and OpGMF.OPR_Consecutivo = McpGmfBaseAfi.MCP_OperaciónConsecutivo and McpGmfBaseAfi.MCP_Cuenta = 'GMFControlND' ) 
left join fycbuc.fyc.dbo.MOVIMIENTO_CUENTA_PARALELA McpGmfBaseCav  with (nolock) on ( OpGMF.OPR_Tipo = McpGmfBaseCav.MCP_OperaciónTipo and OpGMF.OPR_Consecutivo = McpGmfBaseCav.MCP_OperaciónConsecutivo and McpGmfBaseCav.MCP_Cuenta = 'GMFBasePagoCav' ) 
where ASI_Fecha between @fechaIni and @fechaFin 
 and MVC_Cuenta   like '2430%'
 and isnull( McpGmfBaseAfi.MCP_OperaciónTipo , 'SinOperacion') = 'SinOperacion' 
 and isnull( McpGmfBaseCav.MCP_OperaciónTipo , 'SinOperacion') = 'SinOperacion'
 union
select 'FYCCAR' Servidor, ASI_Fecha , OPR_Fecha ,  ASI_Tipo , ASI_CentroCosto , ASI_Soporte , ASI_ConsecutivoSoporte ,  
       MVC_Línea , MVC_Cuenta , MVC_Valor_Débito , MVC_Valor_Crédito , MVC_TerceroTipoNit , MVC_TerceroNit , MVC_CentroCosto , 
	   OPR_EstadoProducto , OPR_UsoConsecutivo , opr_ciudad, opr_oficina, OPR_Usuario , 
	   ASI_OPERACION , ASI_OPERACION_CONSECUTIVO , 
	   ( MVC_Valor_Crédito - MVC_Valor_Débito)/0.004  Base_Gravado , 
	   0  Base_Excento , 
--	   when isnull( McpGmfPagaAfi.MCP_OperaciónConsecutivo , -1) > 0 then  isnull(GMFControlND,0) + isnull(GMFBasePagoCav ,0)  else 0 end 
       ( MVC_Valor_Crédito - MVC_Valor_Débito) ImpuestoConta 
--	   , * 
  from fyccar.fyc.dbo.ASIENTO with ( nolock) 
  join fyccar.fyc.dbo.MOVIMIENTO with ( nolock) 
on ( ASI_Tipo = MVC_AsientoTipo and ASI_Consecutivo = MVC_AsientoConsecutivo ) 
left join fyccar.fyc.dbo.OPERACION OpGMF with (nolock)  on ( OpGMF.OPR_Tipo = ASI_OPERACION and OpGMF.OPR_Consecutivo = ASI_OPERACION_CONSECUTIVO ) 
left join fyccar.fyc.dbo.MOVIMIENTO_CUENTA_PARALELA McpGmfBaseAfi  with (nolock) on ( OpGMF.OPR_Tipo = McpGmfBaseAfi.MCP_OperaciónTipo and OpGMF.OPR_Consecutivo = McpGmfBaseAfi.MCP_OperaciónConsecutivo and McpGmfBaseAfi.MCP_Cuenta = 'GMFControlND' ) 
left join fyccar.fyc.dbo.MOVIMIENTO_CUENTA_PARALELA McpGmfBaseCav  with (nolock) on ( OpGMF.OPR_Tipo = McpGmfBaseCav.MCP_OperaciónTipo and OpGMF.OPR_Consecutivo = McpGmfBaseCav.MCP_OperaciónConsecutivo and McpGmfBaseCav.MCP_Cuenta = 'GMFBasePagoCav' ) 
where ASI_Fecha between @fechaIni and @fechaFin 
 and MVC_Cuenta   like '2430%'
 and isnull( McpGmfBaseAfi.MCP_OperaciónTipo , 'SinOperacion') = 'SinOperacion' 
 and isnull( McpGmfBaseCav.MCP_OperaciónTipo , 'SinOperacion') = 'SinOperacion'
union
select 'FYCOTROS' Servidor, ASI_Fecha , OPR_Fecha ,  ASI_Tipo , ASI_CentroCosto , ASI_Soporte , ASI_ConsecutivoSoporte ,  
       MVC_Línea , MVC_Cuenta , MVC_Valor_Débito , MVC_Valor_Crédito , MVC_TerceroTipoNit , MVC_TerceroNit , MVC_CentroCosto , 
	   OPR_EstadoProducto , OPR_UsoConsecutivo , opr_ciudad, opr_oficina, OPR_Usuario , 
	   ASI_OPERACION , ASI_OPERACION_CONSECUTIVO , 
	   ( MVC_Valor_Crédito - MVC_Valor_Débito)/0.004  Base_Gravado , 
	   0  Base_Excento , 
--	   when isnull( McpGmfPagaAfi.MCP_OperaciónConsecutivo , -1) > 0 then  isnull(GMFControlND,0) + isnull(GMFBasePagoCav ,0)  else 0 end 
       ( MVC_Valor_Crédito - MVC_Valor_Débito) ImpuestoConta 
--	   , * 
  from fycotros.fyc.dbo.ASIENTO with ( nolock) 
  join fycotros.fyc.dbo.MOVIMIENTO with ( nolock) 
on ( ASI_Tipo = MVC_AsientoTipo and ASI_Consecutivo = MVC_AsientoConsecutivo ) 
left join fycotros.fyc.dbo.OPERACION OpGMF with (nolock)  on ( OpGMF.OPR_Tipo = ASI_OPERACION and OpGMF.OPR_Consecutivo = ASI_OPERACION_CONSECUTIVO ) 
left join fycotros.fyc.dbo.MOVIMIENTO_CUENTA_PARALELA McpGmfBaseAfi  with (nolock) on ( OpGMF.OPR_Tipo = McpGmfBaseAfi.MCP_OperaciónTipo and OpGMF.OPR_Consecutivo = McpGmfBaseAfi.MCP_OperaciónConsecutivo and McpGmfBaseAfi.MCP_Cuenta = 'GMFControlND' ) 
left join fycotros.fyc.dbo.MOVIMIENTO_CUENTA_PARALELA McpGmfBaseCav  with (nolock) on ( OpGMF.OPR_Tipo = McpGmfBaseCav.MCP_OperaciónTipo and OpGMF.OPR_Consecutivo = McpGmfBaseCav.MCP_OperaciónConsecutivo and McpGmfBaseCav.MCP_Cuenta = 'GMFBasePagoCav' ) 
where ASI_Fecha between @fechaIni and @fechaFin 
 and MVC_Cuenta   like '2430%'
 and isnull( McpGmfBaseAfi.MCP_OperaciónTipo , 'SinOperacion') = 'SinOperacion' 
 and isnull( McpGmfBaseCav.MCP_OperaciónTipo , 'SinOperacion') = 'SinOperacion'

 END


 IF @BANDERA = 3
 BEGIN
-- ============================================
-- CUENTAS EXENTAS
-- ============================================

SELECT RPD_IdNit,	TER_DocumentoTipo,	TER_DocumentoNúmero,	TER_Desde,	TER_Hasta,	NTR_PrimerApellido,	NTR_SegundoApellido,	NTR_Nombres	
FROM 
	FYCBOG.FYC.DBO.ROL_PERSONA_DOCUMENTO JOIN 
	FYCBOG.FYC.DBO.TERMINO ON (TER_DOCUMENTOTIPO = RPD_DOCUMENTOTIPO AND TER_DOCUMENTONUMERO = RPD_DOCUMENTONUMERO) JOIN 
	FYCBOG.FYC.DBO.ASPECTO_DOCUMENTO_NULO ON (ADN_DOCUMENTOTIPO = RPD_DOCUMENTOTIPO AND ADN_DOCUMENTONUMERO = RPD_DOCUMENTONUMERO) JOIN
	FYCBOG.FYC.DBO.PERSONA_NATURAL ON (NTR_IDNIT = RPD_IDNIT)
WHERE 
	RPD_DOCUMENTOTIPO = 'AFAI' AND
	ADN_PARAMETRONOMBRE = '[ExcentoGMF]'
UNION
SELECT RPD_IdNit,	TER_DocumentoTipo,	TER_DocumentoNúmero,	TER_Desde,	TER_Hasta,	NTR_PrimerApellido,	NTR_SegundoApellido,	NTR_Nombres	
FROM 
	FYCBAR.FYC.DBO.ROL_PERSONA_DOCUMENTO JOIN 
	FYCBAR.FYC.DBO.TERMINO ON (TER_DOCUMENTOTIPO = RPD_DOCUMENTOTIPO AND TER_DOCUMENTONUMERO = RPD_DOCUMENTONUMERO) JOIN 
	FYCBAR.FYC.DBO.ASPECTO_DOCUMENTO_NULO ON (ADN_DOCUMENTOTIPO = RPD_DOCUMENTOTIPO AND ADN_DOCUMENTONUMERO = RPD_DOCUMENTONUMERO) JOIN
	FYCBAR.FYC.DBO.PERSONA_NATURAL ON (NTR_IDNIT = RPD_IDNIT)
WHERE 
	RPD_DOCUMENTOTIPO = 'AFAI' AND
	ADN_PARAMETRONOMBRE = '[ExcentoGMF]'
UNION
SELECT RPD_IdNit,	TER_DocumentoTipo,	TER_DocumentoNúmero,	TER_Desde,	TER_Hasta,	NTR_PrimerApellido,	NTR_SegundoApellido,	NTR_Nombres	
FROM 
	FYCBUC.FYC.DBO.ROL_PERSONA_DOCUMENTO JOIN 
	FYCBUC.FYC.DBO.TERMINO ON (TER_DOCUMENTOTIPO = RPD_DOCUMENTOTIPO AND TER_DOCUMENTONUMERO = RPD_DOCUMENTONUMERO) JOIN 
	FYCBUC.FYC.DBO.ASPECTO_DOCUMENTO_NULO ON (ADN_DOCUMENTOTIPO = RPD_DOCUMENTOTIPO AND ADN_DOCUMENTONUMERO = RPD_DOCUMENTONUMERO) JOIN
	FYCBUC.FYC.DBO.PERSONA_NATURAL ON (NTR_IDNIT = RPD_IDNIT)
WHERE 
	RPD_DOCUMENTOTIPO = 'AFAI' AND
	ADN_PARAMETRONOMBRE = '[ExcentoGMF]'
UNION
SELECT RPD_IdNit,	TER_DocumentoTipo,	TER_DocumentoNúmero,	TER_Desde,	TER_Hasta,	NTR_PrimerApellido,	NTR_SegundoApellido,	NTR_Nombres	
FROM 
	FYCCAR.FYC.DBO.ROL_PERSONA_DOCUMENTO JOIN 
	FYCCAR.FYC.DBO.TERMINO ON (TER_DOCUMENTOTIPO = RPD_DOCUMENTOTIPO AND TER_DOCUMENTONUMERO = RPD_DOCUMENTONUMERO) JOIN 
	FYCCAR.FYC.DBO.ASPECTO_DOCUMENTO_NULO ON (ADN_DOCUMENTOTIPO = RPD_DOCUMENTOTIPO AND ADN_DOCUMENTONUMERO = RPD_DOCUMENTONUMERO) JOIN
	FYCCAR.FYC.DBO.PERSONA_NATURAL ON (NTR_IDNIT = RPD_IDNIT)
WHERE 
	RPD_DOCUMENTOTIPO = 'AFAI' AND
	ADN_PARAMETRONOMBRE = '[ExcentoGMF]'
UNION
SELECT RPD_IdNit,	TER_DocumentoTipo,	TER_DocumentoNúmero,	TER_Desde,	TER_Hasta,	NTR_PrimerApellido,	NTR_SegundoApellido,	NTR_Nombres	
FROM 
	FYCOTROS.FYC.DBO.ROL_PERSONA_DOCUMENTO JOIN 
	FYCOTROS.FYC.DBO.TERMINO ON (TER_DOCUMENTOTIPO = RPD_DOCUMENTOTIPO AND TER_DOCUMENTONUMERO = RPD_DOCUMENTONUMERO) JOIN 
	FYCOTROS.FYC.DBO.ASPECTO_DOCUMENTO_NULO ON (ADN_DOCUMENTOTIPO = RPD_DOCUMENTOTIPO AND ADN_DOCUMENTONUMERO = RPD_DOCUMENTONUMERO) JOIN
	FYCOTROS.FYC.DBO.PERSONA_NATURAL ON (NTR_IDNIT = RPD_IDNIT)
WHERE 
	RPD_DOCUMENTOTIPO = 'AFAI' AND
	ADN_PARAMETRONOMBRE = '[ExcentoGMF]'
END

IF @BANDERA = 4 
 BEGIN 
    SELECT year(dim_tiempo) QYear, month ( Dim_tiempo) Mes , dim_cuentaregistro ,  rpd_idtiponit, rpd_idnit ,   round(sum( mcp_valorcredito -mcp_valordebito ) ,0)   GMFMes 
      FROM cavcrm.cavipetrol.dbo.HST_MOVIMIENTO_CUENTA_PARALELA_DWH31aug2010 with(nolock)
     WHERE DIM_Tiempo between @fechaIni   and @fechafin 
       AND Dim_Documento = 'afai'
       AND DIM_CuentaRegistro like 'GMFVrImpuesto'
       AND DCT_NUMEROUNICO   IN ( 
                     SELECT  DCT_NUMEROUNICO  FROM FYCBOG.FYC.DBO.ASPECTO_DOCUMENTO_NULO JOIN FYCBOG.FYC.DBO.DOCUMENTO ON ( DCT_TIPO = ADN_DOCUMENTOTIPO AND DCT_NUMERO = ADN_DOCUMENTONUMERO ) JOIN FYCBOG.FYC.DBO.ROL_PERSONA_DOCUMENTO ON ( RPD_DOCUMENTOTIPO = DCT_TIPO  AND RPD_DOCUMENTONUMERO = DCT_NUMERO ) WHERE ADN_PARAMETRONOMBRE = '[ExcentoGMF]' 
	           UNION SELECT  DCT_NUMEROUNICO  FROM FYCBAR.FYC.DBO.ASPECTO_DOCUMENTO_NULO JOIN FYCBAR.FYC.DBO.DOCUMENTO ON ( DCT_TIPO = ADN_DOCUMENTOTIPO AND DCT_NUMERO = ADN_DOCUMENTONUMERO ) JOIN FYCBAR.FYC.DBO.ROL_PERSONA_DOCUMENTO ON ( RPD_DOCUMENTOTIPO = DCT_TIPO  AND RPD_DOCUMENTONUMERO = DCT_NUMERO ) WHERE ADN_PARAMETRONOMBRE = '[ExcentoGMF]' 
	           UNION SELECT  DCT_NUMEROUNICO  FROM FYCBUC.FYC.DBO.ASPECTO_DOCUMENTO_NULO JOIN FYCBUC.FYC.DBO.DOCUMENTO ON ( DCT_TIPO = ADN_DOCUMENTOTIPO AND DCT_NUMERO = ADN_DOCUMENTONUMERO ) JOIN FYCBUC.FYC.DBO.ROL_PERSONA_DOCUMENTO ON ( RPD_DOCUMENTOTIPO = DCT_TIPO  AND RPD_DOCUMENTONUMERO = DCT_NUMERO ) WHERE ADN_PARAMETRONOMBRE = '[ExcentoGMF]' 
               UNION SELECT  DCT_NUMEROUNICO  FROM FYCCAR.FYC.DBO.ASPECTO_DOCUMENTO_NULO JOIN FYCCAR.FYC.DBO.DOCUMENTO ON ( DCT_TIPO = ADN_DOCUMENTOTIPO AND DCT_NUMERO = ADN_DOCUMENTONUMERO ) JOIN FYCCAR.FYC.DBO.ROL_PERSONA_DOCUMENTO ON ( RPD_DOCUMENTOTIPO = DCT_TIPO  AND RPD_DOCUMENTONUMERO = DCT_NUMERO ) WHERE ADN_PARAMETRONOMBRE = '[ExcentoGMF]' 
	           UNION SELECT  DCT_NUMEROUNICO  FROM FYCOTROS.FYC.DBO.ASPECTO_DOCUMENTO_NULO JOIN FYCOTROS.FYC.DBO.DOCUMENTO ON ( DCT_TIPO = ADN_DOCUMENTOTIPO AND DCT_NUMERO = ADN_DOCUMENTONUMERO ) JOIN FYCOTROS.FYC.DBO.ROL_PERSONA_DOCUMENTO ON ( RPD_DOCUMENTOTIPO = DCT_TIPO  AND RPD_DOCUMENTONUMERO = DCT_NUMERO ) WHERE ADN_PARAMETRONOMBRE = '[ExcentoGMF]' 
      ) 
     GROUP BY year(dim_tiempo) , month ( Dim_tiempo) , dim_cuentaregistro, rpd_idtiponit, rpd_idnit
 END

 IF @BANDERA = 5 
 BEGIN 
    SELECT @MaximoInsentivo = 0  
    SELECT @MaximoInsentivo = SUM( VDS_VARIABLE_VALOR )  
	  FROM FYCBOG.FYC.DBO.VARIABLES_SISTEMA    
	 WHERE VDS_Nombre like 'GMF_INCENTIVO'
    Select qyear, mes, dim_cuentaregistro, rpd_idtiponit, rpd_idnit , GMFMes /@Factor VrRetiros ,  GMFMes , 
	       case when ( GMFMes /@Factor ) >= @MaximoInsentivo then round( @MaximoInsentivo * @Factor ,0)  else round(GMFMes ,0 )  end VrIncentivo 	
	from 
	 ( 	SELECT year(dim_tiempo) QYear, month ( Dim_tiempo) Mes , dim_cuentaregistro ,  rpd_idtiponit, rpd_idnit ,   sum( mcp_valorcredito -mcp_valordebito )   GMFMes 	  
	      FROM cavcrm.cavipetrol.dbo.HST_MOVIMIENTO_CUENTA_PARALELA_DWH31aug2010 with(nolock) 
         WHERE DIM_Tiempo between @fechaIni   and @fechafin AND Dim_Documento = 'afai' AND DIM_CuentaRegistro like 'GMFVrImpuesto'  AND DCT_NUMEROUNICO   IN ( 
                     SELECT  DCT_NUMEROUNICO  FROM FYCBOG.FYC.DBO.ASPECTO_DOCUMENTO_NULO JOIN FYCBOG.FYC.DBO.DOCUMENTO ON ( DCT_TIPO = ADN_DOCUMENTOTIPO AND DCT_NUMERO = ADN_DOCUMENTONUMERO ) JOIN FYCBOG.FYC.DBO.ROL_PERSONA_DOCUMENTO ON ( RPD_DOCUMENTOTIPO = DCT_TIPO  AND RPD_DOCUMENTONUMERO = DCT_NUMERO ) WHERE ADN_PARAMETRONOMBRE = '[ExcentoGMF]' 
	           UNION SELECT  DCT_NUMEROUNICO  FROM FYCBAR.FYC.DBO.ASPECTO_DOCUMENTO_NULO JOIN FYCBAR.FYC.DBO.DOCUMENTO ON ( DCT_TIPO = ADN_DOCUMENTOTIPO AND DCT_NUMERO = ADN_DOCUMENTONUMERO ) JOIN FYCBAR.FYC.DBO.ROL_PERSONA_DOCUMENTO ON ( RPD_DOCUMENTOTIPO = DCT_TIPO  AND RPD_DOCUMENTONUMERO = DCT_NUMERO ) WHERE ADN_PARAMETRONOMBRE = '[ExcentoGMF]' 
	           UNION SELECT  DCT_NUMEROUNICO  FROM FYCBUC.FYC.DBO.ASPECTO_DOCUMENTO_NULO JOIN FYCBUC.FYC.DBO.DOCUMENTO ON ( DCT_TIPO = ADN_DOCUMENTOTIPO AND DCT_NUMERO = ADN_DOCUMENTONUMERO ) JOIN FYCBUC.FYC.DBO.ROL_PERSONA_DOCUMENTO ON ( RPD_DOCUMENTOTIPO = DCT_TIPO  AND RPD_DOCUMENTONUMERO = DCT_NUMERO ) WHERE ADN_PARAMETRONOMBRE = '[ExcentoGMF]' 
               UNION SELECT  DCT_NUMEROUNICO  FROM FYCCAR.FYC.DBO.ASPECTO_DOCUMENTO_NULO JOIN FYCCAR.FYC.DBO.DOCUMENTO ON ( DCT_TIPO = ADN_DOCUMENTOTIPO AND DCT_NUMERO = ADN_DOCUMENTONUMERO ) JOIN FYCCAR.FYC.DBO.ROL_PERSONA_DOCUMENTO ON ( RPD_DOCUMENTOTIPO = DCT_TIPO  AND RPD_DOCUMENTONUMERO = DCT_NUMERO ) WHERE ADN_PARAMETRONOMBRE = '[ExcentoGMF]' 
	           UNION SELECT  DCT_NUMEROUNICO  FROM FYCOTROS.FYC.DBO.ASPECTO_DOCUMENTO_NULO JOIN FYCOTROS.FYC.DBO.DOCUMENTO ON ( DCT_TIPO = ADN_DOCUMENTOTIPO AND DCT_NUMERO = ADN_DOCUMENTONUMERO ) JOIN FYCOTROS.FYC.DBO.ROL_PERSONA_DOCUMENTO ON ( RPD_DOCUMENTOTIPO = DCT_TIPO  AND RPD_DOCUMENTONUMERO = DCT_NUMERO ) WHERE ADN_PARAMETRONOMBRE = '[ExcentoGMF]' 
               ) 
         GROUP BY year(dim_tiempo) , month ( Dim_tiempo) , dim_cuentaregistro, rpd_idtiponit, rpd_idnit ) ResumenGMF
    where round(GMFMes ,0 )   > 0 
 END

END


