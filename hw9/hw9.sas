/* get data */
LIBNAME f_path "/home/u63563888/435";

DATA data;
	SET f_path.bladder_data;
	
	/* numeric treatment values */
	IF Treatment = "Placebo" THEN treat_num = 1;
	ELSE treat_num = 2;
RUN;

/* sort data so that placebo is reference group */
PROC SORT DATA=data;
	BY DESCENDING treat_num;
RUN;


ods graphics on;
ods pdf file="/home/u63563888/435/homework9/hw9_model_output.pdf";

/* parametric model */
PROC LIFEREG DATA = data ORDER = data;
	CLASS treatment;
	MODEL time*status(0) = init size treatment / 
			COVB DIST = weibull;
RUN;

ods pdf close;
ods graphics off;


/* dataset to get hazard ratio and 95% CI */
DATA temp;
	LENGTH statistic $ 10;
	INPUT statistic value;
	DATALINES;
		estimate 0.7859
		conf_one -0.0025
		conf_two 1.5744
	;
RUN;

DATA haz_vals;
	SET temp;
	beta = -value / 1.2839;
	haz_ratio = exp(beta);
RUN;

ods pdf file="/home/u63563888/435/homework9/hr_calc_data.pdf";
PROC PRINT DATA = haz_vals; RUN;
ods pdf close;


/*
From the Weibull proportional hazards model, we got a hazard
ratio of 0.54 if a patient is given the thiotepa treatment
rather than the placebo, with a 95% confidence interval of
(0.29, 1.00). This means that  if a patient received the 
thiotepa treatment, they are 46% less likely to die than if 
they had been given the placebo. Additionally, since the 
interval is pretty much fully under 1, we can conclude with 95%
confidence that the thiotepa treatment reduces risk of death
overall compared to the placebo.
*/

