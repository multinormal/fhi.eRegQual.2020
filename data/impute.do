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
  // It was not possible to include the stratification variable due to perfect
  // prediction (possibly too many variables in the models?)
  mi impute chained                                                    ///
    (regress)                           age bmi education log_income   ///
    (logit)                             primiparous                    ///
    (logit, omit(i.y2 i.y3 i.y4 i.y5))  y1                             ///
    (logit, omit(i.y1 i.y3 i.y4 i.y5))  y2                             ///
    (logit, omit(i.y1 i.y2 i.y4 i.y5))  y3                             ///
    (logit, omit(i.y1 i.y2 i.y3 i.y5))  y4                             ///
    (logit, omit(i.y1 i.y2 i.y3 i.y4))  y5                             ///
    = i.arm c.cluster_size i.us_available i.lab_available,             ///
    add($m_imputations)                                                ///
    rseed(1234)

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
  label values y yes_no_label

  // Verify that we can correctly recompute the composite outcome using the
  // original (non-imputed) data.
  count if y == TrialOne_adverse_pregoutc & _mi_m == 0
  assert r(N) == `sample_size'
}

