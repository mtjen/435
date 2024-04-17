/* load data */
DATA data;
	INFILE "/home/u63563888/435/homework10/bmt.dat";
	INPUT patient time status rage dage type preg index gvhd;
	
	IF type = 2 THEN is_type_two = 1; ELSE is_type_two = 0;
	IF type = 3 THEN is_type_three = 1; ELSE is_type_three = 0;
	
	IF _N_ = 1 THEN delete;
RUN;


ods graphics on;
ods pdf file="/home/u63563888/435/homework10/hw10_model_output.pdf";

/* parametric model */
PROC LIFEREG DATA = data;
	CLASS type preg gvhd;
	MODEL time*status(0) = rage dage is_type_two is_type_three 
							preg index gvhd / 
							COVB DIST = weibull;
RUN;

ods pdf close;
ods graphics off;


/* get acceleration factors */
DATA temp;
	LENGTH estimate $ 15;
	INPUT estimate value;
	DATALINES;
		type_three 2.9802
		gvhd_0 2.9207
	;
RUN;

DATA accel;
	SET temp;
	rel_accel = exp(-value);
	reduction = 1/rel_accel;
RUN;

ods pdf file="/home/u63563888/435/homework10/aft_vals.pdf";
PROC PRINT DATA = accel; RUN;
ods pdf close;


/*
By running a Weibull AFT model, we saw that the p-values for 
model covariates were only significant for two variables:
type 3 leukemia (CML) and gvhd (graft-versus-host disease status). 

We can use the formula exp(-alpha) to get relative acceleration 
factors. The alpha value for type 3 is 2.9802 and the 
alpha value for not having gvhd compared to having it is 
2.9207. Using the previous formula, we get corresponding
relative acceleration factors of 0.051 and 0.054 respectively.

This means that if all other variables are controlled, having 
type 3 leukemia instead of type 1 leukemia (AML) decreases
chances of death by a factor of 19.7 and not having 
graft-versus-host disease rather than having gvhd decreases 
chances of death by a factor of 18.6.
*/


