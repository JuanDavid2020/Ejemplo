USE [CAVIPETROL_REST040224]
GO
/****** Object:  StoredProcedure [dbo].[ACH_RETURN_EXCENTO]    Script Date: 4/03/2025 12:28:01 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		JSON
-- Create date: 15 APR 2020
-- Description:	DEVUELVE SI UN ASOCIADO ESTA EXCENTO O NO DE GMF
-- =============================================
ALTER PROCEDURE [dbo].[ACH_RETURN_EXCENTO] 
	-- Add the parameters for the stored procedure here
				@IDNIT VARCHAR(20),
				@EXCENTO INT OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT @EXCENTO=CASE WHEN RG_Observacion='Levanta marcación' THEN 1 ELSE 0 END 
	FROM REGISTRO_GMF R
	WHERE R.RG_FECHA = (SELECT MAX(U.RG_FECHA) 
						FROM REGISTRO_GMF U
						WHERE U.RG_Nit = R.RG_Nit)
	AND R.RG_Observación  = 'Levanta marcación'
	AND RG_TIPONIT='CC' AND
	RG_NIT=@IDNIT

	SELECT @EXCENTO=COALESCE(@EXCENTO,0)
	--SELECT @EXCENTO


	SELECT * FROM REGISTRO_GMF
END
