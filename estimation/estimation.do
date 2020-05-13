version 16.1

// Specify the model.
local covars     i.arm i.strat_var
local model_spec family(binomial) link(log) asis // See below for note on asis.
local model      xtgee \`var' `covars', `model_spec'

// Compute the complete case estimate.
tempname original
frame copy imputed `original'
frame `original' {
  // Fit the model.
  mi extract 0, clear
  xtset clusterid
  local var y
  `model' eform
  estimates store complete_case_estimates

  // Make globals containing key results.
  matrix result   = r(table)
  global cc_rr_b  = result["b",      "2.arm"]
  global cc_rr_ll = result["ll",     "2.arm"]
  global cc_rr_ul = result["ul",     "2.arm"]
  global cc_rr_p  = result["pvalue", "2.arm"]

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

  local mi_opts    eform errorok
    // The asis and errorok options are neeeded because, by chance, collinearity
    // can exist between the stratification variable and the dependent variable.
    // See the assert below, which specifies when this happens.

  foreach var of varlist y y1-y5 { 
    // Estimate population averaged effects using a GEE.
    mi estimate, `mi_opts': `model'
    estimates store `var'_estimates

    // Verify that the anticipated imputations were used.
    if ("`var'" != "y2") assert e(M_mi) == $m_imputations
    if ("`var'" == "y2") assert e(M_mi) >=  0.8 * $m_imputations
    // TODO: Is this necessary with the full set of imputations?
    
    // Make globals containing key results.
    matrix result      = r(table)
    global rr_b_`var'  = result["b",      "2.arm"]
    global rr_ll_`var' = result["ll",     "2.arm"]
    global rr_ul_`var' = result["ul",     "2.arm"]
    global rr_p_`var'  = result["pvalue", "2.arm"]
  }
}

