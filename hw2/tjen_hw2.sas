/* load data */
DATA data;
  INFILE "/home/u63563888/435/homework2/cah.dat";
  INPUT treatment time status;
  If _N_ = 1 THEN delete;		/* row of blank values */
RUN;


/* kaplan meier */
PROC LIFETEST DATA=data PLOTS=(s) METHOD=km;
	BY treatment;
	TIME time * status(0);
RUN;