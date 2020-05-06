version 16.1

// Obtain the sample size (before imputation).
local sample_size = _N

// Set up the imputation and the roles of the variables.
mi set mlong

//mi register passive $passives
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
                  add(20) 

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
global passives $passives y

// Verify that we can correctly recompute the composite outcome using the
// original (non-imputed) data.
count if y == TrialOne_adverse_pregoutc & _mi_m == 0
assert r(N) == `sample_size'

// Fit a mixed-effects logistic regression model. Note that we have to use the
// option cmdok to force Stata to fit the model. As documented at the following,
// the coefficients, constant, and their CIs, and the variance components will be
// appropriately estimated, but the CIs for the variance components may not be
// correct. See https://www.statalist.org/forums/forum/general-stata-discussion/general/1349542-mi-estimate-melogit-is-it-legit
mi estimate, or cmdok: melogit y i.arm i.strat_var || clusterid:

// TODO: The protocol says that a GEE will be used. See if we can do this within
// MI.

// TODO: Note that if we replace arm with i.arm, the model does not fit but gives
// identical or very similar estimates. I.e., there is a problem that gets
// introduced when we convert arm into an indicator. The estimates for the two
// approaches are identical except for the constant term, whose CI is slightly
// wider under the arm (rather than i.arm) approach. The interpretation of the
// arm coefficient is that it is the OR for a unit increase in "arm", i.e.,
// it corresponds to the arm=2 (the D condition). So, perhaps rename the
// variable to be something like "treat_D".

