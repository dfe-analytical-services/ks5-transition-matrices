
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
----						Data for TMs			                     ----
----                                                                     ----
----  This code creates the data download tables and the front end data  ----
----                                                                     ----
---- It has been updated for 2022 to include size in the breakdowns and  ----
----  exam cohort - this made a difference to VRQ3 sports studies where  ----
----  different gnumbers were classed as either applied general or tech  ----
----   level. The front end has also had an update on 2021 to include    ----
---- qualification type to disaggregate A and AS level and to give more  ----
----  detail to study skills. Also removed a lot of the unusual manual   ----
---- grade changes.                                                      ----
----                                                                     ----
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------

-- declare the year and all the names of the base tables to be updated to appropriate tables
DECLARE @RPYEAR AS INTEGER = 2022

If object_Id('tempDB..#subj_tab') is not null drop table #subj_tab
select * into #subj_tab from QRD.dbo.Subje01_2022_10_31
If object_Id('tempDB..#tab2') is not null drop table #tab2
select * into #tab2 from QRD.dbo.Table2_2022_10_31
If object_Id('tempDB..#tab3') is not null drop table #tab3
select * into #tab3 from QRD.dbo.Table3_2022_10_31
If object_Id('tempDB..#tab4') is not null drop table #tab4
select * into #tab4 from QRD.dbo.Table4_2022_10_31
If object_Id('tempDB..#subj') is not null drop table #subj
--select distinct SUBLEVNO, SUBJ, MAPPING into #subj from [L3VA].[U2022].[QUAL_SUBJ_LOOKUP]
select distinct SUBJ, MAPPING into #subj from [L3VA].[U2022].[QUAL_SUBJ_LOOKUP]

If object_Id('tempDB..#raw_inst') is not null drop table #raw_inst
select * into #raw_inst from KS5_RESTRICTED.[Outputs].[RAW_Inst_POST16_2022A]
If object_Id('tempDB..#raw_LA') is not null drop table #raw_LA
select * into #raw_LA from KS5_RESTRICTED.[Outputs].[RAW_LEA_POST16_2022A]
If object_Id('tempDB..#exam') is not null drop table #exam
select * into #exam from [KS5_RESTRICTED].[Outputs].[Exam_PT_POST16_2022A]
If object_Id('tempDB..#CSCP_lookup') is not null drop table #CSCP_lookup
select * into #CSCP_lookup from KS5_RESTRICTED.Internal.CSCP_subject_lookup
If object_Id('tempDB..#indicator') is not null drop table #indicator
select * into #indicator from KS5_RESTRICTED.[Outputs].[PupilIndicators_POST16_2022A]
If object_Id('tempDB..#PRIOR') is not null drop table #PRIOR
select * into #PRIOR from KS5_STATISTICS_RESTRICTED.[EES_2022A].[PRIORS_KS4end2021]
If object_Id('tempDB..#Allocations') is not null drop table #Allocations
select PUPILID, END_KS into #Allocations from KS5_RESTRICTED.[Outputs].[PupilAllocations_POST16_2022A]

----------------------------------------------------------
--
--Most of this initial set up code is not important for TMs it's taken from the performance tables data download
--
----------------------------------------------------------

--calculating the original PTQ INCLUDE ignoring COVID impacted to use to flag the COVID impacted results
--the spec for PTQ INCLUDE doesn't include removing # but it appears to be the case when QAing with RM - i think there is something somewhere about # quals
If object_Id('tempDB..#QRD_PTQINCLUDE') is not null drop table #QRD_PTQINCLUDE
select distinct a.QUID, case when a.syllabus_ref = '***' then '' else a.syllabus_ref end as syllabus_ref, a.Wolf_Included_1618 as Wolf_Included_1618_original, KS5_Academic, KS5_Subset,
case when syllabus_ref != 'KNO' and (App1618 = 1 and ((KS5_Equivalences = 1 and KS5_Academic = 1) or Wolf_Included_1618 in (1,2,3)) and QUID != '#') then 1 else 0 end PTQ_INCLUDE_original
into #QRD_PTQINCLUDE
from #subj_tab as a
left join #tab4 as b
on a.Qual_Type = b.Qual_Type

--get the asize and gsize of the different qualications
If object_Id('tempDB..#QRD_SIZE') is not null drop table #QRD_SIZE
select a.QUID, 
max(coalesce(b.GCSE_Equivalent, c.GCSE_Equivalent)) as GSIZE,
max(coalesce(b.AL_Equivalent, c.AL_Equivalent)) as ASIZE
into #QRD_SIZE
from #subj_tab as a
left join #tab2 as b
on a.Qual_Type = b.Qual_Type
left join #tab3 as c
on a.QUID = c.QUID
group by a.QUID


--Code from Ops to create the school type lookup
If object_Id('tempDB..#insti_data') is not null drop table #insti_data
  select distinct r.LEALAB, URN, schname, TAB1618,
case when b.nftype = 20 then 'Sponsored Academy'
when b.nftype = 21 then 'Community School'
when b.nftype = 22 then 'Voluntary Aided School'
when b.nftype = 23 then 'Voluntary Controlled School'
when b.nftype = 24 then 'Foundation School'
when b.nftype = 25 then 'City Technology College'
when b.nftype = 26 then 'Community Special School'
when b.nftype = 27 then 'Foundation Special School'
when b.nftype = 28 then 'Non-Maintained Special School'
when b.nftype = 29 then 'Independent School Approved for SEN pupils'
when b.nftype = 30 then 'Independent School'
when b.nftype = 31 and b.FESITYPE=1 then 'Agriculture and Horticulture College'
when b.nftype = 31 and b.FESITYPE=2 then 'Art, Design and Performing Art College'
when b.nftype = 31 and b.FESITYPE=3 then 'General Further Education College'
when b.nftype = 31 and b.FESITYPE=4 then 'General Further Education College (Special)'
when b.nftype = 31 and b.FESITYPE=5 then 'Sixth Form College'
when b.nftype = 31 and b.FESITYPE=8 then 'Specialist Designated College'
when b.nftype = 31 and b.FESITYPE=9 then 'Tertiary College'
when b.nftype = 32 then 'Community hospital school'
when b.nftype = 33 then 'Foundation hospital school'
when b.nftype = 34 then 'Pupil Referral Unit'
when b.nftype = 35 then 'Sixth Form Centre / Consortia'
when b.nftype = 36 then 'Ministry of Defence Funded College'
when b.nftype = 38 then 'Special College'
when b.nftype = 41 then 'European Schools'
when b.nftype = 42 then 'Playing for Success Centres'
when b.nftype = 43 then 'Offshore Schools'
when b.nftype = 44 then 'Service Childrens Education'
when b.nftype = 45 then 'Higher Education Institutions'
when b.nftype = 46 then 'Welsh Establishment'
when b.nftype = 47 then 'LA Nursery School'
when b.nftype = 48 then 'Other Independent Special School'
when b.nftype = 49 then 'Early Years setting'
when b.nftype = 50 then 'Sponsored Special Academy'
when b.nftype = 51 then 'Converter Academy'
when b.nftype = 52 then 'Free School - Mainstream'
when b.nftype = 53 then 'Free School - Special'
when b.nftype = 54 then 'British Overseas School'
when b.nftype = 55 then 'Special Converter Academy'
when b.nftype = 56 then 'Alternative Provision'
when b.nftype = 57 then 'University Technical College'
when b.nftype = 58 then 'Studio School'
when b.nftype = 59 then 'Free School - 16-19'
when b.nftype = 60 then 'International Schools'
when b.nftype = 63 then 'Academy 16-19 Converter'
when b.nftype = 64 then 'Academy 16-19 Sponsor Led'
when b.nftype = 97 then 'Alternative provision'
when b.nftype = 98 then 'Legacy types'
when b.nftype = 99 then 'Secure Unit'
else b.NFTYPE end as [School or college type]
into #insti_data
from #raw_inst as b 
left join #raw_LA as r 
on b.LEA = r.LEA


/* Get data from exam file. Join on the front end friendly subject names - currently in an internal table on KS5_RESTRICTED
but ultimately we want this to end up in the QRD. Join on the calculated PTQ INCLUDE, ASIZE and GSIZE
Grade X has been removed for TMs
*/
--DECLARE @RPYEAR AS INTEGER = 2022
If object_Id('tempDB..#examprep') is not null drop table #examprep
select LAESTAB, URN, PUPILID, a.GNUMBER, a.BRDSUBNO, _QualificationTypeCode as QUAL_TYPE, SUBLEVNO, AMDEXAM, EXAMYEAR, d.ASIZE, d.GSIZE, MAPPING,
SEASON, GRADE, POINTS_1618, POTENTIAL_LEVEL, c.subject_user_engagement as [Subject], coalesce(PTQ_INCLUDE_original, 0) as PTQ_INCLUDE_original, PTQ_INCLUDE,
DISC_ALL, DISC_0_1, DISC_1_2, DISC_0_2, DISC_SINGLE, DISCS_ALL, DISCS_0_1, DISCS_1_2, DISCS_0_2, DISCS_SINGLE, DISCB_ALL, DISCB_0_1, DISCB_1_2, DISCB_0_2, DISCB_SINGLE,
DISC_ALL_FULL, DISC_0_1_FULL, DISC_1_2_FULL, DISC_0_2_FULL, DISC_SINGLE_FULL, _Wolf_Included_1618, EXAMNO
into #examprep
from #exam as a
left join #QRD_PTQINCLUDE as b
on a.GNUMBER = b.QUID and a.BRDSUBNO = b.Syllabus_Ref
left join #CSCP_lookup as c
on a.MAPPING = c.DISC_CODE
left join #QRD_SIZE as d
on a.GNUMBER = d.QUID
where GRADE != 'X' -- added to stop messing up AS level discounting


/*
select results for the appropriate provider based on COND and without discounting
make changes to the grade:
	- including adding covid impact result based on ptq include - this can be removed once COVID impacted results are out of scope of the data
	- setting pending and no result to no result but now seperating Fail out from no result so they are reported seperately
	- making changes to IB where the cumulative points is given with a letter grade eg. 32D - we remove the letter grade. In the cases of a fail eg. 32F, the result is listed
	as no result - using points to identify this
	- sublevno 129 is an IB combined certificate - the grades that seem to exist are K and J where K is awarded and J is unawareded. This has been set as a pass for K and no result for J
	in previous code and then later in the code the pass was set to no result. We are not sure why this was done and does not appear correct and so I have left as pass and fail.
*/
--DECLARE @RPYEAR AS INTEGER = 2022
If object_Id('tempDB..#examcut') is not null drop table #examcut
select b.*, Qual_Description, z.GPTSPE_1, z.PTSPE_1,
case when PTQ_INCLUDE = 0 and PTQ_INCLUDE_original = 1 then 'COVID result' -- this doesn't matter as I have added the PTQ_INCLUDE = 1 filter to the where statement so this is redundent
when GRADE IN ('Q','R','X') then 'No result'
when GRADE IN ('F','U','N') then 'Fail'
when SUBLEVNO = 130 and POINTS_1618 > 0 then LEFT(GRADE, 2)
when SUBLEVNO = 130 and POINTS_1618 = 0 then 'Fail'
when sublevno=129 then (case when grade='K' then 'Pass' when grade in ('J','F','Q','U','X') then 'Fail' end)
when grade = 'D*' then '*D'
	   when grade = 'PM' then 'MP'
	   when grade = 'MD' then 'DM'
	   when grade = 'D**' then '**D' 
	   when grade = 'DD*' then '*DD'
	   when grade = 'MDD' then 'DDM'
	   when grade = 'MMD' then 'DMM'
	   when grade = 'PMM' then 'MMP'
	   when grade = 'PPM' then 'MPP'
else GRADE end GRADE_UPDATE,
case when _Wolf_Included_1618 IN (1,2,3) then case when PTSPE_1 <1 then '<1'
when PTSPE_1 >=1 and PTSPE_1 <2 then '1-<2'
when PTSPE_1 >=2 and PTSPE_1 <3 then '2-<3'
when PTSPE_1 >=3 and PTSPE_1 <4 then '3-<4'
when PTSPE_1 >=4 and PTSPE_1 <5 then '4-<5'
when PTSPE_1 >=5 and PTSPE_1 <6 then '5-<6'
when PTSPE_1 >=6 and PTSPE_1 <7 then '6-<7'
when PTSPE_1 >=6 and PTSPE_1 <7 then '6-<7'
when PTSPE_1 >=7 and PTSPE_1 <8 then '7-<8'
when PTSPE_1 >=8 and PTSPE_1 <9 then '8-<9'
when PTSPE_1 >=9 then '9>=' end 
else case when GPTSPE_1 <1 then '<1'
when GPTSPE_1 >=1 and GPTSPE_1 <2 then '1-<2'
when GPTSPE_1 >=2 and GPTSPE_1 <3 then '2-<3'
when GPTSPE_1 >=3 and GPTSPE_1 <4 then '3-<4'
when GPTSPE_1 >=4 and GPTSPE_1 <5 then '4-<5'
when GPTSPE_1 >=5 and GPTSPE_1 <6 then '5-<6'
when GPTSPE_1 >=6 and GPTSPE_1 <7 then '6-<7'
when GPTSPE_1 >=6 and GPTSPE_1 <7 then '6-<7'
when GPTSPE_1 >=7 and GPTSPE_1 <8 then '7-<8'
when GPTSPE_1 >=8 and GPTSPE_1 <9 then '8-<9'
when GPTSPE_1 >=9 then '9>=' end end as PRIOR_BAND,
CASE WHEN (COND =1) THEN DISC_ALL  -- not moved, discount over all years, otherwise			
		WHEN (COND =2) THEN DISC_0_1  -- else didn't move in RY and RY-1 and exam is in RY or RY-1
		WHEN (COND =3) THEN DISC_1_2-- else didn't move in RY-1 and RY-2 and exam is in RY-1 or RY-2
		WHEN (COND =4) THEN DISC_0_2-- else same inst in RY and RY-2 and exam is in RY or RY-2
		WHEN (COND =5) THEN DISC_SINGLE-- else exam is in RY
		WHEN (COND =6) THEN DISC_SINGLE-- else exam is in RY-1
		WHEN (COND =7) THEN DISC_SINGLE-- else exam is in RY-2
	ELSE 1 END AS DISC, -- points discounting flag
	CASE WHEN (COND =1) THEN DISCS_ALL
		WHEN (COND =2) THEN DISCS_0_1
		WHEN (COND =3) THEN DISCS_1_2
		WHEN (COND =4) THEN DISCS_0_2
		WHEN (COND =5) THEN DISCS_SINGLE
		WHEN (COND =6)  THEN DISCS_SINGLE
		WHEN (COND =7) THEN DISCS_SINGLE
	ELSE 1 END AS DISCS,-- size discounting flag
	CASE WHEN (COND =1) THEN DISCB_ALL
		WHEN (COND =2) THEN DISCB_0_1
		WHEN (COND =3) THEN DISCB_1_2
		WHEN (COND =4) THEN DISCB_0_2
		WHEN (COND =5) THEN DISCB_SINGLE
		WHEN (COND =6) THEN DISCB_SINGLE
		WHEN (COND =7) THEN DISCB_SINGLE
	ELSE 1 END AS DISCB,-- subset discounting flag,
	CASE WHEN (COND =1) THEN DISC_ALL_FULL  -- not moved, discount over all years, otherwise			
		WHEN (COND =2) THEN DISC_0_1_FULL   -- else didn't move in RY and RY-1 and exam is in RY or RY-1
		WHEN (COND =3) THEN DISC_1_2_FULL -- else didn't move in RY-1 and RY-2 and exam is in RY-1 or RY-2
		WHEN (COND =4) THEN DISC_0_2_FULL -- else same inst in RY and RY-2 and exam is in RY or RY-2
		WHEN (COND =5) THEN DISC_SINGLE_FULL -- else exam is in RY
		WHEN (COND =6) THEN DISC_SINGLE_FULL -- else exam is in RY-1
		WHEN (COND =7) THEN DISC_SINGLE_FULL -- else exam is in RY-2
	ELSE 1 END AS DISC_FULL 
into #examcut
from #indicator as a
left join #PRIOR z
on a.PUPILID = z.pupilid and a.KS4_YEAR_CALC = z.KS4_YEAR_CALC
LEFT join #Allocations y
on a.PUPILID = y.PUPILID
left join #examprep as b
on a.PUPILID = b.PUPILID and a.URN = b.URN
left join #tab4 as c
on b.SUBLEVNO = c.Qual_Number
where [TRIGGER] = 1 and RECTYPE = 1 and COND IN (1,2,3,4,5,6,7) and NAT1618 = 1 and END_KS = 1 --??
  and PTQ_INCLUDE = 1 --and PTQ_INCLUDE_original = 1 -- remove COVID impacted quals for 2022 TMs
  AND (AMDEXAM NOT IN ('TO','CL', 'NR','D','W') OR AMDEXAM IS NULL) 
and ((COND = 1 and ((EXAMYEAR IN (@RPYEAR, (@RPYEAR - 1), (@RPYEAR - 2)) and SEASON = 'S') or (EXAMYEAR IN ((@RPYEAR - 1), (@RPYEAR - 2), (@RPYEAR - 3)) and SEASON = 'W')) )
OR (COND = 2 and ((EXAMYEAR IN (@RPYEAR, (@RPYEAR - 1)) and SEASON = 'S') or (EXAMYEAR IN ((@RPYEAR - 1), (@RPYEAR - 2)) and SEASON = 'W')))
OR (COND = 3 and ((EXAMYEAR IN ((@RPYEAR - 1), (@RPYEAR - 2)) and SEASON = 'S') or (EXAMYEAR IN ((@RPYEAR - 2), (@RPYEAR - 3)) and SEASON = 'W')) )
OR (COND = 4 and ((EXAMYEAR IN (@RPYEAR, (@RPYEAR - 2)) and SEASON = 'S') or (EXAMYEAR IN ((@RPYEAR - 1), (@RPYEAR - 3)) and SEASON = 'W')) )
OR (COND = 5 and ((EXAMYEAR = @RPYEAR and SEASON = 'S') or (EXAMYEAR = (@RPYEAR - 1) and SEASON = 'W')) )
OR (COND = 6 and ((EXAMYEAR = (@RPYEAR - 1) and SEASON = 'S') or (EXAMYEAR = (@RPYEAR - 2) and SEASON = 'W')) )
OR (COND = 7 and ((EXAMYEAR = (@RPYEAR - 2) and SEASON = 'S') or (EXAMYEAR = (@RPYEAR - 3) and SEASON = 'W')) ))


--pull all the grades from the QRD tables 2 and 3 for the qualifications to be reported
If object_Id('tempDB..#grade_struc') is not null drop table #grade_struc
select a.*, b.Grade as grade2, c.Grade as grade3, b.points as points2, c.Points as points3,
coalesce(c.grade, b.grade) as QRD_grade, coalesce(c.points, b.points) as QRD_points,
coalesce(c.last_input_year, b.last_input_year) as last_input_year
into #grade_struc
from (
select distinct GNUMBER, QUAL_TYPE, SUBLEVNO	
from #examcut) as a
left join #tab2 as b
on a.QUAL_TYPE = b.Qual_Type
left join #tab3 as c
on a.GNUMBER = c.QUID

--altering some of the grades for no results and fails and the ordering of distinction, merit and pass
--eg MDD becomes DDM
--DECLARE @RPYEAR AS INTEGER = 2022
If object_Id('tempDB..#grade_struc_update') is not null drop table #grade_struc_update
select distinct GNUMBER, QRD_points, QUAL_TYPE,
case when QRD_grade IN ('Q','R','X') then 'No result'
when QRD_grade IN ('F','U','N') then 'Fail'
when SUBLEVNO = 130 and QRD_points > 0 then LEFT(QRD_grade, 2)
when SUBLEVNO = 130 and QRD_points = 0 then 'Fail'
when sublevno=129 then (case when QRD_grade='K' then 'Pass' when QRD_grade in ('J','F','Q','U','X') then 'Fail' else QRD_grade end)
 when QRD_grade = 'D*' then '*D'
	   when QRD_grade = 'PM' then 'MP'
	   when QRD_grade = 'MD' then 'DM'
	   when QRD_grade = 'D**' then '**D' 
	   when QRD_grade = 'DD*' then '*DD'
	   when QRD_grade = 'MDD' then 'DDM'
	   when QRD_grade = 'MMD' then 'DMM'
	   when QRD_grade = 'PMM' then 'MMP'
	   when QRD_grade = 'PPM' then 'MPP'	
else QRD_grade end as GRADE_update
into #grade_struc_update
from #grade_struc
where last_input_year = @RPYEAR

--concatenate the grades to make a grade structure but remove fail and no result in contrast to previous years
If object_Id('tempDB..#generic_gradeStruc') is not null drop table #generic_gradeStruc
Select Main.GNUMBER, Main.qual_type,
       Left(Main.gradeStructure,Len(Main.gradeStructure)-1) As "gradeStructure"
into #generic_gradeStruc
From
    (
        Select distinct ST2.GNUMBER, ST2.qual_type,
            (
                Select ST1.GRADE_update + ',' AS [text()]
                From #grade_struc_update ST1
                Where ST1.GNUMBER = ST2.GNUMBER and ST1.GRADE_update NOT IN ('No result', 'Fail')
                ORDER BY ST1.GNUMBER, QRD_points desc, GRADE_update
                For XML PATH ('')
            ) gradeStructure
        From #grade_struc_update ST2
    ) [Main]

--create the exam cohort flag 
If object_Id('tempDB..#all_dat') is not null drop table #all_dat
select a.*, b.gradeStructure,
case when KS5_Academic = 1 and KS5_Subset = 1 and SUBLEVNO != 101 then 'A level'
when KS5_Academic = 1 then 'Other academic'
when _Wolf_Included_1618 = 1 then 'Tech level'
when _Wolf_Included_1618 = 2 then 'Applied general'
when _Wolf_Included_1618 = 3 then 'Technical certificate' end as Qualification
into #all_dat
from #examcut as a
left join #generic_gradeStruc as b
on a.GNUMBER = b.GNUMBER
left join #QRD_PTQINCLUDE as y
on a.GNUMBER = y.QUID and a.BRDSUBNO = y.Syllabus_Ref


--national, qualification and subject
If object_Id('tempDB..#nat_subj') is not null drop table #nat_subj
select Qual_Description, a.SUBLEVNO, Potential_Level, ASIZE, GSIZE, a.MAPPING, SUBJ, [Subject], gradeStructure, PRIOR_BAND,  GRADE_UPDATE as GRADE, --Qualification, 
count(PUPILID) as total_students
into #nat_subj
from #all_dat as a
left join #insti_data as d
on a.URN = d.URN
left join #subj e
on a.MAPPING = e.MAPPING --and a.SUBLEVNO = e.SUBLEVNO
where --TAB1618 = 1
 ((Qualification IN ('Other academic', 'Tech level', 'Applied general') and DISCS = 0) OR
(Qualification = 'A level' and (DISCS=0 OR (DISCS=1 AND DISC=1 AND DISCB=0))) OR
(Qualification = 'Technical certificate' and DISC_FULL = 0))
group by Qual_Description, a.SUBLEVNO, Potential_Level, ASIZE, GSIZE, a.MAPPING, SUBJ, [Subject], gradeStructure, PRIOR_BAND, GRADE_UPDATE --Qualification, 
order by Qual_Description, SUBLEVNO, ASIZE, GSIZE, [Subject], GRADE_UPDATE, PRIOR_BAND

--create national data again but for AS so we can ignore usual discounting and implement AS only discounting
If object_Id('tempDB..#nat_subj_AS') is not null drop table #nat_subj_AS
select 'GCE AS level (All)' as Qual_Description, 699 as SUBLEVNO, Potential_Level, ASIZE, GSIZE, a.MAPPING, SUBJ, [Subject], gradeStructure, PRIOR_BAND,  GRADE_UPDATE as GRADE, --Qualification, 
count(PUPILID) as total_students
into #nat_subj_AS
from (select *, ROW_NUMBER() OVER (PARTITION BY LAESTAB, PUPILID, MAPPING, SUBLEVNO
ORDER BY POINTS_1618 DESC, EXAMYEAR DESC, SEASON DESC, EXAMNO) AS MAINEXAM
from #all_dat
where SUBLEVNO = 121) as a
left join #insti_data as d
on a.URN = d.URN
left join /*(
select distinct MAPPING, SUBJ
from*/ #subj
/*where SUBLEVNO IN (111, 121))*/ e
on a.MAPPING = e.MAPPING --and a.SUBLEVNO = e.SUBLEVNO
where MAINEXAM = 1 --TAB1618 = 1
group by Qual_Description, a.SUBLEVNO, Potential_Level, ASIZE, GSIZE, a.MAPPING, SUBJ, [Subject], gradeStructure, PRIOR_BAND, GRADE_UPDATE --Qualification, 
order by Qual_Description, SUBLEVNO, ASIZE, GSIZE, [Subject], GRADE_UPDATE, PRIOR_BAND

-- bind the 2 tables together
If object_Id('tempDB..#bind_nat_dat') is not null drop table #bind_nat_dat
select *
into #bind_nat_dat
from 
(
select  Qual_Description, SUBLEVNO, Potential_Level, ASIZE, GSIZE, MAPPING, [Subject], gradeStructure, PRIOR_BAND, SUBJ, GRADE, total_students
from #nat_subj
where GRADE NOT IN ('COVID result', 'No result')
union
select  Qual_Description, SUBLEVNO, Potential_Level, ASIZE, GSIZE, MAPPING, [Subject], gradeStructure, PRIOR_BAND, SUBJ, GRADE, total_students
from #nat_subj_AS	
where GRADE NOT IN ('COVID result', 'No result')) as a

--filter out quals where there are 15 or fewer entries and output final table
If object_Id('tempDB..#TM_data') is not null drop table #TM_data
select b.*
into #TM_data
from (
select SUBLEVNO, Potential_Level, ASIZE, GSIZE, MAPPING, gradeStructure
from #bind_nat_dat
group by SUBLEVNO, Potential_Level, ASIZE, GSIZE, MAPPING, gradeStructure
having SUM(total_students) > 15) a
left join #bind_nat_dat b
on a.SUBLEVNO = b.SUBLEVNO and a.POTENTIAL_LEVEL = b.POTENTIAL_LEVEL 
and a.ASIZE = b.ASIZE and a.GSIZE = b.GSIZE and a.MAPPING = b.MAPPING and a.gradeStructure = b.gradeStructure


select * from #TM_data
where PRIOR_BAND is NULL

-- 11913 rows
-- up to 11914 rows with grade structure added in
-- 776 NULLS in prior band




--drop table [KS5_STATISTICS_RESTRICTED].[TM_2022].[TM_data_2022A]

select * 
into [KS5_STATISTICS_RESTRICTED].[TM_2022].[TM_data_2022A]
from #TM_data


-- Note
-- JB, 05/01/2023

-- One of the columns had a character length that caused errors in R, 
-- this was identified in SQL using 

-- use KS5_STATISTICS_RESTRICTED
-- select COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
-- from INFORMATION_SCHEMA.COLUMNS 
-- where TABLE_SCHEMA = 'TM_2022' 
-- and TABLE_NAME = 'TM_data_2022A'

-- and then corrected using
-- alter table [TM_2022].[TM_data_2022A] alter column gradeStructure varchar (200) not NULL;
