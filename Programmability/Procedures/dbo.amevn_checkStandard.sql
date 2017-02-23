SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[amevn_checkStandard]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   SELECT
(ba.Qty - bc.PackQty) AS diff
,*
FROM boxaproved ba
left JOIN (
SELECT 
ROW_NUMBER()OVER(PARTITION BY matb_single, MatA_Over ORDER BY dbo.masterboxsumall.PackQty desc  )As RowNum
,*
 from masterboxsumall )AS bc
ON  ba.[Overpack]= bc.[MatA_Over] and ba.single=bc.[MatB_Single]
AND bc.RowNum =1
ORDER BY (ba.Qty - bc.PackQty), single,overpack
END
GO