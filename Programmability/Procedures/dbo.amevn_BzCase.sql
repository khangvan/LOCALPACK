SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[amevn_BzCase] 
@Casenume int =0
,@FindBox varchar(30) = NULL
, @ReqQty int =0
,@InWhichBox varchar(30) = null

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	/*
	0- Good case
	1- Best Case > 90%
	2- Alternative Find Alternative
	3- by Singlebox- Find Overpack aLL Qty
	4- by Singlebox,Qty- Find Overpack Specific Qty
	41- by Singlebox,Qty- Find Overpack Specific Qty
	5- Find Overpack Specific Qty- Advanced
	6- Find How working of Couple

	
	*/
	
IF (@Casenume =0) -- all good case
BEGIN
	; with cte as (SELECT DISTINCT MatB_Single, MatA_Over, DimXYZ, DimLWH, MaxPackto
	--, PackMethod, 
	,PackQty, Ultilization
	 ,STUFF((SELECT DISTINCT ', ' + rtrim(y.PackMethod)
            FROM MasterBoxControl y
            WHEre MAS.MatA_Over=y.MatA_Over
		  AND mas.MatB_Single = y.MatB_Single
		  AND mas.PackQty = y.PackQty
		  AND mas.MaxPackto=y.MaxPackto
		  FOR XML PATH('')), 1, 1, '') [All Method Applied]

	FROM dbo.MasterBoxControl AS MAS
	
	)
	SELECT * 
	,len([All Method Applied])-len(replace([All Method Applied],',',''))+1 AS MethodCount-- count, +1 for qty method
	FROM cte AS CTE
	
	WHERE Ultilization <>-1
	ORDER BY Ultilization desc
END ---- amevn_BzCase 0

IF (@Casenume =1) -- bestcase
BEGIN
		; with cte as (SELECT DISTINCT MatB_Single, MatA_Over, DimXYZ, DimLWH, MaxPackto
	--, PackMethod, 
	,PackQty, Ultilization
	 ,STUFF((SELECT DISTINCT ', ' + rtrim(y.PackMethod)
            FROM MasterBoxControl y
            WHEre MAS.MatA_Over=y.MatA_Over
		  AND mas.MatB_Single = y.MatB_Single
		  AND mas.PackQty = y.PackQty
		  AND mas.MaxPackto=y.MaxPackto
		  FOR XML PATH('')), 1, 1, '') [All Method Applied]

	FROM dbo.MasterBoxControl AS MAS
	
	)
	SELECT * 
	,len([All Method Applied])-len(replace([All Method Applied],',',''))+1 AS MethodCount-- count, +1 for qty method
	FROM cte AS CTE
	
	WHERE Ultilization>0
	AND isnumeric(MatA_Over) =1
	AND CTE.MatB_Single <> cte.MatA_Over
	ORDER BY PackQty desc,Ultilization desc
END -- amevn_BzCase 1

IF (@Casenume =2) -- Find Alternative
BEGIN
	SELECT *
	FROM dbo.MasterBoxControl AS MAS
	WHERE Ultilization>80 and
	 MAS.MatB_Single =@FindBox AND
	 MAS.PackQty=1
	 AND MAS.MatA_Over <>@FindBox

	ORDER BY MAS.Ultilization desc, MAS.PackQty desc
END -- amevn_BzCase 2 ,'142018290'

IF (@Casenume =3) -- Find Over 
BEGIN
	SELECT *
	FROM dbo.MasterBoxControl AS MAS
	WHERE Ultilization>80 and
	 MAS.MatB_Single =@FindBox
	ORDER BY MAS.PackQty desc, MAS.Ultilization desc
END -- amevn_BzCase 3 ,'142018290'


IF (@Casenume =4) -- Find Over with Qty
BEGIN
	SELECT *
	FROM dbo.MasterBoxControl AS MAS
	WHERE Ultilization>80 and
	 MAS.MatB_Single =@FindBox
	 AND MAS.PackQty <=@ReqQty
	ORDER BY MAS.PackQty desc, MAS.Ultilization desc
END -- amevn_BzCase 4 ,'142018290', 10

IF (@Casenume =41) -- Find best one Over with Qty
BEGIN
	; with cte as (SELECT DISTINCT MatB_Single, MatA_Over, DimXYZ, DimLWH, MaxPackto
	--, PackMethod, 
	,PackQty, Ultilization
	 ,STUFF((SELECT DISTINCT ', ' + rtrim(y.PackMethod)
            FROM MasterBoxControl y
            WHEre MAS.MatA_Over=y.MatA_Over
		  AND mas.MatB_Single = y.MatB_Single
		  AND mas.PackQty = y.PackQty
		  AND mas.MaxPackto=y.MaxPackto
		  FOR XML PATH('')), 1, 1, '') [All Method Applied]

	FROM dbo.MasterBoxControl AS MAS
	
	)
	SELECT TOP 1 * 
	,len([All Method Applied])-len(replace([All Method Applied],',',''))+1 AS MethodCount-- count, +1 for qty method
	FROM cte AS CTE
	WHERE Ultilization>80 and
	 MatB_Single =@FindBox
	 AND PackQty <=@ReqQty
	ORDER BY PackQty desc, Ultilization desc
END -- amevn_BzCase 41 ,'142018290', 15

IF (@Casenume =5) -- Find Over with Qty same as case4
BEGIN
	; with cte as (SELECT DISTINCT MatB_Single, MatA_Over, DimXYZ, DimLWH, MaxPackto
	--, PackMethod, 
	,PackQty, Ultilization
	 ,STUFF((SELECT DISTINCT ', ' + rtrim(y.PackMethod)
            FROM MasterBoxControl y
            WHEre MAS.MatA_Over=y.MatA_Over
		  AND mas.MatB_Single = y.MatB_Single
		  AND mas.PackQty = y.PackQty
		  AND mas.MaxPackto=y.MaxPackto
		  FOR XML PATH('')), 1, 1, '') [All Method Applied]
    
	FROM dbo.MasterBoxControl AS MAS
	
	)
	SELECT * 
	,len([All Method Applied])-len(replace([All Method Applied],',',''))+1 AS MethodCount-- count, +1 for qty method
	FROM cte AS CTE
	WHERE Ultilization>80 and
	 MatB_Single =@FindBox
	 AND PackQty <=@ReqQty
	
	ORDER BY CTE.PackQty DESC, CTE.Ultilization desc
END -- amevn_BzCase 5 ,'142018290', 100,''

IF (@Casenume =6) -- Check Couple
BEGIN
	; with cte as (SELECT DISTINCT MatB_Single, MatA_Over, DimXYZ, DimLWH, MaxPackto
	--, PackMethod, 
	,PackQty, Ultilization
	 ,STUFF((SELECT DISTINCT ', ' + rtrim(y.PackMethod)
            FROM MasterBoxControl y
            WHEre MAS.MatA_Over=y.MatA_Over
		  AND mas.MatB_Single = y.MatB_Single
		  AND mas.PackQty = y.PackQty
		  AND mas.MaxPackto=y.MaxPackto
		  FOR XML PATH('')), 1, 1, '') [All Method Applied]

	FROM dbo.MasterBoxControl AS MAS
	
	)
	SELECT * 
	,len([All Method Applied])-len(replace([All Method Applied],',',''))+1 AS MethodCount-- count, +1 for qty method
	FROM cte AS CTE
	WHERE Ultilization>80 and
	 MatB_Single =@FindBox
	 --AND PackQty <=@ReqQty
	AND MatA_Over= @InWhichBox
	ORDER BY CTE.PackQty DESC, CTE.Ultilization desc
END -- amevn_BzCase 6 ,'142018290',0 , '129500801'
-- amevn_BzCase 6 ,'199495300',0 , '142041000'

---
END
GO