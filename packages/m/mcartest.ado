* version 1.0.0	27Aug2012

program mcartest
	version 12
	tempname esthold
	_estimates hold `esthold', restore nullok
	// create and init. main class object
	cap noi {
		mata: u_mi_get_mata_instanced_var("EMObj","mcar_em_obj")
		mata: `EMObj' = _EM_Norm()
		mcartest_work `EMObj' `0'
	}
	local rc = _rc
	cap mata: mata drop `EMObj'
	if _rc {
		exit _rc
	}
	else {
		exit `rc'
	}
end

program mcartest_work, rclass

	gettoken emobj 0 : 0
	syntax [anything(equalok)] [if] [in] [,		/// 
			NOCONstant 			///
			UNequal 			///
			EMOUTput			///
			ITERate(integer 100)		/// //emopts
			TOLerance(real 1e-5)		///
			INIT(string)			///
			NOLOG				///
			MISSing				///
			SAVEPtrace(string asis)		///
			NOCHECKPD			/// //passthru, undoc.
]

	gettoken depvars aftereq: anything, parse("=")
	_fv_check_depvar `depvars'
	unab depvars : `depvars'
	confirm numeric variable `depvars'
	local numdep: word count `depvars'
	gettoken eq indepvars: aftereq, parse("=")
	
	tempvar touse touse2 one
	mark `touse' `if' `in'
	markout `touse' `depvars', sysmissok
	qui count if `touse'
	local N1 `r(N)'
	markout `touse' `indepvars' 
	qui count if `touse'
	local N2 `r(N)'
	if `N2'==0 {
		di as err "no observations found"
		exit 2000
	}
	local Ndrop_cov `N1'-`N2'
	if `Ndrop_cov'>1 {
		di as txt "note: " `Ndrop_cov' as txt " observations omitted" ///
			      " in the test because of covariates missing" 
	}
	else if `Ndrop_cov'==1 {
		di as txt "note: 1 observation omitted in the test" ///
			      " because of covariates missing" 
	}
	
	// check colinearity in dependent variables	
	mark `touse2' if `touse'
	markout `touse2' `depvars'
	qui count if `touse2'
	if `r(N)'>0 {
		_rmcoll `depvars' if `touse2'
		if `r(k_omitted)' {
			di as err "{bf:mcartest:} collinear dependent variables detected"
			exit 498
		}
	}
	
	// expand factor variables in covariates
	if "`indepvars'"!="" {
		fvunab indepvars: `indepvars'
		local 0 `indepvars'
		syntax varlist(fv) //default=none 
		fvexpand `varlist' if `touse'
		_rmcoll `r(varlist)' if `touse', `noconstant'
		local indepvars `r(varlist)'
	}
	else if "`noconstant'"!=""{
		di as err "{bf:noconstant} is not allowed without independent variables"
		exit 198
	}
	
	qui gen byte `one' = 1 if `touse' & "`noconstant'"==""
	
	// check <emopts>
	if (`tolerance'<0) {
		di as err "{bf:tolerance()} must be a nonnegative number"
		exit 198
	}
	InitParse em, `init' name("init()")
	mata: `emobj'.emInit.type = "`s(init)'"
	// saveptrace()
	if (`"`saveptrace'"'!="") {
		_savingopt_parse emcfilename emcreplace : ///
			saveptrace ".stptrace" `"`saveptrace'"'
		if ("`emcreplace'"=="") {
			confirm new file `"`emcfilename'"'
		}
	}
	if ("`emoutput'"=="") {
		local nolog nolog
	}

	mata:	`emobj'.init_opts(); ///
			`emobj'.init("`depvars'","`indepvars'","`one'","`touse'");
	
	// check chi2 df before EM
	mata:	st_local("nmvpat",strofreal(`emobj'.nmvpat))
	mata:	st_numscalar("sumpat",sum(`emobj'.nVarspat))
	if ((`nmvpat'-1)*`numdep'<=sumpat) {
		di as err "insufficient degrees of freedom for chi-square test"
		exit 198
	}
	
	mata:	`emobj'.em_mvreg("`nolog'"!="", 0)
	mata:	`emobj'.post_results("")
	
	if ("`emoutput'"!="") {
		mata: `emobj'.print()
	}
	mata: st_local("emconverged",strofreal(`emobj'.emconverged))

	if `emconverged'!=1 & "`emoutput'"=="" {
		di _newline as txt "{help j_miemnc:EM did not converge.}"
	}
	
	mata:	mcartest("`depvars'", "`indepvars'", "`touse'", ///
			         "`unequal'", "`noconstant'", ///
				     `emobj'.emBeta, `emobj'.emSigma, ///
		             `emobj'.nmvpat, `emobj'.MvpatInfo, `emobj'.sortid, ///
		             `emobj'.pIobs, ///
		             `emobj'.nVarspat, `emobj'.VarsOrdered, `emobj'.orderid ///
			)


	if "`unequal'"!="" & "`indepvars'"=="" {
		display _newline as txt ///
		"Little's MCAR test with unequal variances"
	}
	else if "`unequal'"=="" & "`indepvars'"==""{
		display _newline as txt ///
		"Little's MCAR test"
	}
	else if "`unequal'"!="" & "`indepvars'"!=""{
		display _newline as txt ///
		"Little's CDM test with unequal variances"
	}
	else {
		display _newline as txt ///
		"Little's CDM test"
	}
		
	display "" 
	display as txt "Number of obs       = " ///
			as res `Nobs'
	display as txt "Chi-square distance = " ///
			as res %-12.4f `d2'
	display as txt "Degrees of freedom  = " ///
			as res `df'
	display as txt "Prob > chi-square   = " /// 
		    as res %5.4f `pval'

	return scalar p=`pval'
	return scalar df=`df'
	return scalar chi2=`d2'
	return scalar N_S_em=`nmvpat'
	return scalar N=`Nobs'
end


program InitParse, sclass

	syntax [anything(name=method)] [, * ]
	if ("`method'"=="em") {
		local ADDOPTS ac cc
		local default ac
	}
	else if ("`method'"=="da") {
		local ADDOPTS em
		local default em
	}
	else {
		di as err "InitParse:  unknown method {bf:`method'}"
		exit 198
	}
	sret clear

	local 0 , `options' 
	syntax [,			///
			Betas(string)	///
			SDs(string)	///
			VARs(string)	///
			COV(string)	///
			CORR(string)	///
			`ADDOPTS'	///
			NAME(string) 	///
		  	* 		/// //options
		]

	if ("`name'"=="") {
		local name init()
	}

	if ("`options'"!="") {
		di as err as smcl "`name':  {bf:`options'} not allowed"
		exit 198
	}	
	local opts `betas'`sds'`cov'`corr'`vars'
	local addopts `cc'`ac'`em'

	if ("`addopts'`opts'"=="") {
		sret local init "`default'"
		exit 0
	}
	
	if ("`addopts'"!="") {
		if ("`cc'"!="" & "`ac'"!="") {
			di as err as smcl ///
				"`name':  {bf:cc} and {bf:ac} cannot " ///
				"be combined"
			exit 198
		}
		if ("`opts'"!="") {
			di as err as smcl ///
				"`name':  {bf:`addopts'} cannot be " ///
				"combined with other {bf:`name'}'s suboptions"
			exit 198
		}
		sret local init "`addopts'"
		exit 0
	}
	if ("`cov'"!="" & ("`sds'`vars'`corr'"!="")) {
		di as err as smcl "`name':  {bf:cov()} cannot be "	///
		   "combined with {bf:sds()}, {bf:vars()} or {bf:corr()}"
		exit 198
	}
	if ("`sds'"!="" & "`vars'"!="") {
		di as err as smcl "`name':  {bf:sds()} and {bf:vars()}" ///
			"cannot be combined"
		exit 198
	}
	sreturn local init "user"
end


version 12
mata:

void mcartest(string scalar varname, string scalar indepvars,  ///
			 string scalar touse, string scalar unequal, ///
			 string scalar noconstant, real matrix beta, ///
			 real matrix sigma, real scalar nmvpat, ///
			 real matrix MvpatInfo, real colvector sortid,	///
			 pointer(real rowvector) rowvector pIobs,	///
			 real rowvector nVarspat, string scalar VarsOrdered, ///
			 real rowvector orderid
			 )	
{	
	st_view(Y=.,.,VarsOrdered)
	N = rows(Y)
	p = cols(Y)
	if (indepvars=="") {
		X = J(N,1,1)
	}
	else {
		st_view(X=.,.,indepvars)
		if (noconstant=="") {
			X = X,J(N,1,1)
		}
	}
	numcov = rank(X[sortid,])
	
	// rearrange beta and sigma 
	beta = beta[,orderid]
	sigma = sigma[orderid,orderid]

	// sortid stores the original indices, not adjusted for the omitted 
	Nobs=rows(sortid)
	pat_len = p:- nVarspat
	
	/* calculate the d^2 distance */
	d2 = 0
	
	if (unequal=="") {		   // equal variance
		sigma = sigma*Nobs/(Nobs-numcov)
		for (j=1;j<=nmvpat;j++) {   // loop over patterns
			rowind = sortid[MvpatInfo[j,1]..MvpatInfo[j,2]]'
			yind = (*pIobs[j])
			nj = length(rowind)
			sigmaj = sigma[yind,yind]
			delta = invsym(cross(X[rowind,],X[rowind,]))*cross(X[rowind,], ///
			      Y[rowind,yind])-beta[,yind]
		    W_pat = delta*invsym(sigmaj)*delta'
			
			for (i=1;i<=nj;i++) {
				d2 = d2+X[rowind[i],]*W_pat*X[rowind[i],]'
			}
		}
		df = (sum(pat_len)-p)*numcov
	}
	else {					   // unequal variances
		for (j=1;j<=nmvpat;j++) {   // loop over patterns
			rowind = sortid[MvpatInfo[j,1]..MvpatInfo[j,2]]'
			yind = (*pIobs[j])
			nj = length(rowind)
			sigmaj = sigma[yind,yind]
			betaj = invsym(cross(X[rowind,],X[rowind,]))*cross(X[rowind,],Y[rowind,yind])
			delta = betaj-beta[,yind]
			residj = Y[rowind,yind]-X[rowind,]*betaj
			Sj = cross(residj,residj):/nj
			
			if (diag0cnt(invsym(Sj))>0) {
				errprintf("sample covariance matrix is singular")
				errprintf(" for at least one missing-value pattern\n")
				exit(498)
			}
		    W_pat = delta*invsym(sigmaj)*delta'
		
			for (i=1;i<=nj;i++) {
				d2=d2+X[rowind[i],]*W_pat*X[rowind[i],]'
			}
			d2 = d2+(trace(Sj*invsym(sigmaj))- pat_len[j]- ///
			     log(det(Sj))+log(det(sigmaj)))*nj
		}
		df = sum(pat_len:^2)/2+sum(pat_len)/2-p*(p+1)/2+ ///
		    (sum(pat_len)-p)*numcov
	}
	
	pval=chi2tail(df,d2)
		   
	/* return values */
	st_local("Nobs",strofreal(Nobs)) 
	st_local("d2",strofreal(d2))
	st_local("df",strofreal(df))
	st_local("pval",strofreal(pval))
}

end
