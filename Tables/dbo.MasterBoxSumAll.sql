CREATE TABLE [dbo].[MasterBoxSumAll] (
  [MatB_Single] [varchar](30) NULL,
  [MatA_Over] [varchar](30) NULL,
  [DimXYZ] [varchar](16) NULL,
  [DimLWH] [varchar](16) NULL,
  [MaxPackto] [bigint] NULL,
  [PackQty] [bigint] NULL,
  [Ultilization] [decimal](10, 2) NULL,
  [All Method Applied] [nvarchar](max) NULL,
  [MethodCount] [bigint] NULL
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO