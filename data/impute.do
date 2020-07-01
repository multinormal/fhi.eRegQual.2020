version 16.1

frame copy original imputed, replace
frame imputed {
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
  local adj_vars = "$adj_vars"
  local adj_vars = ustrtrim(usubinstr("`adj_vars'", "i.age_over_40", "", .))
    // Remove age_over_40 as we compute it below from imputed age.
  local adj_vars = ustrtrim(usubinstr("`adj_vars'", "i.primiparous", "", .))
    // Remove primiparous as it needs to be imputed.
  mi impute chained (regress)                                       $imputeds ///
                    (logit, noimputed include(`imputeds' `adj_vars')) y1-y5   ///
                    = i.arm i.lab_available i.us_available , /// c.cluster_size,    ///
                    augment add($m_imputations) 

  // Compute age over 40, which is based on age, which is imputed.
  mi passive: generate age_over_40 = age > 40
  label variable age_over_40 "Age"
  label define age_over_40_label 1 ">40 years" 0 "≤40 years"
  label values age_over_40 age_over_40_label

  // The composite outcome is defined as follows. If:
  // * All of the outcomes are false -> composite outcome is false;
  // * At least one of the outcomes is true -> composite outcome is true;
  // * One or more of the outcomes are missing and all others are false
  //   -> composite outcome is missing.
  tempvar all_false
  mi passive: generate `all_false' = ///
    (y1 == 0) & (y2 == 0) & (y3 == 0) & (y4 == 0) & (y5 == 0)
  tempvar one_true
  mi passive: generate `one_true'  = ///
    (y1 == 1) | (y2 == 1) | (y3 == 1) | (y4 == 1) | (y5 == 1)

  // Compute the composite outcome.
  mi passive: generate y = .
  mi passive: replace  y = 0 if `all_false'
  mi passive: replace  y = 1 if `one_true'
  label variable y "Adverse pregnancy outcome"

  // Verify that we can correctly recompute the composite outcome using the
  // original (non-imputed) data.
  count if y == TrialOne_adverse_pregoutc & _mi_m == 0
  assert r(N) == `sample_size'
}

