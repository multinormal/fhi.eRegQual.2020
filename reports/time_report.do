version 16.1

args filename

// Define the transform to use in nlcom (times were originally logged)
local transform exp(_b[\`var':2.arm])

// Some locals to make this file a little more readable.
local heading putdocx paragraph, style(Heading1)
local subhead putdocx paragraph, style(Heading2)
local newpara putdocx textblock begin, halign(both)
local putdocx textblock end putdocx textblock end

local p_fmt  %5.2f // Format used for P-values.
local e_fmt  %5.2f // Format used for estimates.
local pc_fmt %8.1f // Format used for percentages.

local tbl_num = 0  // A table counter.

// Start the document.
putdocx begin

// Title.
putdocx paragraph, style(Title)
putdocx text ("eRegQual analysis - Time and motion study analysis")

// Author and revision information.
`newpara'
Chris Rose, Norwegian Institute of Public Health 
(<<dd_docx_display: c(current_date)>>)
putdocx textblock end
`newpara'
Generated using git revision: <<dd_docx_display: "${git_revision}">>
putdocx textblock end

// Introduction section.
`heading'
putdocx text ("Introduction")

`newpara'
TODO: Write this.
putdocx textblock end

// Methods section
`heading'
putdocx text ("Methods")

`newpara'
Times (durations) are non-negative and their distributions are positively 
skewed (e.g., there are many consultations of “typical” duration, but some 
that are much longer). Further, we anticipated that the intervention is likely 
to have a multiplicative rather than additive effect. We therefore analyzed 
times on the log scale. We used mixed-effects linear regression to estimate 
relative differences in time between treatment and control. We adjusted for 
the stratification variable (CHMP 2015) and the variables used to constrain 
randomization (cluster size and lab availability; Li 2016) as fixed effects. 
We estimated the effect of observer and whether a visit was a booking visit 
(fixed effects) because we anticipated that these would affect time 
measurements. We modelled cluster as a random effect. It was not possible to 
obtain reliable variance estimates using a model that adjusted for observer as a 
random effect. However, an exploratory analysis that modelled observer as a 
random effect showed that point estimates and confidence intervals comparing 
treatment to control were almost identical for the primary outcome. 
We exponentiated to obtain estimates of relative difference and 95% confidence 
intervals. We followed the intention-to-treat principle for all analyses: 
participants were analyzed in the arms to which they were randomized, and all 
participants were included in the analyses. No data were missing. Statistical 
analyses were performed using Stata 16 (StataCorp LLC, College Station, Texas, 
USA). The statistician was not involved in data collection and was blinded to 
treatment allocation during analysis. Protocol deviations are documented in 
Appendix 1.
putdocx textblock end

// Results section
`heading'
putdocx text ("Results")

`subhead'
putdocx text ("Health information management, client consultation, and care")

`newpara'
TODO: Write this.
putdocx textblock end

frame time {
  local note "* The standard error, z-score, and P-value are from the analysis"
  local note "`note' performed on the log scale."

  foreach var of global time_outcomes {
    local ++tbl_num
    local var_label : variable label `var'
    local title "Table `tbl_num'. `var_label'"
    estimates restore `var'_estimates
    estimates replay

    // Get arm label and estimates for the table.
    // We assume that level 1 is the reference for arm.
    local arm : label (arm) 2 
    local beta = e(b)["y1", "`var':2.arm"]
    local x  = exp(`beta')
    local se = sqrt(e(V)["`var':2.arm", "`var':2.arm"])
    local z  = `beta' / `se'
    local p  = 2 * normal(-abs(`z'))
    local lb = exp(`beta' - (1.96 * `se'))
    local ub = exp(`beta' + (1.96 * `se'))

    // Make strings for the table.
    local x_str  = string(`x',  "`e_fmt'") // Point estimate.
    local se_str = string(`se', "`e_fmt'") // Std. Err.
    local z_str  = string(`z',  "`e_fmt'")  // z.
    local p_str  = string(`p',  "`p_fmt'") // P-value.
    local lb_str = string(`lb', "`e_fmt'") // Lower-bound on CI.
    local ub_str = string(`ub', "`e_fmt'") // Upper-bound on CI.

    // Make the table manually.
    putdocx table tbl_`tbl_num' = (3, 7), title("`title'") note("`note'") ///
                                          border(all, nil)
    // Column titles.
    putdocx table tbl_`tbl_num'(2, 2) = ("Rel. Time"), halign(right)
    putdocx table tbl_`tbl_num'(2, 3) = ("Std. Err.*"), halign(right)
    putdocx table tbl_`tbl_num'(2, 4) = ("z*"),         halign(right)
    putdocx table tbl_`tbl_num'(2, 5) = ("P>|z|*"),     halign(right)
    putdocx table tbl_`tbl_num'(2, 6) = ("[95% Conf. Interval]"),     ///
                                                       halign(right)  ///
                                                       colspan(2)
    // Row titles.
    putdocx table tbl_`tbl_num'(3, 1) = ("arm"),       halign(right)
    // Values.
    putdocx table tbl_`tbl_num'(4, 1) = ("`arm'"),     halign(right)
    putdocx table tbl_`tbl_num'(4, 2) = ("`x_str'"),   halign(right)
    putdocx table tbl_`tbl_num'(4, 3) = ("`se_str'"),  halign(right)
    putdocx table tbl_`tbl_num'(4, 4) = ("`z_str'"),   halign(right)
    putdocx table tbl_`tbl_num'(4, 5) = ("`p_str'"),   halign(right)
    putdocx table tbl_`tbl_num'(4, 6) = ("`lb_str'"),  halign(right)
    putdocx table tbl_`tbl_num'(4, 7) = ("`ub_str'"),  halign(right)

    // Borders.
    putdocx table tbl_`tbl_num'(2, .),   border(top)
    putdocx table tbl_`tbl_num'(3, .),   border(top)
    putdocx table tbl_`tbl_num'(4, .),   border(bottom)
    putdocx table tbl_`tbl_num'(2/4, 1), border(right)
  }
}

`subhead'
putdocx text ("Activities")

`newpara'
The following table shows relative differences in time used finding, reading, 
and writing in the treatment versus control conditions. Values greater than 
unity corresponding to more use of time in the treatment condition.
putdocx textblock end

// TODO: Add methods description for this analysis.
frame activities {
  local ++tbl_num
  local var_label : variable label activity
  local title "Table `tbl_num'. Comparison of relative times spent finding,"
  local title "`title' reading, and writing files"
  local activity_label_name = "`: value label activity'"
  
  estimates restore activity_estimates
  estimates replay

  // Make the table manually - it does not seem possible to use the "=etable"
  // method after nlcom.
  putdocx table tbl_`tbl_num' = (4, 7), title("`title'") ///
                                        border(all, nil)
  // Column titles.
  putdocx table tbl_`tbl_num'(2, 2) = ("Rel. Time"),  halign(right)
  putdocx table tbl_`tbl_num'(2, 3) = ("Std. Err."),  halign(right)
  putdocx table tbl_`tbl_num'(2, 4) = ("z"),          halign(right)
  putdocx table tbl_`tbl_num'(2, 5) = ("P>|z|"),      halign(right)
  putdocx table tbl_`tbl_num'(2, 6) = ("[95% Conf. Interval]"),     ///
                                                      halign(right) ///
                                                      colspan(2)
  local activity_types f r w // Finding, reading, writing.
  local f_activity "Finding"
  local r_activity "Reading"
  local w_activity "Writing"
  local row = 3
  foreach activity_type of local activity_types {
    // Get the control and treatment activity codes.
    local control   = "${paper_`activity_type'_him_lbl}":`activity_label_name'
    local treatment = "${comp_`activity_type'_him_lbl}":`activity_label_name'

    // Compare the activties between the trial arms, and exponentiate to get
    // relative difference in time used.
    nlcom exp(_b[`treatment'.activity] - _b[`control'.activity])

    // Get the relavant quantities - this has been checked against the result
    // reported by nlcom.
    local beta = r(b)[1, 1]
    local se   = sqrt(r(V)[1, 1])
    local z    = `beta' / `se'
    local p    = 2 * normal(-abs(`z'))
    local lb   = `beta' - (1.96 * `se')
    local ub   = `beta' + (1.96 * `se')

    // Make strings for the table.
    local activity = "``activity_type'_activity'"
    local x_str  = string(`beta', "`e_fmt'") // Point estimate.
    local se_str = string(`se',   "`e_fmt'") // Std. Err.
    local z_str  = string(`z',    "`e_fmt'") // z.
    local p_str  = string(`p',    "`p_fmt'") // P-value.
    local lb_str = string(`lb',   "`e_fmt'") // Lower-bound on CI.
    local ub_str = string(`ub',   "`e_fmt'") // Upper-bound on CI.

    // Values.
    putdocx table tbl_`tbl_num'(`row', 1) = ("`activity'"), halign(right)
    putdocx table tbl_`tbl_num'(`row', 2) = ("`x_str'"),    halign(right)
    putdocx table tbl_`tbl_num'(`row', 3) = ("`se_str'"),   halign(right)
    putdocx table tbl_`tbl_num'(`row', 4) = ("`z_str'"),    halign(right)
    putdocx table tbl_`tbl_num'(`row', 5) = ("`p_str'"),    halign(right)
    putdocx table tbl_`tbl_num'(`row', 6) = ("`lb_str'"),   halign(right)
    putdocx table tbl_`tbl_num'(`row', 7) = ("`ub_str'"),   halign(right)

    // Move to the next row.
    local row = `row' + 1
  }

  // Borders.
  putdocx table tbl_`tbl_num'(2, .),   border(top)
  putdocx table tbl_`tbl_num'(3, .),   border(top)
  putdocx table tbl_`tbl_num'(5, .),   border(bottom)
  putdocx table tbl_`tbl_num'(2/5, 1), border(right)
}

// References
`heading'
putdocx text ("References")

`newpara'
Committee for Medicinal Products for Human Use (CHMP) (2015). Guideline on 
adjustment for baseline covariates in clinical trials. London: European 
Medicines Agency.
putdocx textblock end

`newpara'
Li, F., Lokhnygina, Y., Murray, D. M., Heagerty, P. J., & DeLong, E. R. (2016). 
An evaluation of constrained randomization for the design and analysis of 
group‐randomized trials. Statistics in Medicine, 35(10), 1565-1579.
putdocx textblock end

// Appendices

`heading'
putdocx text ("Appendix 1 — Protocol Deviations")

`newpara'
We did not originally plan to model relative times via transformation to the 
log scale. Nor did we originally plan to adjust for observer but chose to do so 
as it is plausible that systematic differences may exist between observers.
putdocx textblock end

`heading'
putdocx text ("Appendix 2 — Full Regression Results")

`subhead'
putdocx text ("Comparisons of time used")

`newpara'
The following tables show the full regression results. Note that time was 
modelled on the log scale and the full estimation results have not been 
exponentiated.
putdocx textblock end

frame time {
  local note  "Data were analyzed on the log scale."
  local note  "`note' Estimates have not been exponentiated."
  foreach var of global time_outcomes {
    local ++tbl_num
    local var_label : variable label `var'
    local title "Table `tbl_num'. `var_label'"
    estimates restore `var'_estimates
    estimates replay
    putdocx table tbl_`tbl_num' = etable, title("`title'") note(`note')
  }
}

`subhead'
putdocx text ("Estimates of time spent finding, reading, and writing files")

`newpara'
The following tables shows the full regression result for the analysis of time 
spent on each activity. Note that time was modelled on the log scale and the 
full estimation results have not been exponentiated.
putdocx textblock end

frame activities {
  local note  "Data were analyzed on the log scale."
  local note  "`note' Estimates have not been exponentiated."
  local ++tbl_num
  local var_label : variable label time
  local title "Table `tbl_num'. `var_label'"
  estimates restore activity_estimates
  estimates replay
  putdocx table tbl_`tbl_num' = etable, title("`title'") note(`note')
}

// Save the report to the specified filename.
putdocx save `"`filename'"', replace
