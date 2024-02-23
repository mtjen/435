/* load data */
DATA data;
	INFILE "/home/u63563888/435/homework5/kidney.dat";
	INPUT survival_time censor age neph;
	IF _N_ = 1 THEN delete;
	
	IF age = 2 THEN age2 = 1; ELSE age2 = 0; 
	IF age = 3 THEN age3 = 1; ELSE age3 = 0;
	
	DROP age;
RUN;


/* create cohorts */
DATA cohort_data;
	INPUT age2 age3 neph; 
	DATALINES;
	0 0 0     
	1 0 1		
;
RUN;    


/* calculate survival function */
PROC PHREG DATA = data;
	MODEL survival_time * censor(0) = 
			age2 age3 neph;
	BASELINE COVARIATES = cohort_data 
				OUT = predictions 
				SURVIVAL = S 
				LOWER = S_lower 
				UPPER = S_upper 
				/ nomean;
RUN;


/* generate data for plot */
DATA plot_data;
	SET predictions;
	LENGTH cohort $ 30;
	IF age2 = 0 and age3 = 0 and neph = 0 
		THEN cohort = "age<60 without a nephrectomy";
	ELSE IF age2 = 1 and age3 = 0 and neph = 1 
		THEN cohort = "60<=age<=70 with a nephrectomy";
RUN;


/* generate plot */
ods graphics on;
ods pdf file="/home/u63563888/435/homework5/hw5_graph.pdf";

goptions reset=all gunit = pct
			rotate=LANDSCAPE gsfmode=replace;

axis1 label=(a=90 "Survivor Function Estimate");
axis2 label=("Survival Time"); 
title "Expected Survival by Cohort";

PROC GPLOT DATA=plot_data;
	PLOT S * survival_time = cohort 
			/ VAXIS=axis1 HAXIS=axis2;
	SYMBOL1 INTERPOL=stepLJ VALUE=diamond COLOR=blue;
	SYMBOL2 INTERPOL=stepLJ VALUE=diamond COLOR=red;
RUN;

ods pdf close;
ods graphics off;

