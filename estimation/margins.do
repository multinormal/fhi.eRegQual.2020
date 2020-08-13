version 16.1

// Define the names and number of variables over which to compute margins.
local margin_vars = ustrtrim(usubinstr("$adj_var_names", "strat_var", "", .))

foreach outcome of global process_outcomes {
  frame `outcome' {
    foreach var of local margin_vars {
      estimates restore `outcome'_estimates
      // If var is a factor, we use the following syntax, otherwise we 
      // specialize for the continuous variables.
      local margins margins `var'#i.arm, post
      if "`var'" == "cluster_size" {
        local margins margins i.arm, at(cluster_size = (0.1 1 2)) post
      }
      if "`var'" == "age" {
        local margins margins i.arm, at(age = (15(10)45)) post
      }
      
      // Compute and store the margins.
      `margins'
      estimates store `var'_margins
    }
  }
}
