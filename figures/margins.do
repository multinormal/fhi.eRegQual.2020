version 16.1

set graphics off

local outcome attendance // TODO: Iterate over the global process_outcomes
                         // TODO: Make a margins plot for each constraint var

// Define the names and number of variables over which to make marginsplots.
local margin_vars = ustrtrim(usubinstr("$adj_var_names", "strat_var", "", .))
local n_plots = wordcount("`margin_vars'")

// Define titles to use for the plots.
local mpo "Marginal probability of"
local attendance_title      "`mpo' ANC attendance"
local hypertension_title    "`mpo' hypertension screening and management"
local diabetes_title        "`mpo' diabetes screening and management"
local malpresentation_title "`mpo' malpresentation screening and management"

frame `outcome' {
  estimates restore `outcome'_estimates

  foreach var of local margin_vars {
    if "`var'" == "cluster_size" {
      margins i.arm, at(cluster_size = (0.1(0.5)2.1))
    }
    else {
      margins i.arm#`var'
    }

    local var_label : variable label `var'
    marginsplot, yscale(range(0 1)) ylabel(#5) ytitle("")   ///
                 title("`var_label'", span)                        ///
                 legend(cols(1) region(color(white)))              ///
                 graphregion(color(white))                         ///
                 plotregion(color(white))                          ///
                 bgcolor(white)                                    ///
                 name(`var', replace)
  }

  graph combine `margin_vars', cols(`n_plots')           ///
                               title(``outcome'_title')  ///
                               graphregion(color(white)) ///
                               plotregion(color(white))
  graph export "products/Margins.pdf", replace
}

set graphics on