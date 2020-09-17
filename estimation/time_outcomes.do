version 16.1

frame time {
  foreach y of global time_outcomes {
      mixed `y' i.arm $time_adj_vars || clusterid: || observer:
      estimates store `y'_estimates
  }
}
