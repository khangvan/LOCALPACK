CREATE TABLE [dbo].[MasterBoxControl] (
  [MatB_Single] [varchar](30) NULL,
  [MatA_Over] [varchar](30) NULL,
  [DimXYZ] [varchar](16) NULL,
  [DimLWH] [varchar](16) NULL,
  [MaxPackto] [bigint] NULL,
  [PackMethod] [nvarchar](128) NULL,
  [PackQty] [bigint] NULL,
  [Ultilization] [decimal](10, 2) NULL
)
ON [PRIMARY]
GO