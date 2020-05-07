version 16.1

// Obtain the sample size (before imputation).
local sample_size = _N

// Set up the imputation and the roles of the variables.
mi set mlong
mi register imputed $imputeds y1-y5
mi register regular $regulars

// Perform imputation. Due to collinearity between the constituent outcome
// variables y1-y5, these variables are exluded as predictors for one another.
// This is achieved by specifying the noimputed option, followed by the include
// option that explicityly lists the imputed variables to include in the
// imputation model. Specifying the omit option did not work as expected. It was
// not possible to include other variables in the model for the constituent
// outcome variables, also due to collinearity.
mi impute chained (regress)                               $imputeds ///
                  (logit, noimputed include($imputeds))   y1-y5     ///
                  = i.arm i.lab_available i.us_available,           ///
                  add($m_imputations) 

// The composite outcome is defined as follows. If:
// * All of the outcomes are false -> composite outcome is false;
// * At least one of the outcomes is true -> composite outcome is true;
// * One or more of the outcomes are missing and all others are false
//   -> composite outcome is missing.
tempvar all_false
generate `all_false' = (y1 == 0) & (y2 == 0) & (y3 == 0) & (y4 == 0) & (y5 == 0)
tempvar one_true
generate `one_true'  = (y1 == 1) | (y2 == 1) | (y3 == 1) | (y4 == 1) | (y5 == 1)

generate y = .
replace  y = 0 if `all_false'
replace  y = 1 if `one_true'
label variable y "Adverse pregnancy outcome"

// Verify that we can correctly recompute the composite outcome using the
// original (non-imputed) data.
count if y == TrialOne_adverse_pregoutc & _mi_m == 0
assert r(N) == `sample_size'

// Estimate population averaged effects using a GEE. This is the planned
// analysis.
mi xtset clusterid
mi estimate, eform: xtgee y i.arm, family(binomial) link(logit)

// We cannot obtain the ICC from the GEE model, so fit a mixed-effects logistic
// mode. Note that we have to use the option cmdok to force Stata to fit the
// model. As documented at the following, the coefficients, constant, and their
// CIs, and the variance components will be appropriately estimated, but the CIs
// for the variance components may not be correct. See
// https://www.statalist.org/forums/forum/general-stata-discussion/general/1349542-mi-estimate-melogit-is-it-legit
//
// mi estimate, or cmdok: melogit y i.arm i.strat_var || clusterid:
// estat icc // TODO: Command not valid after imputation it seems, so estimate
// this from complete cases.
// TODO: Following the note above, the ICC may not be reliable...
