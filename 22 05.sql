USE [SarasDB_K12Saras]
GO
/****** Object:  StoredProcedure [dbo].[uspGetFASATestReportDetails_PDFExport]    Script Date: 22-05-2024 15:00:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Varsha M
-- Create date: 21-05-2024
-- Description:	To get all FA-SA assesment details and Report with scores.
-- History    :
-- =============================================
ALTER PROCEDURE [dbo].[uspGetFASATestReportDetails_PDFExport]
(

	@UserId BIGINT='' ,
	@StudentId BIGINT, 
	@OrganizationId BIGINT, 
	@YearId BIGINT =0,
	@PlanClassID BIGINT=0,
	@Termtypeid BIGINT
)
AS

BEGIN 
SET NOCOUNT ON;  
BEGIN TRY
 
	DECLARE @StartYear INT,@EndYear INT  
	DECLARE @Month1 INT,@Month2 INT  
	DECLARE @OrganizationStartDate DATETIME,@OrganizationEndDate DATETIME  
	DECLARE @ClassID BIGINT

	 SELECT @ClassID=ClassID FROM [User] WHERE Userid=@StudentID AND Isdeleted=0

	SELECT @Month1=AcademicYearStartMonth,@Month2=AcademicYearEndMonth FROM OrganizationSettings WHERE OrganizationID=@organizationid   
    
	SELECT @StartYear=[Year] FROM [Year] WHERE YearID=@yearID 
	 
	SET @EndYear= CASE WHEN @Month1 = 1 THEN @StartYear ELSE @StartYear+1 END
       
	SELECT @OrganizationStartDate=DATEADD(MONTH,@Month1-1,DATEADD(YEAR,@StartYear-1900,0))

	SELECT @OrganizationEndDate= DATEADD(DAY,-1,DATEADD(MONTH,@Month2,DATEADD(YEAR,@EndYear-1900,0))) 

	DECLARE @NoofQuestions INT,@TotalScore INT,@ScheduleInfo NVARCHAR(MAX),@SchedulePublish  NVARCHAR(MAX),@ScheduleCompleted NVARCHAR(MAX)

	DECLARE @UserAnswermapping TABLE(ID INT Identity(1,1),ScheduleUserID bigint,QuestionGUID varchar(50),UserResponse nvarchar(MAX),
    ChoiceGUID nvarchar(200),Assetsubtypeid BIGINT,Isdeleted BIT DEFAULT(0),QuestionID BIGINT,MisConceptionCode NVARCHAR(50))    
       
	CREATE TABLE #TempUserDetails(ID BIGINT IDENTITY(1,1),StudentName NVARCHAR(200),ClassName NVARCHAR(100),ClassID BIGINT,SectionID BIGINT,SectionName NVARCHAR(50),
	AssessmentID BIGINT,AssessmentName NVARCHAR(200),SubmittedDate DATETIME,ObtainedScore  Decimal(5,2),TotalScore  Decimal(5,2),Percentage Decimal(5,2),
	OverallScale NVARCHAR(100),Demonstrates NVARCHAR(200),AssignedStartDate DATETIME, AssignedEndDate DATETIME, RemedialReleaseDate DATETIME, 
	RemedialCompletionStatus INT, ReportsPublishedDate DATETIME,UserID BIGINT,ProfileImageUrl NVARCHAR(1000))

	CREATE TABLE #TempQuestions(ID BIGINT IDENTITY(1,1),QuestionID BIGINT,AssessmentID BIGINT,ScheduleDetailID BIGINT,ScheduleUserID BIGINT,TestAssetID BIGINT,
	QuestionAssetID BIGINT,UserID BIGINT,ObtainedScore Decimal(5,2),TotalScore Decimal(5,2),ThemeorConceptID BIGINT,PlanclassID BIGINT,Competency INT,Complexity INT,UserResponse NVARCHAR(MAX),QuestionGUID NVARCHAR(200))

	INSERT INTO #TempUserDetails(UserID,StudentName,ClassID,ClassName,SectionID,SectionName,ProfileImageUrl)
	SELECT DISTINCT  U.UserID,ISNULL(U.FirstName,'')+' '+ISNULL(U.LastName,''),C.ClassID,C.ClassName,S.ID,S.SectionName,ISNULL(UP.Photo1,'') FROM [User] U 
	INNER JOIN [UserProfile] UP ON U.UserID=UP.UserID AND U.Isdeleted=0 AND UP.isdeleted=0
	INNER JOIN Class C ON C.ClassID=U.ClassID AND C.isdeleted=0
	INNER JOIN Sections S ON S.ID=U.Sectionid AND S.isdeleted=0
	WHERE U.USerID=@StudentId AND U.OrganizationID=@OrganizationId

	INSERT INTO #TempQuestions(QuestionID,AssessmentID,TestAssetID,ScheduleDetailID,ScheduleUserID,QuestionAssetID,Userid,ObtainedScore,TotalScore,ThemeorConceptID,PlanclassID,QuestionGUID)
	SELECT DISTINCT  Q.QuestionID,A.AssessmentID,A.Assetid,SD.ScheduleDetailID,SU.ID,Q.AssetID ,SU.userid,R.Comments,R.MaxScore,Ass.TitleID_CourseID,Ass1.PlanClassID,Q.QuestionGUID
	FROM ScheduleDetails SD 
	INNER JOIN ScheduleUser SU ON SU.ScheduleDetailID=SD.ScheduleDetailID AND SD.isdeleted=0 AND SU.isdeleted=0
	INNER JOIN Assessment A ON A.AssetID=SD.AssetID AND A.Isdeleted=0
	INNER JOIN Asset Ass1 ON Ass1.Assetid=A.Assetid AND Ass1.isdeleted=0
	INNER JOIN tblAssessmentConfiguration TAC ON TAC.AssessmentID=A.AssessmentID 
	INNER JOIN tblAssessmentQuestion TAQ ON TAQ.ConfigurationID=TAC.ConfigurationID
	INNER JOIN Question Q ON Q.QuestionID=TAQ.QuestionID AND Q.isdeleted=0
	INNER JOIN Asset Ass ON Ass.Assetid=Q.Assetid AND Ass.isdeleted=0
	INNER JOIN #TempUserDetails TU ON TU.UserID=SU.UserID   
	INNER JOIN Results R ON R.QuestionID=Q.QuestionID AND R.ScheduleUserID=SU.ID
	--INNER JOIN Plantheme PT ON PT.id= Ass.TitleID_CourseID AND PT.IsDeleted=0   
	INNER JOIN termtestassets TTA ON TTA.AssetId=Ass1.Assetid AND TTA.PlanClassID=Ass1.PlanClassID
	--LEFT JOIN UserResponse UR ON UR.ScheduleUserID=SU.id AND UR.QuestionGUID=Q.QuestionGUID
	WHERE SU.UserID=@StudentId  AND (Ass1.PlanClassID =@PlanClassID OR @PlanClassID=0)  AND TTA.Type=@Termtypeid
	AND  ((SD.StartDate >= @OrganizationStartDate AND SD.EndDate <= @OrganizationEndDate) OR @Yearid=0) 
	--AND (PT.ClassId=@PlanClassID OR @PlanClassID=0)
	AND ISNUMERIC(R.comments)=1

	
	SELECT ClassId,PS.ID SubjectId,PC.ID PlanClassId, ClassName,CASE WHEN PS.Name='EVS' THEN 'Environmental Studies' ELSE PS.name END SubjectName,SUM(TQ.ObtainedScore) ObtainedScore,SUM(TQ.TotalScore) TotalScore,CAST(SUM(TQ.ObtainedScore)/SUM(TQ.TotalScore)*100 AS decimal(18,2)) Percentage
	FROM #TempQuestions TQ
	INNER JOIN PlanClass PC ON PC.ID=TQ.PlanclassID
	INNER JOIN Plansubject PS ON PS.ID=PC.SubjectID AND PC.isdeleted=0 AND PS.isdeleted=0
	INNER JOIN Class C ON C.ClassName=PC.Name AND C.Isdeleted=0
	GROUP BY ClassId,PS.ID  ,PC.ID  , ClassName,PS.Name  
	ORDER BY CASE WHEN PS.Name='English' THEN 1   WHEN PS.Name='MatheMatics' THEN 2 WHEN PS.Name='EVS' THEN 3 END ASC



   INSERT INTO @UserAnswermapping(ScheduleUserId,QuestionGUID,UserResponse,ChoiceGUID,QuestionID)      
   SELECT TQ.ScheduleUserID,TQ.QuestionGUID,fd.v.value('(.)[1]', 'nvarchar(100)'),fd.v.value('data(./@cid)', 'varchar(100)') ,TQ.Questionid
   FROM #TempQuestions TQ  
   INNER JOIN   UserResponse UR ON UR.ScheduleUserID=TQ.ScheduleUserID AND UR.QuestionGUID=TQ.QuestionGUID
   CROSS APPLY UR.UserResponse.nodes('/URs/UR/R') AS fd(v)     
    
	 
	DELETE UR FROM @UserAnswermapping UR 
	WHERE   EXISTS(SELECT 1 FROM QuestionChoiceMapping QM WHERE UR.ChoiceGUID=QM.ChoiceGUID AND QM.QuestionGuid=UR.QuestionGUID AND QM.Choice=UR.UserResponse AND IsCorrect=1)
   
   UPDATE @UserAnswermapping SET UserResponse= CASE WHEN UserResponse='A' THEN 1 WHEN UserResponse='B'  THEN 2 WHEN UserResponse='C' THEN 3 WHEN UserResponse='D'  THEN 4 ELSE UserResponse END

   UPDATE U SET MisConceptionCode=Value FROM @UserAnswermapping U
   INNER JOIN (
   SELECT DISTINCT QM.Questionid, CASE WHEN MK.name='Category of misconception1' AND UR.UserResponse=1 THEN MV.value
   WHEN MK.name='Category of misconception2' AND UR.UserResponse=2 THEN MV.value
   WHEN MK.name='Category of misconception3' AND UR.UserResponse=3 THEN MV.value
   WHEN MK.name='Category of misconception4' AND UR.UserResponse=4 THEN MV.value END Value 
   FROM @UserAnswermapping UR 
   INNER JOIN QuestionMetaDataValue QM ON QM.QuestionID=UR.QuestionID  
   INNER JOIN MEtadatavalue MV ON MV.MetaDataValueID=QM.MetaDataValueID
   INNER JOIN MetaDataKey MK ON MK.MetaDataKeyID=MV.MetaDataKeyID AND MK.name IN ('Category of misconception1','Category of misconception2','Category of misconception3','Category of misconception4')
   ) Q ON Q.QuestionID=U.QuestionID AND ISNULL(Value,'')<>''



	SELECT IDENTITY (BIGINT, 1, 1) AS ID,* INTO #Temp FROM(
	SELECT DISTINCT CASE WHEN MK.name='Skill' THEN 4 WHEN MK.name='Competency' THEN 3 WHEN MK.name in('SubSkill','Sub Skill','Subskills') THEN 10 WHEN MK.name in ('Learning Outcomes','Learning Outcome') THEN 7 WHEN MK.name IN('Assessment Objectives','Assessment objective') THEN 8  END Type,
	CASE WHEN MK.name='Skill' THEN 'Skills' WHEN MK.name='Competency' THEN 'Competency' WHEN MK.name in('SubSkill','Sub Skill','Subskills') THEN 'SubSkills' WHEN MK.name  in ('Learning Outcomes','Learning Outcome') THEN 'Learning Outcome' WHEN MK.name IN('Assessment Objectives','Assessment objective') THEN 'Assessment Objectives'  END CategoryName,MS.Title Name,SUM(TQ.ObtainedScore) ObtainedScore,SUM(TQ.TotalScore) TotalScore,SUM(TQ.ObtainedScore)/SUM(TQ.TotalScore)*100 Percentage,NULL Description,TQ.PlanclassID 
	FROM #TempQuestions TQ
	INNER JOIN QuestionMetaDataValue QM ON QM.QuestionID=TQ.QuestionID  
	INNER JOIN MEtadatavalue MV ON MV.MetaDataValueID=QM.MetaDataValueID
	INNER JOIN MetaDataKey MK ON MK.MetaDataKeyID=MV.MetaDataKeyID AND MK.name IN ('Competency','Skill','SubSkill','Learning Outcomes','Assessment Objectives','Learning Outcome','Assessment objective','Sub Skill','SubSkills')
	INNER JOIN Metadataskills MS ON MS.code=MV.value AND MS.isdeleted=0
	GROUP BY TQ.PlanclassID,MS.Title,CASE WHEN MK.name='Skill' THEN 4 WHEN MK.name='Competency' THEN 3 WHEN MK.name in('SubSkill','Sub Skill','Subskills') THEN 10 WHEN MK.name in ('Learning Outcomes','Learning Outcome') THEN 7 WHEN MK.name IN('Assessment Objectives','Assessment objective') THEN 8  END, CASE WHEN MK.name='Skill' THEN 'Skills' WHEN MK.name='Competency' THEN 'Competency' WHEN MK.name in('SubSkill','Sub Skill','Subskills') THEN 'SubSkills' WHEN MK.name  in ('Learning Outcomes','Learning Outcome') THEN 'Learning Outcome' WHEN MK.name IN('Assessment Objectives','Assessment objective') THEN 'Assessment Objectives'  END --,C.ID
	UNION
	SELECT  DISTINCT  6 Type,'Level of Difficulty' CategoryName,MV.Value,SUM(TQ.ObtainedScore) ObtainedScore,SUM(TQ.TotalScore) TotalScore,SUM(TQ.ObtainedScore)/SUM(TQ.TotalScore)*100 Percentage,NULL Description,TQ.PlanclassID FROM #TempQuestions TQ
	INNER JOIN QuestionMetaDataValue QM ON QM.QuestionID=TQ.QuestionID 
	INNER JOIN MEtadatavalue MV ON MV.MetaDataValueID=QM.MetaDataValueID
	INNER JOIN MetaDataKey MK ON MK.MetaDataKeyID=MV.MetaDataKeyID AND MK.name IN ('Difficulty Level') 
	GROUP BY MV.Value,TQ.PlanclassID
	UNION
	SELECT DISTINCT 5 Type,
	'Category of misconception 1' CategoryName,MS.Title,SUM(TQ.ObtainedScore) ObtainedScore,SUM(TQ.TotalScore) TotalScore,COUNT(DISTINCT UA.Questionid) Percentage,NULL Description,TQ.PlanclassID FROM #TempQuestions TQ
	INNER JOIN @UserAnswermapping UA ON UA.QuestionID=TQ.QuestionID
	INNER JOIN Metadataskills MS ON MS.code=UA.MisConceptionCode AND MS.isdeleted=0
	GROUP BY MS.Title,TQ.PlanclassID
	 ) A ORDER BY Type, CASE WHEN A.Name='easy' THEN 1 WHEN  A.Name='medium' THEN 2  WHEN A.Name='difficult' THEN 3 END ASC
	

	INSERT INTO #TempQuestions(QuestionID,AssessmentID,TestAssetID,ScheduleDetailID,ScheduleUserID,QuestionAssetID,Userid,ObtainedScore,TotalScore,ThemeorConceptID,PlanclassID,QuestionGUID)
	SELECT DISTINCT Q.QuestionID,A.AssessmentID,A.Assetid,SD.ScheduleDetailID,SU.ID,Q.AssetID ,SU.userid,R.Score,R.MaxScore,PT.id,PT.ClassId,Q.QuestionGUID
	FROM ScheduleDetails SD 
	INNER JOIN ScheduleUser SU ON SU.ScheduleDetailID=SD.ScheduleDetailID AND SD.isdeleted=0 AND SU.isdeleted=0
	INNER JOIN Assessment A ON A.AssetID=SD.AssetID AND A.Isdeleted=0
	INNER JOIN Asset Ass1 ON Ass1.Assetid=A.Assetid AND Ass1.isdeleted=0
	INNER JOIN tblAssessmentConfiguration TAC ON TAC.AssessmentID=A.AssessmentID 
	INNER JOIN tblAssessmentQuestion TAQ ON TAQ.ConfigurationID=TAC.ConfigurationID
	INNER JOIN Question Q ON Q.QuestionID=TAQ.QuestionID AND Q.isdeleted=0
	INNER JOIN QuestionAssetThemeMapping QTM ON QTM.QuestionID=Q.QuestionID AND QTM.AssetID=Q.AssetID
	INNER JOIN Asset Ass ON Ass.Assetid=Q.Assetid AND Ass.isdeleted=0
	INNER JOIN #TempUserDetails TU ON TU.UserID=SU.UserID   
	INNER JOIN Results R ON R.QuestionID=Q.QuestionID AND R.ScheduleUserID=SU.ID
	INNER JOIN Plantheme PT ON PT.id= QTM.Themeid AND PT.IsDeleted=0   
	INNER JOIN termtestassets TTA ON TTA.AssetId=Ass1.Assetid AND TTA.PlanClassID=Ass1.PlanClassID
	WHERE SU.UserID=@StudentId  AND Ass1.PlanClassID =@planclassid AND TTA.Type=@Termtypeid
	AND  ((SD.StartDate >= @OrganizationStartDate AND SD.EndDate <= @OrganizationEndDate) OR @Yearid=0) AND (PT.ClassId=@PlanClassID OR @PlanClassID=0)
	AND NOT EXISTS(SELECT 1 FROM #TempQuestions TQ1 WHERE TQ1.ThemeorConceptID=PT.id AND TQ1.ScheduleUserID=SU.id AND TQ1.QuestionID=Q.QuestionID
	AND TQ1.AssessmentID=A.AssessmentID)

	

	INSERT INTO #Temp(Type,CategoryName,[Name],ObtainedScore,TotalScore,Percentage,Description,PlanclassID)
	SELECT  2 Type,'Concepts' CategoryName, PT.Name ,SUM(TQ.ObtainedScore) ObtainedScore,SUM(TQ.TotalScore) TotalScore,SUM(TQ.ObtainedScore)/SUM(TQ.TotalScore)*100 Percentage, NULL Description,PT.ClassId PlanclassID   FROM  PlanTheme PT
	INNER JOIN #TempQuestions TQ ON PT.id= TQ.ThemeorConceptID AND PT.IsDeleted=0  AND PT.LevelID=3
	INNER JOIN QuestionMetaDataValue QM ON QM.QuestionID=TQ.QuestionID  
	INNER JOIN MEtadatavalue MV ON MV.MetaDataValueID=QM.MetaDataValueID  AND MV.Value=PT.name
	INNER JOIN MetaDataKey MK ON MK.MetaDataKeyID=MV.MetaDataKeyID AND REPLACE(MK.name,' ','')='Concept'
	GROUP BY PT.Name,PT.ClassId--,TQ.QuestionID

	--SELECT * FROM #Temp


SELECT  48 ID,	 2 Type,	'Concepts'	CategoryName,'Multiplication Tables of 3, 4 and 6'	Name,1	ObtainedScore,1	TotalScore,100	Percentage,NULL	Description,8 PlanclassID
UNION SELECT 49,	2,	'Concepts'	,'Numbers up to 200'	,0	,1	,0	,NULL	,251
UNION SELECT 50,	2,	'Concepts'	,'Place Value'	,1	,1	,100	,NULL	,251
UNION SELECT 51,	2,	'Concepts'	,'Recognition and Identification of Solid Shapes'	,1	,1	,100	,NULL	,251
UNION SELECT 52,	2,	'Concepts'	,'Subtraction of 3-digit Numbers Without Regrouping'	,0	,1	,0	,NULL	,251
UNION SELECT 53,	2,	'Concepts'	,'Subtraction of Numbers with Regrouping'	,1	,1	,100	,NULL	,251
UNION SELECT 1,	3,	'Competency'	,'Arithmetic ability'	,4	,7	,57.1428	,NULL	,251
UNION SELECT 2,	3,	'Competency'	,'Measuring and estimating'	,1	,1	,100	,NULL	,251
UNION SELECT 3,	3,	'Competency'	,'Organise and Analyse Content'	,1	,2	,50	,NULL	,251
UNION SELECT 4,	3,	'Competency'	,'Visualising and representing'	,1	,1	,100	,NULL	,251
UNION SELECT 5,	3,	'Competency'	,'Write Coherently and Cohesively'	,2	,2	,100	,NULL	,251
UNION SELECT 6,	4,	'Skills'	,'Measurements'	,1	,1	,100	,NULL	,251
UNION SELECT 7,	4,	'Skills'	,'Number Sense'	,4	,7	,57.1428	,NULL	,251
UNION SELECT 8,	4,	'Skills'	,'Reading'	,1	,3	,33.3333	,NULL	,251
UNION SELECT 9,	4,	'Skills'	,'Spatial Ability'	,1	,1	,100	,NULL	,251
UNION SELECT 10,	4,	'Skills'	,'Writing'	,3	,4	,75	,NULL	,251
UNION SELECT 11,	6,	'Level of Difficulty'	,'Easy'	,4	,7	,57.1428	,NULL	,251
UNION SELECT 12,	6,	'Level of Difficulty'	,'Medium'	,3	,5	,60	,NULL	,251
UNION SELECT 13,	6,	'Level of Difficulty'	,'Difficult'	,3	,4	,75	,NULL	,251
UNION SELECT 14,	7,	'Learning Outcome'	,'Compare the objects by using the given features of the 3D shape.'	,1	,1	,100	,NULL	,251
UNION SELECT 15,	7,	'Learning Outcome'	,'Count, read, and write numbers up to 1000.'	,1	,1	,100	,NULL	,251
UNION SELECT 16,	7,	'Learning Outcome'	,'Identify prepositions and their usage'	,0	,1	,0	,NULL	,251
UNION SELECT 17,	7,	'Learning Outcome'	,'Organise and structure thoughts in writing'	,1	,1	,100	,NULL	,251
UNION SELECT 18,	7,	'Learning Outcome'	,'Perform multiplication of numbers fluently to solve real-life problems.'	,1	,1	,100	,NULL	,251
UNION SELECT 19,	7,	'Learning Outcome'	,'Perform multiplication on numbers fluently.'	,0	,1	,0	,NULL	,251
UNION SELECT 20,	7,	'Learning Outcome'	,'Perform simple measurements of length using appropriate measuring instruments.'	,1	,1	,100	,NULL	,251
UNION SELECT 21,	7,	'Learning Outcome'	,'Perform subtraction of 2-digit numbers with regrouping.'	,1	,1	,100	,NULL	,251
UNION SELECT 22,	7,	'Learning Outcome'	,'Performs addition of numbers fluently.'	,1	,1	,100	,NULL	,251
UNION SELECT 23,	7,	'Learning Outcome'	,'Performs subtraction of numbers fluently.'	,0	,1	,0	,NULL	,251
UNION SELECT 24,	7,	'Learning Outcome'	,'Use antonyms correctly'	,1	,1	,100	,NULL	,251
UNION SELECT 25,	7,	'Learning Outcome'	,'Use language and vocabulary appropriately in different contexts'	,1	,1	,100	,NULL	,251
UNION SELECT 26,	7,	'Learning Outcome'	,'Use prepositions appropriately in sentences'	,0	,1	,0	,NULL	,251
UNION SELECT 27,	7,	'Learning Outcome'	,'Use tenses correctly in a given sentence'	,1	,1	,100	,NULL	,251
UNION SELECT 28,	7,	'Learning Outcome'	,'Uses tenses to write grammatically correct sentences'	,0	,1	,0	,NULL	,251
UNION SELECT 29,	7,	'Learning Outcome'	,'Write numbers up to 200 in expanded form'	,0	,1	,0	,NULL	,251
UNION SELECT 30,	8,	'Assessment Objectives'	,'Apply knowledge and understanding of mathematical ideas, techniques and procedures to classroom and real-world situations'	,3	,5	,60	,NULL	,251
UNION SELECT 31,	8,	'Assessment Objectives'	,'Demonstrate knowledge and understanding of mathematical ideas, techniques and procedures'	,3	,4	,75	,NULL	,251
UNION SELECT 32,	8,	'Assessment Objectives'	,'Show understanding of explicit meanings'	,2	,3	,66.6666	,NULL	,251
UNION SELECT 33,	8,	'Assessment Objectives'	,'Show understanding of implicit meanings and perspectives'	,2	,4	,50	,NULL	,251
UNION SELECT 34,	10,	'SubSkills'	,'Acquisition'	,0	,1	,0	,NULL	,251
UNION SELECT 35,	10,	'SubSkills'	,'Creative Thinking: Novelty'	,1	,2	,50	,NULL	,251
UNION SELECT 36,	10,	'SubSkills'	,'Establishing Relevance'	,1	,1	,100	,NULL	,251
UNION SELECT 37,	10,	'SubSkills'	,'Linguistic Fluency'	,3	,4	,75	,NULL	,251
UNION SELECT 38,	10,	'SubSkills'	,'Logical Reasoning'	,2	,2	,100	,NULL	,251
UNION SELECT 39,	10,	'SubSkills'	,'Mathematical Fluency'	,2	,4	,50	,NULL	,251
UNION SELECT 40,	10,	'SubSkills'	,'Recognition and Assimilation'	,1	,2	,50	,NULL	,251
UNION SELECT 41,	2,	'Concepts'	,'Action Words'	,2	,2	,100	,NULL	,251
UNION SELECT 42,	2,	'Concepts'	,'But, Or'	,0	,2	,0	,NULL	,251
UNION SELECT 43,	2,	'Concepts'	,'Message of the Poem, Opposites'	,1	,1	,100	,NULL	,251
UNION SELECT 44,	2,	'Concepts'	,'Was, Were'	,1	,2	,50	,NULL	,251
UNION SELECT 45,	2,	'Concepts'	,'Addition of Numbers with Regrouping'	,1	,1	,100	,NULL	,251
UNION SELECT 46,	2,	'Concepts'	,'Measurement of Length'	,1	,1	,100	,NULL	,251
UNION SELECT 47,	2,	'Concepts'	,'Multiplication Tables of 2, 5 and 10'	,0	,1	,0	,NULL	,251

union select 	48,	3,	'Competency',	'Arithmetic ability',													2,	5,	40,NULL	,254
union select 	49,	3,	'Competency',	'Measuring and estimating',													0,	1,	0	,NULL	,254
union select 	50,	3,	'Competency',	'Visualising and representing',													1,	1,	100,	NULL	,254
union select 	51,	4,	'Skills',	'Measurements',													0,	1,	0,	NULL	,254
union select 	52,	4,	'Skills',	'Number Sense',													2,	5,	40,	NULL	,254
union select 	53,	4,	'Skills',	'Spatial Ability',													1,	1,	100,	NULL	,254
union select 	54,	6,	'Level of Difficulty',	'Easy',													1,	3,	33.3333,	NULL	,254
union select 	55,	6,	'Level of Difficulty',	'Medium',													1,	2,	50,	NULL	,254
union select 	56,	6,	'Level of Difficulty',	'Difficult',													1,	2,	50,	NULL	,254
union select 	57,	7,	'Learning Outcome',	'Compare the objects by using the given features of the 3D shape.',													1,	1,	100,	NULL	,254
union select 	58,	7,	'Learning Outcome',	'Count, read, and write numbers up to 1000.',													1,	1,	100,	NULL	,254
union select 	59,	7,	'Learning Outcome',	'Perform simple measurements of length using appropriate measuring instruments.',													0,	1,	0,	NULL	,254
union select 	60,	7,	'Learning Outcome',	'Perform subtraction of 2-digit numbers with regrouping.',													1,	1,	100,	NULL	,254
union select 	61,	7,	'Learning Outcome',	'Performs addition of numbers fluently.',													0,	1,	0,	NULL	,254
union select 	62,	7,	'Learning Outcome',	'Performs subtraction of numbers fluently.',													0,	1,	0,	NULL	,254
union select 	63,	7,	'Learning Outcome',	'Write numbers up to 200 in expanded form',													0,	1,	0,	NULL	,254
union select 	64,	8,	'Assessment Objectives',	'Apply knowledge and understanding of mathematical ideas, techniques and procedures to classroom and real-world situations',													1,	3,	33.3333,	NULL	,254
union select 	65,	8,	'Assessment Objectives',	'Demonstrate knowledge and understanding of mathematical ideas, techniques and procedures',													2,	4,	50,	NULL	,254
union select 	66,	10,	'SubSkills',	'Establishing Relevance',													1,	1,	100,	NULL	,254
union select 	67,	10,	'SubSkills',	'Logical Reasoning',													0,	2,	0,	NULL	,254
union select 	68,	10,	'SubSkills',	'Mathematical Fluency',													1,	2,	50,	NULL	,254
union select 	69,	10,	'SubSkills',	'Recognition and Assimilation',													1,	2,	50,	NULL	,254
union select 	70,	2,	'Concepts',	'Addition of Numbers with Regrouping',													0,	1,	0,	NULL	,254
union select 	71,	2,	'Concepts',	'Measurement of Length',													0,	1,	0,	NULL	,254
union select 	72,	2,	'Concepts',	'Numbers up to 200',													0,	1,	0,	NULL	,254
union select 	73,	2,	'Concepts',	'Place Value',													1,	1,	100,	NULL	,254
union select 	74,	2,	'Concepts',	'Recognition and Identification of Solid Shapes',													1,	1,	100,	NULL	,254
union select 	75,	2,	'Concepts',	'Subtraction of 3-digit Numbers Without Regrouping',													0,	1,	0,	NULL	,254
union select 	76,	2,	'Concepts',	'Subtraction of Numbers with Regrouping',													1,	1,	100,	NULL	,254





	
	--;WITH CTE AS
	--(
	--	SELECT DISTINCT PT.Id ConceptId,PT1.ID ChapterID, ISNULL(TD.Name,PT1.Name) [ChapterName],SUM(TQ.ObtainedScore) ObtainedScore,SUM(TQ.TotalScore) TotalScore,SUM(TQ.ObtainedScore)/SUM(TQ.TotalScore)*100 Percentage, NULL Description,PT.ClassId PlanclassID,DENSE_RANK () OVER(ORDER BY  SUM(TQ.ObtainedScore)/SUM(TQ.TotalScore)*100 DESC) StudentRank ,TQ.AssessmentID,TQ.ScheduleUserID  FROM  PlanTheme PT
	--    INNER JOIN #TempQuestions TQ ON PT.id= TQ.ThemeorConceptID AND PT.IsDeleted=0  AND PT.LevelID=3
	--	INNER JOIN Plantheme PT1 ON PT1.id=PT.parentID AND PT1.LevelID=2
	--	LEFT JOIN TranslationEntityData TD ON TD.ID=PT1.ID AND TD.TableName='Plantheme'
	--	GROUP BY ISNULL(TD.Name,PT1.Name),PT.ClassId,PT1.ID,TQ.AssessmentID,TQ.ScheduleUserID,PT.Id
		
	--)
	--SELECT DISTINCT 1 ID, CASE WHEN StudentRank BETWEEN 1 AND 5 AND (AVG(CAST(percentage as float)) BETWEEN 80 AND 100) THEN 1 ELSE 2 END [Type],ChapterID,[ChapterName],PlanClassId,0 ObtainedScore,0 TotalScore ,0  percentage,AssessmentID,ScheduleUserID,@ClassID ClassID fROM CTE 
	--GROUP BY StudentRank,ChapterID,[ChapterName],PlanClassId,AssessmentID,ScheduleUserID
	--ORDER BY PlanClassId  ,ChapterID asc
	----ORDER BY StudentRank

SELECT 1 ID,	1 Type,	5038	ChapterID,'Our Neighbourhood and Action Words'	[ChapterName],251 PlanClassId,	0 ObtainedScore,	0 TotalScore,0  percentage,	47407 AssessmentID,	558507 ScheduleUserID,	305 ClassID
UNION SELECT 1,	2,	5043	,'Animal Names and Tenses'	,251,	0,	0,0,	47407,	558507,	305 
UNION SELECT 1,	1,	5044	,'Main Idea and Antoynms'	,251,	0,	0,0,	47407,	558507,	305
UNION SELECT 1,	2,	5046	,'Objects in the Sky, Action Words, and Prepositions'	,251,	0,	0,0,	47407,	558507,	305
UNION SELECT 1,	2,	5328	,'More Addition and Subtraction'	,251,	0,	0,0,	47407,	558507,	305
UNION SELECT 1,	1,	5329	,'Numbers up to 1000'	,251,	0,	0,0,	47407,	558507,	305
UNION SELECT 1,	1,	5330	,'Addition'	,251,	0,	0,0,	47407,	558507,	305
UNION SELECT 1,	1,	5334	,'Measurement '	,251,	0,	0,0,	47407,	558507,	305
UNION SELECT 1,	1,	5336	,'More Multiplication'	,251,	0,	0,0,	47407,	558507,	305
UNION SELECT 1,	2,	5337	,'Multiplication'	,251,	0,	0,0,	47407,	558507,	305
UNION SELECT 1,	1,	5338	,'Subtraction'	,251,	0,	0,0,	47407,	558507,	305
UNION SELECT 1,	2,	5339	,'Numbers up to 200'	,251,	0,	0,0,	47407,	558507,	305
UNION SELECT 1,	1,	5340	,'Shapes and Patterns'	,251,	0,	0,0,	47407,	558507,	305
UNION SELECT 1,	2,	5328	,'More Addition and Subtraction'	,254	,0	,0	,0	,47413	,558561	,305
UNION SELECT 1,	1,	5329	,'Numbers up to', 1000	,254	,0	,0	,0	,47413,	558561,	305
UNION SELECT 1,	2,	5330	,'Addition',254,	0,	0,	0,	47413,	558561,	305
UNION SELECT 1,	2,	5334	,'Measurement', 	254,	0,	0,	0,	47413,	558561,	305
UNION SELECT 1,	1,	5338	,'Subtraction',	254,	0,	0,	0,	47413	,558561,	305
UNION SELECT 1,	2,	5339	,'Numbers up to' ,200	,254	,0	,0	,0	,47413,	558561,	305
UNION SELECT 1,	1,	5340	,'Shapes and Patterns',	254,	0,	0,	0,	47413,	558561,	305
UNION SELECT 1	,2	,6887	,'Food We Eat'	,255	,0	,0	,0	,67467	,558615,	305
UNION SELECT 1,	1	,6892	,'Where We Live and What We Wear'	,255	,0	,0	,0	,67467	,558615	,305
UNION SELECT 1, 	1,	6899,	'Rocks and Soil'	,255	,0	,0	,0	,67467	,558615	,305





	--;WITH CTE AS
	--(
	--	SELECT DISTINCT PT.ID ConceptID,PT.ParentID, PT.Name [ConceptName],SUM(TQ.ObtainedScore) ObtainedScore,SUM(TQ.TotalScore) TotalScore,SUM(TQ.ObtainedScore)/SUM(TQ.TotalScore)*100 Percentage, NULL Description,PT.ClassId PlanclassID,DENSE_RANK () OVER(ORDER BY  SUM(TQ.ObtainedScore)/SUM(TQ.TotalScore)*100 DESC) StudentRank  FROM  PlanTheme PT
	--    INNER JOIN #TempQuestions TQ ON PT.id= TQ.ThemeorConceptID AND PT.IsDeleted=0  AND PT.LevelID=3
	--	GROUP BY PT.Name,PT.ClassId,PT.ID,PT.ParentID
	--)
	--SELECT StudentRank ID, CASE WHEN StudentRank BETWEEN 1 AND 5 AND (percentage BETWEEN 80 AND 100) THEN 1 ELSE 2 END [Type],ConceptID,[ConceptName],ParentID,PlanClassId,ObtainedScore,TotalScore,percentage fROM CTE 
	--ORDER BY PlanClassId,StudentRank ,ConceptID asc

 SELECT 1 Id,	1 Type,	5071 ConceptID,	'Action Words' ConceptName,	5038 ParentID,	251 PlanClassId,	2 ObtainedScore,	2 TotalScore,	100 percentage
UNION SELECT 1,	1,	5117,	'Message of the Poem, Opposites',	5044,	251,	1,	1,	100
UNION SELECT 2,	2,	5125,	'Was, Were',	5043,	251,	1,	2,	50
UNION SELECT 3,	2,	5100,	'But, Or',	5046,	251,	0,	2,	0
UNION SELECT 1,	1,	5349,	'Multiplication Tables of 3, 4 and 6',	5336,	251,	1,	1,	100
UNION SELECT 1,	1,	5374,	'Measurement of Length',	5334,	251,	1,	1,	100
UNION SELECT 1,	1,	5398,	'Place Value',	5329,	251,	1,	1,	100
UNION SELECT 1,	1,	5404,	'Addition of Numbers with Regrouping',	5330,	251,	1,	1,	100
UNION SELECT 1,	1,	5409,	'Recognition and Identification of Solid Shapes',	5340,	251,	1,	1,	100
UNION SELECT 1,	1,	5424,	'Subtraction of Numbers with Regrouping',	5338,	251,	1,	1,	100
UNION SELECT 3,	2,	5343,	'Multiplication Tables of 2, 5 and 10',	5337,	251,	0,	1,	0
UNION SELECT 3,	2,	5390,	'Subtraction of 3-digit Numbers Without Regrouping',	5328,	251,	0,	1,	0
UNION SELECT 3,	2,	5417,	'Numbers up to 200',	5339,	251,	0,	1,	0
UNION SELECT 1,	1,	5398,	'Place Value'	,5329	,254	,1	,1	,100
UNION SELECT 1,	1,	5409,	'Recognition and Identification of Solid Shapes',	5340,	254,	1,	1,	100
UNION SELECT 1,	1,	5424,	'Subtraction of Numbers with Regrouping',	5338,	254,	1,	1,	100
UNION SELECT 2,	2,	5374,	'Measurement of Length'	,5334,	254,	0,	1,	0
UNION SELECT 2,	2,	5390,	'Subtraction of 3-digit Numbers Without Regrouping'	,5328	,254,	0	,1,	0
UNION SELECT 2,	2,	5404,	'Addition of Numbers with Regrouping'	,5330	,254	,0	,1	,0
UNION SELECT 2,	2,	5417,	'Numbers up to' ,200,	5339,	254,	0	,1,	0
UNION SELECT 1,	1	,6896	,'Assessment'	,6892	,255	,4	,4	,100
UNION SELECT 1,	1,	6904,	'Assessment',	6899,	255,	11,	11,	100
UNION SELECT 2,	2,	6888,	'Nutrients in Food'	,6887	,255	,5	,7	,71.4285





	CREATE TABLE #Tempsubjectdetails(ID BIGINT IDENTITY(1,1),TermTestID BIGINT,
	 Maxmarks DECIMAL(5,2),Obtainedmarks DECIMAL(5,2),Testname NVARCHAR(200),ScheduleUserID BIGINT,AssetSubtypeID BIGINT,AssessmentID BIGINT,
	 AssetID BIGINT,PercentageObtained DECIMAL(5,2),PlanClassID BIGINT,ScheduleDetailID BIGINT,Term NVARCHAR(50),SubjectID BIGINT,
	 SubjectName NVARCHAR(500),Percentage DECIMAL(5,2),IsQuestionLevel BIT,Score  DECIMAL(5,2),Attempted BIGINT,type int,Status INT)

	 INSERT INTO #Tempsubjectdetails(ScheduleUserID,AssessmentID,AssetID,ScheduleDetailID,Obtainedmarks,PlanClassID,SubjectID,SubjectName,[type],Status)
	 SELECT DISTINCT SU.ID,Ass.AssessmentID,A.AssetID,SD.ScheduleDetailID,	 
	 CASE WHEN ISNUMERIC(SUD.comments)=1 THEN SUD.comments ELSE null END ,PC.ID ,PS.Id ,PS.Name,TA.type,SUD.Status
	 FROM Schedule S
	 INNER JOIN ScheduleDetails SD ON SD.ScheduleID=S.ScheduleID AND S.isdeleted=0 AND SD.isdeleted=0
	 INNER JOIN ScheduleUser SU ON SU.ScheduleDetailID=SD.ScheduleDetailID AND SU.isdeleted=0
	 INNER JOIN ScheduleUserDetail SUD ON SUD.scheduledetailuserid=SU.id 
	 INNER JOIN Assessment Ass ON Ass.AssetID=SD.AssetID AND Ass.isdeleted=0
	 INNER JOIN Asset A ON A.Assetid=Ass.AssetID AND A.isdeleted=0
	 INNER JOIN TermTestAssets TA ON TA.Assetid=A.AssetId AND TA.Isdeleted=0 AND TA.PlanClassID=A.PlanClassID 
	 INNER JOIN Planclass PC ON PC.id=TA.Planclassid AND PC.isdeleted=0
	 INNER JOIN PlanSubject PS ON PC.SubjectId=PS.ID AND S.Isdeleted=0 AND PS.name not in ( select subjectname from tempsubject)
	 INNER JOIN [User] U ON U.UserID=SU.UserID AND U.Isdeleted=0
	 LEFT JOIN tblAssessmentPreferences AP ON AP.AssessmentID =Ass.AssessmentID
	 WHERE SU.UserID=@StudentID AND U.OrganizationID=@OrganizationID  AND TA.type=@TermTypeID 
	
	
	 UPDATE TD SET Attempted=ISNULL(TD1.Attempted ,0)FROM  #Tempsubjectdetails TD
	 INNER JOIN (SELECT R.Attempted,R.ScheduleUserID FROM Results R 
	 INNER JOIN #Tempsubjectdetails TD ON TD.scheduleuserid=R.ScheduleUserID
	 WHERE R.Attempted=1 
	 ) TD1 ON TD1.ScheduleUserID=TD.ScheduleUserID

	 SELECT DISTINCT
    T.PlanClassID,
    T.SubjectID,
    T.SubjectName,
    CASE 
        WHEN Attempted>=1 THEN 1 ELSE 0 
    END AS IsQuestionLevel  
	FROM     #Tempsubjectdetails T WHERE ISNULL(Status,0)=2
	
END TRY
BEGIN CATCH
DECLARE @ErrorDetail AS NVARCHAR(MAX)  
SET @ErrorDetail = CONVERT(NVARCHAR(MAX),CAST('&SpName='AS NVARCHAR(MAX))+CAST('uspGetFASATestReportDetails_PDFExport' AS NVARCHAR(MAX))+CAST(';'AS NVARCHAR(MAX)))  
SET @ErrorDetail = CONVERT(NVARCHAR(MAX),CAST(@ErrorDetail AS  NVARCHAR(MAX))+CAST('(I)UserId' AS NVARCHAR(MAX)) + CAST(ISNULL(@UserId,'NULL') AS NVARCHAR(MAX)) + CAST(';'AS NVARCHAR(MAX  
)))  
SET @ErrorDetail = CONVERT(NVARCHAR(MAX),CAST(@ErrorDetail AS  NVARCHAR(MAX))+CAST('(I)StudentId' AS NVARCHAR(MAX)) + CAST(ISNULL(@StudentId,'NULL') AS NVARCHAR(MAX)) + CAST(';'AS NVARCHAR(MAX  
)))  
SET @ErrorDetail = CONVERT(NVARCHAR(MAX),CAST(@ErrorDetail AS  NVARCHAR(MAX))+CAST('(I)OrganizationId' AS NVARCHAR(MAX)) + CAST(ISNULL(@OrganizationId,'NULL') AS NVARCHAR(MAX)) + CAST(';'AS NVARCHAR(MAX  
)))
SET @ErrorDetail = CONVERT(NVARCHAR(MAX),CAST(@ErrorDetail AS  NVARCHAR(MAX))+CAST('(I)YearId' AS NVARCHAR(MAX)) + CAST(ISNULL(@YearId,'NULL') AS NVARCHAR(MAX)) + CAST(';'AS NVARCHAR(MAX  
)))

exec [GenerateErrorHandling] @ErrorDetail  
   
DECLARE @Exception AS NVARCHAR(MAX)    
SET @Exception=ERROR_MESSAGE() +'->'+ @ErrorDetail   
RAISERROR (@Exception, 16, 1)  
END CATCH
END
