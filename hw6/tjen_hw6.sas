/* load data */
DATA data;
	INFILE "/home/u63563888/435/homework6/prostat.dat";
	INPUT patient_id treatment survival_time status 
			age serum_haem tumour_size gleason_index;
RUN;


/* ****************************** */
/* COX-SNELL RESIDUALS */
/* ****************************** */

/* final model */
PROC PHREG DATA = data;
	CLASS treatment;
	MODEL survival_time*status(0) = 
			tumour_size gleason_index treatment;
	OUTPUT OUT = cox_phreg LOGSURV = val_cox / METHOD = ch;
RUN;

DATA cox_data;
	SET cox_phreg;
	cox_resid = -val_cox;
RUN;


/* kaplan meier */
PROC LIFETEST DATA = cox_data METHOD = km OUTSURV = cox_km;
	TIME cox_resid * status(0);
RUN;

/* filter data */
DATA cox_filtered;
	SET cox_km;
	IF cox_resid = 0 or survival = 0 THEN delete; 
	
	KEEP cox_resid survival;
RUN;

/* get cumulative hazard */
DATA cox_w_haz;
	SET cox_filtered;
	h = -log(survival);
	DROP survival;
RUN;


/* plot */
ods graphics on;
ods pdf file="/home/u63563888/435/homework6/hw6_cox_graph.pdf";

goptions ROTATE=LANDSCAPE;
axis1 label=(h=2 f=swiss 'Cox-Snell Residual Value');
axis2 label=(h=2 f=swiss a=90 'Cumulative Hazard of Residual');
title 'Cox-Snell Residuals Plot';
PROC GPLOT DATA = cox_w_haz;
      PLOT h*cox_resid h*h / overlay vaxis=axis2 haxis=axis1;
      symbol1 interpol=j h=1 l=2 v=square  c=black;
      symbol2 interpol=j;
RUN; 

ods pdf close;
ods graphics off;


/* ****************************** */
/* MARTINGALE RESIDUALS */
/* ****************************** */

/* final model */
PROC PHREG DATA = data;
	CLASS treatment;
	MODEL survival_time*status(0) = 
			tumour_size gleason_index treatment;
	OUTPUT OUT = mart_phreg RESMART = val_mart;
RUN;

/* plots */
ods graphics on;
ods pdf file="/home/u63563888/435/homework6/hw6_mart_graph.pdf";

PROC SGPLOT DATA = mart_phreg;
	LOESS Y=val_mart X=tumour_size;
	TITLE "Martingale Residual Plot for Tumour Size";
RUN;

PROC SGPLOT DATA = mart_phreg;
	LOESS Y=val_mart X=gleason_index;
	TITLE "Martingale Residual Plot for Gleason Index";
RUN;

PROC SGPLOT DATA = mart_phreg;
	LOESS Y=val_mart X=treatment;
	TITLE "Martingale Residual Plot for Treatment";
RUN;

ods pdf close;
ods graphics off;


/* ****************************** */
/* SCHOENFELD RESIDUALS */
/* ****************************** */

/* final model */
PROC PHREG DATA = data;
	CLASS treatment;
	MODEL survival_time*status(0) = 
			tumour_size gleason_index treatment;
	OUTPUT OUT = sch_phreg 
			RESSCH = val_sch_tumour val_sch_gleason val_sch_treat;
RUN;


/* kaplan meier for treatment (categorical) */
PROC LIFETEST DATA = data METHOD = km OUTSURV = sch_treat;
	TIME survival_time * status(0);
	TEST tumour_size gleason_index treatment;
RUN;

DATA sch_vals;
	SET sch_treat(KEEP = survival_time survival);
	logT = log(survival_time);
	logLogSurv = log(-log(survival));
RUN;


/* plot */
ods graphics on;
ods pdf file="/home/u63563888/435/homework6/hw6_sch_graph.pdf";

PROC SGPLOT DATA = sch_phreg;
	SCATTER Y=val_sch_tumour X=survival_time;
	REFLINE 0 / AXIS = y LINEATTRS = (COLOR = red PATTERN = dot);
	TITLE "Schoenfeld Residual Plot for Tumour Size";
RUN;


PROC SGPLOT DATA = sch_phreg;
	SCATTER Y=val_sch_gleason X=survival_time;
	REFLINE 0 / AXIS = y LINEATTRS = (COLOR = red PATTERN = dot);
	TITLE "Schoenfeld Residual Plot for Gleason Index";
RUN;


PROC SGPLOT DATA = sch_vals;
	SERIES x=survival_time y=logT;
	SERIES x=survival_time y=logLogSurv;
	TITLE "Schoenfeld Residual Plot for Treatment";
	YAXIS LABEL="Value";
RUN;

ods pdf close;
ods graphics off;


/* ****************************** */
/* TABLE OF RESIDUALS */
/* ****************************** */

DATA residuals;
	MERGE cox_data (KEEP = patient_id cox_resid)
			mart_phreg (KEEP = patient_id val_mart)
			sch_phreg (KEEP = patient_id val_sch_tumour 
											val_sch_gleason 
											val_sch_treat);
	BY patient_id;
RUN;

ods pdf file="/home/u63563888/435/homework6/residual_data.pdf";
PROC PRINT DATA = residuals; RUN;
ods pdf close;
