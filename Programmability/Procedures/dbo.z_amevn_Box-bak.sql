SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[z_amevn_Box-bak]
@Sing varchar(30) = NULL, @Over varchar(30)= NULL
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
select a.material as MatA_Over,b.material as MatB_Single
/*Cast Name Dimension*/, CAST(a.l AS varchar(4))+'x'+  CAST(a.w AS varchar(4))+'x'+  CAST(a.H AS varchar(4))AS DimLWH
/*Cast Name Dimension*/, CAST(X AS varchar(4))+'x'+  CAST(Y AS varchar(4))+'x'+  CAST(Z AS varchar(4))AS DimXYZ
,a.l*a.w*a.h as DimA 
,b.DimB
-- solution here
,FLOOR((a.l*a.w*a.h)/(b.DimB)) AS MaxPackto
, Floor([L]/[X])*Floor([W]/[Y])*Floor([H]/[Z]) as XLYWZH
, Floor([L]/[Y])*Floor([W]/[Z])*Floor([H]/[X]) as YLZWXH
, Floor([L]/[Z])*Floor([W]/[X])*Floor([H]/[Y]) as ZLXWYH
, Floor([W]/[X])*Floor([H]/[Y])*Floor([L]/[Z]) as XWYHZL
, Floor([H]/[X])*Floor([L]/[Y])*Floor([W]/[Z]) as XHYLZW
, Floor([L]/[Z])*Floor([W]/[Y])*Floor([H]/[X]) as ZLYWXH
, Floor([L]/[Y])*Floor([W]/[X])*Floor([H]/[Z]) as YLXWZH
, Floor([L]/[X])*Floor([W]/[Z])*Floor([H]/[Y]) as XLZWYH
, Floor([W]/[Z])*Floor([H]/[Y])*Floor([L]/[X]) as ZWYHXL
, Floor([H]/[Z])*Floor([L]/[Y])*Floor([W]/[X]) as ZHYLXW
-- solution here
 from 
 (SELECT material,L,W,H, l*w*h as DimA FROM masterbox) a --overpack khang change for thin layer
--masterbox a--overpack
cross join  (
select material,l AS X,w AS Y,h AS Z, l*w*h as DimB from masterbox--singlebox
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




/*
1- max pack at
2- solution
3- unpivot test: amevn_Box
4- cal Ulti : -1: undefine
5-aggument : amevn_Box '142042300','142057701'
*/



END
GO