version 16.1

// Specify the covariates.
local covars i.arm i.strat_var

frame attendance {
  xtlogit y `covars', vce(cluster clusterid) or

  // TODO: Note that in the trial (including for the health outcome), stratified
  // randomization with constraints was used. The paper below provides some
  // evidence that in addition to the stratification variable, the variables
  // used as constraints should be adjusted for, *especially if they are likely
  // prognostic*. Ideally, the adjustment should be performed for values of the
  // variables measured at the level of the individual, not the cluster. The
  // variables use as constraints were: lab, US, clinic size, prop. 
  // new mothers aged > 40 years, and prop periparous? women. 
  // See the papers mentioned in 
  // https://aheblog.com/2019/05/08/method-of-the-month-constrained-randomisation/

  estimates store attendance_estimates
}