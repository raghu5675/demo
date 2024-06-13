
CREATE PROCEDURE [DBO].[uspValidUserdetails]
(
    @Email NVARCHAR(500),
    @Organization NVARCHAR(500),
	@Status NVARCHAR(10)='' OUTPUT

)
AS
BEGIN
	SET NOCOUNT ON;
BEGIN TRY
 
			
    BEGIN

		IF  EXISTS (SELECT 1 FROM tbluserdetails WHERE @Email = Email AND @Organization = Organization AND IsDeleted = 0 )
        BEGIN

            SET @Status='S001'
		END 
		ELSE
			SET @Status='S002'
	END 
		
END TRY

BEGIN CATCH
		
		SET @Status='F001'
		
		SELECT ERROR_MESSAGE() AS ErrorMessage, ERROR_LINE() AS ErrorLine
		END CATCH

END