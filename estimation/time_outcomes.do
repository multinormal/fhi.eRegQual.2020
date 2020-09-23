version 16.1

local technique technique(bfgs 5 nr 5)

frame time {
  foreach y of global time_outcomes {
      mixed `y' i.arm $time_adj_vars || clusterid:
      assert e(converged) == 1
      estimates store `y'_estimates
  }
}
