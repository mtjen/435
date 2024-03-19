/* load data */
DATA data;
	INFILE "/home/u63563888/435/homework6/prostat.dat";
	INPUT patient_id treatment survival_time status 
			age serum_haem tumour_size gleason_index;
RUN;


/* final model */
PROC PHREG DATA = data;
	CLASS treatment;
	MODEL survival_time*status(0) = 
			tumour_size gleason_index treatment;
	OUTPUT OUT = phreg_out DFBETA = dfbSize dfbIndex dfbTreat LMAX = lmax;
RUN;


/* rank by survival time */
PROC RANK DATA = phreg_out (DROP = status age serum_haem) 
			OUT = ranked_data; 
	VAR survival_time;
	RANKS surv_rank;
RUN;


/* plot */
ods graphics on;
goptions ROTATE=LANDSCAPE;

ods pdf file="/home/u63563888/435/homework7/hw7_lMax_plots.pdf";

PROC GPLOT DATA = ranked_data;
	TITLE "L-Max Plots";
	BUBBLE lmax*surv_rank=patient_id / BLABEL BSIZE=1 BCOLOR=bib;
	BUBBLE lmax*tumour_size=patient_id / BLABEL BSIZE=1 BCOLOR=bib;
	BUBBLE lmax*gleason_index=patient_id / BLABEL BSIZE=1 BCOLOR=bib;
	BUBBLE lmax*treatment=patient_id / BLABEL BSIZE=1 BCOLOR=bib;
RUN; QUIT;

ods pdf file="/home/u63563888/435/homework7/hw7_deltaBeta_plots.pdf";

PROC GPLOT DATA = ranked_data;
	TITLE "Delta-Beta Index Plots by Covariate";
	BUBBLE dfbSize*surv_rank=patient_id / BLABEL BSIZE=1 BCOLOR=bib;
	BUBBLE dfbIndex*surv_rank=patient_id / BLABEL BSIZE=1 BCOLOR=bib;
	BUBBLE dfbTreat*surv_rank=patient_id / BLABEL BSIZE=1 BCOLOR=bib;
RUN; QUIT;

ods pdf close;
ods graphics off;


ods pdf file="/home/u63563888/435/homework7/ranked_data.pdf";
PROC PRINT DATA = ranked_data; RUN;
ods pdf close;
