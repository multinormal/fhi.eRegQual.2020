version 16.1

// Specify the model.
local model xtlogit \`var' i.arm $adj_vars

// Compute the complete case estimate.
tempname original
frame copy imputed `original'
frame `original' {
  // Fit the model.
  mi extract 0, clear
  xtset clusterid
  local var y
  `model', or
  estimates store complete_case_estimates

  // Make globals containing key results.
  matrix result   = r(table)
  global cc_or_b  = result["b",      "`var':2.arm"]
  global cc_or_ll = result["ll",     "`var':2.arm"]
  global cc_or_ul = result["ul",     "`var':2.arm"]
  global cc_or_p  = result["pvalue", "`var':2.arm"]

  // Estimate ICC.
  loneway `var' clusterid
  global icc    = r(rho)
  global icc_lb = r(lb)
  global icc_ub = r(ub)
}

// Compute the multiply-imputed estimates.
tempname imputed
frame copy imputed `imputed'
frame `imputed' {
  mi xtset clusterid

  local mi_opts or errorok noisily // TODO: Remove noisily when imputation works
    // The errorok option is neeeded because, by chance, collinearity
    // can exist between the stratification variable and the dependent variable.
    // See the assert below, which specifies when this happens.

  foreach var of varlist y y1-y5 {
    local this_model "`model'"
    if "`var'" == "y2" {
      // For this variable, the stratification variable predicts outcome
      // perfectly for one of the districts in some imputations, resulting in 
      // it being dropped from analysis in some analyses of imputed data sets,
      // resulting in an error in mi estimate.
      local this_model = ustrtrim(usubinstr("`this_model'", "i.strat_var", "", .))
    }

    mi estimate, `mi_opts': `this_model'
    estimates store `var'_estimates

    // Verify that the anticipated imputations were used.
    if ("`var'" != "y2") assert e(M_mi) == $m_imputations
    if ("`var'" == "y2") assert e(M_mi) >=  0.7 * $m_imputations
    
    // Make globals containing key results.
    matrix result      = r(table)
    global rr_b_`var'  = result["b",      "`var':2.arm"]
    global rr_ll_`var' = result["ll",     "`var':2.arm"]
    global rr_ul_`var' = result["ul",     "`var':2.arm"]
    global rr_p_`var'  = result["pvalue", "`var':2.arm"]
  }
}

