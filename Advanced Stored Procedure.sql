USE [CP_Build_Prior]
GO
/****** Object:  StoredProcedure [dbo].[INPUT_SPREAD_UPDATE]    Script Date: 3/19/2020 10:08:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
----------------------------------------------------------------------------------------------
--                                 INPUT SPREAD PROCEDURE                                   --
--AUTHOR: TONY BEJOS																		--
--DATE: 9/1/2019																			--
--PURPOSE: TO AUTO UPDATE INPUT SPREADS FOR AUTO/LEASE										--
----------------------------------------------------------------------------------------------	

ALTER Procedure [dbo].[INPUT_SPREAD_UPDATE]
AS

--UPDATE LEASE SPREADS, THEN TASK IN LKP_AUTO_INPUT_SPREAD TABLE PRIOR TO EXECUTING PROCEDURE

Begin 
SET NOCOUNT ON

declare @lease_afi float
declare @lease_bank float
declare @autobank_pool_A float
declare @afi_pool_A float

set @lease_afi = (SELECT DISTINCT INPUT_SPRD FROM QRM_LEASE_ALFA_REMEDIATION WHERE LEGALENTID = 'US_Auto')
set @lease_bank = (SELECT DISTINCT INPUT_SPRD FROM QRM_LEASE_ALFA_REMEDIATION WHERE LEGALENTID = 'AutoBank')
set @autobank_pool_A = (SELECT INPUT_SPRD FROM LKP_AUTO_INPUT_SPREAD WHERE Legalentid = 'AutoBank' AND Lookup_Key = 'Account=A_')
set @afi_pool_A = (SELECT INPUT_SPRD FROM LKP_AUTO_INPUT_SPREAD WHERE Legalentid = 'US_Auto' AND Lookup_Key = 'Account=A_')




--Retail Lease FROM LEASE QUERY 

--AFI
update QRM_LEASE_ALFA_REMEDIATION 
set INPUT_SPRD = @lease_afi
where LEGALENTID <> 'AutoBank'

----BANK 
update QRM_LEASE_ALFA_REMEDIATION 
set INPUT_SPRD = @lease_bank
where LEGALENTID = 'AutoBank'

PRINT 'LEASE SPREADS UPDATED'
--------------------------------------
--Retail Auto
update QRM_AUTO_ALFA_REMEDIATION
Set Input_Sprd = IP.INPUT_SPRD 
From QRM_AUTO_ALFA_REMEDIATION iw 
join LKP_AUTO_INPUT_SPREAD ip 
on IW.legalentid = ip.legalentid 
and LEFT(IW._Account,10) = ip.lookup_key


-----Carvana
UPDATE QRM_AUTO_CARVANA_A  
SET Input_Sprd = B.INPUT_SPRD 
From QRM_AUTO_CARVANA_A A
join LKP_AUTO_INPUT_SPREAD B ON A.legalentid = B.legalentid 
and LEFT(A._Account,10) = B.lookup_key 

--Direct Lending
UPDATE QRM_AUTO_DIRECT_LENDING  
SET Input_Sprd = B.INPUT_SPRD 
From QRM_AUTO_DIRECT_LENDING A
join LKP_AUTO_INPUT_SPREAD B ON A.legalentid = B.legalentid 
and LEFT(A._Account,10) = B.lookup_key 

PRINT 'RETAIL, CARVANA, DIRECT LENDING UPDATED'

--Paste from Lease AFI
update QRM_MANUAL_INPUT
set INPUT_SPRD = @lease_afi
where TRANSACTID =  'Manual_Input_26'

--Paste from Lease Bank 
update QRM_MANUAL_INPUT
set INPUT_SPRD = @lease_bank
where TRANSACTID =  'Manual_Input_27'

----Paste from Auto/AFI Pool A 
update QRM_MANUAL_INPUT
set INPUT_SPRD = @afi_pool_A
where TRANSACTID = 'Manual_Input_28' 

----Paste from Auto/Bank Pool A
update QRM_MANUAL_INPUT
set INPUT_SPRD = @autobank_pool_A
where TRANSACTID = 'Manual_Input_29' 

PRINT 'MANUAL INPUT UPDATED'
----Drive Time


UPDATE [QRM_AUTO_DRIVE_TIME_A] 
SET Input_Sprd = B.INPUT_SPRD 
From [QRM_AUTO_DRIVE_TIME_A] A
join LKP_AUTO_INPUT_SPREAD B ON A.legalentid = B.legalentid 
and LEFT(A._Account,10) = B.lookup_key 

----COMTRAC



UPDATE QRM_COMTRAC_ALFA
SET Input_Sprd= B.INPUT_SPRD 
From [QRM_COMTRAC_ALFA]  A
join LKP_AUTO_INPUT_SPREAD B ON A.legalentid = B.legalentid 
and LEFT(A._Account,10) = B.lookup_key 

PRINT 'DRIVE TIME/CARVANA UPDATED'

END