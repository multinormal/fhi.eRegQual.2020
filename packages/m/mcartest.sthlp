{smcl}
{* version 1.0.0  27Aug2012}{...}
{cmd:help mcartest}{right: ({browse "http://www.stata-journal.com/article.html?article=st0318":SJ13-4: st0318})}
{hline}

{title:Title}

{p2colset 5 17 19 2}{...}
{p2col :{hi:mcartest} {hline 2}}Little's chi-squared test for MCAR or CDM{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{phang}Test for missing completely at random (MCAR)

{p 8 17 2}{cmd:mcartest} {it:{help varlist:depvars}} {ifin} [{cmd:,} {opt nocon:stant}
{opt un:equal} {opt emout:put} {it:{help mi_impute_mvn##em_opts:em_options}}]

{phang}Test for covariate-dependent missingness (CDM)

{p 8 17 2}{cmd:mcartest} {it:{help depvars}} {cmd:=} {it:{help indepvars}} {ifin} [{cmd:,}
{opt nocon:stant} {opt un:equal} {opt emout:put} {it:{help mi_impute_mvn##em_opts:em_options}}]


{marker description}{...}
{title:Description}

{pstd}{cmd:mcartest} performs Little's chi-squared test for the MCAR
assumption and accommodates arbitrary missing-value patterns.
{it:depvars} contains a list of variables with missing values to be
tested.  {it:depvars} requires at least two variables.  {it:indepvars}
contains a list of covariates.  When {it:indepvars} are specified,
{cmd:mcartest} tests the CDM assumption for {it:depvars} conditional on
{it:indepvars} (see {help mcartest##L1988:Little [1995]}).  The test
statistic uses multivariate normal estimates from the
expectation-maximization (EM) algorithm (see {helpb mi impute mvn}).
The {cmd:unequal} option performs Little's augmented chi-squared test,
which allows unequal variances between missing-value patterns.  See
{help mcartest##L1988:Little (1988)} for details.


{marker options}{...}
{title:Options}

{phang}{opt noconstant} suppresses constant term.

{phang}{opt unequal} specifies that unequal variances between
missing-value patterns be allowed.  By default, the test assumes equal
variances between different missing-value patterns.

{phang}{opt emoutput} specifies that intermediate output from EM
estimation be displayed.

{phang}{it:{help mi_impute_mvn##em_opts:em_options}} specifies the
options in EM algorithm; see {helpb mi impute mvn}.


{marker examples}{...}
{title:Examples:  Testing MCAR and CDM assumptions}

{pstd}Fictional blood-test data{p_end}
{phang2}{cmd:. use bloodtest}{p_end}

{pstd}Show the missing-value patterns of the data{p_end}
{phang2}{cmd:. misstable summarize}{p_end}
{phang2}{cmd:. misstable pattern, freq}{p_end}

{pstd}Test if {cmd:chol}, {cmd:trig}, {cmd:diasbp}, and {cmd:sysbp} are
jointly MCAR; use 200 iterations in the EM algorithm, and display its
output{p_end}
{phang2}{cmd:. mcartest chol trig diasbp sysbp, emoutput nolog iterate(200)}{p_end}

{pstd}Test MCAR using unequal variances between missing-value
patterns{p_end}
{phang2}{cmd:. mcartest chol trig diasbp sysbp, unequal}{p_end}

{pstd}Test whether {cmd:chol}, {cmd:trig}, {cmd:diasbp}, and {cmd:sysbp}
are jointly CDM given all the covariates{p_end}
{phang2}{cmd:. mcartest chol trig diasbp sysbp = weight height exercise i.age i.female i.alcohol i.smoking}{p_end}


{marker stored_results}{...}
{title:Stored results}

{pstd}{cmd:mcartest} stores the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(N)}}number of observations{p_end}
{synopt:{cmd:r(N_S_em)}}number of unique missing-value patterns{p_end}
{synopt:{cmd:r(chi2)}}Little's chi-squared statistic{p_end}
{synopt:{cmd:r(df)}}chi-squared degrees of freedom{p_end}
{synopt:{cmd:r(p)}}chi-squared p-value{p_end}
{p2colreset}{...}


{marker references}{...}
{title:References}

{marker L1988}{...}
{phang}Little, R. J. A.  1988.  A test of missing completely at random for
multivariate data with missing values.
{it:Journal of the American Statistical Association} 83: 1198-1202.

{marker L1995}{...}
{phang}--------.  1995.  Modeling the drop-out mechanism in
repeated-measures studies.
{it:Journal of the American Statistical Association} 90: 1112-1121.


{title:Author}

{pstd}Cheng Li{p_end}
{pstd}Northwestern University{p_end}
{pstd}Evanston, IL{p_end}
{pstd}chengli2014@u.northwestern.edu{p_end}


{title:Also see}

{p 4 14 2}Article:  {it:Stata Journal}, volume 13, number 4: {browse "http://www.stata-journal.com/article.html?article=st0318":st0318}{p_end}
