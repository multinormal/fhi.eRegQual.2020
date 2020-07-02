version 16.1

foreach outcome of global process_outcomes {
  frame `outcome' {
    local vce_opts vce(cluster clusterid)
    if "`outcome'" == "malpresentation" local vce_opts ""
    xtlogit y i.arm $adj_vars, `vce_opts' or
    estimates store `outcome'_estimates
  }
}
