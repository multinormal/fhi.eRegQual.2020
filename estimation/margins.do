version 16.1

// Define the names of variables over which to compute margins.
local margin_vars = ustrtrim(usubinstr("$adj_var_names", "strat_var", "", .))

// Create an associative array to map between (outcome, variable) name pairs and
// corresponding names used to store margins estimates.
mata: margins_map = asarray_create("string")

// Define a program to query the associative array. The name used to store the
// margins estimates for the given outcome and variable is returned in
// r(estimates_name).
capture program drop margin_name
program margin_name, rclass
  args outcome var
  tempname ret_val
  mata: i = asarray(margins_map, "`outcome'_`var'")
  mata: st_local("`ret_val'", strofreal(i))
  return local estimates_name = "margins_``ret_val''"
end

local i = 1
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
      
      // Compute the margins.
      `margins'

      // Store the estimated results in the map.
      local name margins_`i'
      estimates store `name'
      mata: asarray(margins_map, "`outcome'_`var'", `i')
      local i = `i' + 1
    }
  }
}
