version 16.1

frame imputed {
  // Estimate population averaged effects using a GEE. This is the planned
  // analysis.
  mi xtset clusterid
  mi estimate, eform: xtgee y i.arm i.strat_var, family(binomial) link(logit)

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
}


