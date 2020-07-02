version 16.1

// TODO: Use different marker shapes and perhaps try to stagger things to avoid
// overplotting.

set graphics off

// Define titles to use for the margins plots.
local mpo "Marginal probability of"
local attendance_margins_title      "`mpo' ANC attendance"
local hypertension_margins_title    "`mpo' hypertension" "screening & management"
local diabetes_margins_title        "`mpo' diabetes" "screening & management"
local malpresentation_margins_title "`mpo' malpresentation" "screening & management"
local anemia_margins_title          "`mpo' anemia" "screening & management"
local fetalgrowth_margins_title     "`mpo' fetal growth" "screening & management"

// Define the names and number of variables over which to make marginsplots.
local margin_vars = ustrtrim(usubinstr("$adj_var_names", "strat_var", "", .))
local n_plots = wordcount("`margin_vars'")

// Define the ticks and labels used for the vertical axes of the left-most plot.
local y_ticks 0 "0%" 0.2 "20%" 0.4 "40%" 0.6 "60%" 0.8 "80%" 1.0 "100%"

foreach outcome of global process_outcomes {
  frame `outcome' {
    estimates restore `outcome'_estimates

    foreach var of local margin_vars {
      // Cluster size will be plotted left-most, and will be given labels
      // on the y axis. All others will use the following "blanked" labels.
      local ylabel ylabel(0 " " 0.2 " " 0.4 " " 0.6 " " 0.8 " " 1.0 " ")
      local xscale
      
      // If var is a factor, we use the following syntax, otherwise we 
      // specialize for the continuous variables.
      local margins margins i.arm#`var'
      if "`var'" == "cluster_size" {
        local margins margins i.arm, at(cluster_size = (0.1 1 2))
        local xscale          xscale(range(0 2.25)) 
        local xscale `xscale' xlabel(0.1 "10" 1 "100" 2 "200")
        local ylabel ylabel(`y_ticks', angle(horizontal))
      }
      if "`var'" == "age" {
        local margins margins i.arm, at(age = (15(10)45))
        local xscale          xscale(range(10 50)) 
        local xscale `xscale' xlabel(15 25 35 45)
      }
      
      // Compute and plot the margins.
      `margins'
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

    // Combine and save the margins plots.
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
