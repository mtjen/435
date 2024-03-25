/* get data */
LIBNAME f_path "/home/u63563888/435";

DATA data;
	SET f_path.bladder_data;
	
	IF Treatment = "Placebo" THEN treat = 1;
	ELSE treat = 2;
	
	WHERE time ^= 0; 
	/* gives issue to using log and PHREG already ignores */
RUN;


/* cox model tests for beta2 */
PROC PHREG DATA = data;
	CLASS treat;
	MODEL time*status(0) = init size treat treat_t;
	treat_t = treat*time;
RUN;

PROC PHREG DATA = data;
	CLASS treat;
	MODEL time*status(0) = init size treat treat_logt;
	treat_logt = treat*log(time);
RUN;


/*
	By using a Cox model and a suitable time-dependent variable 
to investigate the effect of treatment, we can test the 
assumption of proportional hazards with respect to 
all the covariates included in the model. 
	To find a suiteable time-dependent variable, we tried a 
couple versions for g(t). These two methods were to set 
g(t)=t and g(t)=log(t), with each not returning significant 
p-values for beta2 (the time dependent variable). 
	With both of these models though, the parameter estimate for 
beta2 was negative. This indicates that relative risk for 
treatment decreases with time. However, since neither test 
returned a significant p-value for beta2, we can determine that 
the proportional hazards assumption is not violated.
*/

