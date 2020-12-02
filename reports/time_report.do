version 16.1

args filename

// Define the transform to use in nlcom (times were originally logged)
local transform exp(_b[\`var':2.arm])

// Some locals to make this file a little more readable.
local heading putdocx paragraph, style(Heading1)
local subhead putdocx paragraph, style(Heading2)
local newpara putdocx textblock begin, halign(both)
local putdocx textblock end putdocx textblock end
local table_cell "putdocx table tbl_\`tbl_num'"

local p_fmt  %5.3f // Format used for P-values.
local e_fmt  %5.2f // Format used for estimates.
local pc_fmt %8.1f // Format used for percentages.

local tbl_num = 0  // A table counter.

// Start the document.
putdocx begin

// Title.
putdocx paragraph, style(Title)
putdocx text ("eRegTime analysis - Time and motion study analysis")

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
This document presents analyses for the time and motion component of the 
eRegTime trial.
putdocx textblock end

// Methods section
`heading'
putdocx text ("Methods")

// TODO: Rewrite the methods text.
`newpara'
TODO: Write this.
putdocx textblock end

// `newpara'
// Times (durations) are non-negative and their distributions are often positively 
// skewed (e.g., there are many consultations of “typical” duration, but some 
// are much longer). Further, we anticipated that the intervention is likely 
// to have a multiplicative rather than additive effect on time use. We therefore 
// analyzed times on the log scale. We used mixed-effects linear regression to 
// estimate relative differences in time used on health information management, 
// client consultation, and client care, comparing treatment to control. We 
// adjusted for the stratification variable (CHMP 2015) and the variables used to 
// constrain randomization (cluster size and lab availability; Li 2016) as fixed 
// effects. We anticipated that booking visits would be longer than subsequent 
// visits, and therefore adjusted for visity type as a fixed effect. We modelled 
// the cluster-randomized design using a random intercept for each clinic, and 
// also adjusted confidence intervals for within-observer clustering of 
// time measurement.
// putdocx textblock end

// `newpara'
// Similarly, we used mixed-effects linear regression to estimate time used 
// finding, reading, and writing files using paper or the eRegistry. This 
// analysis was identical to the previous one, with the exceptions that 
// activity (finding, reading, etc.) was modelled as a fixed effect and clustering 
// of activities within consultations within clinic was modelled using nested 
// random effects. Note that it was necessary to retain treatment allocation as a 
// fixed effect because while participants in the control arm could not use the 
// eRegistry, those in the treatment arm could use computer- and paper-based 
// methods.
// putdocx textblock end

// `newpara'
// We exponentiated to obtain estimates of relative differences in 
// time used, and computed predictive margins of mean time spent finding, reading, 
// and writing files. We report uncertainty on estimates and predictions using 
// 95% confidence intervals. We followed the intention-to-treat principle for all 
// analyses: participants were analyzed in the arms to which they were randomized, 
// and all participants were included in the analyses. No data were missing. 
// Statistical analyses were performed using Stata 16 (StataCorp LLC, College 
// Station, Texas, USA). The statistician was not involved in data collection and 
// was blinded to treatment allocation for the analyses of relative differences in 
// time used on health information management, client consultation, and client 
// care. It was not possible to blind the statistician to treatment allocation for 
// the analyses of time used finding, reading, and writing files because the 
// treatment allocation was obvious. Protocol deviations are documented in 
// Appendix 1.
// putdocx textblock end

// Show results on next page.
putdocx pagebreak

// Results section
`heading'
putdocx text ("Results")

`subhead'
putdocx text ("Health information management and client care")

`newpara'
The following table presents comparisons of time used on health information 
management and client care.
putdocx textblock end

// Define a note for the tables (this is also used below!).
local note "*Sample means were not computed on the log scale."
local note "`note' †Estimates of relative differences in time used were adjusted for"
local note "`note' the stratification variable, cluster size, lab availability,"
local note "`note' and booking visit. ‡Confidence intervals and"
local note "`note' P-values were adjusted for possible cluster effects due to"
local note "`note' the cluster RCT design and observer. §Total time includes"
local note "`note' activities not accounted for in health information management"
local note "`note' and client care."

// Make the table.
frame time {
  // Determine which level of the arm variable corresponds to the intervention.
  local int_level = "Intervention":arm

  // Make the table manually.
  local ++tbl_num
  local title "Table `tbl_num'. Analysis of total time use, and time use on health information management and client care."
  local n_rows = 5 + wordcount("$main_time_outcomes")
  local r = 1 // A row counter.
  putdocx table tbl_`tbl_num' = (`n_rows', 7), title("`title'") note("`note'") border(all, nil)
  
  // Column titles.
  local r = `r' + 1
  `table_cell'(`r', 2) = ("Sample means (mins)*"), halign(center) colspan(2)

  local r = `r' + 1
  `table_cell'(`r', 2) = ("Control"),                       halign(center)
  `table_cell'(`r', 3) = ("Intervention"),                  halign(center)
  `table_cell'(`r', 4) = ("Relative Time†"), halign(center)
  `table_cell'(`r', 5) = ("[95% Conf. Interval]‡"),          halign(center) colspan(2)  
  `table_cell'(`r', 6) = ("P-value‡"),                       halign(center)

  // Primary outcome results.
  local outcome_groups total_time_outcomes him_time_outcomes care_time_outcomes
  foreach group in `outcome_groups' {
    // Table section, with borders at top and bottom.
    local r = `r' + 1
    `table_cell'(`r', 1) = ("${`group'_section}"),  halign(left) colspan(8)
    `table_cell'(`r', .),   border(top)    // Across the top of the section.
    `table_cell'(`r', .),   border(bottom) // Across the bottom of the section.

    foreach y of global `group' {
      local r = `r' + 1

      // Format the sample means.
      local samp_mean_con = string(${samp_mean_`y'_con}, "`e_fmt'")
      local samp_mean_int = string(${samp_mean_`y'_int}, "`e_fmt'")

      // Format the estimates.
      estimates restore `y'
      local beta = _b[`int_level'.arm]
      local se = _se[`int_level'.arm]
      local z  = `beta' / `se'
      local p = 2 * normal(-abs(`z'))
      local p = string(`p', "`p_fmt'")
      if `p' < 0.01 local p = "<0.001"
      local lb = `beta' - (1.96 * `se')
      local ub = `beta' + (1.96 * `se')
      local rel_diff = string(exp(`beta'), "`e_fmt'")
      local lb = string(exp(`lb'), "`e_fmt'")
      local ub = string(exp(`ub'), "`e_fmt'")

      // Make a row for these results.
      `table_cell'(`r', 1) = ("${`y'_row_lbl}"),           halign(left)
      `table_cell'(`r', 2) = ("`samp_mean_con'"),   halign(center)
      `table_cell'(`r', 3) = ("`samp_mean_int'"),   halign(center)
      `table_cell'(`r', 4) = ("`rel_diff'"),        halign(center)
      `table_cell'(`r', 5) = ("`lb'"),              halign(center)
      `table_cell'(`r', 6) = ("`ub'"),              halign(center)
      `table_cell'(`r', 7) = ("`p'"),               halign(center)
    }

    // Borders.
    `table_cell'(2, .),   border(top)    // Across the top of the table.
    `table_cell'(`r', .), border(bottom)
  }
}

// Show next table on next page.
putdocx pagebreak

`subhead'
putdocx text ("Activities")

`newpara'
The following table shows relative differences in time used on activities such 
as finding, reading, and writing in the treatment versus control conditions.
putdocx textblock end

frame time {
  // Determine which level of the arm variable corresponds to the intervention.
  local int_level = "Intervention":arm

  // Make the table manually.
  local ++tbl_num
  local title "Table `tbl_num'. Analysis of time used finding, reading, and writing."
  local n_rows = 5 + wordcount("$minor_time_outcomes")
  local r = 1 // A row counter.
  putdocx table tbl_`tbl_num' = (`n_rows', 7), title("`title'") note("`note'") border(all, nil)
  
  // Column titles.
  local r = `r' + 1
  `table_cell'(`r', 2) = ("Sample means (mins)*"), halign(center) colspan(2)

  local r = `r' + 1
  `table_cell'(`r', 2) = ("Control"),                       halign(center)
  `table_cell'(`r', 3) = ("Intervention"),                  halign(center)
  `table_cell'(`r', 4) = ("Relative Time†"), halign(center)
  `table_cell'(`r', 5) = ("[95% Conf. Interval]‡"),          halign(center) colspan(2)  
  `table_cell'(`r', 6) = ("P-value‡"),                       halign(center)

  // Primary outcome results.
  local outcome_groups                  find_time_outcomes read_time_outcomes 
  local outcome_groups `outcome_groups' write_time_outcomes // TODO: REINSTATE??? post_cons_time_outcomes
  foreach group in `outcome_groups' {
    // Table section, with borders at top and bottom.
    local r = `r' + 1
    `table_cell'(`r', 1) = ("${`group'_section}"),  halign(left) colspan(8)
    `table_cell'(`r', .),   border(top)    // Across the top of the section.
    `table_cell'(`r', .),   border(bottom) // Across the bottom of the section.

    foreach y of global `group' {
      local r = `r' + 1

      // Format the sample means.
      local samp_mean_con = string(${samp_mean_`y'_con}, "`e_fmt'")
      local samp_mean_int = string(${samp_mean_`y'_int}, "`e_fmt'")

      // Format the estimates.
      estimates restore `y'
      local beta = _b[`int_level'.arm]
      local se = _se[`int_level'.arm]
      local z  = `beta' / `se'
      local p = 2 * normal(-abs(`z'))
      local p = string(`p', "`p_fmt'")
      if `p' < 0.01 local p = "<0.001"
      local lb = `beta' - (1.96 * `se')
      local ub = `beta' + (1.96 * `se')
      local rel_diff = string(exp(`beta'), "`e_fmt'")
      local lb = string(exp(`lb'), "`e_fmt'")
      local ub = string(exp(`ub'), "`e_fmt'")

      // Make a row for these results.
      `table_cell'(`r', 1) = ("${`y'_row_lbl}"),           halign(left)
      `table_cell'(`r', 2) = ("`samp_mean_con'"),   halign(center)
      `table_cell'(`r', 3) = ("`samp_mean_int'"),   halign(center)
      `table_cell'(`r', 4) = ("`rel_diff'"),        halign(center)
      `table_cell'(`r', 5) = ("`lb'"),              halign(center)
      `table_cell'(`r', 6) = ("`ub'"),              halign(center)
      `table_cell'(`r', 7) = ("`p'"),               halign(center)
    }

    // Borders.
    `table_cell'(2, .),   border(top)    // Across the top of the table.
    `table_cell'(`r', .), border(bottom)
  }
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
We did not plan to model relative times via transformation to the log scale. 
Nor did we plan to adjust for observer but chose to do so as it is plausible 
that systematic differences may exist between observers. We did not plan in 
detail how time used finding, reading, or writing files would be analyzed.
putdocx textblock end

`heading'
putdocx text ("Appendix 2 — Full Regression Results")

`subhead'
putdocx text ("Comparisons of time used")

`newpara'
The following tables show the full regression results. Note that time was 
modelled on the log scale and the full estimation results have not been 
exponentiated here.
putdocx textblock end

frame time {
  local note  "Data were analyzed on the log scale."
  local note  "`note' Estimates have not been exponentiated."

  foreach y of global time_outcomes {
    local ++tbl_num
    local label : variable label `y'
    local title "Table `tbl_num'. `label' — full regression results"
    estimates restore `y'
    estimates replay
    `table_cell' = etable, title("`title'") note(`note')
  }
}

// Save the report to the specified filename.
putdocx save `"`filename'"', replace
