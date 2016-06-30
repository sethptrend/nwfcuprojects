#!/usr/bin/perl

#Seth Phillips
#2/16/2016
#script to export a query into a tsv and also create a key file
use warnings;
use strict;
use JSON;
use lib '\\\\d-spokane\\servicing$\\DMExportTemp\\lib\\';
use Connection::Datamart;
use DateTime;
use DateTime::Duration;


my $db = Connection::Datamart->new();

my $targetdate = shift;
#field names
my @fields = ('Loan ID',
'Billing Method',
'Daily Interest Loan',
'Date of Note',
'Due Date of Next Payment',
'Due Date of First Payment',
'Due Days',
'Funding Date',
'Interest Rate',
'Interest Type',
'Loan Name',
'Loan Status',
'Loan Type',
'Original Interest Rate',
'Original P&I Payment',
'P&I Payment',
'Payment Frequency',
'Payment Type',
'Print Late Notices?',
'Term in Months',
'Lien Position',
'Loan Purpose Type',
'Maturity Date',
'Interest Calc Method',
'Late Charge Description',
'Current Principal Balances',
'Original Loan Amount',
'Current T&I Bal',
'Year to Date Interest Paid (at closing)',
'Amortized Loan Stmt-Suppress (eStmt)',
'Borrower Last Name',
'Borrower 1 SSN',
'Borrower 1 First Name',
'Borrower 1 Middle Name',
'Borrower 1 Email Address',
'Borrower 1 Home Phone',
'Borrower 1 Cell Phone',
'Borrower 1 Credit Score',
'Borrower 1 Credit Score Date',
'Borrower 1 Credit Score ID',
'Borrower 1 DOB',
'Borrower 2 Last Name',
'Borrower 2 SSN',
'Borrower 2 First Name',
'Borrower 2 Middle Name',
'Borrower 2 Email Address',
'Borrower 2 Home Phone',
'Borrower 2 Cell Phone',
'Borrower 2 Credit Score',
'Borrower 2 Credit Score Date',
'Borrower 2 Credit Score ID',
'Borrower 2 DOB',
'Borrower 3 Last Name',
'Borrower 3 SSN',
'Borrower 3 First Name',
'Borrower 3 Middle Name',
'Borrower 3 Email Address',
'Borrower 3 Home Phone',
'Borrower 3 Cell Phone',
'Borrower 3 Credit Score',
'Borrower 3 Credit Score Date',
'Borrower 3 Credit Score ID',
'Borrower 3 DOB',
'Borrower 4 Last Name',
'Borrower 4 SSN',
'Borrower 4 First Name',
'Borrower 4 Middle Name',
'Borrower 4 Email Address',
'Borrower 4 Home Phone',
'Borrower 4 Cell Phone',
'Borrower 4 Credit Score',
'Borrower 4 Credit Score Date',
'Borrower 4 Credit Score ID',
'Borrower 4 DOB',
'Property Street',
'Property City',
'Property State',
'Property Zip',
'Orig & Current Appraised Date',
'Orig & Current Appraised Amount',
'Purpose Code',
'Legal Description',
'Sales Price',
'Mailing Name',
'Mailing Address 1',
'Mailing Address 2',
'Mailing City',
'Mailing State',
'Mailing Zip',
'Non-saleable to FNMA',
'Beginning T&I Amount',
'Next T&I Analysis Date',
'Pay Interest on Loss Draft?',
'Pay Interest on T&I',
'Tax Servicer',
'Property County',
'Parcel Number',
'Member #',
'Bank Code',
'Investor Code',
'Group Code',
'Percentage Sold',
'SSN Code',
'Association',
'Hybrid ARM?',
'Analysis Notification Days',
'Reset Notification Days',
'Interest Rate Change Formula',
'Rounding Parameter',
'Payment Selection Option',
'ARM Margin' ,
'ARM Years before first change',
'ARM Months before first change',
'ARM Months between changes',
'ARM First rate change cap',
'ARM Incremental cap',
'ARM Index type',
'ARM First Maximum Rate',
'ARM First Minimum Rate',
'ARM Maximum Rate',
'ARM Minimum Rate',
'ARM First Rate Change Date',
'ARM Next Rate Change Date',
'ARM First Payment Change Date',
'ARM Next Payment Change Date',
#'ARM Date to reflect first change',
'# of months cushion disclosure',
#'ARM Date to reflect next change',
'',
#'MI Company',
#'Mortgage Insurance',
#'City/Town Tax',
#'Flood Insurance',
#'Homeowners Insurance',
#'Property Taxes (Escrow)',
#'School Tax',
#'Hail/Windstorm Insurance',
'Borrower 1 Suffix',
'Borrower 2 Suffix',
'Borrower 3 Suffix',
'Borrower 4 Suffix',
'P&I Change Formula',
'Statements',
'E-Statements',
'Service Fee Type',
'Service Fee Rate',
'Loan Plan Name');


my @ph2fields = (
'Loan ID'
,'Due Date of First Payment'
,'Monthly T&I pmt'
,'Borrower 1 Work Phone'
,'Borrower 2 Work Phone'
,'Borrower 3 Work Phone'
,'Borrower 4 Work Phone'
,'PMI coverage Effective Date'
,'PMI coverage Percent'
,'PMI Certification Number'
,'PMI Cancellation Type'
,'PMI Automation Type'
,'PMI Premium Amount'
,'PMI Premium Percent'
,'PMI Tax Amount'
,'PMI Tax Percent'
,'Flood Community Number'
,'Flood Certificate Number'
,'Borrower wk ph type'
,'Flood Life of Loan Carrier'
,'Flood Zone'
,'Flood Zone Deter Date'
,'VA Loan Number'
,'Current VA Servicer #'
,'PT Payee'
,'PT Payee type'
,'PT TI Frequency'
,'PT Account#'
,'PT Include Cushion'
,'PT Non-escrow'
,'PT Total Disbursments'
,'PT Date 1'
,'PT Date 2'
,'PT Date 3'
,'PT Date 4'
,'PT Date 5'
,'PT Date 6'
,'PT Date 7'
,'PT Date 8'
,'PT Date 9'
,'PT Date 10'
,'PT Date 11'
,'PT Date 12'
,'PT Paid 1'
,'PT Paid 2'
,'PT Paid 3'
,'PT Paid 4'
,'PT Paid 5'
,'PT Paid 6'
,'PT Paid 7'
,'PT Paid 8'
,'PT Paid 9'
,'PT Paid 10'
,'PT Paid 11'
,'PT Paid 12'
,'MI Payee'
,'MI Payee type'
,'MI TI Frequency'
,'MI Account#'
,'MI Include Cushion'
,'MI Non-escrow'
,'MI Total Disbursments'
,'MI Date 1'
,'MI Date 2'
,'MI Date 3'
,'MI Date 4'
,'MI Date 5'
,'MI Date 6'
,'MI Date 7'
,'MI Date 8'
,'MI Date 9'
,'MI Date 10'
,'MI Date 11'
,'MI Date 12'
,'MI Paid 1'
,'MI Paid 2'
,'MI Paid 3'
,'MI Paid 4'
,'MI Paid 5'
,'MI Paid 6'
,'MI Paid 7'
,'MI Paid 8'
,'MI Paid 9'
,'MI Paid 10'
,'MI Paid 11'
,'MI Paid 12'
,'HOI Payee'
,'HOI Payee type'
,'HOI TI Frequency'
,'HOI Account#'
,'HOI Include Cushion'
,'HOI Non-escrow'
,'HOI Total Disbursments'
,'HOI Date 1'
,'HOI Date 2'
,'HOI Date 3'
,'HOI Date 4'
,'HOI Date 5'
,'HOI Date 6'
,'HOI Date 7'
,'HOI Date 8'
,'HOI Date 9'
,'HOI Date 10'
,'HOI Date 11'
,'HOI Date 12'
,'HOI Paid 1'
,'HOI Paid 2'
,'HOI Paid 3'
,'HOI Paid 4'
,'HOI Paid 5'
,'HOI Paid 6'
,'HOI Paid 7'
,'HOI Paid 8'
,'HOI Paid 9'
,'HOI Paid 10'
,'HOI Paid 11'
,'HOI Paid 12'
,'SCHOOL Payee'
,'SCHOOL Payee type'
,'SCHOOL TI Frequency'
,'SCHOOL Account#'
,'SCHOOL Include Cushion'
,'SCHOOL Non-escrow'
,'SCHOOL Total Disbursments'
,'SCHOOL Date 1'
,'SCHOOL Date 2'
,'SCHOOL Date 3'
,'SCHOOL Date 4'
,'SCHOOL Date 5'
,'SCHOOL Date 6'
,'SCHOOL Date 7'
,'SCHOOL Date 8'
,'SCHOOL Date 9'
,'SCHOOL Date 10'
,'SCHOOL Date 11'
,'SCHOOL Date 12'
,'SCHOOL Paid 1'
,'SCHOOL Paid 2'
,'SCHOOL Paid 3'
,'SCHOOL Paid 4'
,'SCHOOL Paid 5'
,'SCHOOL Paid 6'
,'SCHOOL Paid 7'
,'SCHOOL Paid 8'
,'SCHOOL Paid 9'
,'SCHOOL Paid 10'
,'SCHOOL Paid 11'
,'SCHOOL Paid 12'
,'WI Payee'
,'WI Payee type'
,'WI TI Frequency'
,'WI Account#'
,'WI Include Cushion'
,'WI Non-escrow'
,'WI Total Disbursments'
,'WI Date 1'
,'WI Date 2'
,'WI Date 3'
,'WI Date 4'
,'WI Date 5'
,'WI Date 6'
,'WI Date 7'
,'WI Date 8'
,'WI Date 9'
,'WI Date 10'
,'WI Date 11'
,'WI Date 12'
,'WI Paid 1'
,'WI Paid 2'
,'WI Paid 3'
,'WI Paid 4'
,'WI Paid 5'
,'WI Paid 6'
,'WI Paid 7'
,'WI Paid 8'
,'WI Paid 9'
,'WI Paid 10'
,'WI Paid 11'
,'WI Paid 12'
,'FLOOD Payee'
,'FLOOD Payee type'
,'FLOOD TI Frequency'
,'FLOOD Account#'
,'FLOOD Include Cushion'
,'FLOOD Non-escrow'
,'FLOOD Total Disbursments'
,'FLOOD Date 1'
,'FLOOD Date 2'
,'FLOOD Date 3'
,'FLOOD Date 4'
,'FLOOD Date 5'
,'FLOOD Date 6'
,'FLOOD Date 7'
,'FLOOD Date 8'
,'FLOOD Date 9'
,'FLOOD Date 10'
,'FLOOD Date 11'
,'FLOOD Date 12'
,'FLOOD Paid 1'
,'FLOOD Paid 2'
,'FLOOD Paid 3'
,'FLOOD Paid 4'
,'FLOOD Paid 5'
,'FLOOD Paid 6'
,'FLOOD Paid 7'
,'FLOOD Paid 8'
,'FLOOD Paid 9'
,'FLOOD Paid 10'
,'FLOOD Paid 11'
,'FLOOD Paid 12'
,'CT Payee'
,'CT Payee type'
,'CT TI Frequency'
,'CT Account#'
,'CT Include Cushion'
,'CT Non-escrow'
,'CT Total Disbursments'
,'CT Date 1'
,'CT Date 2'
,'CT Date 3'
,'CT Date 4'
,'CT Date 5'
,'CT Date 6'
,'CT Date 7'
,'CT Date 8'
,'CT Date 9'
,'CT Date 10'
,'CT Date 11'
,'CT Date 12'
,'CT Paid 1'
,'CT Paid 2'
,'CT Paid 3'
,'CT Paid 4'
,'CT Paid 5'
,'CT Paid 6'
,'CT Paid 7'
,'CT Paid 8'
,'CT Paid 9'
,'CT Paid 10'
,'CT Paid 11'
,'CT Paid 12'

);

#table for Hazard Company Names
my %hcntable = (
'AAA' => 'AAA'
,'AAA INSURANCE' => 'AAA'
,'AAA MID-ATLANTIC INSURANCE' => 'AAA'
,'AAA TEXAS' => 'AAA'
,'ALLSTATE' => 'ALLSTATE'
,'ALLSTATE - DESIGNER\'S INSURANCE AGENCY' => 'ALLSTATE'
,'ALLSTATE INSURANCE' => 'ALLSTATE'
,'ALLSTATE INSURANCE COMPANY' => 'ALLSTATE'
,'ALLSTATE PROPERTY AND CASUALTY INSURANCE' => 'ALLSTATE'
,'AMERICAN STRATEGIC INSURANCE CO.' => 'ASI'
,'AMERIPRISE' => 'AMERIPRISE'
,'AMICA' => 'AMICA'
,'AMICA - REGIONAL OFFICE' => 'AMICA'
,'AMICA MUTUAL INSURANCE CO.' => 'AMICA'
,'ARMED FORCES INSURANCE EXCHANGE' => 'AMICA'
,'ASI' => 'ASI'
,'ASI LLOYDS' => 'ASI'
,'ENCOMPASS' => 'ENCOMPASS'
,'ERIE' => 'ERIE'
,'ERIE INSURANCE' => 'ERIE'
,'ERIE INSURANCE COMPANY' => 'ERIE'
,'FARMER\'S INSURANCE' => 'FARMERS'
,'FARMERS' => 'FARMERS'
,'GEICO' => 'GEICO'
,'GEICO INSURANCE' => 'GEICO'
,'HANOVER' => 'HANOVER'
,'HANOVER INSURANCE' => 'HANOVER'
,'HARTFORD' => 'HARTFORD'
,'HARTFORD INSURANCE' => 'HARTFORD'
,'HOMESITE' => 'HOMESITE'
,'HOMESITE INSURANCE' => 'HOMESITE'
,'HOMESITE INSURANCE CO.' => 'HOMESITE'
,'HOMESITE INSURANCE COMPANY' => 'HOMESITE'
,'LIBERTY' => 'LIBERTY'
,'LIBERTY MUTUAL' => 'LIBERTY'
,'LIBERTY MUTUAL INSURANCE' => 'LIBERTY'
,'METLIFE' => 'METLIFE'
,'MMG' => 'MMG'
,'NATIONWIDE' => 'NATIONWIDE'
,'NATIONWIDE INSURANCE' => 'NATIONWIDE'
,'NATIONWIDE MUTUAL FIRE INSURANCE' => 'NATIONWIDE'
,'NORTHERN NECK' => 'NORTHERN NECK'
,'QBE' => 'QBE'
,'SAFECO' => 'SAFECO'
,'SAFECO INSURANCE' => 'SAFECO'
,'ST. JOHNS' => 'ST. JOHNS'
,'STATE FARM' => 'STATE FARM'
,'STATE FARM INSURANCE' => 'STATE FARM'
,'STILLWATER' => 'STILLWATER'
,'TRAVELERS' => 'TRAVELERS'
,'TRAVELERS - GEICO' => 'TRAVELERS'
,'UNITED' => 'UNITED'
,'UNITED PROPERTY & CASUALTY' => 'UNITED'
,'USAA' => 'USAA'
,'VA FARM BUREAU INSURANCE' => 'VIRGINIA FARM BUREAU'
,'VIRGINIA FARM BUREAU' => 'VIRGINIA FARM BUREAU'
);


#table for ARM information
my %arm = ('CA55' => {
			'ARM Index Code' => 'Other',
			'ARM Margin' => '2.5',	#floor is margin
			'ARM Years before first change' => '5',
			'ARM Months before first change' => '60',
			'ARM Months between changes' => '60',
			'ARM First rate change cap' => '2',
			'ARM Incremental cap' => '2',
			'ARM Lifetime cap' => '5',
			'ARM Index type' => '5 Year T-Bill'
		     },
	    'JA55' => {
			'ARM Index Code' => 'Other',
			'ARM Margin' => '2.5',	#floor is margin
			'ARM Years before first change' => '5',
			'ARM Months before first change' => '60',
			'ARM Months between changes' => '60',
			'ARM First rate change cap' => '2',
			'ARM Incremental cap' => '2',
			'ARM Lifetime cap' => '5',
			'ARM Index type' => '5 Year T-Bill'
		     },
	   'CA3' => {
			'ARM Index Code' => 'LIBOR',
			'ARM Margin' => '1.75',	#floor is margin
			'ARM Years before first change' => '3',
			'ARM Months before first change' => '36',
			'ARM Months between changes' => '12',
			'ARM First rate change cap' => '2',
			'ARM Incremental cap' => '2',
			'ARM Lifetime cap' => '6',
			'ARM Index type' => '1 Year Libor'
		     },
	   'CA5' => {
			'ARM Index Code' => 'LIBOR',
			'ARM Margin' => '1.75',	#floor is margin
			'ARM Years before first change' => '5',
			'ARM Months before first change' => '60',
			'ARM Months between changes' => '12',
			'ARM First rate change cap' => '2',
			'ARM Incremental cap' => '2',
			'ARM Lifetime cap' => '5',
			'ARM Index type' => '1 Year Libor'
		     },
	   'JA51' => {
			'ARM Index Code' => 'LIBOR',
			'ARM Margin' => '2.75',	#floor is margin
			'ARM Years before first change' => '5',
			'ARM Months before first change' => '60',
			'ARM Months between changes' => '12',
			'ARM First rate change cap' => '2',
			'ARM Incremental cap' => '2',
			'ARM Lifetime cap' => '5',
			'ARM Index type' => '1 Year Libor'
		     }
	);

#This table defines "Loan Plan Name"
	#MS Loan Plan Name	Mtgbot	Mtgbot	Mtgbot	Mtgbot	Mtgbot	Mtgbot
	#10 1 30 Yr ARM	CA10	CA10 R				
	#10 Yr Fixed	C10	C10 R				
	#15 HI BAL	HB15	HB15 R				
	#15 Yr VA HI BAL	V15 HB	V15 HB R				
	#15 Yr Conv HARP	DU15 125					
	#15 Yr Fixed	C15	C15 R	EL15 80	EL15 80 1	EL15 90	EL15 90 1
	#15 Yr Jumbo Fixed	J15	J15 R	SJ15	SJ15 R		
	#15 Yr VA Fixed	V15	V15 R				
	#20 Yr Fixed	C20	C20 R				
	#3 1 30 Yr ARM	CA3	CA3 R				
	#30 HI BAL	HB30	HB30 R				
	#30 Yr Conv 97	C30 97	CFT				
	#30 Yr Conv HARP	DU30 125					
	#30 yr fixed	C30	C30 R				
	#30 Yr Jumbo Fixed	J30	J30 R	SJ30	SJ30 R		
	#30 Yr VA Fixed	V30	V30 R				
	#30 Yr VA HI BAL	V30 HB R	V30 HB				
	#30YR CONV 100	C30 100					
	#5 1 30 Yr ARM	CA5	CA5 R				
	#5 1 Jumbo 30 Yr Arm	JA51					
	#5 5 ARM	CA55	CA55 R				
	#5 5 J ARM	JA55	JA55 R				
	#7 1 30 Yr ARM	CA7	CA7 R			
my %lpntable = (
		'HR30' => '30 Yr Fixed HR',
		'CFT' => '30 Yr Fixed',
		'CA10' => '10 1 30 Yr ARM',
		'CA10 R' => '10 1 30 Yr ARM',
		'C10' => '10 Yr Fixed',
		'C10 R' => '10 Yr Fixed',
		'HB15' => '15 HI BAL',
		'HB15 R' => '15 HI BAL',
		'V15 HB' => '15 Yr VA HI BAL',
		'V15 HB R'  => '15 Yr VA HI BAL',
		'DU15 125' => '15 Yr Conv HARP',
		'C15' => '15 Yr Fixed',
		'C15 R' => '15 Yr Fixed',
		'EL15 80' => '15 Yr Fixed',
		'EL15 80 1' => '15 Yr Fixed',
		'EL15 90' => '15 Yr Fixed',
		'EL15 90 1' => '15 Yr Fixed',
		'J15' => '15 Yr Jumbo Fixed',
		'J15 R' => '15 Yr Jumbo Fixed',
		'SJ15' => '15 Yr Jumbo Fixed',
		'SJ15 R' => '15 Yr Jumbo Fixed',
		'V15' => '15 Yr VA Fixed',
		'V15 R' => '15 Yr VA Fixed',
		'C20' => '20 Yr Fixed',	
		'C20 R' => '20 Yr Fixed',
		'CA3' => '3 1 30 Yr ARM',
		'CA3 R' => '3 1 30 Yr ARM',
		'HB30' => '30 HI BAL',
		'HB30 R' => '30 HI BAL',
		'C30 97	CFT' => '30 Yr Conv 97',
		'DU30 125' => '30 Yr Conv HARP',
		'C30' => '30 Yr Fixed',	
		'C30 R' => '30 Yr Fixed',
		'J30' => '30 Yr Jumbo Fixed',
		'J30 R' => '30 Yr Jumbo Fixed',
		'SJ30' => '30 Yr Jumbo Fixed',
		'SJ30 R' => '30 Yr Jumbo Fixed',
		'V30' => '30 Yr VA Fixed',
		'V30 R' => '30 Yr VA Fixed',
		'V30 HB' => '30 Yr VA HI BAL',
		'V30 HB R' => '30 Yr VA HI BAL',
		'C30 100' => '30YR CONV 100',
		'CA5' => '5 1 30 Yr ARM',
		'CA5 R' => '5 1 30 Yr ARM',
		'JA51' => '5 1 Jumbo 30 Yr Arm',
		'CA55' => '5 5 ARM',
		'CA55 R' => '5 5 ARM',
		'JA55' => '5 5 J ARM',
		'JA55 R' => '5 5 J ARM',
		'CA7' => '7 1 30 Yr',
		'CA7 R' => '7 1 30 Yr',
		);
		

#calculate the minimum acceptable MI date - not doing this anymore but leaving the die in
die "Expect date in YYYY-MM-DD format.  Try again\n" unless $targetdate =~ /(\d\d\d\d)-(\d\d)-(\d\d)/;
#my $miDateMin = DateTime->new( year => $1, month => $2, day => 1, locale => 'en_US');
#$miDateMin->add( months => 1, end_of_month => 'preserve');


#pmi automation type table:
##ARCH, Genworth - Level Monthly, MGIC - Monthly Premiums, Radian - Monthly Premiums & UGRIC
my %autotype = (
			'MGIC' => 'MGIC - Monthly Premiums'
			,'United Guaranty' => 'UGRIC'
			,'Genworth' => 'Genworth - Level Monthly'
			,'Radian' => 'Radian - Monthly Premiums'

		);
		
#MI Company valid choices
# full spelling Mortgage Guaranty Insurance Corp; Arch Mortgage Insur Co, Genworth Financial, Radian Mortgage Insur Co and United Guaranty
my %micompanytable = (
			'MGIC' => 'Mortgage Guaranty Insurance Corp',
			'United Guaranty' => 'United Guaranty',
		);
	
#giant sql query
my $qry = <<"EOT";
SELECT  g.loanGeneral_Id as "LID"
,g.LenderRegistrationIdentifier AS 'Loan ID'
	, lockp.ProductCode AS 'ProductCode'
      , 'Coupons' as 'Billing Method'
	  , 'No' as 'Daily Interest Loan'
	   ,ld.ClosingDate AS 'Date of Note'
	   ,ld.FirstPaymentDate as 'Due Date of Next Payment'
	   ,ld.FirstPaymentDate as 'Due Date of First Payment'
	  , '1' as 'Due Days'
	  , fd._FundedDate as 'Funding Date'
	  , lockp.BaseRate as 'Interest Rate'
	  , mt.LoanAmortizationType as 'Interest Type'
	  , b1._LastName + ', ' + b1._FirstName + ' ' + b1._MiddleName as 'Loan Name'
	  , 'Active' as 'Loan Status'
	  , mt.MortgageType as 'Loan Type'
	  , gld.RequestedInterestRatePercent as 'Original Interest Rate'
	  , phe1._PaymentAmount as 'Original P&I Payment'
	  , phe1._PaymentAmount as 'P&I Payment'
	  , PaymentFrequencyType as 'Payment Frequency'
	  , mt.LoanAmortizationType as 'Payment Type'
	  , 'Print Late Notices and Assess Late Charge' as 'Print Late Notices?'
	  , mt.LoanAmortizationTermMonths as 'Term in Months'
	  , '1st Mortgage' as 'Lien Position'
	  , lld.LoanPurposeType as 'Loan Purpose Type'
	  , ld.LoanMaturityDate as 'Maturity Date'
	  , mt.MortgageType as 'Interest Calc Method'
	  , '' as 'Late Charge Description'
	  , mt.BaseLoanAmount + tdet.MIAndFundingFeeFinancedAmount as 'Current Principal Balances'
	  , mt.BaseLoanAmount + tdet.MIAndFundingFeeFinancedAmount as 'Original Loan Amount'
	  ,titot.tot as 'Current T&I Bal'
	  , nineohone._TotalAmount as 'Year to Date Interest Paid (at closing)'
	  , 'Yes' as 'Amortized Loan Stmt-Suppress (eStmt)'
	  , b1._LastName as 'Borrower Last Name'
	  , b1._SSN as 'Borrower 1 SSN'
	  , b1._FirstName as 'Borrower 1 First Name'
	  , b1._MiddleName as 'Borrower 1 Middle Name'
	  , b1._EmailAddress as 'Borrower 1 Email Address'
	  ,b1._HomeTelephoneNumber as 'Borrower 1 Home Phone'
	  ,b1._CellTelephoneNumber as 'Borrower 1 Cell Phone'
	  ,b1.CreditScore as 'Borrower 1 Credit Score'
	  ,ii.InterviewerApplicationSignedDate as 'Borrower 1 Credit Score Date'
	  ,CASE WHEN b1.CreditScore = b1.EquifaxCreditScore THEN 'Equifax Beacon' WHEN b1.CreditScore = b1.ExperianCreditScore THEN 'Experian' WHEN b1.CreditScore = b1.TransUnionCreditScore THEN 'TransUnion Empirica' END AS 'Borrower 1 Credit Score ID'
	  , b1._BirthDate as 'Borrower 1 DOB'
	  ,residence._StreetAddress  as 'b1mailing1'
	  ,residence._City as 'b1mailingcity'
	  ,residence._State as 'b1mailingstate'
	  ,residence._PostalCode as 'b1mailingzip'
	  , b2._LastName as 'Borrower 2 Last Name'
	  , b2._SSN as 'Borrower 2 SSN'
	  , b2._FirstName as 'Borrower 2 First Name'
	  , b2._MiddleName as 'Borrower 2 Middle Name'
	  , b2._EmailAddress as 'Borrower 2 Email Address'
	  ,b2._HomeTelephoneNumber as 'Borrower 2 Home Phone'
	  ,b2._CellTelephoneNumber as 'Borrower 2 Cell Phone'
	  ,b2._FaxTelephoneNumber as 'Borrower 2 Fax'
	  ,b2.CreditScore as 'Borrower 2 Credit Score'
	  ,ii.InterviewerApplicationSignedDate as 'Borrower 2 Credit Score Date'
	  ,CASE 
            WHEN b2.CreditScore = b2.EquifaxCreditScore
                  THEN 'Equifax Beacon'
            WHEN b2.CreditScore = b2.ExperianCreditScore
                  THEN 'Experian'
		    WHEN b2.CreditScore = b2.TransUnionCreditScore
					THEN 'TransUnion Empirica'
            END AS 'Borrower 2 Credit Score ID'
	  , b2._BirthDate as 'Borrower 2 DOB'
	  , b3._LastName as 'Borrower 3 Last Name'
	  , b3._SSN as 'Borrower 3 SSN'
	  , b3._FirstName as 'Borrower 3 First Name'
	  , b3._MiddleName as 'Borrower 3 Middle Name'
	  , b3._EmailAddress as 'Borrower 3 Email Address'
	  ,b3._HomeTelephoneNumber as 'Borrower 3 Home Phone'
	  ,b3._CellTelephoneNumber as 'Borrower 3 Cell Phone'
	  ,b3._FaxTelephoneNumber as 'Borrower 3 Fax'
	  ,b3.CreditScore as 'Borrower 3 Credit Score'
	  ,ii.InterviewerApplicationSignedDate as 'Borrower 3 Credit Score Date'
	  ,CASE 
            WHEN b3.CreditScore = b3.EquifaxCreditScore
                  THEN 'Equifax Beacon'
            WHEN b3.CreditScore = b3.ExperianCreditScore
                  THEN 'Experian'
		    WHEN b3.CreditScore = b3.TransUnionCreditScore
					THEN 'TransUnion Empirica'
            END AS 'Borrower 3 Credit Score ID'
	  , b3._BirthDate as 'Borrower 3 DOB'

	  , b4._LastName as 'Borrower 4 Last Name'
	  , b4._SSN as 'Borrower 4 SSN'
	  , b4._FirstName as 'Borrower 4 First Name'
	  , b4._MiddleName as 'Borrower 4 Middle Name'
	  , b4._EmailAddress as 'Borrower 4 Email Address'
	  ,b4._HomeTelephoneNumber as 'Borrower 4 Home Phone'
	  ,b4._CellTelephoneNumber as 'Borrower 4 Cell Phone'
	  ,b4._FaxTelephoneNumber as 'Borrower 4 Fax'
	  ,b4.CreditScore as 'Borrower 4 Credit Score'
	  ,ii.InterviewerApplicationSignedDate as 'Borrower 4 Credit Score Date'
	  ,CASE 
            WHEN b4.CreditScore = b4.EquifaxCreditScore
                  THEN 'Equifax Beacon'
            WHEN b4.CreditScore = b4.ExperianCreditScore
                  THEN 'Experian'
		    WHEN b4.CreditScore = b4.TransUnionCreditScore
					THEN 'TransUnion Empirica'
            END AS 'Borrower 4 Credit Score ID'
	  , b4._BirthDate as 'Borrower 4 DOB'
	  , p._StreetAddress as 'Property Street'
	  , p._City as 'Property City'
	  , p._State as 'Property State'
	  , p._PostalCode as 'Property Zip'
	  , AppraisalDate as 'Orig & Current Appraised Date'
	  ,CASE WHEN td.PropertyAppraisedValueAmount is NULL THEN td.PropertyEstimatedValueAmount WHEN td.PropertyEstimatedValueAmount is NULL THEN td.PropertyAppraisedValueAmount END AS 'Orig & Current Appraised Amount'
	  , lp.PropertyUsageType as 'Purpose Code'
	  , legaldesc._textdescription as 'Legal Description'
	  , lld.PurchasePriceAmount as 'Sales Price'
	  , b1._FirstName + ' ' + b1._LastName as 'Mailing Name'
	  , mail._StreetAddress as 'Mailing Address 1'
	  , mail._StreetAddress2 as 'Mailing Address 2'
	  , mail._City as 'Mailing City'
	  , mail._State as 'Mailing State'
	  , mail._PostalCode as 'Mailing Zip'
	  , cfns.AttributeValue as 'Non-saleable to FNMA'
	  ,titot.tot as 'Beginning T&I Amount'
	  ,DATEADD(year, 1, fd._FundedDate) as 'Next T&I Analysis Date'
	  , 'Yes' as 'Pay Interest on Loss Draft?'
	  , 'Yes' as 'Pay Interest on T&I'
	  , 'First American Real Estate' as 'Tax Servicer'
	  	  , b1._SSN as 'Borrower 1 SSN'
	  	  , b2._SSN as 'Borrower 2 SSN'
	  	  , b3._SSN as 'Borrower 3 SSN'
	  , b4._SSN as 'Borrower 4 SSN'
	  , p._County as 'Property County'
	    , p.AssessorsParcelIdentifier as 'Parcel Number'
	    ,cfmember.AttributeValue as 'Member #'
	    ,mihud._MonthlyAmount as 'Mortgage Insurance'
	     		 ,MID.MICompanyName as 'MI Company'
				 ,MID.MICertificateIdentifier as 'PMI Certification Number'
				 ,MID.MIProgram_1003 as 'MIProgramID'
				 ,MID.MIInitialPremiumRatePercent as 'PMI Premium Percent'
				 ,MID.MIInitialPremiumAmount as 'PMI Premium Amount'
			,mid.MIRenewalCalculationType as 'MI RENEWAL'
			,PHEMI.MICoveragePercent1003 as 'PMI coverage Percent'
			,PHEMI.UWMICompanyName as 'UWMICompanyName'
	     		 ,cttax._MonthlyAmount as 'City/Town Tax'
	    		 ,cttax._SystemFeeName as 'cttax name'
	     		 ,fip._MonthlyAmount as 'Flood Insurance'
	    		 ,fip._SystemFeeName as 'fip name'
	    		 ,hwi._MonthlyAmount as 'Hail/Windstorm Insurance'
	    		 ,hwi._SystemFeeName as 'hwi name'
	    		 ,hoi._MonthlyAmount as 'Homeowners Insurance'
	    		 ,hoi._SystemFeeName as 'hoi name'
	    		 ,pte._MonthlyAmount as 'Property Taxes (Escrow)'
	    		 ,pte._SystemFeeName as 'pte name'
	    		 ,stax._MonthlyAmount as 'School Tax'
		 ,stax._SystemFeeName as 'stax name'
		  ,b1._NameSuffix as 'Borrower 1 Suffix'
		   ,b2._NameSuffix as 'Borrower 2 Suffix'
		    ,b3._NameSuffix as 'Borrower 3 Suffix'
		     ,b4._NameSuffix as 'Borrower 4 Suffix'
	       ,B1WRK._TelephoneNumber as 'Borrower 1 Work Phone'
	    	,B2WRK._TelephoneNumber as 'Borrower 2 Work Phone'
	    	,B3WRK._TelephoneNumber as 'Borrower 3 Work Phone'
		,B4WRK._TelephoneNumber as 'Borrower 4 Work Phone'
		,flood.NFIPCommunityIdentifier as 'Flood Community Number'
		,flood.FloodCertificationIdentifier as 'Flood Certificate Number'
		,flood.NFIPFloodZoneIdentifier as 'Flood Zone'
		,flood.FloodDeterminationDate as 'Flood Zone Deter Date'
		,flood.FloodCompanyName as 'Flood Life of Loan Carrier'
		,ESCROWPT._DueDate as 'Property Tax Due Date'
		,ESCROWPT._ItemType as 'PT ID'
		,ESCROWPT._DueDate as 'PT Date 1'
		,ESCROWPT._SecondDueDate as 'PT Date 2'
		,ESCROWPT._ThirdDueDate as 'PT Date 3'
		,ESCROWPT._FourthDueDate as 'PT Date 4'
		,ESCROWPT._PaymentFrequencyType as 'Property Tax Frequency'
		,ESCROWHOI._ItemType as 'HOI ID'
		,ESCROWHOI._DueDate as 'Homeowners Insurance Due Date'
		,ESCROWHOI._DueDate as 'HOI Date 1'
		,ESCROWHOI._SecondDueDate as 'HOI Date 2'
		,ESCROWHOI._ThirdDueDate as 'HOI Date 3'
		,ESCROWHOI._FourthDueDate as 'HOI Date 4'
		,ESCROWHOI._PaymentFrequencyType as 'HoI Frequency'
		,ESCROWMI._ItemType as 'MI ID'
		,ESCROWMI._DueDate as 'Mortgage Insurance Due Date'
		,ESCROWMI._DueDate as 'MI Date 1'
		,ESCROWMI._SecondDueDate as 'MI Date 2'
		,ESCROWMI._ThirdDueDate as 'MI Date 3'
		,ESCROWMI._FourthDueDate as 'MI Date 4'
		,ESCROWMI._PaymentFrequencyType as 'MI Frequency'
		,titot.monthtot as 'Monthly T&I pmt'
		,ESCROWSCHOOL._ItemType as 'SCHOOL ID'
		,ESCROWSCHOOL._PaymentFrequencyType as 'SCHOOL Frequency'
		,ESCROWSCHOOL._DueDate as 'SCHOOL Due Date'
		,ESCROWSCHOOL._DueDate as 'SCHOOL Date 1'
		,ESCROWSCHOOL._SecondDueDate as 'SCHOOL Date 2'
		,ESCROWSCHOOL._ThirdDueDate as 'SCHOOL Date 3'
		,ESCROWSCHOOL._FourthDueDate as 'SCHOOL Date 4'
		,ESCROWCT._ItemType as 'CT ID'
		,ESCROWCT._PaymentFrequencyType as 'CT Frequency'
		,ESCROWCT._DueDate as 'CT Due Date'
		,ESCROWCT._DueDate as 'CT Date 1'
		,ESCROWCT._SecondDueDate as 'CT Date 2'
		,ESCROWCT._ThirdDueDate as 'CT Date 3'
		,ESCROWCT._FourthDueDate as 'CT Date 4'
		,ESCROWWI._ItemType as 'WI ID'
		,ESCROWWI._PaymentFrequencyType as 'WI Frequency'
		,ESCROWWI._DueDate as 'WI Due Date'
		,ESCROWWI._DueDate as 'WI Date 1'
		,ESCROWWI._SecondDueDate as 'WI Date 2'
		,ESCROWWI._ThirdDueDate as 'WI Date 3'
		,ESCROWWI._FourthDueDate as 'WI Date 4'
		,ESCROWFLOOD._ItemType as 'FLOOD ID'
		,ESCROWFLOOD._PaymentFrequencyType as 'FLOOD Frequency'
		,ESCROWFLOOD._DueDate as 'FLOOD Due Date'
		,ESCROWFLOOD._DueDate as 'FLOOD Date 1'
		,ESCROWFLOOD._SecondDueDate as 'FLOOD Date 2'
		,ESCROWFLOOD._ThirdDueDate as 'FLOOD Date 3'
		,ESCROWFLOOD._FourthDueDate as 'FLOOD Date 4'
		,ci.HazardInsurancePolicyIdentifier as 'cihipi'
		,ci.FloodInsurancePolicyIdentifier as 'cihifi'
		,VAHI._UnparsedName as 'vahihi'

FROM LENDER_LOAN_SERVICE.dbo.LOAN_GENERAL G
LEFT JOIN LENDER_LOAN_SERVICE.dbo.ACCOUNT_INFO AI
      ON G.LOANGENERAL_ID = AI.LOANGENERAL_ID
LEFT JOIN [LENDER_LOAN_SERVICE].dbo.[TRANSACTION_DETAIL] tdet 
	ON g.loanGeneral_Id = tdet.loanGeneral_Id
LEFT JOIN LENDER_LOAN_SERVICE.dbo.INSTITUTION i
      ON AI.InstitutionIdentifier = i.InstitutionNumber
LEFT JOIN LENDER_LOAN_SERVICE.dbo.[USER] U
      ON I.AEUserId = U.[USER_Id]
LEFT JOIN LENDER_LOAN_SERVICE.dbo.LOCK_LOAN_DATA lld
      ON g.loanGeneral_Id = lld.loanGeneral_Id
LEFT JOIN LENDER_LOAN_SERVICE.dbo.LOCK_PRICE lockp
      ON g.loanGeneral_Id = lockp.loanGeneral_Id
LEFT JOIN LENDER_LOAN_SERVICE.dbo.GFE_LOAN_DATA gld
      ON g.loanGeneral_Id = gld.loanGeneral_Id
LEFT JOIN LENDER_LOAN_SERVICE.dbo.GFE_ADDITIONAL_DATA gad
      ON g.loanGeneral_Id = gad.loanGeneral_Id
LEFT JOIN LENDER_LOAN_SERVICE.dbo.INTERVIEWER_INFORMATION ii
      ON g.loanGeneral_Id = ii.loanGeneral_Id
LEFT JOIN LENDER_LOAN_SERVICE.dbo.LOAN_FEATURES lf
      ON g.loanGeneral_Id = lf.loanGeneral_Id
LEFT JOIN LENDER_LOAN_SERVICE.dbo.LOAN_PURPOSE lp
      ON g.loanGeneral_Id = lp.loanGeneral_Id
LEFT JOIN LENDER_LOAN_SERVICE.dbo.MERS m
      ON g.loanGeneral_Id = m.loanGeneral_Id
LEFT JOIN LENDER_LOAN_SERVICE.dbo.MORTGAGE_TERMS mt
      ON g.loangeneral_id = mt.loanGeneral_Id
LEFT JOIN LENDER_LOAN_SERVICE.dbo.PROPERTY p
      ON g.loanGeneral_Id = p.loanGeneral_Id
LEFT JOIN LENDER_LOAN_SERVICE.dbo._MAIL_TO mail
      ON g.loanGeneral_Id = mail.loanGeneral_Id
            AND mail.BorrowerID = 'BRW1'
LEFT JOIN LENDER_LOAN_SERVICE.dbo._RESIDENCE residence
	ON g.loanGeneral_Id = residence.loanGeneral_Id
            AND residence.BorrowerID = 'BRW1'
            AND residence.BorrowerResidencyType = 'Current'
LEFT JOIN LENDER_LOAN_SERVICE.dbo.BORROWER b1
      ON g.loanGeneral_Id = b1.loanGeneral_Id
            AND b1.BorrowerID = 'BRW1'
LEFT JOIN LENDER_LOAN_SERVICE.dbo.BORROWER b2
      ON g.loanGeneral_Id = b2.loanGeneral_Id
            AND b2.BorrowerID = 'BRW2'
LEFT JOIN LENDER_LOAN_SERVICE.dbo.BORROWER b3
      ON g.loanGeneral_Id = b3.loanGeneral_Id
            AND b3.BorrowerID = 'BRW3'
LEFT JOIN LENDER_LOAN_SERVICE.dbo.BORROWER b4
      ON g.loanGeneral_Id = b4.loanGeneral_Id
            AND b4.BorrowerID = 'BRW4'
LEFT JOIN LENDER_LOAN_SERVICE.dbo.ADDITIONAL_LOAN_DATA ald
      ON g.loanGeneral_Id = ald.loanGeneral_Id
LEFT JOIN LENDER_LOAN_SERVICE.dbo.UNDERWRITING_DATA ud
      ON g.loanGeneral_Id = ud.loanGeneral_Id
LEFT JOIN LENDER_LOAN_SERVICE.dbo.INVESTOR_LOCK il
      ON g.loanGeneral_Id = il.loanGeneral_Id
LEFT JOIN LENDER_LOAN_SERVICE.dbo.LOAN_DETAILS ld
      ON g.loanGeneral_Id = ld.loanGeneral_Id
LEFT JOIN LENDER_LOAN_SERVICE.dbo.FUNDING_DATA fd
      ON g.loanGeneral_Id = fd.loanGeneral_Id
LEFT JOIN LENDER_LOAN_SERVICE.dbo.FLOOD_DETERMINATION as flood
	  ON g.loanGeneral_Id = flood.loanGeneral_Id
LEFT JOIN LENDER_LOAN_SERVICE.dbo.DENIAL_LETTER dl
      ON g.loanGeneral_Id = dl.loanGeneral_Id
LEFT JOIN LENDER_LOAN_SERVICE.dbo.CLOSING_AGENT cagent
      ON g.loanGeneral_Id = cagent.loanGeneral_Id
            AND cagent._Type = 'ClosingAgent'
LEFT JOIN LENDER_LOAN_SERVICE.dbo.VENDOR_AGENT vagent
      ON g.loanGeneral_Id = vagent.loanGeneral_Id
            AND vagent._Type = 'LeadSource'
LEFT JOIN LENDER_LOAN_SERVICE.dbo.CALCULATION cpayments
      ON g.loanGeneral_Id = cpayments.loanGeneral_Id
            AND cpayments._Name = 'TotalPayments'
LEFT JOIN LENDER_LOAN_SERVICE.dbo.CALCULATION cincome
      ON g.loanGeneral_Id = cincome.loanGeneral_Id
            AND cincome._Name = 'TotalMonthlyIncome'
LEFT JOIN LENDER_LOAN_SERVICE.dbo.CALCULATION cdisp
      ON g.loanGeneral_Id = cdisp.loanGeneral_Id
            AND cdisp._Name = 'NetLoanDisbursementAmount'
LEFT JOIN LENDER_LOAN_SERVICE.dbo.CALCULATION cfin
      ON g.loanGeneral_Id = cfin.loanGeneral_Id
            AND cfin._Name = 'FinanceCharge'
LEFT JOIN LENDER_LOAN_SERVICE.dbo.CALCULATION cratio
      ON g.loanGeneral_Id = cratio.loanGeneral_Id
            AND cratio._Name = 'TotalObligationsIncomeRatio'
LEFT JOIN LENDER_LOAN_SERVICE.dbo.CALCULATION chousing
      ON g.loanGeneral_Id = chousing.loanGeneral_Id
            AND chousing._Name = 'TotalPrimaryHousingExpense'
LEFT JOIN LENDER_LOAN_SERVICE.dbo.CALCULATION cmonthly
      ON g.loanGeneral_Id = cmonthly.loanGeneral_Id
            AND cmonthly._Name = 'TotalAllMonthlyPayment'
LEFT JOIN LENDER_LOAN_SERVICE.dbo.LOAN_ASSIGNEE lauw
      ON g.loanGeneral_Id = lauw.loanGeneral_Id
            AND lauw._Role = 'Underwriter'
LEFT JOIN LENDER_LOAN_SERVICE.dbo.LOAN_ASSIGNEE lauwm
      ON g.loanGeneral_Id = lauwm.loanGeneral_Id
            AND lauwm._Role = 'Underwriting Manager'
LEFT JOIN LENDER_LOAN_SERVICE.dbo.LOAN_ASSIGNEE lalo
      ON g.loanGeneral_Id = lalo.loanGeneral_Id
            AND lalo._Role = 'Loan Opener'
LEFT JOIN LENDER_LOAN_SERVICE.dbo.LOAN_ASSIGNEE lalom
      ON g.loanGeneral_Id = lalom.loanGeneral_Id
            AND lalom._Role = 'Loan Opener Manager'
LEFT JOIN LENDER_LOAN_SERVICE.dbo.LOAN_ASSIGNEE lac
      ON g.loanGeneral_Id = lac.loanGeneral_Id
            AND lac._Role = 'Closer'
LEFT JOIN LENDER_LOAN_SERVICE.dbo.LOAN_ASSIGNEE lacm
      ON g.loanGeneral_Id = lacm.loanGeneral_Id
            AND lacm._Role = 'Closing Manager'
LEFT JOIN LENDER_LOAN_SERVICE.dbo.LOAN_ASSIGNEE lap
      ON g.loanGeneral_Id = lap.loanGeneral_Id
            AND lap._Role = 'Lender Processor'
LEFT JOIN LENDER_LOAN_SERVICE.dbo.LOAN_ASSIGNEE lapm
      ON g.loanGeneral_Id = lapm.loanGeneral_Id
            AND lapm._Role = 'Processing Manager'
LEFT JOIN (
      SELECT loangeneral_id
            ,MAX(_date) AS 'UWDecisionDate'
      FROM LENDER_LOAN_SERVICE.dbo.UNDERWRITING_DECISIONS
      GROUP BY loanGeneral_Id
      ) uw
      ON uw.loanGeneral_Id = g.loanGeneral_Id
LEFT JOIN LENDER_LOAN_SERVICE.dbo.COMPLIANCE_ALERTS ca
      ON g.loangeneral_id = ca.loangeneral_id
LEFT JOIN LENDER_LOAN_SERVICE.dbo.PROPOSED_HOUSING_EXPENSE PHE1
      ON phe1.loangeneral_id = g.loangeneral_id
            AND PHE1.HOUSINGEXPENSETYPE = 'FirstMortgagePrincipalAndInterest'
LEFT JOIN LENDER_LOAN_SERVICE.dbo.PROPOSED_HOUSING_EXPENSE PHE2
      ON phe2.loangeneral_id = g.loangeneral_id
            AND PHE2.HOUSINGEXPENSETYPE = 'HazardInsurance'
LEFT JOIN LENDER_LOAN_SERVICE.dbo.PROPOSED_HOUSING_EXPENSE PHE3
      ON phe3.loangeneral_id = g.loangeneral_id
            AND PHE3.HOUSINGEXPENSETYPE = 'RealEstateTax'
LEFT JOIN LENDER_LOAN_SERVICE.dbo.PROPOSED_HOUSING_EXPENSE PHEMI
      ON PHEMI.loangeneral_id = g.loangeneral_id
            AND PHEMI.HOUSINGEXPENSETYPE = 'MI'
LEFT JOIN LENDER_LOAN_SERVICE.dbo.MI_DATA MID
      ON mid.loangeneral_id = g.loangeneral_id
LEFT JOIN LENDER_LOAN_SERVICE.dbo.LOCK_PRICE LOP
      ON lop.loangeneral_id = g.loangeneral_id
LEFT JOIN LENDER_LOAN_SERVICE.dbo.VENDOR_AGENT vagent1
      ON g.loanGeneral_Id = vagent1.loanGeneral_Id
            AND vagent1._Type = 'TitleCompanySettlementAgent'
LEFT JOIN LENDER_LOAN_SERVICE.dbo.GLOBAL_VENDOR_AGENT vend
      ON vagent1._IdentifierInAvista = vend._IdentifierInAvista
            AND vend._Type = 'TitleCompany'
LEFT JOIN LENDER_LOAN_SERVICE.dbo.GLOBAL_VENDOR_AGENT_CONTACT_DETAIL det
      ON vend.globalVendorAgentId = det.globalVendorAgentId
LEFT JOIN (
			SELECT sum(_TotalAmount) as tot , sum(_MonthlyAmount) as monthtot, loanGeneral_Id   FROM [LENDER_LOAN_SERVICE].[dbo].[HUD_LINE]  where  hudType='HUD' and _LineNumber > 999 and _LineNumber < 1100 group by loanGeneral_Id 
)  titot on titot.loanGeneral_Id=g.loangeneral_id
LEFT JOIN [LENDER_LOAN_SERVICE].[dbo].[HUD_LINE] nineohone on nineohone.loanGeneral_Id=g.loangeneral_id and hudType='HUD' and _LineNumber=1401
LEFT JOIN LENDER_LOAN_SERVICE.dbo._LEGAL_DESCRIPTION legaldesc on legaldesc.loanGeneral_Id=g.loanGeneral_Id and legaldesc._Type='LongLegal'
LEFT JOIN LENDER_LOAN_SERVICE.dbo.CUSTOM_FIELD cfmember on cfmember.loanGeneral_Id=g.loanGeneral_Id and cfmember.AttributeUniqueName='Member Number'
LEFT JOIN LENDER_LOAN_SERVICE.dbo.CUSTOM_FIELD cfns on cfns.loanGeneral_Id=g.loanGeneral_Id and cfns.AttributeUniqueName='Non-Saleable?'
LEFT JOIN [LENDER_LOAN_SERVICE].[dbo].[HUD_LINE] cttax on cttax.loanGeneral_Id=g.loangeneral_id and cttax.hudType='HUD' and cttax._LineNumber=1001 and cttax._SystemFeeName='City/Town Tax'
 LEFT JOIN [LENDER_LOAN_SERVICE].[dbo].[HUD_LINE] fip on fip.loanGeneral_Id=g.loangeneral_id and fip.hudType='HUD' and fip._LineNumber=1002 and fip._SystemFeeName='Flood Insurance'
 LEFT JOIN [LENDER_LOAN_SERVICE].[dbo].[HUD_LINE] hwi on hwi.loanGeneral_Id=g.loangeneral_id and hwi.hudType='HUD' and hwi._LineNumber=1003 and hwi._SystemFeeName='Hail/Windstorm Insurance'
 LEFT JOIN [LENDER_LOAN_SERVICE].[dbo].[HUD_LINE] hoi on hoi.loanGeneral_Id=g.loangeneral_id and hoi.hudType='HUD' and hoi._LineNumber=1004 and hoi._SystemFeeName='Homeowners Insurance'
  LEFT JOIN [LENDER_LOAN_SERVICE].[dbo].[HUD_LINE] mihud on mihud.loanGeneral_Id=g.loangeneral_id and mihud.hudType='HUD' and mihud._LineNumber=1005 and mihud._SystemFeeName='Mortgage Insurance'
  LEFT JOIN [LENDER_LOAN_SERVICE].[dbo].[HUD_LINE] pte on pte.loanGeneral_Id=g.loangeneral_id and pte.hudType='HUD' and pte._LineNumber=1006 and pte._SystemFeeName='Property Taxes'
  LEFT JOIN [LENDER_LOAN_SERVICE].[dbo].[HUD_LINE] stax on stax.loanGeneral_Id=g.loangeneral_id and stax.hudType='HUD' and stax._LineNumber=1007 and stax._SystemFeeName='School Tax'
LEFT JOIN [LENDER_LOAN_SERVICE].[dbo].EMPLOYER B1WRK on B1WRK.loanGeneral_Id=g.loanGeneral_Id and B1WRK.BorrowerID='BRW1' and B1WRK.CurrentEmploymentMonthsOnJob is not NULL
LEFT JOIN [LENDER_LOAN_SERVICE].[dbo].EMPLOYER B2WRK on B2WRK.loanGeneral_Id=g.loanGeneral_Id and B2WRK.BorrowerID='BRW2' and B2WRK.CurrentEmploymentMonthsOnJob is not NULL
LEFT JOIN [LENDER_LOAN_SERVICE].[dbo].EMPLOYER B3WRK on B3WRK.loanGeneral_Id=g.loanGeneral_Id and B3WRK.BorrowerID='BRW3' and B3WRK.CurrentEmploymentMonthsOnJob is not NULL
LEFT JOIN [LENDER_LOAN_SERVICE].[dbo].EMPLOYER B4WRK on B4WRK.loanGeneral_Id=g.loanGeneral_Id and B4WRK.BorrowerID='BRW4' and B4WRK.CurrentEmploymentMonthsOnJob is not NULL
LEFT JOIN [LENDER_LOAN_SERVICE].[dbo].[ESCROW] ESCROWPT on ESCROWPT.loanGeneral_Id=g.loanGeneral_Id and ESCROWPT._ItemType='CountyPropertyTax'
LEFT JOIN [LENDER_LOAN_SERVICE].[dbo].[ESCROW] ESCROWCT on ESCROWCT.loanGeneral_Id=g.loanGeneral_Id and ESCROWCT._ItemType='CityPropertyTax'
LEFT JOIN [LENDER_LOAN_SERVICE].[dbo].[ESCROW] ESCROWSCHOOL on ESCROWSCHOOL.loanGeneral_Id=g.loanGeneral_Id and ESCROWSCHOOL._ItemType='DistrictPropertyTax'
LEFT JOIN [LENDER_LOAN_SERVICE].[dbo].[ESCROW] ESCROWWI on ESCROWWI.loanGeneral_Id=g.loanGeneral_Id and ESCROWWI._ItemType='WindstormInsurance'
LEFT JOIN [LENDER_LOAN_SERVICE].[dbo].[ESCROW] ESCROWFLOOD on ESCROWFLOOD.loanGeneral_Id=g.loanGeneral_Id and ESCROWFLOOD._ItemType='FloodInsurance'
LEFT JOIN [LENDER_LOAN_SERVICE].[dbo].[ESCROW] ESCROWHOI on ESCROWHOI.loanGeneral_Id=g.loanGeneral_Id and ESCROWHOI._ItemType='HazardInsurance'
LEFT JOIN [LENDER_LOAN_SERVICE].[dbo].[ESCROW] ESCROWMI on ESCROWMI.loanGeneral_Id=g.loanGeneral_Id and ESCROWMI._ItemType='MortgageInsurance'
LEFT JOIN [LENDER_LOAN_SERVICE].[dbo].[TRANSMITTAL_DATA] td on td.loanGeneral_Id=g.loanGeneral_Id
LEFT JOIN [LENDER_LOAN_SERVICE].[dbo].CLOSING_INSTRUCTIONS ci on g.loanGeneral_Id=ci.loanGeneral_Id
LEFT JOIN [LENDER_LOAN_SERVICE].dbo.VENDOR_AGENT VAHI on VAHI.loanGeneral_Id=g.loanGeneral_Id and VAHI._Type='HazardInsurer'
WHERE g.loanStatus = 20
      AND cast(fd._fundeddate AS DATE)='$targetdate'
       AND gld.LoanProgram not like 'HELOC\%'
    AND gld.LoanProgram not like 'EL\%'
EOT



my $recs = $db->GetCustomRecords($qry);

my $flag = 0;

#printing nulls as ''
no warnings 'uninitialized';
open my $tsv, ">", "\\\\d-spokane\\servicing\$\\Misc\\"."MortgageBotUpdate-$targetdate\.txt";
open my $ph2tsv, ">", "\\\\d-spokane\\servicing\$\\Misc\\"."Ph2MortgageBotUpdate-$targetdate\.txt";
for my $rec (@$recs){
#place to hack fields before output
	$rec->{'# of months cushion disclosure'} = '2';
	$rec->{'Payment Type'} =~ s/Rate//;
	$rec->{'Interest Type'} =~ s/Rate//;
	$rec->{'Loan Type'} =~ s/VA/VA (GI)/;
	
	$rec->{'Late Charge Description'} = '4% of Principal and Interest - Veterans' if $rec->{'Loan Type'} eq 'VA (GI)';
	$rec->{'Late Charge Description'} = '5% of Principal & Interest - 15 day Grace Period' unless $rec->{'Loan Type'} eq 'VA (GI)';
	
	$rec->{'Borrower 2 Credit Score Date'} = '' unless $rec->{'Borrower 2 Last Name'};
	$rec->{'Borrower 3 Credit Score Date'} = '' unless $rec->{'Borrower 3 Last Name'};
	$rec->{'Borrower 4 Credit Score Date'} = '' unless $rec->{'Borrower 4 Last Name'};
	#if we have a 3 and not a 2, rotate 3 into 2, 4 into 3, scrub 4
	if($rec->{'Borrower 3 SSN'} and !($rec->{'Borrower 2 SSN'})){
			#print "Copying stuff for loan $rec->{'Loan ID'}\n";
			$rec->{'Borrower 2 SSN'} = $rec->{'Borrower 3 SSN'};
			$rec->{'Borrower 2 First Name'} = $rec->{'Borrower 3 First Name'};
			$rec->{'Borrower 2 Middle Name'} = $rec->{'Borrower 3 Middle Name'};
			$rec->{'Borrower 2 Last Name'} = $rec->{'Borrower 3 Last Name'};
			$rec->{'Borrower 2 Email Address'} = $rec->{'Borrower 3 Email Address'};
			$rec->{'Borrower 2 Home Phone'} = $rec->{'Borrower 3 Home Phone'};
			$rec->{'Borrower 2 Cell Phone'} = $rec->{'Borrower 3 Cell Phone'};
			$rec->{'Borrower 2 Credit Score'} = $rec->{'Borrower 3 Credit Score'};
			$rec->{'Borrower 2 Credit Score Date'} = $rec->{'Borrower 3 Credit Score Date'};
			$rec->{'Borrower 2 Credit Score ID'} = $rec->{'Borrower 3 Credit Score ID'};
			$rec->{'Borrower 2 DOB'} = $rec->{'Borrower 3 DOB'};
			$rec->{'Borrower 2 Suffix'} = $rec->{'Borrower 3 Suffix'};
			
			$rec->{'Borrower 3 SSN'} = $rec->{'Borrower 4 SSN'};
			$rec->{'Borrower 3 First Name'} = $rec->{'Borrower 4 First Name'};
			$rec->{'Borrower 3 Middle Name'} = $rec->{'Borrower 4 Middle Name'};
			$rec->{'Borrower 3 Last Name'} = $rec->{'Borrower 4 Last Name'};
			$rec->{'Borrower 3 Email Address'} = $rec->{'Borrower 4 Email Address'};
			$rec->{'Borrower 3 Home Phone'} = $rec->{'Borrower 4 Home Phone'};
			$rec->{'Borrower 3 Cell Phone'} = $rec->{'Borrower 4 Cell Phone'};
			$rec->{'Borrower 3 Credit Score'} = $rec->{'Borrower 4 Credit Score'};
			$rec->{'Borrower 3 Credit Score Date'} = $rec->{'Borrower 4 Credit Score Date'};
			$rec->{'Borrower 3 Credit Score ID'} = $rec->{'Borrower 4 Credit Score ID'};
			$rec->{'Borrower 3 DOB'} = $rec->{'Borrower 4 DOB'};
			$rec->{'Borrower 3 Suffix'} = $rec->{'Borrower 4 Suffix'};
			
			$rec->{'Borrower 4 SSN'} = '';
			$rec->{'Borrower 4 First Name'} = '';
			$rec->{'Borrower 4 Middle Name'} = '';
			$rec->{'Borrower 4 Last Name'} = '';
			$rec->{'Borrower 4 Email Address'} = '';
			$rec->{'Borrower 4 Home Phone'} = '';
			$rec->{'Borrower 4 Cell Phone'} = '';
			$rec->{'Borrower 4 Credit Score'} = '';
			$rec->{'Borrower 4 Credit Score Date'} = '';
			$rec->{'Borrower 4 Credit Score ID'} = '';
			$rec->{'Borrower 4 DOB'} = '';
			$rec->{'Borrower 4 Suffix'} = '';
	}
	$rec->{'Mailing Name'} =~ s/^\s+|\s+$//g;
	$rec->{'Mailing Name'} = $rec->{'Borrower First Name'} . ' ' . $rec->{'Borrower 1 Last Name'} unless $rec->{'Mailing Name'};
	$rec->{'Mailing Name'} .= ' & ' . $rec->{'Borrower 2 First Name'} . ' ' .  $rec->{'Borrower 2 Last Name'} if $rec->{'Borrower 2 Last Name'};
	$rec->{'Mailing Name'} .= ' & ' . $rec->{'Borrower 3 First Name'} . ' ' .  $rec->{'Borrower 3 Last Name'} if $rec->{'Borrower 3 Last Name'};
	$rec->{'Mailing Name'} .= ' & ' . $rec->{'Borrower 4 First Name'} . ' ' .  $rec->{'Borrower 4 Last Name'} if $rec->{'Borrower 4 Last Name'};
	
	$rec->{'Property County'} =~ s/([\w\']+)/\u\L$1/g;
	$rec->{'Property County'} =~ s/\W//g;
	#$rec->{'Property County'} = ucfirst lc $rec->{'Property County'};
############
	
	unless($rec->{'Mailing Zip'}){
		if($rec->{'Purpose Code'} =~ /PrimaryResidence/){
			$rec->{'Mailing Address 1'} = $rec->{'Property Street'};
			$rec->{'Mailing City'} = $rec->{'Property City'};
			$rec->{'Mailing State'} = $rec->{'Property State'};
			$rec->{'Mailing Zip'} = $rec->{'Property Zip'};
		} else {
			$rec->{'Mailing Address 1'} = $rec->{'b1mailing1'};		
			$rec->{'Mailing City'} = $rec->{'b1mailingcity'};
			$rec->{'Mailing State'} = $rec->{'b1mailingstate'};
			$rec->{'Mailing Zip'} = $rec->{'b1mailingzip'};
		}
	}
	
	$rec->{'Interest Calc Method'} = 'Fannie Mae' if $rec->{'Interest Calc Method'} =~ /Conventional/;
	$rec->{'Non-saleable to FNMA'} = $rec->{'Non-saleable to FNMA'} ? 'Y' : '';
	$rec->{'SSN Code'} = 'SSN';
	$rec->{'Association'} = ($rec->{'Borrower 2 SSN'} or $rec->{'Borrower 3 SSN'} or $rec->{'Borrower 4 SSN'}) ? 'Joint Contractual Liability' : 'Individual Account';
	
	$rec->{'Loan Plan Name'} = $lpntable{$rec->{ProductCode}};
	
	
	#arm loan stuff
	my $armuse = '';
	if($rec->{ProductCode} =~ /CA55/) { $armuse = 'CA55'}
	elsif ($rec->{ProductCode} =~ /JA55/) { $armuse = 'JA55'}
	elsif ($rec->{ProductCode} =~ /CA3/) { $armuse = 'CA3'}
	elsif ($rec->{ProductCode} =~ /CA5/) { $armuse = 'CA5'}
	elsif ($rec->{ProductCode} =~ /JA51/) { $armuse = 'JA51'}
	
	if($armuse){
		$rec->{'Hybrid ARM?'} = 'Yes';
		
		$rec->{'Analysis Notification Days'} = 75;
		$rec->{'Reset Notification Days'} = 180;
		$rec->{'Interest Rate Change Formula'} = 'Standard Interest Rate Calculation';
		$rec->{'Rounding Parameter'} = 'Nearest 1/8';
		$rec->{'Payment Selection Option'} = 'Use the Amortized Payment';
		
		map {$rec->{$_} = $arm{$armuse}->{$_}} keys %{$arm{$armuse}};
		$rec->{'P&I Change Formula'} = 'Standard P&I Calculation';
		
		$rec->{'ARM Floor'} = $rec->{'ARM Margin'};
		
		$rec->{'ARM First Maximum Rate'} = $rec->{'Interest Rate'} + $rec->{'ARM Incremental cap'};
		$rec->{'ARM First Minimum Rate'} = ($rec->{'Interest Rate'} - $rec->{'ARM Incremental cap'} > $rec->{'ARM Margin'}) ? ($rec->{'Interest Rate'} - $rec->{'ARM Incremental cap'}) : $rec->{'ARM Margin'};
		$rec->{'ARM Maximum Rate'} = $rec->{'Interest Rate'} + $rec->{'ARM Lifetime cap'};
		$rec->{'ARM Minimum Rate'} = ($rec->{'Interest Rate'} - $rec->{'ARM Lifetime cap'} > $rec->{'ARM Margin'}) ? ($rec->{'Interest Rate'} - $rec->{'ARM Lifetime cap'}) : $rec->{'ARM Margin'};
		if($rec->{'Due Date of First Payment'} =~ /(\d\d\d\d)-(\d\d)-(\d\d)/){
		my $date = DateTime->new( year => $1, month => $2, day => $3, locale => 'en_US');
		$date->add( months => ($rec->{'ARM Months before first change'} - 1), end_of_month => 'preserve');
		$rec->{'ARM First Rate Change Date'} = $date->ymd('-');
		$rec->{'ARM Next Rate Change Date'} = $rec->{'ARM First Rate Change Date'};
		$date->add( months => 1, end_of_month => 'preserve');
		$rec->{'ARM First Payment Change Date'} = $date->ymd('-');
		$rec->{'ARM Next Payment Change Date'} = $rec->{'ARM First Payment Change Date'};
		$rec->{'ARM Date to reflect first change'} = $rec->{'ARM First Payment Change Date'};
		$rec->{'ARM Date to reflect next change'} = $rec->{'ARM First Payment Change Date'};
		}
	
	}
	
	
	#4 fields from 3/23/16 JM e-mail, all default values
	$rec->{'Statements'} =  'N';
	$rec->{'E-Statements'} = 'Y';
	$rec->{'Service Fee Type'} = 'Rate';
	$rec->{'Service Fee Rate'} = '.00000';
	
	
######
#Phase 2 hacks
#####
	$rec->{'Flood Life of Loan Carrier'} =  "CBCInnovis Flood" if $rec->{'Flood Life of Loan Carrier'} eq 'CBCInnovis Flood Zone Determination Services';
	if($rec->{'MI Company'}){
	#ARCH, Genworth - Level Monthly, MGIC - Monthly Premiums, Radian - Monthly Premiums & UGRIC
	$rec->{'PMI Automation Type'} = $autotype{$rec->{'MI Company'}};
		$rec->{'PMI coverage Effective Date'} = $rec->{'Funding Date'};
		$rec->{'PMI Cancellation Type'} = 'Standard';
		#$rec->{'ProgramPremiums'} = 'Monthly Premiums' if $rec->{'MIProgramID'} eq '2';
		#$rec->{'PMI Automation Type'} = $rec->{'UWMICompanyName'} . ' - ' . $rec->{'ProgramPremiums'};
	
		#apply the table
		$rec->{'MI Company'} = $micompanytable{$rec->{'MI Company'}} if $micompanytable{$rec->{'MI Company'}};
	
	}
	#maybe US default for now
	$rec->{'Borrower wk ph type'} = 'U.S.';
	
	
	#flood zone NO if B, C, X & D
	$rec->{'Flood Zone'} = 'NO' if $rec->{'Flood Zone'} =~ /^[BCXD]$/;
	#make sure parcel number IS NOT BLANK
	$rec->{'Parcel Number'} = $rec->{'Parcel Number'}?$rec->{'Parcel Number'}:'blank';
	
	
	
##########
#T&I Expansion
#########


#PTax
my $fakedatestring = '';
if($rec->{'Date of Note'} =~ /(\d\d\d\d)-(\d\d)-(\d\d)/){
	my $date = DateTime->new( year => $1, month => $2, day => $3, locale => 'en_US');
	$date->add(months=> 12, end_of_month => 'preserve');
	$fakedatestring = $date->ymd('-');
}

	if($rec->{'Property Tax Frequency'} eq 'Annual'){
		$rec->{'PT TI Frequency'} = 'Annually';
		$rec->{'PT Total Disbursments'} = 12*$rec->{'Property Taxes (Escrow)'};
		$rec->{'PT Date 1'} = $rec->{'Property Tax Due Date'};
		$rec->{'PT Paid 1'} = $rec->{'PT Total Disbursments'};
		
		
	}elsif ($rec->{'Property Tax Frequency'} eq 'Monthly'){
		
		$rec->{'PT TI Frequency'} = 'Monthly';
		$rec->{'PT Total Disbursments'} = 12*$rec->{'Property Taxes (Escrow)'};
		if($rec->{'Property Tax Due Date'} =~ /(\d\d\d\d)-(\d\d)-(\d\d)/){
			my $date = DateTime->new( year => $1, month => $2, day => $3, locale => 'en_US');
		
		for my $count (1..12){
			$rec->{"PT Paid $count"} = $rec->{'Property Taxes (Escrow)'};
			$rec->{"PT Date $count"} = $date->ymd('-');
			$date->add( months => 1, end_of_month => 'preserve');
		}
		}
		
	}elsif ($rec->{'Property Tax Frequency'} eq 'SemiAnnual'){
		$rec->{'PT TI Frequency'} = "Semi Annually";
		
		$rec->{'PT Total Disbursments'} = 12*$rec->{'Property Taxes (Escrow)'};
		if($rec->{'Property Tax Due Date'} =~ /(\d\d\d\d)-(\d\d)-(\d\d)/){
					my $date = DateTime->new( year => $1, month => $2, day => $3, locale => 'en_US');	
				for my $count (1..2){
					$rec->{"PT Paid $count"} = $rec->{'Property Taxes (Escrow)'} * 6;
					#$rec->{"PT Date $count"} = $date->ymd('-');
					$date->add( months => 6, end_of_month => 'preserve');
				}
		}
	}elsif ($rec->{'Property Tax Frequency'} eq 'Quarterly'){
		$rec->{'PT TI Frequency'} = "Quarterly";
		$rec->{'PT Total Disbursments'} = 12*$rec->{'Property Taxes (Escrow)'};
			if($rec->{'Property Tax Due Date'} =~ /(\d\d\d\d)-(\d\d)-(\d\d)/){
							my $date = DateTime->new( year => $1, month => $2, day => $3, locale => 'en_US');
						
						for my $count (1..4){
							$rec->{"PT Paid $count"} = $rec->{'Property Taxes (Escrow)'} * 3;
							#$rec->{"PT Date $count"} = $date->ymd('-');
							$date->add( months => 3, end_of_month => 'preserve');
						}
		}
	
	}
	if($rec->{'PT ID'} and $rec->{'Property Tax Frequency'} eq ''){
			$rec->{'PT Include Cushion'} = 'No';
			$rec->{'PT TI Frequency'} = 'Annually';
			$rec->{'PT Non-escrow'} = 'Yes';
			$rec->{'PT Payee'} = 'Property Taxes';
			$rec->{'PT Payee type'} = 'Tax Collector';
			$rec->{'PT Account#'} = $rec->{'Parcel Number'}?$rec->{'Parcel Number'}:'blank';
			$rec->{'PT Total Disbursments'} = 12*$rec->{'Property Taxes (Escrow)'};
			$rec->{'PT Date 1'} = $fakedatestring;
		}elsif($rec->{'PT ID'}){
			$rec->{'PT Payee'} = 'Property Taxes';
			$rec->{'PT Payee type'} = 'Tax Collector';
			$rec->{'PT Include Cushion'} = 'Yes';
			$rec->{'PT Account#'} = $rec->{'Parcel Number'}?$rec->{'Parcel Number'}:'blank';
			$rec->{'PT Non-escrow'} = 'No';
		}
		
		
		
#CTTax


	if($rec->{'CT Frequency'} eq 'Annual'){
		$rec->{'CT TI Frequency'} = 'Annually';
		
		$rec->{'CT Date 1'} = $rec->{'CT Due Date'};
		$rec->{'CT Paid 1'} = $rec->{'City/Town Tax'}*12;
		
		
	}elsif ($rec->{'CT Frequency'} eq 'Monthly'){
		
		$rec->{'CT TI Frequency'} = 'Monthly';
		
		if($rec->{'CT Due Date'} =~ /(\d\d\d\d)-(\d\d)-(\d\d)/){
			my $date = DateTime->new( year => $1, month => $2, day => $3, locale => 'en_US');
		
		for my $count (1..12){
			$rec->{"CT Paid $count"} = $rec->{'City/Town Tax'};
			$rec->{"CT Date $count"} = $date->ymd('-');
			$date->add( months => 1, end_of_month => 'preserve');
		}
		}
		
	}elsif ($rec->{'CT Frequency'} eq 'SemiAnnual'){
		$rec->{'CT TI Frequency'} = "Semi Annually";
		if($rec->{'CT Due Date'} =~ /(\d\d\d\d)-(\d\d)-(\d\d)/){
					my $date = DateTime->new( year => $1, month => $2, day => $3, locale => 'en_US');	
				for my $count (1..2){
					$rec->{"CT Paid $count"} = $rec->{'City/Town Tax'} * 6;
					#$rec->{"CT Date $count"} = $date->ymd('-');
					$date->add( months => 6, end_of_month => 'preserve');
				}
		}
	}elsif ($rec->{'CT Frequency'} eq 'Quarterly'){
		$rec->{'CT TI Frequency'} = "Quarterly";
		
			if($rec->{'CT Due Date'} =~ /(\d\d\d\d)-(\d\d)-(\d\d)/){
							my $date = DateTime->new( year => $1, month => $2, day => $3, locale => 'en_US');
						
						for my $count (1..4){
							$rec->{"CT Paid $count"} = $rec->{'City/Town Tax'} * 3;
							#$rec->{"CT Date $count"} = $date->ymd('-');
							$date->add( months => 3, end_of_month => 'preserve');
						}
		}
	
	}
	if($rec->{'CT ID'} and $rec->{'CT Frequency'} eq ''){
			$rec->{'CT Include Cushion'} = 'No';
			$rec->{'CT TI Frequency'} = 'Annually';
			$rec->{'CT Non-escrow'} = 'Yes';
			$rec->{'CT Payee'} = 'City/Town Tax';
			$rec->{'CT Payee type'} = 'Tax Collector';
			$rec->{'CT Account#'} = $rec->{'Parcel Number'};
			$rec->{'CT Total Disbursments'} = 12*$rec->{'City/Town Tax'};
		}elsif($rec->{'CT ID'}){
			$rec->{'CT Total Disbursments'} = 12*$rec->{'City/Town Tax'};
			$rec->{'CT Payee'} = 'City/Town Tax';
			$rec->{'CT Payee type'} = 'Tax Collector';
			$rec->{'CT Include Cushion'} = 'Yes';
			$rec->{'CT Account#'} = $rec->{'Parcel Number'};
			$rec->{'CT Non-escrow'} = 'No';
		}

#MI	
#$rec->{'Mortgage Insurance Due Date'} = $miDateMin->ymd('-') if $miDateMin->ymd('-') lt $rec->{'Mortgage Insurance Due Date'};

	if($rec->{'MI ID'} and $rec->{'MI Frequency'} eq ''){
			$rec->{'MI Include Cushion'} = 'No';
			$rec->{'MI Non-escrow'} = 'Yes';
			$rec->{'MI Payee'} = $rec->{'MI Company'};
			$rec->{'MI Payee type'} = 'Tax Collector';
			$rec->{'MI Account#'} = $rec->{'PMI Certification Number'};
			$rec->{'MI Total Disbursments'} = 12*$rec->{'Mortgage Insurance'};
		}elsif($rec->{'MI ID'}){
			$rec->{'MI Total Disbursments'} = 12*$rec->{'Mortgage Insurance'};
			$rec->{'MI Payee'} = $rec->{'MI Company'};
			$rec->{'MI Payee type'} = 'Tax Collector';
			$rec->{'MI Include Cushion'} = 'Yes';
			$rec->{'MI Non-escrow'} = 'No';
	}
	if($rec->{'MI Frequency'} eq 'Annual'){
			
			$rec->{'MI TI Frequency'} = 'Annually';
			$rec->{'MI Date 1'} = $rec->{'Mortgage Insurance Due Date'};
			$rec->{'MI Paid 1'} = $rec->{'MI Total Disbursments'};
			$rec->{'MI Account#'} = $rec->{'PMI Certification Number'};
		
		
		}elsif ($rec->{'MI Frequency'} eq 'Monthly'){
			$rec->{'MI Account#'} = $rec->{'PMI Certification Number'};
			$rec->{'MI TI Frequency'} = 'Monthly';
			
			if($rec->{'Mortgage Insurance Due Date'} =~ /(\d\d\d\d)-(\d\d)-(\d\d)/){
				my $date = DateTime->new( year => $1, month => $2, day => $3, locale => 'en_US');
			
			for my $count (1..12){
				$rec->{"MI Paid $count"} = $rec->{'Mortgage Insurance'};
				$rec->{"MI Date $count"} = $date->ymd('-');
				$date->add( months => 1, end_of_month => 'preserve');
			}
			}
	}

#HOI
#fix vahihi
$rec->{'vahihi'} = defined($hcntable{uc($rec->{'vahihi'})})?$hcntable{uc($rec->{'vahihi'})}:'Hazard';

#payment expansion
	if($rec->{'HoI Frequency'} eq 'Annual'){
		$rec->{'HOI TI Frequency'} = 'Annually';
		
		$rec->{'HOI Date 1'} = $rec->{'Homeowners Insurance Due Date'};
		$rec->{'HOI Paid 1'} = $rec->{'HOI Total Disbursments'};
	}elsif ($rec->{'Property Tax Frequency'} eq 'Monthly'){
		$rec->{'HOI TI Frequency'} = 'Monthly';
		$rec->{'HOI Total Disbursments'} = 12*$rec->{'Homeowners Insurance'};
		if($rec->{'Homeowners Insurance Due Date'} =~ /(\d\d\d\d)-(\d\d)-(\d\d)/){
			my $date = DateTime->new( year => $1, month => $2, day => $3, locale => 'en_US');
		
		for my $count (1..12){
			$rec->{"HOI Paid $count"} = $rec->{'Homeowners Insurance'};
			$rec->{"HOI Date $count"} = $date->ymd('-');
			$date->add( months => 1, end_of_month => 'preserve');
		}
		}
	}
	
	
#disbursement and fixed
	if($rec->{'HOI ID'} and $rec->{'HoI Frequency'} eq ''){
				$rec->{'HOI Include Cushion'} = 'No';
				$rec->{'HOI TI Frequency'} = 'Annually';
				$rec->{'HOI Non-escrow'} = 'Yes';
				$rec->{'HOI Payee'} = 'Hazard';
				$rec->{'HOI Account#'} = $rec->{'cihipi'}?$rec->{'cihipi'}:'blank';
				$rec->{'HOI Payee type'} = 'Insurance Company';
				$rec->{'HOI Date 1'} = $fakedatestring;
				$rec->{'HOI Total Disbursments'} = 12*$rec->{'Homeowners Insurance'};
			}elsif($rec->{'HOI ID'}){
			        $rec->{'HOI Payee'} = 'Hazard';
			        $rec->{'HOI Payee type'} = 'Insurance Company';
				$rec->{'HOI Include Cushion'} = 'Yes';
				$rec->{'HOI Non-escrow'} = 'No';
				$rec->{'HOI Account#'} = $rec->{'cihipi'}?$rec->{'cihipi'}:'blank';
				$rec->{'HOI Total Disbursments'} = 12*$rec->{'Homeowners Insurance'};
	}
#School
	
if($rec->{'SCHOOL Frequency'} eq 'Annual'){
		$rec->{'SCHOOL TI Frequency'} = 'Annually';
		
		$rec->{'SCHOOL Date 1'} = $rec->{'SCHOOL Due Date'};
		$rec->{'SCHOOL Paid 1'} = $rec->{'SCHOOL Total Disbursments'};
		
		
	}elsif ($rec->{'SCHOOL Frequency'} eq 'Monthly'){
		$rec->{'SCHOOL TI Frequency'} = 'Monthly';
		
		
		if($rec->{'SCHOOL Due Date'} =~ /(\d\d\d\d)-(\d\d)-(\d\d)/){
			my $date = DateTime->new( year => $1, month => $2, day => $3, locale => 'en_US');
		
		for my $count (1..12){
			$rec->{"SCHOOL Paid $count"} = $rec->{'School Tax'};
			$rec->{"SCHOOL Date $count"} = $date->ymd('-');
			$date->add( months => 1, end_of_month => 'preserve');
		}
		}
		
	}elsif ($rec->{'SCHOOL Frequency'} eq 'SemiAnnual'){
		$rec->{'SCHOOL TI Frequency'} = "Semi Annually";
		
		
		if($rec->{'SCHOOL Due Date'} =~ /(\d\d\d\d)-(\d\d)-(\d\d)/){
					my $date = DateTime->new( year => $1, month => $2, day => $3, locale => 'en_US');
				
				for my $count (1..2){
					$rec->{"SCHOOL Paid $count"} = $rec->{'School Tax'} * 6;
					#$rec->{"SCHOOL Date $count"} = $date->ymd('-');
					$date->add( months => 6, end_of_month => 'preserve');
				}
		}
	}elsif ($rec->{'SCHOOL Frequency'} eq 'Quarterly'){
		$rec->{'SCHOOL TI Frequency'} = "Quarterly";		
		if($rec->{'SCHOOL Due Date'} =~ /(\d\d\d\d)-(\d\d)-(\d\d)/){
					my $date = DateTime->new( year => $1, month => $2, day => $3, locale => 'en_US');
				
				for my $count (1..4){
					$rec->{"SCHOOL Paid $count"} = $rec->{'School Tax'} * 3;
					#$rec->{"SCHOOL Date $count"} = $date->ymd('-');
					$date->add( months => 3, end_of_month => 'preserve');
				}
		}
	}
	if($rec->{'SCHOOL ID'} and $rec->{'SCHOOL Frequency'} eq ''){
				$rec->{'SCHOOL Include Cushion'} = 'No';
				$rec->{'SCHOOL TI Frequency'} = 'Annually';
				$rec->{'SCHOOL Non-escrow'} = 'Yes';
				$rec->{'SCHOOL Payee'} = 'School Tax';
				$rec->{'SCHOOL Payee type'} = 'Tax Collector';
				$rec->{'SCHOOL Account#'} = $rec->{'Parcel Number'};
				$rec->{'SCHOOL Total Disbursments'} = 12*$rec->{'School Tax'};
				$rec->{'SCHOOL Date 1'} = $fakedatestring;
			}elsif($rec->{'SCHOOL ID'}){
				$rec->{'SCHOOL Payee'} = 'School Tax';
				$rec->{'SCHOOL Account#'} = $rec->{'Parcel Number'};
				$rec->{'SCHOOL Payee type'} = 'Tax Collector';
				$rec->{'SCHOOL Include Cushion'} = 'Yes';
				$rec->{'SCHOOL Non-escrow'} = 'No';
				$rec->{'SCHOOL Total Disbursments'} = 12*$rec->{'School Tax'};
	}
	
	
	
	
#Windstorm Insurance
#frequency based
if($rec->{'WI Frequency'} eq 'Annual'){
		
		$rec->{'WI TI Frequency'} = 'Annually';
		
		$rec->{'WI Date 1'} = $rec->{'WI Due Date'};
		$rec->{'WI Paid 1'} = $rec->{'WI Total Disbursments'};
		
		
	}

#Escrow, cushion , defaults
if($rec->{'WI ID'} and $rec->{'WI Frequency'} eq ''){
				$rec->{'WI Include Cushion'} = 'No';
				$rec->{'WI TI Frequency'} = 'Annually';
				$rec->{'WI Non-escrow'} = 'Yes';
				$rec->{'WI Payee'} = 'Hail/Windstorm';
				$rec->{'WI Payee type'} = 'Insurance Company';
				$rec->{'WI Account#'} = 'blank';
				$rec->{'WI Date 1'} = $fakedatestring;
				$rec->{'WI Total Disbursments'} = 12*$rec->{'Hail/Windstorm Insurance'};
			}elsif($rec->{'WI ID'}){
				$rec->{'WI Include Cushion'} = 'Yes';
				$rec->{'WI Non-escrow'} = 'No';
				$rec->{'WI Payee'} = 'Hail/Windstorm';
				$rec->{'WI Payee type'} = 'Insurance Company';
				$rec->{'WI Account#'} = 'blank';
				$rec->{'WI Total Disbursments'} = 12*$rec->{'Hail/Windstorm Insurance'};
	}

#Flood Insurance
#frequency based
if($rec->{'FLOOD Frequency'} eq 'Annual'){
		
		$rec->{'FLOOD TI Frequency'} = 'Annually';
		
		$rec->{'FLOOD Date 1'} = $rec->{'FLOOD Due Date'};
		$rec->{'FLOOD Paid 1'} = $rec->{'FLOOD Total Disbursments'};
		
		
	}

#Escrow, cushion , defaults
if($rec->{'FLOOD ID'} and $rec->{'FLOOD Frequency'} eq ''){
				$rec->{'FLOOD Include Cushion'} = 'No';
				$rec->{'FLOOD TI Frequency'} = 'Annually';
				$rec->{'FLOOD Non-escrow'} = 'Yes';
				$rec->{'FLOOD Payee'} = 'Flood';
				$rec->{'FLOOD Payee type'} = 'Insurance Company';
				$rec->{'FLOOD Account#'} = $rec->{'cihifi'}?$rec->{'cihifi'}:'blank';
				$rec->{'FLOOD Total Disbursments'} = 12*$rec->{'Flood Insurance'};
				$rec->{'FLOOD Date 1'} = $fakedatestring;
			}elsif($rec->{'FLOOD ID'}){
				$rec->{'FLOOD Include Cushion'} = 'Yes';
				$rec->{'FLOOD Non-escrow'} = 'No';
				$rec->{'FLOOD Payee'} = 'Flood';
				$rec->{'FLOOD Payee type'} = 'Insurance Company';
				$rec->{'FLOOD Account#'} = $rec->{'cihifi'}?$rec->{'cihifi'}:'blank';
				$rec->{'FLOOD Total Disbursments'} = 12*$rec->{'Flood Insurance'};
	}

	print $tsv join("\t", map {$rec->{$_}} @fields);
	print $tsv "\n";
	print $ph2tsv join ("\t", map {$rec->{$_}} @ph2fields);
	print $ph2tsv "\n";
	$flag++;
}

close $tsv;
close $ph2tsv;

if($flag){
	open my $key, ">", "\\\\d-spokane\\servicing\$\\Misc\\"."keyfile$targetdate\.txt";
	print $key join("\n", @fields);
	open my $ph2key, ">", "\\\\d-spokane\\servicing\$\\Misc\\"."ph2keyfile$targetdate\.txt";
	print $ph2key  join("\t", @ph2fields);
	close $key;
	close $ph2key;
}