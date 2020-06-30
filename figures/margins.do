version 16.1

set graphics off

local outcome attendance // TODO: Iterate over the global process_outcomes
                         // TODO: Make a margins plot for each constraint var

// Define the names and number of variables over which to make marginsplots.
local margin_vars = ustrtrim(usubinstr("$adj_var_names", "strat_var", "", .))
local n_plots = wordcount("`margin_vars'")

frame `outcome' {
  estimates restore `outcome'_estimates

  foreach var of local margin_vars {
    if "`var'" == "cluster_size" {
      margins i.arm, at(cluster_size = (0.1 1 2))
      local xscale          xscale(range(0 2.25)) 
      local xscale `xscale' xlabel(0.1 "10" 1 "100" 2 "200")
      local ylabel ylabel(0 "0" 0.2 "0.2" 0.4 "0.4" 0.6 "0.6" 0.8 "0.8" 1.0 "1")
    }
    else {
      margins i.arm#`var'
      local xscale
      local ylabel ylabel(0 " " 0.2 " " 0.4 " " 0.6 " " 0.8 " " 1.0 " ")
    }

    local var_label : variable label `var'
    marginsplot, yscale(range(0 1)) `ylabel' ytitle("")  ///
                 `xscale'                                ///
                 title("`var_label'", span)              ///
                 legend(cols(1) region(color(white)))    ///
                 graphregion(color(white))               ///
                 plotregion(color(white))                ///
                 bgcolor(white)                          ///
                 name(`var', replace)
  }

  graph combine `margin_vars', cols(`n_plots')           ///
                               graphregion(color(white)) ///
                               plotregion(color(white))
  global `outcome'_margins_fname "products/Margins - `outcome'"
  graph export "${`outcome'_margins_fname}.pdf", replace
  graph export "${`outcome'_margins_fname}.png", replace
}

set graphics on
