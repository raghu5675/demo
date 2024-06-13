CREATE OR ALTER PROCEDURE dbo.[UspGetDomainActivityEvaluationDetails]
(
	@userid BIGINT,
	@yearId BIGINT,
	@classID BIGINT,
	@sectionid BIGINT,
	@Termtestid BIGINT,
	@ThemeName VARCHAR(100),
	@PlanClassId BIGINT,
	@DomainId BIGINT,
	@ActivityId BIGINT,
	@PageNo BIGINT,
	@PageSize BIGINT
)
AS
BEGIN
	SET NOCOUNT ON;
BEGIN TRY
	DECLARE
		@ErrorLine BIGINT,
		@ErrorMessage NVARCHAR(4000),
		@SchemaName VARCHAR(500),
		@ErrorProcedure NVARCHAR(500),
		@ErrorSeverity BIGINT,
		@ErrorState BIGINT,
		@SPID BIGINT,
		@ServerName NVARCHAR(500),
		@ServiceName NVARCHAR(500),
		@HostName NVARCHAR(500),
		@ProgramName NVARCHAR(1000),
		@CommandLine NVARCHAR(4000),
		@LoginUser NVARCHAR(50);
		

		SELECT 
			Id as RubricId, 
			Name as RubricName, 
			Marks as RubricScore
		FROM RubricLevels 
		WHERE Id IN (11,12,13,14) 

		UNION ALL 

		SELECT 
			DAM.DomainId,
			DAM.ActivityId,
			U.UserId,
			U.FirstName as StudentName,
			RubricLevelId as RubricId,
			ARO.Remarks
		FROM dbo.ActivityRecordObservation ARO 
		INNER JOIN [User] U ON ARO.UserId = U.UserID AND U.IsDeleted = 0
		INNER JOIN DomianActivityMapping DAM ON DAM.ActivityId = ARO.ActivityId

------------------------------------------------------
SELECT ARO.Remarks 

FROM dbo.ActivityRecordObservation ARO  

UNION ---

SELECT DAM.DomainId,
			DAM.ActivityId
FROM 
DomianActivityMapping DAM 

	
END TRY
BEGIN CATCH
	SELECT
		@ErrorLine = ERROR_LINE(),
		@ErrorMessage = ERROR_MESSAGE(),
		@SchemaName = 'dbo',
		@ErrorProcedure = ERROR_PROCEDURE(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE(),
		@SPID = @@SPID,
		@ServerName = @@SERVERNAME,
		@ServiceName = @@SERVICENAME,
		@HostName = HOST_NAME(),
		@ProgramName = PROGRAM_NAME(),
		@CommandLine = '''EXECUTE dbo.[UspGetDomainActivityEvaluationDetails] ' +
					   ISNULL(CAST(@userid AS VARCHAR(20)), 'No Value') + ', ' +
					   ISNULL(CAST(@yearId AS VARCHAR(20)), 'No Value') + ', ' +
					   ISNULL(CAST(@classID AS VARCHAR(20)), 'No Value') + ', ' +
					   ISNULL(CAST(@sectionid AS VARCHAR(20)), 'No Value') + ', ' +
					   ISNULL(CAST(@Termtestid AS VARCHAR(20)), 'No Value') + ', ' +
					   '''' + ISNULL(@ThemeName, 'No Value') + ''', ' +
					   ISNULL(CAST(@PlanClassId AS VARCHAR(20)), 'No Value') + ', ' +
					   ISNULL(CAST(@DomainId AS VARCHAR(20)), 'No Value') + ', ' +
					   ISNULL(CAST(@ActivityId AS VARCHAR(20)), 'No Value') + ', ' +
					   ISNULL(CAST(@PageNo AS VARCHAR(20)), 'No Value') + ', ' +
					   ISNULL(CAST(@PageSize AS VARCHAR(20)), 'No Value') + ''',',
		@LoginUser = SUSER_SNAME();
	
	--EXECUTE dbo.uspCaptureError @ErrorLine, @ErrorMessage, @SchemaName, @ErrorProcedure, @ErrorSeverity,
	--	@ErrorState, @SPID, @ServerName, @ServiceName, @HostName, @ProgramName, @CommandLine, @LoginUser;

	SELECT ERROR_MESSAGE() AS ErrorMessage, ERROR_LINE() AS ErrorLine;
END CATCH

END