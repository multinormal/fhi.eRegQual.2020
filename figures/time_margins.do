version 16.1

set graphics off

// Specify the ranges for the y-axes.
local yscale_total_time yscale(range(0 35))   ylabel(0(5)35)
local yscale_him_time   yscale(range(0 20))   ylabel(0(5)20)
local yscale_care_time  yscale(range(0 15))   ylabel(0(5)15)
local yscale_find_time  yscale(range(0 1.5))  ylabel(0(0.5)1.5)
local yscale_read_time  yscale(range(0 1.5))  ylabel(0(0.5)1.5)
local yscale_write_time yscale(range(0 20))   ylabel(0(5)20)

// Define the names and number of variables over which to make marginsplots.
local margin_vars = ustrtrim(usubinstr("$time_adj_var_names", "strat_var", "", .))
local n_plots = wordcount("`margin_vars'")

// Define the symbols for the arms.
local symbols plot1opts(msymbol(D)) plot2opts(msymbol(O))

frame time {
  foreach outcome of global time_margin_outcomes {
    local outcome_label : variable label `outcome'
    if "`outcome_label'" != "HIM"   local outcome_label = strlower("`outcome_label'")
    if "`outcome_label'" != "total" local outcome_label = "on `outcome_label'"
    if "`outcome_label'" == "total" local outcome_label = "in `outcome_label'"

    foreach var of local margin_vars {
      local xscale fxsize(30)
      local ytitle ytitle("")

      if "`var'" == "cluster_size" {
        local xscale          xscale(range(0.04 0.26))
        local xscale `xscale' xlabel(0.05 "5" 0.1 "10" 0.15 "15" 0.2 "20" 0.25 "25")
        local ylabel ylabel(`y_ticks', angle(horizontal))
        local ytitle ytitle("Marginal mean time used `outcome_label' (mins)")
      }

      // Restore the estimates for this (outcome, var) pair.
      time_margin_name `outcome' `var'
      local estimates_name = r(estimates_name)
      estimates restore `estimates_name'

      // Plot the margins.
      local var_label : variable label `var'
      marginsplot, `ylabel' `ytitle'                      ///
                  `yscale_`outcome''                      ///
                  `xscale'                                ///
                  legend(rows(1) region(color(white)))    ///
                  title("")                               ///
                  graphregion(color(white))               ///
                  plotregion(color(white))                ///
                  bgcolor(white)                          ///
                  `symbols'                               ///
                  name(`var', replace)
    }

    // Combine and save the margins plots.
    set scheme white_background // Hack to address thin lines around plot.
    grc1leg `margin_vars', cols(`n_plots')                        ///
                           legendfrom(cluster_size)               ///
                           graphregion(color(white) lwidth(none)) ///
                           plotregion(color(white))
    global `outcome'_margins_fname "products/Margins - `outcome'"
    graph export "${`outcome'_margins_fname}.pdf", replace
    graph export "${`outcome'_margins_fname}.png", replace
    graph export "${`outcome'_margins_fname}.eps", replace
  }
}

set graphics on
