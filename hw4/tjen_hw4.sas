/* load data */
DATA data;
	INFILE "/home/u63563888/435/homework4/myeloma.dat";
	INPUT patient_num survival_time status age 
			sex Bun Ca Hb Pcells Protein;
			
	/* convert sex values (1 and 2) to is_male */
	IF sex = 1 THEN is_male = 1;
	ELSE is_male = 0;
	
	DROP patient_num sex;
RUN;


/* forward selection */
PROC PHREG DATA = data;
	MODEL survival_time * status(0) = 
			age is_male Bun Ca Hb Pcells Protein 
			/ SELECTION = FORWARD;
RUN;


/* backward selection */
PROC PHREG DATA = data;
	MODEL survival_time * status(0) = 
			age is_male Bun Ca Hb Pcells Protein 
			/ SELECTION = BACKWARD;
RUN;


/* stepwise selection */
PROC PHREG DATA = data;
	MODEL survival_time * status(0) = 
			age is_male Bun Ca Hb Pcells Protein 
			/ SELECTION = STEPWISE;
RUN;
