version 16.1

frame time {
  foreach y of global time_outcomes {
      //mixed `y' i.arm $time_adj_vars || observer:, vce(cluster clusterid)
      mixed `y' i.arm $time_adj_vars || clusterid: || observer:
      // TODO: The above non-commented code seems fine, and gives identical
      // estimates to the opposite order of the random effects, but runs faster.
      estimates store `y'_estimates
  }
}
