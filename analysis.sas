/* Generated Code (IMPORT) */
/* Source File: cancer.csv */
/* Source Path: /home/zzw00490/STAT7780/Project */
/* Code generated on: 11/28/18, 10:42 AM */

/*import the clean data*/
FILENAME REFFILE '/home/zzw00490/STAT7780/Project/cancer.csv';

PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV replace
	OUT=WORK.cancer;
	GETNAMES=YES;
RUN;

PROC CONTENTS DATA=WORK.cancer; RUN;

/*un necessary step*/
data cancer1;
 set cancer;
drop birth;/*not really easy to find out the age, so just drop it*/
proc CONTENTS DATA=WORK.cancer1; RUN;

/*frequency table*/
proc freq data=cancer1;
 table race gender marriage side;
run;
proc means maxdec=3 data=cancer1;
 var size side agediag nodes extension;
run;


/****some graphes of response****/
/*histogram*/
proc univariate data=cancer1;
 var month;
 histogram month /kernel;
 ods select Histogram;
run;
/*cdf*/
proc univariate data = cancer1;
var month;
cdfplot month;
ods select CDFPlot;
run;

/****life test****/
/*nonparametric Kaplan Meier estimator.*/
proc lifetest data=cancer1
 outsurv = cancer1_fitted alpha = 0.05 plots = S(CL CB = EP);
 time month*status(0);
 ods select CensoredSummary SurvivalPlot Means Quartiles;
run;

/****with different group****/
/*gender*/
proc sort data=cancer1;by gender;run;
proc lifetest data=cancer1
 outsurv = cancer1_fitted alpha = 0.05 plots = S(CL CB = EP);
 strata gender;
 time month*status(0);
 ods select SurvivalPlot HomTests;
 title 'Survival Plot with Different Gender';
run;
/*race*/
proc lifetest data=cancer1
 outsurv = cancer_fitted alpha = 0.05 plots = S(CL CB = EP);
 strata race;
 time month*status(0);
 ods select SurvivalPlot HomTests;
 title 'Survival Plot with Different race';
run;
/*marriage*/
proc lifetest data=cancer1
 outsurv = cancer_fitted alpha = 0.05 plots = S(CL CB = EP);
 strata marriage;
 time month*status(0);
 ods select SurvivalPlot HomTests;
 title 'Survival Plot with Marriage';
run;
/*side*/
proc lifetest data=cancer1
 outsurv = cancer_fitted alpha = 0.05 plots = S(CL CB = EP);
 strata side;
 time month*status(0);
 ods select SurvivalPlot HomTests;
 title 'Survival Plot with Different sides';
run;


/****lifereg****/
/****with assumption****/

proc lifereg data = cancer1;
 class side gender marriage race; 
 model month*status(0)= size side gender marriage race agediag nodes extension;/*weibull-special of gamma*/
 probplot; 
 ods select FitStatistics ProbPlot;
run;
/*exponental-special of weibull*/
proc lifereg data = cancer1;
 class side gender marriage race; 
 model month*status(0)= size side gender marriage race agediag nodes extension/dist=exponential;
  ods select FitStatistics ProbPlot;
 probplot;
run; 
/*gamma*//*lowest*/
proc lifereg data = cancer1;
 class side gender marriage race; 
 model month*status(0)= size side gender marriage race agediag nodes extension/dist=gamma;
 probplot;
run; 
/*lognormal-special of gamma*/
proc lifereg data = cancer1;
 class side gender marriage race; 
 model month*status(0)= size side gender marriage race agediag nodes extension/dist=lnormal;
  ods select FitStatistics ProbPlot;
 probplot;
run; 
/*loglogistic*/
proc lifereg data = cancer1;
 class side gender marriage race; 
 model month*status(0)= size side gender marriage race agediag nodes extension/dist=llogistic;
  ods select FitStatistics ProbPlot;
 probplot;
run;



/****simple phreg****/
proc phreg data=cancer1;
 class side(ref='1') gender(ref='0') marriage(ref='1') race(ref='1');
 model month*status(0)= size side gender marriage race agediag nodes extension;
 assess ph/resample=100;
run;


/****transformation on variable?****/
/*node*/
proc phreg data=cancer1;
 class side(ref='1') gender(ref='0') marriage(ref='1') race(ref='1');
 model month*status(0)= size side gender race agediag lognode extension;
 logage=log(agediag+1);
 lognode=log(nodes+1);
 logex=log(extension+1);
 assess var=(lognode)/resample;
run;
/*age*/
proc phreg data=cancer1;
 class side(ref='1') gender(ref='0') marriage(ref='1') race(ref='1');
 model month*status(0)= size side gender race logage nodes extension;
 logage=log(agediag+1);
 lognode=log(nodes+1);
 logex=log(extension+1);
 assess var=(logage)/resample;
run;
/*extension*/
proc phreg data=cancer1;
 class side(ref='1') gender(ref='0') marriage(ref='1') race(ref='1');
 model month*status(0)= size side gender race agediag nodes logex;
 logage=log(agediag+1);
 lognode=log(nodes+1);
 logex=log(extension+1);
 assess var=(logex)/resample;
run;
/*size*/
proc phreg data=cancer1;
 class side(ref='1') gender(ref='0') marriage(ref='1') race(ref='1');
 model month*status(0)= logsize side gender race agediag nodes extension;
 logage=log(agediag+1);
 lognode=log(nodes+1);
 logex=log(extension+1);
 logsize=log(size);
 assess var=(logsize)/resample;
run;
/*size, age cannot equal to zero*/
proc phreg data=cancer1;
 class side(ref='1') gender(ref='0') marriage(ref='1') race(ref='1');
 model month*status(0)= size side gender race logage nodes extension;
 logage=log(agediag);
 lognode=log(nodes+1);
 logex=log(extension+1);
 assess var=(logage)/resample;
run;

/*stepwise with interaction on size, extension with nodes*/
proc phreg data=cancer1;
 class side(ref='1') gender(ref='0') race(ref='1');
 model month*status(0)= side gender race logage nodes extension logsize logage*nodes extension*logsize nodes*extension logsize*logage
 /selection=stepwise ;
 logage=log(agediag);
 logsize=log(size);
run;
/*only want logsize*extension interactiong*/

/*final model*/
proc phreg data=cancer1;
 class side(ref='1') gender(ref='0') race(ref='1');
 model month*status(0)= side gender race logage nodes extension logsize extension*logsize;
 logage=log(agediag);
 logsize=log(size);
run;


/****assumption****/
proc phreg data=cancer1 noprint;
 class side(ref='0') gender(ref='0') marriage(ref='1') race(ref='0');
 model month*status(0)= size side gender marriage race logage nodes extension;
 output out = cancer1_fitted logsurv = CoxSnell;
 logage=log(agediag+1);
run;
/*Cox-Snell residual*/
data cancer1_fitted;
   set cancer1_fitted;
   CoxSnell = -CoxSnell;   
   label CoxSnell = 'Cox-Snell Residual';
run;
/*Nelson-Aalen estimate*/
proc phreg data = cancer1_fitted noprint;
   model CoxSnell*status(0)= ;   
   output out = cancer1_fitted2 logsurv = haz;
run;
data cancer1_fitted2;
   set cancer1_fitted2;
   haz = -haz;
   label haz = 'Estimated Cumulative Hazard Rate';
run;
proc sort data = cancer1_fitted2; by CoxSnell;
proc sgplot data = cancer1_fitted2 noautolegend;
   step x = CoxSnell y = haz; 
   lineparm x=0 y=0 slope=1;
run;/*good enough*/



/****strata?****/
/*marriage*/
proc phreg data=cancer1 noprint;
 class side(ref='0') gender(ref='0') marriage(ref='1') race(ref='0');
 model month*status(0)= size side gender race logage nodes extension;
 strata marriage;
  logage=log(agediag+1);
 output out = cancer1_stratified logsurv = CoxSnell;
run;
data cancer1_stratified;
   set cancer1_stratified;
   CoxSnell = -CoxSnell;   
   label CoxSnell = 'Cox-Snell Residual';
run;
proc sort data = cancer1_stratified; by marriage;
proc phreg data = cancer1_stratified noprint;
   model CoxSnell * status(0) = ;   
   output out = cancer1_stratified2 logsurv = haz / method = ch;
   by marriage;
run;
data cancer1_stratified2;
   set cancer1_stratified2;
   haz = -haz;
   label haz = 'Estimated Cumulative Hazard Rate';
run;
proc sort data = cancer1_stratified2; by CoxSnell;
proc sgplot data = cancer1_stratified2;
   step x = CoxSnell y = haz / group = marriage;   
   lineparm x=0 y=0 slope=1;
   xaxis label = 'Cox-Snell Residual';
   yaxis label = 'Estimated Cumulative Hazard Rate';
run;

/*gender*/
proc phreg data=cancer1 noprint;
 class side(ref='0') gender(ref='0') marriage(ref='1') race(ref='0');
 model month*status(0)= size side marriage race logage nodes extension;
 strata gender;
 logage=log(agediag+1);
 output out = cancer1_stratified logsurv = CoxSnell;
run;
data cancer1_stratified;
   set cancer1_stratified;
   CoxSnell = -CoxSnell;   
   label CoxSnell = 'Cox-Snell Residual';
run;
proc sort data = cancer1_stratified; by gender;
proc phreg data = cancer1_stratified noprint;
   model CoxSnell * status(0) = ;   
   output out = cancer1_stratified2 logsurv = haz / method = ch;
   by gender;
run;
data cancer1_stratified2;
   set cancer1_stratified2;
   haz = -haz;
   label haz = 'Estimated Cumulative Hazard Rate';
run;
proc sort data = cancer1_stratified2; by CoxSnell;
proc sgplot data = cancer1_stratified2;
   step x = CoxSnell y = haz / group = gender;   
   lineparm x=0 y=0 slope=1;
   xaxis label = 'Cox-Snell Residual';
   yaxis label = 'Estimated Cumulative Hazard Rate';
run;

/*side*/
proc phreg data=cancer1 noprint;
 class side(ref='0') gender(ref='0') marriage(ref='1') race(ref='0');
 model month*status(0)= size race marriage gender logage nodes extension;
 strata side;
  logage=log(agediag+1);
 output out = cancer1_stratified logsurv = CoxSnell;
run;
data cancer1_stratified;
   set cancer1_stratified;
   CoxSnell = -CoxSnell;   
   label CoxSnell = 'Cox-Snell Residual';
run;
proc sort data = cancer1_stratified; by side;
proc phreg data = cancer1_stratified noprint;
   model CoxSnell * status(0) = ;   
   output out = cancer1_stratified2 logsurv = haz / method = ch;
   by side;
run;
data cancer1_stratified2;
   set cancer1_stratified2;
   haz = -haz;
   label haz = 'Estimated Cumulative Hazard Rate';
run;
proc sort data = cancer1_stratified2; by CoxSnell;
proc sgplot data = cancer1_stratified2;
   step x = CoxSnell y = haz / group = side; 
   lineparm x=0 y=0 slope=1;
   xaxis label = 'Cox-Snell Residual';
   yaxis label = 'Estimated Cumulative Hazard Rate';
run;

/*race*/
proc phreg data=cancer1 noprint;
 class side(ref='0') gender(ref='0') marriage(ref='1') race(ref='0');
 model month*status(0)= size side marriage gender logage nodes extension;
 strata race;
  logage=log(agediag+1);
 output out = cancer1_stratified logsurv = CoxSnell;
run;
data cancer1_stratified;
   set cancer1_stratified;
   CoxSnell = -CoxSnell;   
   label CoxSnell = 'Cox-Snell Residual';
run;
proc sort data = cancer1_stratified; by race;
proc phreg data = cancer1_stratified noprint;
   model CoxSnell * status(0) = ;   
   output out = cancer1_stratified2 logsurv = haz / method = ch;
   by race;
run;
data cancer1_stratified2;
   set cancer1_stratified2;
   haz = -haz;
   label haz = 'Estimated Cumulative Hazard Rate';
run;
proc sort data = cancer1_stratified2; by CoxSnell;
proc sgplot data = cancer1_stratified2;
   step x = CoxSnell y = haz / group = race; 
   lineparm x=0 y=0 slope=1;
   xaxis label = 'Cox-Snell Residual';
   yaxis label = 'Estimated Cumulative Hazard Rate';
run;

/***** deviance residuals *****/
proc phreg data = cancer1;
 class  side(ref='0') gender(ref='0') marriage(ref='1') race(ref='0');
 model month*status(0)= size side marriage gender logage nodes extension;
 logage=log(agediag+1);
 output out = fitted1 resmart = mgale resdev = resdev xbeta = risk;
run;
proc sgplot data = fitted1; 
   scatter x = risk y = mgale;
run;
proc sgplot data = fitted1; 
   scatter x = risk y = resdev;
run;/*doesn't have any outlier*/

