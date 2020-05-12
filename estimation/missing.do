version 16.1

// Local macro to compute percentage of data that are missing following a
// misstable patterns command.
local pc_miss 100 * (r(N_incomplete) / (r(N_incomplete) + r(N_complete)))

frame imputed {
  // Plot the density of each of the continuous imputed variables.
  foreach var of global imputeds {
    quietly misstable patterns `var' if _mi_m == 0
    global pc_miss_`var' = `pc_miss'
  }

  // Estimate the percentages of missing data for the outcome variables.
  foreach var of varlist y y1-y5 {
    quietly misstable patterns `var' if _mi_m == 0
    global pc_miss_`var' = `pc_miss'
  }
}

local miss_vars $pc_miss_y1, $pc_miss_y2, $pc_miss_y3, $pc_miss_y4, $pc_miss_y5
global pc_min_miss = min(`miss_vars')
global pc_max_miss = max(`miss_vars')

