CREATE TABLE [dbo].[catalog] (
    [id]            VARCHAR (64) NOT NULL,
    [asset_type]    INT          NULL,
    [asset_subtype] VARCHAR (32) NULL,
    [channel]       VARCHAR (3)  NOT NULL,
    [title]         TEXT         NULL,
    [genre]         VARCHAR (32) NULL,
    [tags]          TEXT         NULL,
    [created]       DATETIME     DEFAULT (getdate()) NULL,
    [updated]       DATETIME     DEFAULT (getdate()) NULL,
    CONSTRAINT [UK_catalog] UNIQUE NONCLUSTERED ([id] ASC, [channel] ASC)
);


GO
CREATE CLUSTERED INDEX [cid_cr]
    ON [dbo].[catalog]([id] ASC, [channel] ASC);

