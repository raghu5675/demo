
CREATE PROCEDURE [DBO].[uspInsertUserdetails]
(
    @Email NVARCHAR(500),
    @FirstName NVARCHAR(500),
    @LastName NVARCHAR(500),
   
    @Organization NVARCHAR(500),
    @Country NVARCHAR(100),
    @Role NVARCHAR(100),
    @Phone NVARCHAR(50),
	@Status NVARCHAR(10)='' OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
BEGIN TRY
 
			
    BEGIN
		IF NOT EXISTS (SELECT 1 FROM tbluserdetails WHERE @Email = Email AND @Organization = Organization AND IsDeleted = 0)
        BEGIN
            -- Insert data into tbluserdetails table
            INSERT INTO tbluserdetails (Email, FirstName, LastName, Organization, Country, Role, Phone,CreatedDate,IsDeleted)
            VALUES (@Email, @FirstName, @LastName,  @Organization, @Country, @Role, @Phone,GETUTCDATE(),0);
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