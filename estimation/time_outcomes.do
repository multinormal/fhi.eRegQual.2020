version 16.1

frame time {
  foreach y of global time_outcomes {
      mixed `y' i.arm $time_adj_vars || clusterid:
      assert e(converged) == 1
      estimates store `y'_estimates
  }
}
