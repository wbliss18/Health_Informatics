LIBNAME term "\\files\users\willb\Desktop\CHS753\TermProject";

DATA term_brfss14;
SET term.term_brfss14;
RUN;

proc contents data = term_brfss14;
run;

DATA termData;
SET term_brfss14;

IF CHCSCNCR in (1) THEN HadSkinCancer = "Yes";
ElSE IF CHCSCNCR in (2) THEN HadSkinCancer = "No ";

IF SEX in (1) THEN Sex1 = "Male  ";
ELSE IF SEX in (2) THEN Sex1 = "Female";

IF _AGE_G in (1, 2) THEN Age = "18-34 yrs";
ELSE IF _AGE_G in (3,4,5) THEN Age = "35-64 yrs";
ELSE IF _AGE_G in (6) THEN Age = "65+ yrs   ";

IF _EDUCAG in (1, 2 ) THEN Education ="High School or Less";
ELSE IF _EDUCAG in (3) THEN Education ="Some College         ";
ELSE IF _EDUCAG in (4) THEN Education ="College Graduated    ";

IF _RACEGR3 in (1) THEN Race ="White    ";
ELSE IF _RACEGR3 in (5) THEN Race ="Hispanic";
ELSE IF _RACEGR3 in (2, 3, 4) THEN Race ="Others  ";

IF _INCOMG in (1, 2) THEN Income = "$29.9k -      ";
ELSE IF _INCOMG in (3, 4) THEN Income = "$30k-49.9K";
ELSE IF _INCOMG in (5) THEN Income = "$50k+      ";

IF MARITAL in (1) THEN Married ="Yes  "; *is this correct?;
ELSE IF MARITAL in (2, 3, 4, 5, 6) THEN Married ="No ";

IF GENHLTH in (1, 2, 3) THEN GeneralHealth = "Excell/Good";
ELSE IF GENHLTH in (4, 5) THEN GeneralHealth = "Fair/Poor   ";

IF Hlthcvr1 in (4) THEN HealthPlan = "Medicaid     "  ;
ELSE IF Hlthcvr1 in (1, 2, 3, 5, 6, 7) THEN HealthPlan = "Other Plans "  ;
ELSE IF Hlthcvr1 in (8) THEN HealthPlan = "No Plan         ";

IF _RFDRHV4 in (1) THEN HeavyDrinker = "No ";
else IF _RFDRHV4 in (2) THEN HeavyDrinker = "Yes";

IF DELAYMED in (1,2,3,4,5,6) THEN DelayedMedical ="Yes";
ELSE IF DELAYMED in (8) THEN DelayedMedical ="No ";

Run;

PROC FREQ data = termData;
TABLE Sex1 Age Education Race Income Married GeneralHealth HealthPlan HeavyDrinker DelayedMedical HadSkinCancer/ NOCUM;
RUN;

PROC SURVEYFREQ DATA = termData;
STRATUM _STSTR;
CLUSTER _PSU;
WEIGHT _LLCPWT;

TABLE Sex1*HadSkinCancer /cl row chisq;
TABLE Age*HadSkinCancer /cl row chisq;
TABLE Education*HadSkinCancer /cl row chisq;
TABLE Race*HadSkinCancer /cl row chisq;
TABLE Income*HadSkinCancer /cl row chisq;
TABLE Married*HadSkinCancer /cl row chisq;
TABLE GeneralHealth*HadSkinCancer /cl row chisq;
TABLE HealthPlan*HadSkinCancer /cl row chisq;
TABLE HeavyDrinker*HadSkinCancer /cl row chisq;
TABLE DelayedMedical*HadSkinCancer /cl row chisq;

RUN;


PROC SURVEYLOGISTIC DATA = termData;

STRATUM _STSTR;
CLUSTER _PSU;
WEIGHT _LLCPWT;

Class  HadSkinCancer Sex1 Age Education Race Income Married GeneralHealth HealthPlan HeavyDrinker DelayedMedical;

MODEL HadSkinCancer (REF = "No") =  Sex1 Age Education Race Income Married GeneralHealth HealthPlan HeavyDrinker DelayedMedical /link = logit CLODDS;

CONTRAST 'Female vs. Male' Sex1 2 /ESTIMATE=exp;

CONTRAST '18-34 vs. 65+' Age 2 1 /ESTIMATE=exp;
CONTRAST '35-64 vs. 65+' Age 1 2 /ESTIMATE=exp;
CONTRAST '18-34 vs. 35-64' Age 1 -1 /ESTIMATE=exp;

CONTRAST 'Hispanic vs. White' Race 2 1 /ESTIMATE=exp;
CONTRAST 'Other vs. White' Race 1 2 /ESTIMATE=exp;
CONTRAST 'Hispanic vs. Other' Race 1 1 /ESTIMATE=exp;

CONTRAST 'High School vs. College' Education -1 1 /ESTIMATE=exp;
CONTRAST 'Some College vs. College' Education -2 -1 /ESTIMATE=exp;
CONTRAST 'High School vs. Some College' Education 1 2 /ESTIMATE=exp;

CONTRAST 'Non-Married vs. Married' Married 2 /ESTIMATE=exp;

CONTRAST '29.9k- vs. 50k+' Income 2 1 /ESTIMATE=exp;
CONTRAST '30-49.9k vs. 50k+' Income 1 2 /ESTIMATE=exp;
CONTRAST '29.9k- vs. 30-49k' Income 0 -1 /ESTIMATE=exp;

CONTRAST 'Fair/Poor vs. Excellent/Good' GeneralHealth -2 /ESTIMATE=exp;

CONTRAST 'Yes vs No' HeavyDrinker -2 /ESTIMATE=exp;

CONTRAST 'No Plan vs. Medicaid' HealthPlan -1 0 /ESTIMATE=exp;
CONTRAST 'No Plan vs. Other Plan' HealthPlan 1 2 /ESTIMATE=exp;
CONTRAST 'Medicaid vs. Other Plan' HealthPlan 2 1 /ESTIMATE=exp;


RUN;

/*
Class Level Infomation

Sex1 
	Female 1   
 	Male -1   

	Female vs. Male 	-> 2
 
Age 
	18-34 yrs 1 0 
  	35-64 yrs 0 1 
  	65+ yrs -1 -1 

	18-34 vs. 65+ -> 2 1
	35-64 vs. 65+ -> 1 2
	18-34 vs. 35-64 -> 1 -1

Race 
	Hispanic 1 0 
  	Others 0 1 
  	White -1 -1 

	Hispanic vs. White		-> 2 1
	Other vs. White			-> 1 2
	Hispanic vs. Other		-> 1 1

Education 
	College Graduated 1 0 
  	High School or Less 0 1 
  	Some College -1 -1 

	High School vs. College  		-> -1 1
	Some College vs. College		-> -2 -1
	High School vs. Some College	-> 1 2

Married 
	No 1   
  	Yes -1   

	Non-Married vs. Married -> 2


Income 
	$29.9k - 		1 0 
	$30k-49.9K 		0 1 
  	$50k+ 			-1 -1 

	29.9k- vs. 50k+			-> 2 1
	30-49.9k vs. 50k+		-> 1 2
	29.9k- vs. 30-49k		-> 0 -1

GeneralHealth 
	Excell/Good 1   
  	Fair/Poor -1   

	Fair/Poor vs. Excellent/Good -> -2

HeavyDrinker 
	No 1   
  	Yes -1   

	Yes vs No -> -2

HealthPlan 
	Medicaid 1 0 
  	No Plan 0 1 
  	Other Plans -1 -1 

	No Plan vs. Medicaid	-> -1 0
	No Plan vs. Other Plan	-> 1 2
	Medicaid vs. Other Plan	-> 2 1
*/
