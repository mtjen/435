/* load data */
DATA data;
	INFILE "/home/u63563888/435/homework3/bladder.dat";
	INPUT patient time status treat init size;
	DROP patient treat init size; 
	If _N_ = 1 THEN delete;		/* row of blank values */
	
	/* make treatment values more descriptive */
	LENGTH Treatment $ 8;
	IF treat = 1 THEN Treatment = "Placebo";
	ELSE Treatment = "Thiotepa";
RUN;


/* kaplan meier plot */
ods graphics on;
ods pdf file= "/home/u63563888/435/homework3/hw3_save.pdf";
ods select survivalPlot;

PROC LIFETEST DATA=data PLOTS=survival(test atrisk) METHOD=km;
	STRATA Treatment / TEST = logrank;
	TIME time * status(0);
RUN;

ods pdf close;
ods graphics off;



/* log rank p-value analysis */
/* The log-rank p-value is 0.2175, which means that there
	is not a statistically detectable difference in survival 
	probability between the group that received the placebo 
	treatment and the group that received the thiotepa
	treatment */

	

/* export dataset */
LIBNAME exp_path "~/435/";

DATA whole_data;
	INFILE "/home/u63563888/435/homework3/bladder.dat";
	INPUT patient time status treat init size;
	If _N_ = 1 THEN delete;		/* row of blank values */
	
	/* make treatment values more descriptive */
	LENGTH treatment $ 8;
	IF treat = 1 THEN Treatment = "Placebo";
	ELSE Treatment = "Thiotepa";
	
	DROP treat;
RUN;

DATA exp_path.bladder_data;
	SET whole_data;
RUN;

