
CREATE PROCEDURE rpp.uspgetstudentdetailsforlivereview(
	@proctorid BIGINT,
	@partnerintegrationids VARCHAR(MAX),
	@startdate DATETIME2 = NULL,
	@enddate DATETIME2 = NULL
	)
AS
BEGIN
   

    BEGIN
        CREATE TABLE #partnerintegarationidslist_uspgetstudentdetailsforlivereview (
            id BIGINT PRIMARY KEY IDENTITY(1, 1),
            partnerintegarationid BIGINT
        );

        INSERT INTO #partnerintegarationidslist_uspgetstudentdetailsforlivereview (partnerintegarationid)
        SELECT CAST(value AS BIGINT) FROM STRING_SPLIT(@partnerintegrationids, ',');

        IF @startdate IS NULL
        BEGIN
            SET @startdate = CONCAT(CONVERT(DATE, GETDATE()), ' 00:00:00.00');
        END;

        IF @enddate IS NULL
        BEGIN
            SET @enddate = GETDATE();
        END;

        CREATE TABLE #t$schedulelist (
            ID INT PRIMARY KEY IDENTITY(1, 1),
            OrganizationId BIGINT,
            OrganizationName VARCHAR(255),
            TestNameInformationId BIGINT,
            TestName VARCHAR(255),
            PartnerIntegrationId VARCHAR(255),
            StudScheduleId BIGINT,
            ScheduleStartDateTime DATETIME2,
            ScheduleEndDateTime DATETIME2,
            Remarks VARCHAR(255),
            StudentName VARCHAR(255),
            ReviewStatus BIGINT,
            StorageConfiguration VARCHAR(255),
            TestDetailsId BIGINT,
            ScheduleName VARCHAR(255),
            AttemptId BIGINT,
            VideoCode VARCHAR(255),
            VideoPath VARCHAR(255),
            TokenId VARCHAR(255),
            SessionId VARCHAR(255),
            StreamStartTime DATETIME2,
            StreamEndTime DATETIME2,
            DesktopVideoCode VARCHAR(255),
            DesktopVideoPath VARCHAR(255),
            DesktopTokenId VARCHAR(255),
            DesktopSessionId VARCHAR(255),
            IsSecuredTest BIGINT,
            SecondaryVideoCode VARCHAR(255),
            SecondaryVideoPath VARCHAR(255),
            SecondaryTokenId VARCHAR(255),
            SecondarySessionId VARCHAR(255),
            ActiveBit NUMERIC(1,0),
            IsTestStopped NUMERIC(1,0),
            IsSubmitted NUMERIC(1,0),
            FirstAttempt BIGINT,
            ScheduleUserCode VARCHAR(255),
            ThirdPartyUrl VARCHAR(255),
            ScheduleId BIGINT,
            UpdatedReviewStatus BIGINT,
			latestAttemptId BIGINT
        );

        INSERT INTO #t$schedulelist (OrganizationId, OrganizationName, TestNameInformationId, TestName, PartnerIntegrationId, StudScheduleId, ScheduleStartDateTime, ScheduleEndDateTime, Remarks, StudentName, ReviewStatus, StorageConfiguration)
        SELECT
            tg.organisationid AS OrganizationId,
            tg.organisationname AS OrganizationName,
            COALESCE(tn.testnameinformationid, 0) AS TestNameInformationId,
            tn.testname AS TestName,
            ts.partnerintegrationid AS PartnerIntegrationId,
            ts.studscheduleid AS StudScheduleId,
            ts.schedulestartdatetime AS ScheduleStartDateTime,
            ts.scheduleenddatetime AS ScheduleEndDateTime,
            COALESCE(ts.remarks, '') AS Remarks,
            COALESCE(ts.studentname, '') AS StudentName,
            COALESCE(tr1.reviewstatus, 0) AS ReviewStatus,
            storageconfiguration AS StorageConfiguration
        FROM
            rpt.tblproctoravail AS tp
        INNER JOIN
            rpt.tblstudentscheduledetails AS ts ON tp.proctoravailid = ts.proctoravailid AND tp.isdeleted = 0
        INNER JOIN
            rpt.tbltestnameinformation AS tn ON tn.testnameinformationid = ts.testnameinformationid
        INNER JOIN
            rpt.tblorganisation AS tg ON tg.organisationid = ts.orgid AND tg.isdeleted = 0 AND tg.isenabled = 1
        INNER JOIN
            rpt.tblusers AS tu ON tu.userid = tp.userid AND tu.isenabled = 1 AND tu.isdeleted = 0
        INNER JOIN
            #partnerintegarationidslist_uspgetstudentdetailsforlivereview AS pil ON pil.partnerintegarationid = CAST(ts.partnerintegrationid AS BIGINT)
        LEFT OUTER JOIN
            rpt.tblproctoronlinereview AS tr1 ON tr1.studscheduleid = ts.studscheduleid AND tr1.isdeleted = 0
        LEFT OUTER JOIN
            rpt.tblorganisationconfiguration AS oc ON oc.organisationid = tg.organisationid AND oc.isdeleted = 0
        WHERE
            tp.userid = @proctorid
            AND (
                CAST(ts.schedulestartdatetime AS DATE) BETWEEN CAST(@startdate AS DATE) AND CAST(@enddate AS DATE)
                OR CAST(ts.scheduleenddatetime AS DATE) BETWEEN CAST(@startdate AS DATE) AND CAST(@enddate AS DATE)
            )
            AND ts.isdeleted = 0
            AND tn.isdeleted = 0
        ORDER BY
            ts.schedulestartdatetime 

        UPDATE #t$schedulelist
        SET TestDetailsId = td.testdetailid,
            IsSecuredTest = COALESCE(td.issecuredtest, 0),
            IsSubmitted = td.issubmitted
        FROM
            rpt.tbltestdetails AS td
        WHERE
            LOWER(CAST(#t$schedulelist.partnerintegrationid AS VARCHAR(255))) = LOWER(CAST(td.partnerintegrationid AS VARCHAR(255)))
            AND td.organisationid = #t$schedulelist.OrganizationId
            AND td.isdeleted = 0;

        UPDATE #t$schedulelist
        SET ScheduleUserCode = COALESCE(su.scheduleusercode, ''),
            ScheduleId = SD.scheduleid
        FROM
            rpt.tblorganisation AS tg
        INNER JOIN
            rpt.tblscheduleuser AS su ON LOWER(su.organizationcode) = LOWER(tg.organizationcode) AND su.isdeleted = 0
        INNER JOIN
            rpt.tblscheduledetails AS SD ON SD.scheduledetailid = SU.scheduledetailid AND SD.isdeleted = 0
        WHERE
            #t$schedulelist.PartnerIntegrationId = su.scheduleuserid
            AND tg.organisationid = #t$schedulelist.OrganizationId
            AND tg.isdeleted = 0;

        ;WITH cte
        AS (SELECT
            TestDetailsId,
            AttemptId,
            ROW_NUMBER() OVER (PARTITION BY TestDetailsId ORDER BY AttemptId DESC) AS rl
            FROM rpt.tbltestattempts
            WHERE isdeleted = 0)
        UPDATE #t$schedulelist
        SET AttemptId = cte.AttemptId
        FROM cte
        WHERE rl = 1 AND #t$schedulelist.TestDetailsId = cte.TestDetailsId;

        ;WITH cte
        AS (SELECT
            TestDetailsId,
            AttemptId,
            ROW_NUMBER() OVER (PARTITION BY TestDetailsId ORDER BY AttemptId ASC) AS rl
            FROM rpt.tbltestattempts
            WHERE isdeleted = 0)
        UPDATE #t$schedulelist
        SET FirstAttempt = cte.AttemptId
        FROM cte
        WHERE rl = 1 AND #t$schedulelist.TestDetailsId = cte.TestDetailsId;

        ;WITH cte
        AS (SELECT
            TA.StreamStartTime,
            TA.EndDateTime,
            TA.DesktopVideoCode,
            TA.DesktopVideoPath,
            TA.DesktopTokenID,
            TA.DesktopSessionID,
            TA.VideoCode,
            TA.VideoPath,
            TA.TokenId,
            TA.SessionId,
            TA.TestDetailsId,
            TA.IsTestStopped,
            ROW_NUMBER() OVER (PARTITION BY TA.TestDetailsId ORDER BY TA.TestDetailsId, TA.AttemptID DESC) AS RL
            FROM #t$schedulelist SL
            INNER JOIN rpt.tblTestAttempts TA ON SL.TestDetailsId = TA.TestDetailsId AND TA.isdeleted = 0
        )
        UPDATE #t$schedulelist
        SET StreamStartTime = TA.StreamStartTime,
            StreamEndTime = TA.EndDateTime,
            DesktopVideoCode = TA.DesktopVideoCode,
            DesktopVideoPath = TA.DesktopVideoPath,
            DesktopTokenId = TA.DesktopTokenID,
            DesktopSessionId = TA.DesktopSessionID,
            VideoCode = TA.VideoCode,
            VideoPath = TA.VideoPath,
            TokenId = TA.TokenId,
            SessionId = TA.SessionId,
            IsTestStopped = TA.IsTestStopped
        FROM cte TA
        WHERE TA.RL = 1 AND #t$schedulelist.TestDetailsId = TA.TestDetailsId;

        ;WITH cte1
        AS (SELECT
            SL.studscheduleid,
            TA.ReviewStatus,
            DENSE_RANK() OVER (PARTITION BY TA.studscheduleid ORDER BY TA.Createddate DESC) AS RL
            FROM #t$schedulelist SL
            INNER JOIN rpt.tblProctorOnlineReview TA ON SL.studscheduleid = TA.studscheduleid AND TA.isdeleted = 0
        )
        UPDATE #t$schedulelist
        SET ReviewStatus = (CASE WHEN S1.ReviewStatus IS NULL THEN 0 ELSE S1.ReviewStatus END)
        FROM (
            SELECT
                S.studscheduleid,
                TR1.ReviewStatus
            FROM
                #t$schedulelist S
            LEFT JOIN
                cte1 TR1 ON TR1.studscheduleid = S.studscheduleid
            WHERE
                RL = 1
        ) S1
        WHERE
            #t$schedulelist.studscheduleid = S1.studscheduleid;

        UPDATE #t$schedulelist
        SET ActiveBit = sc1.activebit
        FROM (
            SELECT
                sc1.*
            FROM
                rpt.secondarycameradetails AS sc1
            INNER JOIN #t$schedulelist AS sl ON sl.AttemptId = sc1.attemptid AND sl.PartnerIntegrationId = sc1.scheduleuserid
            ORDER BY
                sc1.videocode
           
        ) AS sc1
        WHERE
            #t$schedulelist.AttemptId = sc1.attemptid;

        UPDATE #t$schedulelist
        SET ActiveBit = 1
        FROM (
            SELECT
                sc1.*
            FROM
                rpt.secondarycameradetails AS sc1
            INNER JOIN #t$schedulelist AS sl ON sl.AttemptId = sc1.attemptid AND sl.PartnerIntegrationId = sc1.scheduleuserid
            WHERE
                sc1.isdeleted = 0
            ORDER BY
                sc1.videocode
           
        ) AS sc1
        WHERE
            #t$schedulelist.AttemptId = sc1.attemptid;

    
UPDATE #t$schedulelist
SET UpdatedReviewStatus = Reviewstatus;

UPDATE #t$schedulelist
SET UpdatedReviewStatus = 11
FROM rpt.tbltestpausedetails AS s1
WHERE
    s1.Pid = #t$schedulelist.PartnerIntegrationId
    AND s1.attemptid = #t$schedulelist.LatestAttemptId
    AND s1.ispaused = 1
    AND s1.isdeleted = 0;

UPDATE #t$schedulelist
SET UpdatedReviewStatus = 12
FROM rpt.tbltestattempts AS s1
WHERE
    s1.AttemptId = #t$schedulelist.LatestAttemptId
    AND s1.IsTestStopped = 1
    AND s1.IsDeleted = 0;

UPDATE #t$schedulelist
SET UpdatedReviewStatus = 13
FROM RPT.tbltestautopausedetails AS s1
WHERE
  #t$schedulelist.LatestAttemptId = s1.AttemptId
   AND s1.ActionType = 1
    AND s1.IsDeleted = 0;


SELECT 
    OrganizationId, OrganizationName, TestNameInformationId, TestName, PartnerIntegrationId, StudScheduleId, 
    ScheduleStartDateTime, ScheduleEndDateTime, Remarks, StudentName, ReviewStatus, StorageConfiguration,
    VideoCode, VideoPath, TokenId, SessionId, TestDetailsId, AttemptId, StreamStartTime, 
    StreamEndTime, DesktopVideoCode, DesktopVideoPath, DesktopTokenId, DesktopSessionId, IsSecuredTest,
    COALESCE(pausetime, 0) AS pausetime, COALESCE(extratime, 0) AS extratime, SecondaryVideoCode, 
    SecondaryVideoPath, SecondaryTokenId, SecondarySessionId, ActiveBit, IsTestStopped, IsSubmitted, 
    FirstAttempt, ScheduleUserCode, ThirdPartyUrl, ScheduleId, UpdatedReviewStatus
FROM #t$schedulelist;

END ;

END; 


