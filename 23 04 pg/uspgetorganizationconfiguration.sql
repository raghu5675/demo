-- PROCEDURE: rpp.uspgetorganizationconfiguration(character varying, character varying, refcursor, refcursor)

-- DROP PROCEDURE IF EXISTS rpp.uspgetorganizationconfiguration(character varying, character varying, refcursor, refcursor);

CREATE OR REPLACE PROCEDURE rpp.uspgetorganizationconfiguration(
	par_customercode character varying,
	par_organizationcode character varying DEFAULT NULL::character varying,
	INOUT p_refcur refcursor DEFAULT NULL::refcursor,
	INOUT p_refcur_2 refcursor DEFAULT NULL::refcursor)
LANGUAGE 'plpgsql'
AS $BODY$
/* ============================================= */
/* Author:		Balaji D */
/* Create date: 08-07-2022 */
/* Description:	This sp is used to get all customer code */
/* History */
/* 1;SAndhyaShree BM;12-07-2022; Added new output column */
/* 2;Sandhyashree B M 14-07-2022 Added new o/p column */
/* 3;Sandhyashree B M 19-07-2022 Added new o/p columns */
/* ============================================= */
 
BEGIN
    
    BEGIN
        CREATE TEMPORARY TABLE t$temp
        (id BIGINT GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),
            organizationid BIGINT,
            useragreement TEXT,
            fmmcountrequired NUMERIC(1, 0),
            hmmcountrequired NUMERIC(1, 0),
            testplayerurl TEXT,
            bucketname VARCHAR(200),
            singlesignonurl TEXT,
            issecurebrowser NUMERIC(1, 0),
            securebrowsertype INTEGER,
            comparisonforstudent NUMERIC(1, 0),
            comparisonforproctor NUMERIC(1, 0),
            photocomparisontype INTEGER,
            storagetype INTEGER,
            issecondarycamerarequired NUMERIC(1, 0),
            isaudioanalysissc NUMERIC(1, 0),
            iscorrectflagsc NUMERIC(1, 0),
            isroomvideorequired NUMERIC(1, 0),
            streamingtype INTEGER,
            fmsdurationsc INTEGER,
            configurationsystemtypesc INTEGER,
            isroomvideorequiredlive NUMERIC(1, 0),
            ischatfeaturerequiredlive NUMERIC(1, 0),
            isfacemismatchcountrequiredlive NUMERIC(1, 0),
            isheadshotrequiredlive NUMERIC(1, 0),
            recordingtypelive INTEGER,
            configurationsystemtypelive INTEGER,
            isautoproctortagging NUMERIC(1, 0),
            isroomvideorequiredrr NUMERIC(1, 0),
            isfacemismatchcountrequiredrr NUMERIC(1, 0),
            isheadshotrequiredrr NUMERIC(1, 0),
            recordingtyperr INTEGER,
            configurationsystemtyperr INTEGER,
            issecurebrowserimage NUMERIC(1, 0),
            thresholdfrequency INTEGER,
            iscorrectflagimage NUMERIC(1, 0),
            isroomvideorequiredimage NUMERIC(1, 0),
            configurationsystemtypeimage INTEGER,
            audioanalysislive NUMERIC(1, 0),
            audioanalysisreviewer NUMERIC(1, 0),
            islivemoderequired NUMERIC(1, 0),
            isimagemoderequired NUMERIC(1, 0),
            isreviewermoderequired NUMERIC(1, 0),
            isaudioanalysisrequired NUMERIC(1, 0),
            isfmmcountrequired NUMERIC(1, 0),
            iscorrectflag NUMERIC(1, 0),
            anlaysistype INTEGER,
            imagemodeanalysis INTEGER,
            isaudiocallingrequiredlive NUMERIC(1, 0),
            isscreenrecordingrequiredlive NUMERIC(1, 0),
            isscreenrecordingrequiredremote NUMERIC(1, 0),
            isscanalysisrequiredlive NUMERIC(1, 0),
            isscanalysisrequiredremote NUMERIC(1, 0),
            isvideoanalysisfrequency INTEGER,
            isfmmfrequency INTEGER,
            imagetimeinterval INTEGER,
		     ThirdPartyAPIURL TEXT,
		     AgumatedProctoringReview  NUMERIC(1, 0),
			 AutomatedProctoringReview  NUMERIC(1, 0),
			 AgumatedProctoring  NUMERIC(1, 0),
			 AutomatedProctoring  NUMERIC(1, 0)) ON COMMIT DROP;

        IF (LOWER(COALESCE(par_CustomerCode, '')) <> LOWER('') AND LOWER(COALESCE(par_OrganizationCode, '')) <> LOWER('')) THEN
           
		   INSERT INTO t$temp (organizationid, useragreement, fmmcountrequired, hmmcountrequired, testplayerurl, bucketname, singlesignonurl, issecurebrowser, securebrowsertype, comparisonforstudent, comparisonforproctor, photocomparisontype, storagetype, issecondarycamerarequired, isaudioanalysissc, iscorrectflagsc, isroomvideorequired, streamingtype, fmsdurationsc, configurationsystemtypesc, issecurebrowserimage, thresholdfrequency, iscorrectflagimage, isroomvideorequiredimage, configurationsystemtypeimage, islivemoderequired, isimagemoderequired, isreviewermoderequired, isaudioanalysisrequired, isfmmcountrequired, iscorrectflag, anlaysistype, imagemodeanalysis, isvideoanalysisfrequency, isfmmfrequency, imagetimeinterval,ThirdPartyAPIURL,
			AgumatedProctoringReview,AutomatedProctoringReview,AgumatedProctoring,AutomatedProctoring)
            SELECT
                o1.organisationid, o.useragreement, o.fmmcountrequired, o.hmmcountrequired, o.testplayerurl, o.bucketname, o.singlesignonurl, o.issecuredbrowser, o.securebrowsertypeid, o.comparionforstudent, o.comparisonforproctor, o.photocomparisontypeid, o.storagetype, o.issecondarycamerarequired, sc.isaudioanalysis, sc.iscorrectflag, o.isroomvideorequired, sc.streamingtype, sc.fmsduration, sc.configurationsystemtype, it.issecurebrowser, it.thresholdfrequency, it.iscorrectflag, it.isroomvideorequired, it.configurationsystemtype, o.islivemoderequired, o.isimagemoderequired, o.isreviewermoderequired, o.isaudioanalysisrequired, o.isfmmcountrequired, o.iscorrectflag, o.analysis, it.imagemodeanalysis, o.isvideoanalysisfrequency, o.isfmmfrequency, it.imagetimeinterval
				,O.ThirdPartyAPIURL,O.AgumatedProctoringReview,O.AutomatedProctoringReview,O.AgumatedProctoring,O.AutomatedProctoring,
				O.AllowedWarning,O.AllowedHighflag,O.AllowedMediumflag,O.AllowedLowflag,O.AllowedTotalflag
                FROM  rpt.tblorganisationconfiguration AS o
                INNER JOIN  rpt.tblorganisation AS o1
                    ON o1.organisationid = o.organisationid AND o1.isdeleted = 0
                INNER JOIN  rpt.tblcustomers AS c
                    ON c.customerid = o1.customerid AND c.isdeleted = 0
                LEFT OUTER JOIN  rpt.tblsecondarycameraconfiguration AS sc
                    ON sc.organizationid = o.organisationid AND o.isdeleted = 0 AND sc.isdeleted = 0
                LEFT OUTER JOIN  rpt.tblimagetestconfiguration AS it
                    ON it.organisationid = o.organisationid AND it.isdeleted = 0
                WHERE LOWER(o1.organizationcode) = LOWER(par_OrganizationCode) AND LOWER(c.customercode) = LOWER(par_CustomerCode) AND o1.isenabled = 1;
            UPDATE t$temp AS t
            SET isroomvideorequiredlive = lt.isroomvideorequired, ischatfeaturerequiredlive = lt.ischatfeaturerequired, isfacemismatchcountrequiredlive = lt.isfacemismatchcountrequired, isheadshotrequiredlive = lt.isheadshotrequired, recordingtypelive = lt.recordingtype, configurationsystemtypelive = lt.configurationsystemtype, isautoproctortagging = lt.isautoproctortagging, audioanalysislive = lt.isaudiofeaturerequired, isaudiocallingrequiredlive = lt.isaudiocallingrequired, isscreenrecordingrequiredlive = lt.isscreenrecordingrequired, isscanalysisrequiredlive = lt.isscanalysisrequired
            FROM  rpt.tbllivetestconfiguration AS lt
                WHERE lt.isdeleted = 0 AND lt.proctoringtypeid = 1 AND lt.organisationid = t.organizationid;
            UPDATE t$temp AS t
            SET isroomvideorequiredrr = lt.isroomvideorequired, isfacemismatchcountrequiredrr = lt.isfacemismatchcountrequired, isheadshotrequiredrr = lt.isheadshotrequired, recordingtyperr = lt.recordingtype, configurationsystemtyperr = lt.configurationsystemtype, audioanalysisreviewer = lt.isaudiofeaturerequired, isscreenrecordingrequiredremote = lt.isscreenrecordingrequired, isscanalysisrequiredremote = lt.isscanalysisrequired
            FROM  rpt.tbllivetestconfiguration AS lt
                WHERE lt.isdeleted = 0 AND lt.proctoringtypeid = 2 AND lt.organisationid = t.organizationid;
            OPEN p_refcur FOR
            SELECT
                useragreement, fmmcountrequired, hmmcountrequired, testplayerurl, bucketname, singlesignonurl, issecurebrowser, securebrowsertype, comparisonforstudent, comparisonforproctor, photocomparisontype, storagetype, issecondarycamerarequired, isaudioanalysissc, iscorrectflagsc, isroomvideorequired, streamingtype, fmsdurationsc, configurationsystemtypesc, isroomvideorequiredlive, ischatfeaturerequiredlive, isfacemismatchcountrequiredlive, isheadshotrequiredlive, recordingtypelive, configurationsystemtypelive, isautoproctortagging, isroomvideorequiredrr, isfacemismatchcountrequiredrr, isheadshotrequiredrr, recordingtyperr, configurationsystemtyperr, issecurebrowserimage, thresholdfrequency, iscorrectflagimage, isroomvideorequiredimage, configurationsystemtypeimage, audioanalysislive, audioanalysisreviewer, islivemoderequired, isimagemoderequired, isreviewermoderequired, isaudioanalysisrequired, isfmmcountrequired, iscorrectflag, anlaysistype, imagemodeanalysis, isaudiocallingrequiredlive, isscreenrecordingrequiredlive, isscreenrecordingrequiredremote, isscanalysisrequiredlive, isscanalysisrequiredremote, isvideoanalysisfrequency, isfmmfrequency, imagetimeinterval,
				ThirdPartyAPIURL,AgumatedProctoringReview,AutomatedProctoringReview,AgumatedProctoring,AutomatedProctoring
                FROM t$temp;
        ELSE
            IF (LOWER(COALESCE(par_CustomerCode, '')) <> LOWER('') AND LOWER(COALESCE(par_OrganizationCode, '')) = LOWER('')) THEN
                INSERT INTO t$temp (organizationid, useragreement, fmmcountrequired, hmmcountrequired, testplayerurl, bucketname, singlesignonurl, issecurebrowser, securebrowsertype, comparisonforstudent, comparisonforproctor, photocomparisontype, storagetype, issecondarycamerarequired, isaudioanalysissc, iscorrectflagsc, isroomvideorequired, streamingtype, fmsdurationsc, configurationsystemtypesc, issecurebrowserimage, thresholdfrequency, iscorrectflagimage, isroomvideorequiredimage, configurationsystemtypeimage, islivemoderequired, isimagemoderequired, isreviewermoderequired, isaudioanalysisrequired, isfmmcountrequired, iscorrectflag, anlaysistype, imagemodeanalysis, isvideoanalysisfrequency, isfmmfrequency, imagetimeinterval,ThirdPartyAPIURL,
			     AgumatedProctoringReview,AutomatedProctoringReview,AgumatedProctoring,AutomatedProctoring)
                SELECT
                    o1.organisationid, o.useragreement, o.fmmcountrequired, o.hmmcountrequired, o.testplayerurl, o.bucketname, o.singlesignonurl, o.issecuredbrowser, o.securebrowsertypeid, o.comparionforstudent, o.comparisonforproctor, o.photocomparisontypeid, o.storagetype, o.issecondarycamerarequired, sc.isaudioanalysis, sc.iscorrectflag, o.isroomvideorequired, sc.streamingtype, sc.fmsduration, sc.configurationsystemtype, it.issecurebrowser, it.thresholdfrequency, it.iscorrectflag, it.isroomvideorequired, it.configurationsystemtype, o.islivemoderequired, o.isimagemoderequired, o.isreviewermoderequired, o.isaudioanalysisrequired, o.isfmmcountrequired, o.iscorrectflag, o.analysis, it.imagemodeanalysis, o.isvideoanalysisfrequency, o.isfmmfrequency, imagetimeinterval
					,O.ThirdPartyAPIURL,O.AgumatedProctoringReview,O.AutomatedProctoringReview,O.AgumatedProctoring,O.AutomatedProctoring,
                    O.AllowedWarning,O.AllowedHighflag,O.AllowedMediumflag,O.AllowedLowflag,O.AllowedTotalflag
					FROM  rpt.tblorganisationconfiguration AS o
                    INNER JOIN  rpt.tblorganisation AS o1
                        ON o1.organisationid = o.organisationid AND o1.isdeleted = 0
                    INNER JOIN  rpt.tblcustomers AS c
                        ON c.customerid = o1.customerid AND c.isdeleted = 0
                    INNER JOIN  rpt.tblusers AS u
                        ON u.organisationid = o1.organisationid AND u.roleid = 7 AND u.isdeleted = 0
                    LEFT OUTER JOIN  rpt.tblsecondarycameraconfiguration AS sc
                        ON sc.organizationid = o.organisationid AND o.isdeleted = 0 AND sc.isdeleted = 0
                    LEFT OUTER JOIN  rpt.tblimagetestconfiguration AS it
                        ON it.organisationid = o.organisationid AND it.isdeleted = 0
                    WHERE LOWER(c.customercode) = LOWER(par_CustomerCode) AND o1.isenabled = 1;
                UPDATE t$temp AS t
                SET isroomvideorequiredlive = lt.isroomvideorequired, ischatfeaturerequiredlive = lt.ischatfeaturerequired, isfacemismatchcountrequiredlive = lt.isfacemismatchcountrequired, isheadshotrequiredlive = lt.isheadshotrequired, recordingtypelive = lt.recordingtype, configurationsystemtypelive = lt.configurationsystemtype, isautoproctortagging = lt.isautoproctortagging, audioanalysislive = lt.isaudiofeaturerequired, isaudiocallingrequiredlive = lt.isaudiocallingrequired, isscreenrecordingrequiredlive = lt.isscreenrecordingrequired, isscanalysisrequiredlive = lt.isscanalysisrequired
                FROM  rpt.tbllivetestconfiguration AS lt
                    WHERE lt.isdeleted = 0 AND lt.proctoringtypeid = 1 AND lt.organisationid = t.organizationid;
                UPDATE t$temp AS t
                SET isroomvideorequiredrr = lt.isroomvideorequired, isfacemismatchcountrequiredrr = lt.isfacemismatchcountrequired, isheadshotrequiredrr = lt.isheadshotrequired, recordingtyperr = lt.recordingtype, configurationsystemtyperr = lt.configurationsystemtype, audioanalysisreviewer = lt.isaudiofeaturerequired, isscreenrecordingrequiredremote = lt.isscreenrecordingrequired, isscanalysisrequiredremote = lt.isscanalysisrequired
                FROM  rpt.tbllivetestconfiguration AS lt
                    WHERE lt.isdeleted = 0 AND lt.proctoringtypeid = 2 AND lt.organisationid = t.organizationid;
                OPEN p_refcur_2 FOR
                SELECT
                    useragreement, fmmcountrequired, hmmcountrequired, testplayerurl, bucketname, singlesignonurl, issecurebrowser, securebrowsertype, comparisonforstudent, comparisonforproctor, photocomparisontype, storagetype, issecondarycamerarequired, isaudioanalysissc, iscorrectflagsc, isroomvideorequired, streamingtype, fmsdurationsc, configurationsystemtypesc, isroomvideorequiredlive, ischatfeaturerequiredlive, isfacemismatchcountrequiredlive, isheadshotrequiredlive, recordingtypelive, configurationsystemtypelive, isautoproctortagging, isroomvideorequiredrr, isfacemismatchcountrequiredrr, isheadshotrequiredrr, recordingtyperr, configurationsystemtyperr, issecurebrowserimage, thresholdfrequency, iscorrectflagimage, isroomvideorequiredimage, configurationsystemtypeimage, audioanalysislive, audioanalysisreviewer, islivemoderequired, isimagemoderequired, isreviewermoderequired, isaudioanalysisrequired, isfmmcountrequired, iscorrectflag, anlaysistype, imagemodeanalysis, isaudiocallingrequiredlive, isscreenrecordingrequiredlive, isscreenrecordingrequiredremote, isscanalysisrequiredlive, isscanalysisrequiredremote, isvideoanalysisfrequency, isfmmfrequency, imagetimeinterval,
					ThirdPartyAPIURL,AgumatedProctoringReview,AutomatedProctoringReview,AgumatedProctoring,AutomatedProctoring
                    FROM t$temp;
            END IF;
        END IF;
         END;
     
END;
$BODY$;

ALTER PROCEDURE rpp.uspgetorganizationconfiguration(character varying, character varying, refcursor, refcursor)
    OWNER TO balaji;
