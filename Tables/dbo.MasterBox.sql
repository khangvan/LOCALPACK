CREATE TABLE [dbo].[MasterBox] (
  [Material] [varchar](30) NULL,
  [Description] [nvarchar](255) NULL,
  [L] [int] NULL,
  [W] [int] NULL,
  [H] [int] NULL,
  [t] [int] NOT NULL DEFAULT (0),
  [ID] [int] IDENTITY
)
ON [PRIMARY]
GO