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
TODO: Write this.
putdocx textblock end

// Results section
`heading'
putdocx text ("Results")

`newpara'
TODO: Write this.
putdocx textblock end

frame time {
  foreach var of global time_outcomes {
    local ++tbl_num
    local var_label : variable label `var'
    local title "Table `tbl_num'. `var_label'"
    estimates replay `var'_estimates
    //nlcom `transform', post
    estimates table, eform
    putdocx table tbl_`tbl_num' = etable, title("`title'")
    /// putdocx table tbl_`tbl_num'(2, 1) = (" ") // Remove outcome var name.
    /// putdocx table tbl_`tbl_num'(2, 2) = ("Odds Ratio"), halign(right)
    /// local n_rows  23
    /// local n_start 5
    /// if "`var'" == "y2" local n_rows  16
    /// if "`var'" == "y2" local n_start 5
    /// forvalues i = `n_rows'(-1)`n_start' { // Drop rows not of interest.
    ///   putdocx table tbl_`tbl_num'(`i', .), drop
    /// }
  }
}

// References
`heading'
putdocx text ("References")

`newpara'
TODO: Add references.
putdocx textblock end

// Appendices

`heading'
putdocx text ("Appendix 1 — Protocol Deviations")

`newpara'
We did not originally plan to model relative times via transfomation to the 
log scale. Nor did we originally plan to model observer as a random effect but 
chose to do so as it is plausible that systematic differences may exist between 
observers.
putdocx textblock end

`heading'
putdocx text ("Appendix 3 — Full Regression Results")

`newpara'
The following tables show the full regression results. Note that time was 
modelled on the log scale and the full estimation results have not been 
exponentiated.
putdocx textblock end

frame time {
  foreach var of global time_outcomes {
    local ++tbl_num
    local var_label : variable label `var'
    local title "Table `tbl_num'. `var_label' — Analyzed on log scale"
    estimates replay `var'_estimates
    putdocx table tbl_`tbl_num' = etable, title("`title'")
    // TODO: putdocx table tbl_`tbl_num'(2, 2) = ("Odds Ratio"), halign(right)
  }
}

// Save the report to the specified filename.
putdocx save `"`filename'"', replace
