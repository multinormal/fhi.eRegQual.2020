version 16.1

set graphics off

// Define the number of imputations to plot.
local imputations_to_plot 5
assert `imputations_to_plot' <= $m_imputations

// Make the plots.
tempname this_frame
frame copy imputed `this_frame'
frame `this_frame' {
  mi set M = `imputations_to_plot'

  // Generate a variable for each imputed variable that contains the original
  // values (with the missing data), repeated for each imputed data set.
  mi convert wide, clear
  foreach var of varlist $imputeds y1-y5 y {
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

  // Plot the density of each of the continuous imputed variables.
  local cont_imputed = ustrtrim(usubinstr("$imputeds", "primiparous", "", .))
  foreach var of local cont_imputed {
    local pc_miss = string(${pc_miss_`var'}, "%8.1f") + "% missing"

    local var_label : variable label `var'
    twoway (kdensity `var'_orig)                                   ///
           (kdensity `var'),                                       ///
           by(imputation arm, note("")                             ///
              graphregion(color(white))                            ///
              plotregion(color(white))                             ///
              bgcolor(white))                                      ///
           xtitle("`var_label' (`pc_miss')")                       ///
           yscale(lcolor(white))                                   ///
           subtitle(, bcolor(white) lcolor(white))                 ///
           ylabel(none)                                            ///
           legend(label(1 "Original") label(2 "Imputed")           ///
                  region(color(white)))
    global `var'_plot_fname "products/Imputations - `var_label'"
    graph export "${`var'_plot_fname}.pdf", replace
    graph export "${`var'_plot_fname}.png", replace
  }

  // Plot the distribution of each of the dichotomous imputed variables.
  foreach var of varlist y y1-y5 primiparous {
    local pc_miss = string(${pc_miss_`var'}, "%8.1f") + "% missing"
    local var_label : variable label `var'

    splitvallabels imputation, recode
    graph hbar (count),                                             ///
      over(`var', label(labsize(small)))                            ///
      over(arm, label(labsize(small)))                              ///
      over(imputation, label(labsize(small)) relabel(`r(relabel)')) ///
      blabel(bar) intensity(25)                                     ///
      ytitle("`var_label' (`pc_miss')") yscale(range(0 3500))       ///
      legend(region(lcolor(white)))                                 ///
      graphregion(color(white)) plotregion(color(white)) bgcolor(white)
    global `var'_plot_fname "products/Imputations - `var_label'"
    graph export "${`var'_plot_fname}.pdf", replace
    graph export "${`var'_plot_fname}.png", replace
    graph export "${`var'_plot_fname}.eps", replace
  }
}

set graphics on
