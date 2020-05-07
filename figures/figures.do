version 16.1

set graphics off

tempname this_frame
frame copy imputed `this_frame'

// Define the number of imputations to plot.
local imputations_to_plot 5
assert `imputations_to_plot' <= $m_imputations

frame `this_frame' {
  mi set M = `imputations_to_plot'

  // Generate a variable for each imputed variable that contains the original
  // values (with the missing data), repeated for each imputed data set.
  mi convert wide, clear
  local the_vars log_income
  foreach var of local the_vars {
    generate `var'_orig = `var'
  }
  mi convert flong, clear

  // Create readable value labels for the imputations, and order them so that
  // the original data will appear first in the plots.
  generate imputation_str = ""
  replace imputation_str = "Original" if _mi_m == 0
  replace imputation_str = "Imputation " + string(_mi_m) if _mi_m != 0
  encode imputation_str, generate(imputation)
  replace imputation = (`imputations_to_plot' + 1) - imputation
  local label_var: value label imputation
  label define `label_var' 0 "Original", modify

  codebook imputation
  // Plot the density of each of the continuous imputed variables.
  foreach var of local the_vars {
    local var_label : variable label `var'
    twoway (kdensity `var'_orig) ///
           (kdensity `var'),     ///
           by(imputation, note(""))        ///
           legend(label(1 "Original") label(2 "Imputed"))
    graph export "products/Imputations - `var_label'.pdf", replace
  }
}

set graphics on

