filename seer9 'I:\project\7780\RESPIR.TXT';

data in;
 infile seer9 lrecl=362;
 input 
  @1   PUBCSNUM           $char8./*patient ID*/
  @9   REG                $char10./*SEER registry*/
  @301 SRV_TIME_MON       $char4./*survival months*/
  @19  MAR_STAT           $char1./*marital Status at DX */
  @28  YR_BRTH            $char4./*year of birth*/
  @25  AGE_DX             $char3./*Age at Diagnosis*/
  @24  SEX                $char1./*gender of patient*/
  @20  RACE1V             $char2./*race of patient*/ 
  @47  LATERAL            $char1./*the initial side of tumor*/
  @61  EOD10_SZ	          $char3./*EOD-tumer size*/
  @64  EOD10_EX           $char2./*EOD-extension*/
  @71  EOD10_NE           $char2./*number of regional nodes examined*/
  @272 VSRTSADX           $char1./*SEER cause of death classification*/
  ;
proc contents data=in;run;

data clean;
 set in;
 month     =input(SRV_TIME_MON,4.);
 status    =input(VSRTSADX,1.);
 marriage  =input(MAR_STAT,1.);
 birth     =input(YR_BRTH,4.);
 agediag   =input(AGE_DX,3.);
 side      =input(LATERAL,1.);
 sex       =input(sex,1.);
 size      =input(EOD10_SZ,3.);
 extension =input(EOD10_EX,2.);
 nodes     =input(EOD10_NE,2.);
 if REG ='0000001527'; /*Atlanta*/
 if RACE1V='01' then white=1; else white=0;/*creat dummies for race*/
 if RACE1V='02' then black=1; else black=0;/*three race group, white,balck,other*/
 if sex='1'     then gender=1; else gender=0;/*dummy for sex, 1 stands for male*/
 if cmiss(of _all_) then delete;/*delete missing values*/
 keep month status marriage birth agediag side 
      gender white black size extension nodes;
proc contents data=clean;run;


data clean2;
set clean;
if month<9999;/*unknow with month greater than 9999*/
if agediag<998;/*known age*/
if marriage<3;/*only consider single and married*/
if status<2;/*live(death not because of cancer) or death*/
if side=0 or side=1 or side=2 or side=5;
/*no side, left, right, pair(midline)*/
if size NE 999;/*999 means unknown size*//*in */
if extension<100;/*allow values 00-99*/
if nodes<90;/*only consider exact number of nodes*/
run;

/*basic analysis*/
proc means data=clean2 n min max mean std;
 var agediag size extension nodes;
run;


proc export data=clean2 
dbms=csv outfile="I:\project\7780\cancer.csv" replace;
run;
