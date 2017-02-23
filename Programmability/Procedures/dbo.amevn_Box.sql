SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[amevn_Box]
--@Sing varchar(30) = NULL, @Over varchar(30)= NULL
	AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

  
	if OBJECT_ID('masterboxcontrol') IS NOT NULL
	BEGIN
	drop TABLE masterboxcontrol
END

 ;WITH cte AS (
select a.Material as MatA_Over,B.Material as MatB_Single
/*Cast Name Dimension*/, CAST(a.l AS varchar(6))+'x'+  CAST(a.w AS varchar(4))+'x'+  CAST(a.H AS varchar(4))AS DimLWH
/*Cast Name Dimension*/, CAST(X AS varchar(6))+'x'+  CAST(Y AS varchar(4))+'x'+  CAST(Z AS varchar(4))AS DimXYZ
,a.DimA 
,b.DimB
-- solution here
,FLOOR((a.DimA)/(b.DimB)) AS MaxPackto
, Floor(([L]-2*a.t)/[X])*Floor(([W]-2*a.t)/[Y])*Floor(([H]-4*a.t)/[Z]) as XLYWZH
, Floor(([L]-2*a.t)/[Y])*Floor(([W]-2*a.t)/[Z])*Floor(([H]-4*a.t)/[X]) as YLZWXH
, Floor(([L]-2*a.t)/[Z])*Floor(([W]-2*a.t)/[X])*Floor(([H]-4*a.t)/[Y]) as ZLXWYH
, Floor(([W]-2*a.t)/[X])*Floor(([H]-4*a.t)/[Y])*Floor(([L]-2*a.t)/[Z]) as XWYHZL
, Floor(([H]-4*a.t)/[X])*Floor(([L]-2*a.t)/[Y])*Floor(([W]-2*a.t)/[Z]) as XHYLZW
, Floor(([L]-2*a.t)/[Z])*Floor(([W]-2*a.t)/[Y])*Floor(([H]-4*a.t)/[X]) as ZLYWXH
, Floor(([L]-2*a.t)/[Y])*Floor(([W]-2*a.t)/[X])*Floor(([H]-4*a.t)/[Z]) as YLXWZH
, Floor(([L]-2*a.t)/[X])*Floor(([W]-2*a.t)/[Z])*Floor(([H]-4*a.t)/[Y]) as XLZWYH
, Floor(([W]-2*a.t)/[Z])*Floor(([H]-4*a.t)/[Y])*Floor(([L]-2*a.t)/[X]) as ZWYHXL
, Floor(([H]-4*a.t)/[Z])*Floor(([L]-2*a.t)/[Y])*Floor(([W]-2*a.t)/[X]) as ZHYLXW
-- solution here
 from 
 (
 SELECT  CAST(material AS varchar(30)) as Material, 
 cast(L AS BIGINT) AS L,cast(W AS BIGINT) AS W ,cast(H AS BIGINT) AS H,cast(isnull(t,0) AS BIGINT) AS T
 ,(cast(l AS BIGINT)-2*cast(t AS BIGINT))*(cast(w AS BIGINT)-2*cast(t AS BIGINT))*(cast(h AS BIGINT)-4*cast(t AS BIGINT)) AS DimA
 FROM masterbox 
 ) a --overpack khang change for thin layer
--masterbox a--overpack
cross join  
(
 SELECT CAST(material AS varchar(30)) as Material, 
 cast(L AS BIGINT) AS X,cast(W AS BIGINT) AS Y,cast(H AS BIGINT) AS Z,cast(isnull(t,0) AS BIGINT) AS t
 ,(cast(l AS BIGINT)-2*cast(t AS BIGINT))*(cast(w AS BIGINT)-2*cast(t AS BIGINT))*(cast(h AS BIGINT)-4*cast(t AS BIGINT)) AS DimB
 FROM masterbox -- single box
) B
--on a.material=b.material
--WHERE b.Material='142018290' AND a.material='129500801'
--order by a.material, B.material

) -- prepare for method
SELECT MatB_Single,MatA_Over
,DimXYZ,DimLWH,  
MaxPackto , 
/*PiVot value here*/tb2.PackMethod,tb2.PackQty
/*Calculation Ulti*/,  Ultilization=case when tb2.PackQty =0 then '-1'
when tb2.PackQty >0 THEN convert(decimal(10,2), cast(tb2.PackQty AS float)/cast(MaxPackto AS float)*100)
END 
/*for new table*/ INTO MasterBoxControl
FROM cte tb1

UNPIVOT(
PackQty For PackMethod in (XLYWZH,
YLZWXH,
ZLXWYH,
XWYHZL,
XHYLZW,
ZLYWXH,
YLXWZH,
XLZWYH,
ZWYHXL,
ZHYLXW)
) AS tb2
--WHERE MatB_Single=@Sing AND MatA_Over=@Over
order by MatA_Over, MatB_Single, tb2.PackQty desc
;

SELECT * FROM dbo.MasterBoxControl AS MAS


/*
1- max pack at
2- solution
3- unpivot test: amevn_Box
4- cal Ulti : -1: undefine
5-aggument : amevn_Box '142042300','142057701'
*/


--do for all

	if OBJECT_ID('MasterBoxSumAll') IS NOT NULL
	BEGIN
	drop TABLE MasterBoxSumAll
END

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
	INTO MasterBoxSumAll
	FROM cte AS CTE
	
	WHERE Ultilization>0
	AND isnumeric(MatA_Over) =1
	AND CTE.MatB_Single <> cte.MatA_Over
	ORDER BY PackQty desc,Ultilization desc


END
GO