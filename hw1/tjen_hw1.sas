/* import data */
PROC IMPORT DATAFILE = '~/435/homework1/nsclc.xls'
	OUT = data
	DBMS = xls
    REPLACE;
    SHEET = 'Sheet1';
RUN;


/* calculate survival times */
DATA surv_data;
	SET data;
	
	/* overall survival */
	IF dod ^= . THEN DO;
		os = dod - dotx;
		os_censor_flag = 1;
	END;
	ELSE DO;
		os = dols - dotx;
		os_censor_flag = 0;
	END;
	
	/* progression free survival */
	IF dop ^= . THEN DO;		/* know date of progression */
		pfs = dop - dotx;
		pfs_censor_flag = 1;
	END;
	ELSE IF dod ^= . THEN DO;   /* know date of death */
		pfs = dod - dotx;
		pfs_censor_flag = 1;
	END;
	ELSE DO;							
		pfs = dols - dotx;
		pfs_censor_flag = 0;
	END;
RUN;


/* export merged dataset */
LIBNAME exp_path "~/435/";

DATA exp_path.surv_data;
	SET surv_data;
RUN;

