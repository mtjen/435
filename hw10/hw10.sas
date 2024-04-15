/* load data */
DATA data;
	INFILE "/home/u63563888/435/homework10/bmt.dat";
	INPUT patient time status rage dage type preg index gvhd;
	IF _N_ = 1 THEN delete;
RUN;


/* parametric model */
PROC LIFEREG DATA = data;
	CLASS type preg gvhd;
	MODEL time*status(0) = rage dage type preg index gvhd / 
							COVB DIST = weibull;
RUN;


/* get acceleration factors */
DATA temp;
	LENGTH estimate $ 15;
	INPUT estimate value;
	DATALINES;
		type_1_v_3 -2.9802
		type_2_v_3 -2.7947
		gvhd_0_v_1 2.9207
	;
RUN;

DATA accel;
	SET temp;
	rel_accel = exp(-value);
RUN;



/*
By running a Weibull AFT model, we saw that the p-values for 
model covariates were only significant for two variables:
type (type of leukemia) and gvhd (graft-versus-host disease status). 

We can use the formula exp(-alpha) to get relative acceleration 
factors. The alpha value for type 1 compared to type 3 is -2.9802, 
the alpha value for type 2 compared to type 3 is -2.7947, and the 
alpha value for not having gvhd compared to having it is 
2.9207. Using the previous formula, we get corresponding
relative acceleration factors of 19.7, 16.4, and 0.1 respectively.

This means that if all other variables are controlled, having 
type 1 leukemia (AML) instead of type 3 leukemia (CML) accelerates
chances of death by a factor of 19.7, having type 2 leukemia (all)
instead of type 3 leukemia accelerates chances of death by a factor
of 16.4, and not having graft-versus-host disease instead of 
having gvhd decreases chances of death by a factor of 10.
*/

