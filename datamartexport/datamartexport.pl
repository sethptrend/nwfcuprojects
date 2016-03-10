#!/usr/bin/perl

#Seth Phillips
#2/16/2016
#script to export a query into a tsv and also create a key file
use warnings;
use strict;
use JSON;
use lib '\\\\Shenandoah\\sphillips$\\My Documents\\sethpgit\\lib'; #thanks windows
use Connection::Datamart;


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
'Percentage Sold');

#giant sql query
my $qry = <<"EOT";
SELECT g.LenderRegistrationIdentifier AS 'Loan ID'
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
	  , TotalLoanAmount as 'Current Principal Balances'
	  , TotalLoanAmount as 'Original Loan Amount'
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
					THEN 'TransUnion Emprica'
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
					THEN 'TransUnion Emprica'
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
	  , PropertyAppraisedValueAmount as 'Orig & Current Appraised Amount'
	  , lp.PropertyUsageType as 'Purpose Code'
	  , legaldesc._textdescription as 'Legal Description'
	  , PurchasePriceAmount as 'Sales Price'
	  , b1._FirstName + ' ' + b1._LastName + ' & ' + b2._FirstName + ' ' + b2._LastName as 'Mailing Name'
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

FROM LENDER_LOAN_SERVICE.dbo.LOAN_GENERAL G
LEFT JOIN LENDER_LOAN_SERVICE.dbo.ACCOUNT_INFO AI
      ON G.LOANGENERAL_ID = AI.LOANGENERAL_ID
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
		SELECT sum(_TotalAmount) as tot , loanGeneral_Id   FROM [LENDER_LOAN_SERVICE].[dbo].[HUD_LINE]  where  hudType='HUD' and _LineNumber > 999 and _LineNumber < 1100 group by loanGeneral_Id 
)  titot on titot.loanGeneral_Id=g.loangeneral_id
LEFT JOIN [LENDER_LOAN_SERVICE].[dbo].[HUD_LINE] nineohone on nineohone.loanGeneral_Id=g.loangeneral_id and hudType='HUD' and _LineNumber=1401
LEFT JOIN LENDER_LOAN_SERVICE.dbo._LEGAL_DESCRIPTION legaldesc on legaldesc.loanGeneral_Id=g.loanGeneral_Id and legaldesc._Type='LongLegal'
LEFT JOIN LENDER_LOAN_SERVICE.dbo.CUSTOM_FIELD cfmember on cfmember.loanGeneral_Id=g.loanGeneral_Id and cfmember.AttributeUniqueName='Member Number'
LEFT JOIN LENDER_LOAN_SERVICE.dbo.CUSTOM_FIELD cfns on cfns.loanGeneral_Id=g.loanGeneral_Id and cfns.AttributeUniqueName='Non-Saleable?'
WHERE g.loanStatus = 20
      AND cast(fd._fundeddate AS DATE)='$targetdate'
       AND gld.LoanProgram not like 'HELOC\%'
    AND gld.LoanProgram not like 'EL\%'
EOT



my $recs = $db->GetCustomRecords($qry);

my $flag = 0;

#printing nulls as ''
no warnings 'uninitialized';
open my $tsv, ">", "\\\\d-spokane\\servicing\$\\import\\"."MortgageBotUpdate-$targetdate\.txt";
for my $rec (@$recs){
#place to hack fields before output
	$rec->{'Payment Type'} =~ s/Rate//;
	$rec->{'Interest Type'} =~ s/Rate//;
	$rec->{'Loan Type'} =~ s/VA/VA (GI)/;
	
	$rec->{'Borrower 2 Credit Score Date'} = '' unless $rec->{'Borrower 2 Last Name'};
	$rec->{'Borrower 3 Credit Score Date'} = '' unless $rec->{'Borrower 3 Last Name'};
	$rec->{'Borrower 4 Credit Score Date'} = '' unless $rec->{'Borrower 4 Last Name'};

	$rec->{'Mailing Name'} =~ s/^\s+|\s+$//g;
	$rec->{'Mailing Name'} = $rec->{'Borrower Last Name'} . ' ' . $rec->{'Borrower 1 First Name'} unless $rec->{'Mailing Name'};
############
	
	unless($rec->{'Mailing Zip'}){
	$rec->{'Mailing Address 1'} = $rec->{'Property Street'};
	$rec->{'Mailing City'} = $rec->{'Property City'};
	$rec->{'Mailing State'} = $rec->{'Property State'};
	$rec->{'Mailing Zip'} = $rec->{'Property Zip'};
	
	$rec->{'Interest Calc Method'} = 'Fannie Mae' if $rec->{'Interest Calc Method'} =~ /Conventional/;
	$rec->{'Non-saleable to FNMA'} = $rec->{'Non-saleable to FNMA'} ? 'Y' : 'N';
	}

	print $tsv join("\t", map {$rec->{$_}} @fields);
	print $tsv "\n";
	$flag++;
}

close $tsv;

if($flag){
	open my $key, ">", "\\\\d-spokane\\servicing\$\\import\\"."keyfile.txt";
	print $key join("\n", @fields);
	close $key;
}