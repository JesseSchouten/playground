CREATE PROCEDURE dbo.Upsert_Catalog
(
    @id varchar(64),
    @asset_type int,
    @asset_subtype varchar(32),
    @channel varchar(8),
    @title text,
	@genre varchar(32),
	@tags text
)
AS
BEGIN
	BEGIN TRANSACTION;
 
	UPDATE dbo.catalog WITH (UPDLOCK, SERIALIZABLE) 
	SET asset_type = @asset_type, asset_subtype = @asset_subtype, title = @title, genre = @genre, tags = @tags, updated = CURRENT_TIMESTAMP 
	WHERE id=@id AND channel=@channel

	IF @@ROWCOUNT = 0
	BEGIN
	  INSERT INTO dbo.catalog (id, asset_type, asset_subtype, channel, title, genre, tags) 
	  VALUES(@id, @asset_type, @asset_subtype, @channel, @title, @genre, @tags)
	END

	COMMIT TRANSACTION
END