version 16.1

set graphics off

// Define titles to use for the margins plots.
local mpo "Marginal probability of"
local attendance_margins_title      "`mpo' ANC attendance"
local hypertension_margins_title    "`mpo' hypertension" "screening & management"
local diabetes_margins_title        "`mpo' diabetes" "screening & management"
local malpresentation_margins_title "`mpo' malpresentation" "screening & management"

// Define the names and number of variables over which to make marginsplots.
local margin_vars = ustrtrim(usubinstr("$adj_var_names", "strat_var", "", .))
local n_plots = wordcount("`margin_vars'")

foreach outcome of global process_outcomes {
  frame `outcome' {
    estimates restore `outcome'_estimates

    foreach var of local margin_vars {
      if "`var'" == "cluster_size" {
        margins i.arm, at(cluster_size = (0.1 1 2))
        local xscale          xscale(range(0 2.25)) 
        local xscale `xscale' xlabel(0.1 "10" 1 "100" 2 "200")
        local ylabel ylabel(0 "0%" 0.2 "20%" 0.4 "40%" 0.6 "60%" 0.8 "80%" 1.0 "100%", angle(horizontal))
      }
      else {
        margins i.arm#`var'
        local xscale
        local ylabel ylabel(0 " " 0.2 " " 0.4 " " 0.6 " " 0.8 " " 1.0 " ")
      }

      local var_label : variable label `var'
      marginsplot, yscale(range(0 1)) `ylabel' ytitle("") ///
                  `xscale'                                ///
                  title("`var_label'", span)              ///
                  legend(cols(1) region(color(white)))    ///
                  graphregion(color(white))               ///
                  plotregion(color(white))                ///
                  bgcolor(white)                          ///
                  name(`var', replace)
    }

    set scheme white_background // Hack to address thin lines around plot.
    graph combine `margin_vars', cols(`n_plots')                    ///
                                 title("``outcome'_margins_title'") ///
                                 graphregion(color(white) lwidth(none)) ///
                                 plotregion(color(white))
    global `outcome'_margins_fname "products/Margins - `outcome'"
    graph export "${`outcome'_margins_fname}.pdf", replace
    graph export "${`outcome'_margins_fname}.png", replace
  }
}

set graphics on
