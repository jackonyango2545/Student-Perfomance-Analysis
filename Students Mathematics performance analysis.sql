--Lets select the database we are using since we have alot of databases
USE students_performance;

--Lets have a brief description of our data.
--Lets see what columns we have and their respective data types
SELECT COLUMN_NAME,DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME='student-mat';

SELECT TOP 15 * FROM [student-mat];

--Lets start the process of data cleaning

/*Lets rename varios columns so that we will not need the data's information to understamd what each column entails
We are going to use the concept of LIKE and WILDCARDS whenever we can to avoid the code being too long*/

IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='student-mat' AND COLUMN_NAME= 'famsize')
BEGIN
	EXEC sp_rename '[student-mat].famsize', 'Family Size','COLUMN';	
END;

IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='student-mat' AND COLUMN_NAME= 'Pstatus')
BEGIN
	EXEC sp_rename '[student-mat].Pstatus', 'Parental Status','COLUMN';	
	PRINT 'DONE';
END;

IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='student-mat' AND COLUMN_NAME LIKE '_edu')
BEGIN

	EXEC sp_rename '[student-mat].Medu', 'Mothers Education','COLUMN';
	PRINT 'DONE';
	EXEC sp_rename '[student-mat].Fedu', 'Fathers Education','COLUMN';
	PRINT 'DONE';
END;


IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='student-mat'  AND COLUMN_NAME LIKE '_job')
BEGIN
	EXEC sp_rename '[student-mat].Mjob', 'Mothers Job','COLUMN';
	PRINT 'DONE';
	EXEC sp_rename '[student-mat].Fjob', 'Fathers Job','COLUMN';
	PRINT 'DONE';
END;

IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='student-mat' AND COLUMN_NAME= 'famrel')
BEGIN
	EXEC sp_rename '[student-mat].famrel', 'Family Relations','COLUMN';
	PRINT 'DONE';
END;


IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='student-mat' AND COLUMN_NAME= 'failures')
BEGIN
	EXEC sp_rename '[student-mat].failures', 'Failed Classes','COLUMN';
	PRINT 'DONE';
END;

IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='student-mat' AND COLUMN_NAME LIKE '%sup')
BEGIN
	EXEC sp_rename '[student-mat].schoolsup', 'School Support','COLUMN';
	EXEC sp_rename '[student-mat].famsup', 'Family Support','COLUMN';
	PRINT 'DONE';
END;

IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='student-mat' AND COLUMN_NAME= 'paid')
BEGIN
	EXEC sp_rename '[student-mat].paid', 'Extra Classes','COLUMN';
	PRINT 'DONE';
END;

IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='student-mat' AND COLUMN_NAME LIKE '_alc')
BEGIN
	EXEC sp_rename '[student-mat].Dalc', 'Daily Alcohol Consumption','COLUMN';
	EXEC sp_rename '[student-mat].Walc', 'Weekend Alcohol Consumption','COLUMN';
	PRINT 'DONE';
END;


IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='student-mat' AND COLUMN_NAME= 'absences')
BEGIN
	EXEC sp_rename '[student-mat].absences', 'Classes Missed','COLUMN';
	PRINT 'DONE';
END;

IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='student-mat' AND COLUMN_NAME LIKE 'G_')
BEGIN
	EXEC sp_rename '[student-mat].G1', 'CAT_1','COLUMN';
	EXEC sp_rename '[student-mat].G2', 'CAT_2','COLUMN';
	EXEC sp_rename '[student-mat].G3', 'CAT_3','COLUMN';
	PRINT 'DONE';
END;

--We need to change some data types like for example the age,G1,62 etc this will enable us to use them for numerical computation easily
ALTER TABLE [student-mat] ALTER COLUMN age INT;
ALTER TABLE [student-mat] ALTER COLUMN [Classes Missed] DECIMAL(10,2);
ALTER TABLE [student-mat] ALTER COLUMN CAT_1 DECIMAL(10,2);
ALTER TABLE [student-mat] ALTER COLUMN CAT_2 DECIMAL(10,2);
ALTER TABLE [student-mat] ALTER COLUMN CAT_3 DECIMAL(10,2);

--We need to take care of the nulls,but since we have 33 columns it will be hectic to check for all of them at once but we can check when we are doing or working on our queries

--Lets create a column that will have the total scores.That is for the 3 cats. We will call it marks
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='student-mat' AND COLUMN_NAME='Marks')
BEGIN
	ALTER TABLE [student-mat] ADD Marks DECIMAL(10,2);
	PRINT 'ADDED'
END;

UPDATE [student-mat] 
SET Marks= CAT_1 + CAT_2 + CAT_3;
--Lets another one for grades,this will be used to subdivide the students to 5 different grades
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='student-mat' AND COLUMN_NAME='Grade')
BEGIN
	ALTER TABLE [student-mat] ADD Grade VARCHAR(5);
	PRINT 'ADDED'
END;
/*Lets fill it with grades,we are going to use the Marks column since it contains the final score of each student.
Since their are only 3 exams and each adds upto 60,we can create the grading system with interval of 12 that is 60/5 where 5 is the grades possible and 60 is the maximum possible marks to attain*/
UPDATE [student-mat]
SET Grade=
CASE
	WHEN Marks<= 12 THEN 'F'
	WHEN Marks > 12 AND Marks<=24 THEN 'D'
	WHEN Marks > 24 AND Marks<=36 THEN 'C'
	WHEN Marks > 36 AND Marks<=48 THEN 'B'
	ELSE 'A'
END;
--Lets check for the average marks for each cats and for overall.This will help us
SELECT sex,AVG(CAT_1) AS 'AVERAGE MARKS FOR CAT 1',AVG(CAT_2) AS 'AVERAGE MARKS FOR CAT 2' ,AVG(CAT_3) AS 'AVERAGE MARKS FOR CAT 3',
AVG(Marks) AS 'Average Marks' FROM [student-mat]
GROUP BY sex;
--So we can say that students who score 40 to 60 have passed,20 to 40 are average and people who are below 20 have failed since our average is 30 for female and 33 for male
--Lets clean our texts and put them in a manner that can be easily understood
--Lets start with 
UPDATE [student-mat]
SET address=
CASE
	WHEN address= 'U' THEN 'Urban'
	WHEN address= 'R' THEN 'Rural'
	ELSE address
END;

UPDATE [student-mat]
SET sex = 
CASE 
	WHEN sex= 'F' THEN 'Female'
	WHEN sex= 'M' THEN 'Male'
	ELSE sex
END;


/*Which gender and age tends to perform well and does the school and location have influence over it
Lets start by looking for null values on the specific columns we will use*/
SELECT * FROM [student-mat]
WHERE sex IS NULL OR [address] IS NULL OR age IS NULL OR school IS NULL OR Marks IS NULL OR Grade IS NULL;
--Since we have no nulls we have nothing to worry about

IF NOT EXISTS( SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='gender_based_performance')
BEGIN
	CREATE TABLE gender_based_performance(
		Gender VARCHAR(10),
		[address] VARCHAR(10),
		Age INT,
		school VARCHAR(10),
		Location VARCHAR(10),
		[Number of Students] INT,
		[Minimum Score] INT,
		[Average Score] DECIMAL(10,2),
		[Maximum Score] INT);

	INSERT INTO gender_based_performance
	SELECT sex AS Gender,[address],age,school,address AS Location,COUNT(school) AS 'Number of Students',MIN(Marks) AS 'Minimum Score',AVG(Marks) AS 'Average Score',MAX(Marks) AS 'Maximum Score'
	FROM [student-mat]
	GROUP BY sex,age,school,address
	ORDER BY [Average Score] DESC;
END;

/*What are the relations between having support and classes missed and does it have influence over the marks obtained*/
--Lets start by checking for null values on the columns we are going to need on our analysis
SELECT * FROM [student-mat]
WHERE sex IS NULL OR [address] IS NULL OR [Family Support]IS NULL OR [Classes Missed] IS NULL OR Marks IS NULL
--Since we have no nulls we have nothing to worry about

IF NOT EXISTS( SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='support')
BEGIN
	CREATE TABLE support(
		sex VARCHAR(10),
		[address] VARCHAR(10),
		[Family Support] VARCHAR(10),
		[School Support] VARCHAR(10),
		[Number of Students] INT,
		[Average Number of Classes Missed] INT,
		[Average Score] DECIMAL(10,2));
	INSERT INTO support
	SELECT sex,[address],[Family Support],[School Support],COUNT([School Support]) AS 'Number of Students',AVG([Classes Missed]) AS 'Average Number of Classes Missed',
	AVG(Marks) AS 'Average Score' 
	FROM [student-mat]
	GROUP BY sex,address,[School Support],[Family Support]
	ORDER BY 'Average Score' DESC;
END;
--Lets add a column that will specify the type of support.Like if its family,school,both or none,this will help us during our visualisation maybe when using piechart
IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='support' AND COLUMN_NAME='Support Type')
BEGIN
	ALTER TABLE support ADD [Support Type] VARCHAR(20)
	PRINT 'Support Type Added'
END;

UPDATE support
SET [Support Type] =
CASE
	WHEN [School Support] ='yes' AND [Family Support]= 'yes' THEN 'Both'
	WHEN [School Support] ='yes' AND [Family Support]= 'no' THEN 'School'
	WHEN [School Support] ='no' AND [Family Support]= 'yes' THEN 'Family'
	WHEN [School Support] ='no' AND [Family Support]= 'no' THEN 'None'
	ELSE [Support Type]
END;

SELECT * FROM support;

/*Does the parental status, educational level and parent's job have influence over the students performance?
Lets try to figure out the possible parental jobs that are avalable*/
--Lets check for null values on the columns of parent's jobs,education and status
SELECT * FROM [student-mat]
WHERE [Parental Status] IS NULL OR [Mothers Education] IS NULL OR [Fathers Education] IS NULL OR [Mothers Job] IS NULL OR [Fathers Job] IS NULL;
--Since we have no nulls we have nothing to worry about
--What are the available and popular parents jobs
SELECT [Fathers Job],COUNT([Fathers Job]) AS 'Number appeared' FROM [student-mat]
GROUP BY [Fathers Job]
ORDER BY 'Number appeared' DESC;

SELECT [Mothers Job],COUNT([Mothers Job]) AS 'Number appeared' FROM [student-mat]
GROUP BY [Mothers Job]
ORDER BY 'Number appeared' DESC;

--Which is the most popular parents work combination
SELECT [Mothers Job],[Fathers Job],COUNT([Fathers Job]) AS 'Number appeared together' FROM [student-mat]
GROUP BY [Mothers Job],[Fathers Job]
ORDER BY 'Number appeared together' DESC;


--Lets alter the values on the column of parental status
UPDATE [student-mat]
SET [Parental Status]=
CASE
	WHEN [Parental Status]='A' THEN 'Separated'
	WHEN [Parental Status]='T' THEN 'Together'
	ELSE [Parental Status]
END;
--Lets see the common parental status that we have
SELECT [Parental Status],COUNT([Parental Status]) AS 'Count' FROM [student-mat]
GROUP BY [Parental Status];
--We have very few Separated couples on our data tha the ones together that is 41 separated and 354 that are together that is approximately 1 out of 10 people

/*Lets look at the possible combination of the parental jobs.This can help us to see if their is a pattern on the education levels
It can be seen that most women tend to marry men that have almost the same educational status,that is most counts fall where the educational status is equal or + or -1
The number on our columns represents 0 - none, 1 - primary education (4th grade), 2 – 5th to 9th grade, 3 – secondary education or 4 – higher education */
SELECT [Mothers Education],[Fathers Education],COUNT([Fathers Education]) FROM [student-mat]
GROUP BY [Mothers Education],[Fathers Education]
ORDER BY [Mothers Education] DESC

/*Now lets go on with our objective that is to find whether the parental status, educational level and parent's job have influence over the students performance?*/
IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='parental_effects')
BEGIN
	CREATE TABLE parental_effects(
		sex VARCHAR(10),
		[Parental Status] VARCHAR(10),
		[Mothers Education] VARCHAR(10),
		[Fathers Education] VARCHAR(10),
		[Mothers Job] VARCHAR(10),
		[Fathers Job] VARCHAR(10),
		[Number of Students] INT,
		[Average Marks] DECIMAL(10,2));
	INSERT INTO parental_effects
	SELECT sex,[Parental Status],[Mothers Education],[Fathers Education],[Mothers Job],[Fathers Job],COUNT(sex) AS 'Number of Students',
	AVG(Marks) AS 'Average Marks' FROM [student-mat]
	GROUP BY sex,[Parental Status],[Mothers Education],[Fathers Education],[Mothers Job],[Fathers Job]
	ORDER BY 'Average Marks' ASC;
END;

/*What is the average alcohol consumption of each gender and the distribution over different ages?
Can it be caused by Family relationts or support?*/
--We are going to need the columns of age,sex,Family Support,Family Relations,Daily Alcohol Consumption,Weekend Alcohol Consumption
SELECT * FROM [student-mat]
WHERE age IS NULL OR sex IS NULL OR [Family Support] IS NULL OR [Family Relations] IS NULL OR
[Daily Alcohol Consumption] IS NULL OR [Weekend Alcohol Consumption] IS NULL;
--Since we have no nulls we have nothing to worry about

/*We can change the columns datatypes for the columns of Alcohol consumptions to be int,
even if they dont represent integers,it will be beneficiall when finding the average alcohol consumption rate and when trying to find correlation*/
ALTER TABLE [student-mat] ALTER COLUMN [Daily Alcohol Consumption] DECIMAL(10,4);
ALTER TABLE [student-mat] ALTER COLUMN [Weekend Alcohol Consumption] DECIMAL(10,4);

--Lets start by finding the average alcohol conumption rate for each gender
SELECT sex,AVG([Daily Alcohol Consumption]) AS 'Average Daily Rate',AVG([Weekend Alcohol Consumption]) AS 'Average Weekend Rate'
FROM [student-mat]
GROUP BY sex;
--Lets see the distribution of the alcohol consumption
SELECT sex,[Daily Alcohol Consumption] ,[Weekend Alcohol Consumption],COUNT([Weekend Alcohol Consumption])
FROM [student-mat]
GROUP BY sex,[Daily Alcohol Consumption] ,[Weekend Alcohol Consumption]
ORDER BY sex,[Daily Alcohol Consumption] ,[Weekend Alcohol Consumption] DESC;

SELECT TOP 10 * FROM [student-mat]
ORDER BY [Family Relations] DESC;
/*The nuimerics on the family relations have the following meaning
quality of family relationships from 1 - very bad to 5 - excellent therefore we can change its values to be easily understandable*/

/*Before we change the values to text lets sneak a peak on the average family relationship of each gender
ALTER TABLE [student-mat] ALTER COLUMN [Family Relations] DECIMAL(10,4);
SELECT sex,AVG([Family Relations]) FROM [student-mat]
GROUP BY sex;
female tend to have a good family relations with average score of 4 as compared to female who have average score of 3.8944230*/

ALTER TABLE [student-mat] ALTER COLUMN [Family Relations] VARCHAR(50);
UPDATE [student-mat]
SET [Family Relations] =
CASE
    WHEN [Family Relations] = '1.0000' THEN 'Very Bad'
    WHEN [Family Relations] = '2.0000' THEN 'Bad'
    WHEN [Family Relations] = '3.0000' THEN 'Moderate'
    WHEN [Family Relations] = '4.0000' THEN 'Good'
    WHEN [Family Relations] = '5.0000' THEN 'Excellent'
    ELSE [Family Relations]
END;

--Lets create the table we are going to use on our visualization.
/*What is the average alcohol consumption of each gender and the distribution over different ages?
Can it be caused by Family relations or support?*/
IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='alcohol_effects')
BEGIN
	CREATE TABLE alcohol_effects(
		sex VARCHAR(10),
		age INT,
		[Average  Daily Consumtion Rate] DECIMAL(5,2),
		[Average Weekend Consumption Rate] DECIMAL(5,2),
		[Family Relations] VARCHAR(10),
		[Family Support]  VARCHAR(10),
		[Number of Students] INT,
		[Average Marks] INT);

	INSERT INTO alcohol_effects
	SELECT sex,age,AVG([Daily Alcohol Consumption]) AS 'Average  Daily Consumtion Rate',AVG([Weekend Alcohol Consumption]) AS 'Average Weekend Consumption Rate',
	[Family Relations],[Family Support],COUNT(sex) AS 'Number of Students',AVG(Marks) AS 'Average Marks'
	FROM [student-mat]
	GROUP BY sex,age,[Family Relations],[Family Support]
	ORDER BY 'Number of Students' DESC;
END;

--What is the relationship between school support, paid classes and the number failed classes and average score
--Lets start by checking for null values
SELECT * FROM [student-mat]
WHERE [School Support] IS NULL OR [Extra Classes] IS NULL OR [Failed Classes]  IS NULL

--We have no nulls on the columns we are going to deal with
--Lets see the distribution of the number of failed class missed by each gender
ALTER TABLE [student-mat] ALTER COLUMN [Failed Classes] DECIMAL(10,2);
SELECT sex,AVG([Failed Classes]) FROM [student-mat]
GROUP BY sex;

SELECT sex,[Failed Classes],[Classes Missed],COUNT(sex) FROM [student-mat]
GROUP BY sex,[Failed Classes],[Classes Missed];

IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='classes_effects')
BEGIN
	CREATE TABLE classes_effects(
		sex VARCHAR(10),
		age INT,
		[Extra Classes] VARCHAR(10),
		[Failed Classes] DECIMAL,
		[Average Number of classes missed] DECIMAL(10,2),
		[Number of Students] INT,
		[Average Marks] DECIMAL(10,2));
	INSERT INTO classes_effects
	SELECT sex,age,[Extra Classes],[Failed Classes],ROUND(AVG([Classes Missed]),2) AS 'Average Number of classes missed',
	COUNT(sex) AS 'Number of Students',ROUND(AVG(Marks),2) AS 'Average Marks' FROM [student-mat]
	GROUP BY sex,age,[School Support],[Extra Classes],[Failed Classes];
END;

/*What are the effects of social factors to the students performance
In the,we are going to look at factors like going out,romance,desire for higher education,internet access*/
SELECT * FROM [student-mat]
WHERE romantic IS NULL OR higher IS NULL OR internet IS NULL OR goout IS NULL OR studytime IS NULL OR Grade IS NULL;
--We have no nulls on the columns we are interested in,then we can start
--Lets change up the values we have on the column of goout to be easily understood
select goout,COUNT(goout) FROM [student-mat]
GROUP BY goout;

UPDATE [student-mat]
SET goout=
CASE
	WHEN goout='1' THEN 'Very Low'
	WHEN goout='2' THEN 'Low'
	WHEN goout='3' THEN 'Moderate'
	WHEN goout='4' THEN 'High'
	WHEN goout='5' THEN 'Very High'
	ELSE goout
END;
--Our Time is in terms of Hours
UPDATE [student-mat]
SET studytime=
CASE
	WHEN studytime='1' THEN 'Below 2'
	WHEN studytime='2' THEN '2 to 5'
	WHEN studytime='3' THEN '5 to 10'
	WHEN studytime='4' THEN 'Above 10'
	ELSE studytime
END;

IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='social_factors')
BEGIN
	CREATE TABLE social_factors(
		sex VARCHAR(10),
		age INT,
		romantic VARCHAR(10),
		higher VARCHAR(10),
		internet VARCHAR(10),
		goout VARCHAR(10),
		studytime VARCHAR(10),
		Grade VARCHAR(10),
		[Number of Students] INT);

	INSERT INTO social_factors
	SELECT sex,age,romantic,higher,internet,goout,studytime,Grade,COUNT(sex) AS 'Number of Students'
	FROM [student-mat]
	GROUP BY sex,age,romantic,higher,internet,goout,studytime,Grade
	ORDER BY 'Number of Students' DESC;
END;
