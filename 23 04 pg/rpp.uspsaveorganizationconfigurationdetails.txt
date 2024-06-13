-- PROCEDURE: rpp.uspsaveorganizationconfigurationdetails(character varying, character varying, character varying, numeric, numeric, character varying, character varying, character varying, numeric, integer, numeric, numeric, integer, integer, numeric, numeric, numeric, numeric, integer, integer, integer, numeric, numeric, numeric, integer, integer, numeric, numeric, numeric, integer, integer, numeric, integer, numeric, integer, character varying, numeric, numeric, numeric, numeric, numeric, numeric, numeric, numeric, integer, integer, numeric, numeric, numeric, numeric, numeric, integer, integer, integer, character varying, numeric, numeric, numeric, numeric, numeric)

-- DROP PROCEDURE IF EXISTS rpp.uspsaveorganizationconfigurationdetails(character varying, character varying, character varying, numeric, numeric, character varying, character varying, character varying, numeric, integer, numeric, numeric, integer, integer, numeric, numeric, numeric, numeric, integer, integer, integer, numeric, numeric, numeric, integer, integer, numeric, numeric, numeric, integer, integer, numeric, integer, numeric, integer, character varying, numeric, numeric, numeric, numeric, numeric, numeric, numeric, numeric, integer, integer, numeric, numeric, numeric, numeric, numeric, integer, integer, integer, character varying, numeric, numeric, numeric, numeric, numeric);

CREATE OR REPLACE PROCEDURE rpp.uspsaveorganizationconfigurationdetails(
	par_customercode character varying,
	par_organizationcode character varying DEFAULT NULL::character varying,
	par_useragreement character varying DEFAULT NULL::character varying,
	par_fmmcountrequired numeric DEFAULT NULL::numeric,
	par_hmmcountrequired numeric DEFAULT NULL::numeric,
	par_testplayerurl character varying DEFAULT NULL::character varying,
	par_bucketname character varying DEFAULT NULL::character varying,
	par_singlesignonurl character varying DEFAULT NULL::character varying,
	par_issecurebrowser numeric DEFAULT NULL::numeric,
	par_securebrowsertype integer DEFAULT NULL::integer,
	par_comparisonforstudent numeric DEFAULT NULL::numeric,
	par_comparisonforproctor numeric DEFAULT NULL::numeric,
	par_photocomparisontype integer DEFAULT NULL::integer,
	par_storagetype integer DEFAULT NULL::integer,
	par_issecondarycamerarequired numeric DEFAULT NULL::numeric,
	par_isaudioanalysissc numeric DEFAULT NULL::numeric,
	par_iscorrectflagsc numeric DEFAULT NULL::numeric,
	par_isroomvideorequired numeric DEFAULT NULL::numeric,
	par_streamingtype integer DEFAULT NULL::integer,
	par_fmsdurationsc integer DEFAULT NULL::integer,
	par_configurationsystemtypesc integer DEFAULT NULL::integer,
	par_ischatfeaturerequiredlive numeric DEFAULT NULL::numeric,
	par_isfacemismatchcountrequiredlive numeric DEFAULT NULL::numeric,
	par_isheadshotrequiredlive numeric DEFAULT NULL::numeric,
	par_recordingtypelive integer DEFAULT NULL::integer,
	par_configurationsystemtypelive integer DEFAULT NULL::integer,
	par_isautoproctortagging numeric DEFAULT NULL::numeric,
	par_isfacemismatchcountrequiredrr numeric DEFAULT NULL::numeric,
	par_isheadshotrequiredrr numeric DEFAULT NULL::numeric,
	par_recordingtyperr integer DEFAULT NULL::integer,
	par_configurationsystemtyperr integer DEFAULT NULL::integer,
	par_issecurebrowserimage numeric DEFAULT NULL::numeric,
	par_thresholdfrequency integer DEFAULT NULL::integer,
	par_iscorrectflagimage numeric DEFAULT NULL::numeric,
	par_configurationsystemtypeimage integer DEFAULT NULL::integer,
	INOUT par_status character varying DEFAULT ''::character varying,
	par_audioanalysislive numeric DEFAULT NULL::numeric,
	par_audioanalysisreviewer numeric DEFAULT NULL::numeric,
	par_islivemoderequired numeric DEFAULT NULL::numeric,
	par_isimagemoderequired numeric DEFAULT NULL::numeric,
	par_isreviewermoderequired numeric DEFAULT NULL::numeric,
	par_isaudioanalysisrequired numeric DEFAULT NULL::numeric,
	par_isfmmcountrequired numeric DEFAULT NULL::numeric,
	par_iscorrectflag numeric DEFAULT NULL::numeric,
	par_anlaysistype integer DEFAULT NULL::integer,
	par_imagemodeanalysis integer DEFAULT NULL::integer,
	par_isaudiocallingrequiredlive numeric DEFAULT NULL::numeric,
	par_isscreenrecordingrequiredlive numeric DEFAULT NULL::numeric,
	par_isscreenrecordingrequiredremote numeric DEFAULT NULL::numeric,
	par_isscanalysisrequiredlive numeric DEFAULT NULL::numeric,
	par_isscanalysisrequiredremote numeric DEFAULT NULL::numeric,
	par_isvideoanalysisfrequency integer DEFAULT NULL::integer,
	par_isfmmfrequency integer DEFAULT NULL::integer,
	par_imagetimeinertvalcaptured integer DEFAULT NULL::integer,
	par_thirdpartyapiurl character varying DEFAULT ''::character varying,
	par_agumatedproctoringreview numeric DEFAULT NULL::numeric,
	par_automatedproctoringreview numeric DEFAULT NULL::numeric,
	par_agumatedproctoring numeric DEFAULT NULL::numeric,
	par_automatedproctoring numeric DEFAULT NULL::numeric,
	par_isallowmultiuserconnection numeric DEFAULT NULL::numeric,
	par_AllowedWarning integer DEFAULT NULL::integer,
	par_AllowedHighflag integer DEFAULT NULL::integer,
	par_AllowedMediumflag integer DEFAULT NULL::integer,
	par_AllowedLowflag integer DEFAULT NULL::integer,
	par_AllowedTotalflag integer DEFAULT NULL::integer
)  
LANGUAGE 'plpgsql'
AS $BODY$
/* ================================================================= */
/* Author:		Balaji D */
/* Create date: 07-07-2022 */
/* Description:	This sp is used to save sytem config for organization */
/* History: */
/* 1;Balaji D;11-07-2022;Added Logic Edit case */
/* 1;Sandhyashree BM ;12-07-2022;Added new input params @AudioAnalysisLive,@AudioAnalysisReviewer */
/* 2;Sandhyashree B M ;14-07-2022;Added new input parameters @IsLiveModeRequired,@IsImageModeRequired,@IsReviewerModeRequired */
/* 3;Balaji D;15-07-2022;Added new input parameters */
/* 4;Sandhyashree B M ;Added new input paramters @IsVideoAnalysisfrequency @IsFMMfrequency */
/* ================================================================== */
 
BEGIN
     
    BEGIN
        IF LOWER(COALESCE(par_OrganizationCode, '')) = LOWER('') AND LOWER(COALESCE(par_CustomerCode, '')) <> LOWER('') THEN
            CREATE TEMPORARY TABLE t$temporg
            (id BIGINT GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
                organizationid BIGINT) ON COMMIT DROP;
          
		  INSERT INTO t$temporg (organizationid)
            SELECT DISTINCT
                o.organisationid
                FROM  rpt.tblorganisation AS o
                INNER JOIN  rpt.tblcustomers AS c
                    ON c.customerid = o.customerid AND o.isdeleted = 0 AND c.isdeleted = 0
                WHERE LOWER(c.customercode) = LOWER(par_CustomerCode);
          
		  INSERT INTO  rpt.tblorganisationconfiguration (organisationid, useragreement, fmmcountrequired,
			 hmmcountrequired, testplayerurl, bucketname, singlesignonurl, issecuredbrowser, 
			securebrowsertypeid, comparionforstudent, comparisonforproctor, photocomparisontypeid,
			storagetype, issecondarycamerarequired, islivemoderequired, isimagemoderequired, 
			isreviewermoderequired, isaudioanalysisrequired, isfmmcountrequired, iscorrectflag, analysis,
			isroomvideorequired, isvideoanalysisfrequency, isfmmfrequency,ThirdPartyAPIURL,
			AgumatedProctoringReview,AutomatedProctoringReview,AgumatedProctoring,AutomatedProctoring,isallowmultiuserconnection,
			AllowedWarning,AllowedHighflag,AllowedMediumflag,AllowedLowflag,AllowedTotalflag)
            SELECT
                t.organizationid, par_UserAgreement, par_FMMCountRequired, par_HMMCountRequired, 
				par_TestPlayerURL, par_BucketName, par_SingleSignOnURL, par_IsSecureBrowser,
				par_SecureBrowserType, par_ComparisonForStudent, par_ComparisonForProctor, 
				par_PhotoComparisonType, par_StorageType, par_IsSecondaryCameraRequired, 
				par_IsLiveModeRequired, par_IsImageModeRequired, par_IsReviewerModeRequired,
				par_IsAudioAnalysisRequired, par_IsFMMCountRequired, par_IscorrectFlag, par_AnlaysisType,
				par_IsRoomVideoRequired, par_IsVideoAnalysisfrequency, par_IsFMMfrequency,par_thirdpartyapiurl,
				par_agumatedproctoringreview,par_automatedproctoringreview,par_agumatedproctoring,par_automatedproctoring,par_isallowmultiuserconnection,
				par_AllowedWarning,par_AllowedHighflag,par_AllowedMediumflag,par_AllowedLowflag,par_AllowedTotalflag
                FROM t$temporg AS t
                WHERE NOT EXISTS (SELECT
                    1
                    FROM  rpt.tblorganisationconfiguration AS toc
                    WHERE isdeleted = 0 AND t.organizationid = toc.organisationid);

            IF par_IsSecondaryCameraRequired = 1 THEN
                INSERT INTO  rpt.tblsecondarycameraconfiguration (organizationid, isaudioanalysis, iscorrectflag, streamingtype, fmsduration, configurationsystemtype)
                SELECT
                    organizationid, par_IsAudioAnalysisSC, par_IsCorrectFlagSC, par_StreamingType, par_FMSDurationSC, par_ConfigurationSystemtypeSC
                    FROM t$temporg AS t
                    WHERE NOT EXISTS (SELECT
                        1
                        FROM  rpt.tblsecondarycameraconfiguration AS tsc
                        WHERE isdeleted = 0 AND tsc.organizationid = t.organizationid);
            END IF;

            IF par_IsLiveModeRequired = 1 THEN
                INSERT INTO  rpt.tbllivetestconfiguration (organisationid, proctoringtypeid, ischatfeaturerequired, isfacemismatchcountrequired, isheadshotrequired, recordingtype, configurationsystemtype, isautoproctortagging, isaudiofeaturerequired, isaudiocallingrequired, isscreenrecordingrequired, isscanalysisrequired)
                SELECT
                    organizationid, 1, par_IsChatFeatureRequiredLive, par_IsFaceMismatchCountRequiredLive, par_IsHeadShotRequiredLive, par_RecordingTypeLive, par_ConfigurationSystemtypeLive, par_IsAutoProctorTagging, par_AudioAnalysisLive, par_IsAudioCallingRequiredLive, par_IsScreenRecordingRequiredLive, par_IsSCAnalysisRequiredLive
                    FROM t$temporg AS t
                    WHERE NOT EXISTS (SELECT
                        1
                        FROM  rpt.tbllivetestconfiguration AS tl
                        WHERE isdeleted = 0 AND proctoringtypeid = 1 AND t.organizationid = tl.organisationid);
            END IF;

            IF par_IsImageModeRequired = 1 THEN
                INSERT INTO  rpt.tblimagetestconfiguration (organisationid, issecurebrowser, thresholdfrequency, iscorrectflag, configurationsystemtype, imagemodeanalysis, imagetimeinterval)
                SELECT
                    organizationid, par_IsSecureBrowserImage, par_ThresholdFrequency, par_IsCorrectFlagImage, par_ConfigurationSystemtypeImage, par_ImageModeAnalysis, par_ImageTimeInertvalCaptured
                    FROM t$temporg AS t
                    WHERE NOT EXISTS (SELECT
                        1
                        FROM  rpt.tblimagetestconfiguration AS ti
                        WHERE isdeleted = 0 AND t.organizationid = ti.organisationid);
            END IF;

            IF par_IsReviewerModeRequired = 1 THEN
                INSERT INTO  rpt.tbllivetestconfiguration (organisationid, proctoringtypeid, isfacemismatchcountrequired, isheadshotrequired, recordingtype, configurationsystemtype, isaudiofeaturerequired, isscreenrecordingrequired, isscanalysisrequired)
                SELECT
                    organizationid, 2, par_IsFaceMismatchCountRequiredRR, par_IsHeadShotRequiredRR, par_RecordingTypeRR, par_ConfigurationSystemtypeRR, par_AudioAnalysisReviewer, par_IsScreenRecordingRequiredRemote, par_IsSCAnalysisRequiredRemote
                    FROM t$temporg AS t
                    WHERE NOT EXISTS (SELECT
                        1
                        FROM  rpt.tbllivetestconfiguration AS tl
                        WHERE isdeleted = 0 AND proctoringtypeid = 2 AND t.organizationid = tl.organisationid);
            END IF;
           
           

            IF EXISTS (SELECT
                1
                FROM t$temporg AS o
                INNER JOIN  rpt.tblorganisationconfiguration AS oc
                    ON oc.organisationid = o.organizationid AND oc.isdeleted = 0
                LIMIT 1) THEN
				
                UPDATE  rpt.tblorganisationconfiguration AS oc
                SET useragreement = par_UserAgreement, fmmcountrequired = par_FMMCountRequired, 
				hmmcountrequired = par_HMMCountRequired, testplayerurl = par_TestPlayerURL, 
				bucketname = par_BucketName, singlesignonurl = par_SingleSignOnURL,
				issecuredbrowser = par_IsSecureBrowser, securebrowsertypeid = par_SecureBrowserType, 
				comparionforstudent = par_ComparisonForStudent, comparisonforproctor = par_ComparisonForProctor, 
				photocomparisontypeid = par_PhotoComparisonType, storagetype = par_StorageType,
				issecondarycamerarequired = par_IsSecondaryCameraRequired, islivemoderequired = par_IsLiveModeRequired, 
				isimagemoderequired = par_IsImageModeRequired, isreviewermoderequired = par_IsReviewerModeRequired,
				isaudioanalysisrequired = par_IsAudioAnalysisRequired, isfmmcountrequired = par_IsFMMCountRequired, 
				iscorrectflag = par_IscorrectFlag, analysis = par_AnlaysisType, isroomvideorequired = par_IsRoomVideoRequired, 
				isvideoanalysisfrequency = par_IsVideoAnalysisfrequency, isfmmfrequency = par_IsFMMfrequency,thirdpartyapiurl=par_thirdpartyapiurl,
				agumatedproctoringreview=par_agumatedproctoringreview,automatedproctoringreview=par_automatedproctoringreview,agumatedproctoring=par_agumatedproctoring,automatedproctoring=par_automatedproctoring,isallowmultiuserconnection = par_IsAllowmultiUserConnection,
				AllowedWarning=par_AllowedWarning,AllowedHighflag=par_AllowedHighflag,AllowedMediumflag=par_AllowedMediumflag,AllowedLowflag=par_AllowedLowflag,AllowedTotalflag=par_AllowedTotalflag
                FROM t$temporg AS o
                    WHERE oc.organisationid = o.organizationid AND oc.isdeleted = 0;
                   
                   
                UPDATE  rpt.tblsecondarycameraconfiguration AS scs
                SET isaudioanalysis = par_IsAudioAnalysisSC, iscorrectflag = par_IsCorrectFlagSC, streamingtype = par_StreamingType, fmsduration = par_FMSDurationSC, configurationsystemtype = par_ConfigurationSystemtypeSC
                FROM t$temporg AS o
                    WHERE scs.organizationid = o.organizationid AND scs.isdeleted = 0;
                
				 UPDATE RPT.tblLiveTestConfiguration AS LTC SET  IsChatFeatureRequired=par_IsChatFeatureRequiredLive, 
				 IsFaceMismatchCountRequired=par_IsFaceMismatchCountRequiredLive,IsHeadShotRequired=par_IsHeadShotRequiredLive,
                 RecordingType=par_RecordingTypeLive, ConfigurationSystemtype=par_ConfigurationSystemtypeLive, IsAutoProctorTagging=par_IsAutoProctorTagging,
				 IsAudioFeatureRequired=par_AudioAnalysisLive,IsAudioCallingRequired=par_isaudiocallingrequiredlive,
				 IsScreenRecordingRequired=par_isscreenrecordingrequiredlive,IsSCAnalysisRequired=par_isscanalysisrequiredlive
                 FROM t$temporg O WHERE LTC.OrganisationID=O.Organizationid AND LTC.isdeleted=0 AND proctoringTypeID=1;

                UPDATE RPT.tblLiveTestConfiguration AS LTC SET   IsFaceMismatchCountRequired=par_isfacemismatchcountrequiredrr,
				IsHeadShotRequired=par_isheadshotrequiredrr,RecordingType=par_recordingtyperr,ConfigurationSystemtype=par_configurationsystemtyperr,
				IsAudioFeatureRequired=par_audioanalysisreviewer,IsScreenRecordingRequired=par_isscreenrecordingrequiredremote,
				IsSCAnalysisRequired=par_isscanalysisrequiredremote
                FROM  t$temporg O WHERE LTC.OrganisationID=O.Organizationid AND LTC.isdeleted=0
                AND proctoringTypeID=2;

                UPDATE  rpt.tblimagetestconfiguration AS itc_dml
                SET issecurebrowser = par_IsSecureBrowserImage, thresholdfrequency = par_ThresholdFrequency, iscorrectflag = par_IsCorrectFlagImage, configurationsystemtype = par_ConfigurationSystemtypeImage, imagemodeanalysis = par_ImageModeAnalysis, imagetimeinterval = par_ImageTimeInertvalCaptured
                FROM t$temporg AS o
                    WHERE itc_dml.organisationid = o.organizationid AND itc_dml.isdeleted = 0;
            END IF;
        ELSE
            IF LOWER(COALESCE(par_OrganizationCode, '')) <> LOWER('') AND LOWER(COALESCE(par_CustomerCode, '')) <> LOWER('') THEN
               
			INSERT INTO  rpt.tblorganisationconfiguration (organisationid, useragreement,
			fmmcountrequired, hmmcountrequired, testplayerurl, bucketname, singlesignonurl, 
			issecuredbrowser, securebrowsertypeid, comparionforstudent, comparisonforproctor, 
			photocomparisontypeid, storagetype, issecondarycamerarequired, islivemoderequired, 
			isimagemoderequired, isreviewermoderequired, isaudioanalysisrequired, isfmmcountrequired,
			iscorrectflag, analysis, isroomvideorequired, isvideoanalysisfrequency, isfmmfrequency,ThirdPartyAPIURL,
			AgumatedProctoringReview,AutomatedProctoringReview,AgumatedProctoring,AutomatedProctoring,isallowmultiuserconnection,
			AllowedWarning,AllowedHighflag,AllowedMediumflag,AllowedLowflag,AllowedTotalflag)
            SELECT o.organisationid, par_UserAgreement, par_FMMCountRequired, par_HMMCountRequired, 
			par_TestPlayerURL, par_BucketName, par_SingleSignOnURL, par_IsSecureBrowser, par_SecureBrowserType,
			par_ComparisonForStudent, par_ComparisonForProctor, par_PhotoComparisonType, par_StorageType,
			par_IsSecondaryCameraRequired, par_IsLiveModeRequired, par_IsImageModeRequired, par_IsReviewerModeRequired,
			par_IsAudioAnalysisRequired, par_IsFMMCountRequired, par_IscorrectFlag, par_AnlaysisType, 
			par_IsRoomVideoRequired, par_IsVideoAnalysisfrequency, par_IsFMMfrequency,par_thirdpartyapiurl,
			par_agumatedproctoringreview,par_automatedproctoringreview,par_agumatedproctoring,par_automatedproctoring,par_isallowmultiuserconnection,
			par_AllowedWarning,par_AllowedHighflag,par_AllowedMediumflag,par_AllowedLowflag,par_AllowedTotalflag
            FROM  rpt.tblorganisation AS o
            WHERE NOT EXISTS (SELECT 1
								FROM  rpt.tblorganisationconfiguration AS toc
								WHERE isdeleted = 0 AND o.organisationid = toc.organisationid) AND LOWER(o.organizationcode) = LOWER(par_OrganizationCode);

                IF par_IsSecondaryCameraRequired = 1 THEN
                    INSERT INTO  rpt.tblsecondarycameraconfiguration (organizationid, isaudioanalysis, iscorrectflag, streamingtype, fmsduration, configurationsystemtype)
                    SELECT
                        organisationid, par_IsAudioAnalysisSC, par_IsCorrectFlagSC, par_StreamingType, par_FMSDurationSC, par_ConfigurationSystemtypeSC
                        FROM  rpt.tblorganisation AS t
                        WHERE NOT EXISTS (SELECT
                            1
                            FROM  rpt.tblsecondarycameraconfiguration AS ts
                            WHERE isdeleted = 0 AND t.organisationid = ts.organizationid) AND LOWER(t.organizationcode) = LOWER(par_OrganizationCode);
                END IF;

                IF par_IsLiveModeRequired = 1 THEN
                    INSERT INTO  rpt.tbllivetestconfiguration (organisationid, proctoringtypeid, ischatfeaturerequired, isfacemismatchcountrequired, isheadshotrequired, recordingtype, configurationsystemtype, isautoproctortagging, isaudiofeaturerequired, isaudiocallingrequired, isscreenrecordingrequired, isscanalysisrequired)
                    SELECT
                        organisationid, 1, par_IsChatFeatureRequiredLive, par_IsFaceMismatchCountRequiredLive, par_IsHeadShotRequiredLive, par_RecordingTypeLive, par_ConfigurationSystemtypeLive, par_IsAutoProctorTagging, par_AudioAnalysisLive, par_IsAudioCallingRequiredLive, par_IsScreenRecordingRequiredLive, par_IsSCAnalysisRequiredLive
                        FROM  rpt.tblorganisation AS t
                        WHERE NOT EXISTS (SELECT
                            1
                            FROM  rpt.tbllivetestconfiguration AS tl
                            WHERE isdeleted = 0 AND proctoringtypeid = 1 AND t.organisationid = tl.organisationid) AND LOWER(t.organizationcode) = LOWER(par_OrganizationCode);
                END IF;

                IF par_IsImageModeRequired = 1 THEN
                    INSERT INTO  rpt.tblimagetestconfiguration (organisationid, issecurebrowser, thresholdfrequency, iscorrectflag, configurationsystemtype, imagetimeinterval)
                    SELECT
                        organisationid, par_IsSecureBrowserImage, par_ThresholdFrequency, par_IsCorrectFlagImage, par_ConfigurationSystemtypeImage, par_ImageTimeInertvalCaptured
                        FROM  rpt.tblorganisation AS t
                        WHERE NOT EXISTS (SELECT
                            1
                            FROM  rpt.tblimagetestconfiguration AS ti
                            WHERE isdeleted = 0 AND t.organisationid = ti.organisationid) AND LOWER(t.organizationcode) = LOWER(par_OrganizationCode);
                END IF;

                IF par_IsReviewerModeRequired = 1 THEN
                    INSERT INTO  rpt.tbllivetestconfiguration (organisationid, proctoringtypeid, isfacemismatchcountrequired, isheadshotrequired, recordingtype, configurationsystemtype, isaudiofeaturerequired, isscreenrecordingrequired, isscanalysisrequired)
                    SELECT
                        organisationid, 2, par_IsFaceMismatchCountRequiredRR, par_IsHeadShotRequiredRR, par_RecordingTypeRR, par_ConfigurationSystemtypeRR, par_AudioAnalysisReviewer, par_IsScreenRecordingRequiredRemote, par_IsSCAnalysisRequiredRemote
                        FROM  rpt.tblorganisation AS t
                        WHERE NOT EXISTS (SELECT
                            1
                            FROM  rpt.tbllivetestconfiguration AS tl
                            WHERE isdeleted = 0 AND proctoringtypeid = 2 AND t.organisationid = tl.organisationid) AND LOWER(t.organizationcode) = LOWER(par_OrganizationCode);
                END IF;

                IF EXISTS (SELECT
                    1
                    FROM  rpt.tblorganisationconfiguration AS oc
                    INNER JOIN  rpt.tblorganisation AS o
                        ON oc.organisationid = o.organisationid AND oc.isdeleted = 0 AND o.isdeleted = 0 AND LOWER(o.organizationcode) = LOWER(par_OrganizationCode)
                    LIMIT 1) THEN
                    
					UPDATE RPT.tblOrganisationConfiguration AS OC SET  UserAgreement=par_useragreement,FMMCountRequired=par_FMMCountRequired, 
					HMMCountRequired=par_HMMCountRequired, TestPlayerUrl=par_TestPlayerURL,BucketName=par_BucketName, 
					SingleSignOnURL=par_SingleSignOnURL,IsSecuredBrowser=par_IsSecureBrowser, SecureBrowserTypeID=par_SecureBrowserType,
                    ComparionForStudent=par_ComparisonForStudent, ComparisonForProctor=par_ComparisonForProctor, 
					PhotoComparisonTypeID=par_PhotoComparisonType,StorageType=par_StorageType, 
					IsSecondaryCameraRequired=par_IsSecondaryCameraRequired,IsLiveModeRequired=par_IsLiveModeRequired,
					IsImageModeRequired=par_IsImageModeRequired,IsReviewerModeRequired=par_IsReviewerModeRequired,
                    IsAudioAnalysisRequired=par_IsAudioAnalysisRequired,IsFMMCountRequired=par_IsFMMCountRequired,
					IsCorrectFlag=par_IscorrectFlag,Analysis=par_AnlaysisType,IsRoomVideoRequired=par_IsRoomVideoRequired,
					IsVideoAnalysisfrequency=par_IsVideoAnalysisfrequency,IsFMMfrequency=par_IsFMMfrequency,thirdpartyapiurl=par_thirdpartyapiurl,
				    agumatedproctoringreview=par_agumatedproctoringreview,automatedproctoringreview=par_automatedproctoringreview,
					agumatedproctoring=par_agumatedproctoring,automatedproctoring=par_automatedproctoring,isallowmultiuserconnection = par_IsAllowmultiUserConnection,
                    AllowedWarning=par_AllowedWarning,AllowedHighflag=par_AllowedHighflag,AllowedMediumflag=par_AllowedMediumflag,AllowedLowflag=par_AllowedLowflag,AllowedTotalflag=par_AllowedTotalflag
					FROM   RPT.tblOrganisation O WHERE OC.OrganisationID=O.OrganisationID AND OC.isdeleted=0
                    AND O.OrganizationCode=par_OrganizationCode;

                    UPDATE RPT.tblSecondaryCameraConfiguration AS SCS SET IsAudioAnalysis=par_IsAudioAnalysisSC,IsCorrectFlag=par_IsCorrectFlagSC,
                     StreamingType=par_StreamingType,FMSDuration=par_FMSDurationSC,ConfigurationSystemtype=par_ConfigurationSystemtypeSC
                     FROM  RPT.tblOrganisation O WHERE SCS.Organizationid=O.OrganisationID AND SCS.isdeleted=0
                     AND O.OrganizationCode=par_OrganizationCode;

                    UPDATE RPT.tblLiveTestConfiguration AS LTC SET   IsChatFeatureRequired=par_IsChatFeatureRequiredLive,
					 IsFaceMismatchCountRequired=par_IsFaceMismatchCountRequiredLive,IsHeadShotRequired=par_IsHeadShotRequiredLive,
                     RecordingType=par_RecordingTypeLive,ConfigurationSystemtype=par_ConfigurationSystemtypeLive,
					 IsAutoProctorTagging=par_IsAutoProctorTagging,IsAudioFeatureRequired=par_AudioAnalysisLive,
                     IsAudioCallingRequired=par_isaudiocallingrequiredlive,IsScreenRecordingRequired=par_isscreenrecordingrequiredlive,
					 IsSCAnalysisRequired=par_isscanalysisrequiredlive
                     FROM   RPT.tblOrganisation O WHERE LTC.OrganisationID=O.OrganisationID AND LTC.isdeleted=0
                     AND proctoringTypeID=1 AND  O.OrganizationCode=par_OrganizationCode;
                    
                    UPDATE RPT.tblLiveTestConfiguration AS LTC SET  IsFaceMismatchCountRequired=par_isfacemismatchcountrequiredrr,
					IsHeadShotRequired=par_isheadshotrequiredrr,RecordingType=par_recordingtyperr,
					ConfigurationSystemtype=par_configurationsystemtyperr,IsAudioFeatureRequired=par_audioanalysisreviewer,
                    IsScreenRecordingRequired=par_isscreenrecordingrequiredremote,IsSCAnalysisRequired=par_isscanalysisrequiredremote
                    FROM    RPT.tblOrganisation O WHERE LTC.OrganisationID=O.OrganisationID AND LTC.isdeleted=0
                    AND proctoringTypeID=2 AND  O.OrganizationCode=par_OrganizationCode;
                    

                    UPDATE  rpt.tblimagetestconfiguration AS itc_dml
                    SET issecurebrowser = par_IsSecureBrowserImage, thresholdfrequency = par_ThresholdFrequency, iscorrectflag = par_IsCorrectFlagImage, configurationsystemtype = par_ConfigurationSystemtypeImage, imagemodeanalysis = par_ImageModeAnalysis, imagetimeinterval = par_ImageTimeInertvalCaptured
                    FROM  rpt.tblorganisation AS o
                        WHERE itc_dml.organisationid = o.organisationid AND itc_dml.isdeleted = 0 AND LOWER(o.organizationcode) = LOWER(par_OrganizationCode);
                END IF;
            END IF;
        END IF;
        par_Status := 'S001';
        
    END;
     
END;
$BODY$;

ALTER PROCEDURE rpp.uspsaveorganizationconfigurationdetails(character varying, character varying, character varying, numeric, numeric, character varying, character varying, character varying, numeric, integer, numeric, numeric, integer, integer, numeric, numeric, numeric, numeric, integer, integer, integer, numeric, numeric, numeric, integer, integer, numeric, numeric, numeric, integer, integer, numeric, integer, numeric, integer, character varying, numeric, numeric, numeric, numeric, numeric, numeric, numeric, numeric, integer, integer, numeric, numeric, numeric, numeric, numeric, integer, integer, integer, character varying, numeric, numeric, numeric, numeric, numeric)
    OWNER TO balaji;
