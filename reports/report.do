version 16.1

args filename

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
putdocx text ("eRegQual analysis")

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
This document presents the methods used to analyze the adverse pregnancy and 
process outcome data for the eRegQual trial and presents the results.
putdocx textblock end

// Methods section
`heading'
putdocx text ("Methods")

`newpara'
Because constituent outcome data were missing for about a third of participants 
(see results), we used Little's tests (Little 1988) of the null hypotheses that 
data were jointly missing completely at random (MCAR) and covariate-dependent 
missing (CDM). We then used multiple imputation via chained equations (van 
Buuren 2007) to create and analyze <<dd_docx_display: $m_imputations>> 
multiply-imputed datasets. We imputed using the auxiliary variables trial arm, 
years of education, average monthly household income (transformed to the log 
scale due to the skewed distribution of income), body mass index, ultrasound 
availability, and the variables used as constraints in the randomization 
(cluster size, age, lab availability, and parity). We were not able to include 
auxiliary variables that indicated previous pregnancy with pre-eclampsia or 
previous history of GDM due to collinearity. We evaluated convergence of the 
imputation algorithm by inspecting trace plots and evaluated imputed data by 
inspecting kernel density and histograms comparing the distributions of imputed 
and complete case data.
putdocx textblock end

`newpara'
An adverse pregnancy outcome was defined to have occurred if at least one of the 
constituent outcomes occurred, and not to have occurred if none of the 
constituent outcomes occurred. For each imputed data set and outcome, we 
estimated an odds ratio to compare treatment to control using logistic 
regression, accounting for the cluster-randomized design using random effects. 
We combined estimates for each outcome using Rubin's rules (Rubin 2004). For 
comparison, we also performed a complete case analysis under the MCAR 
assumption. We estimated the intraclass correlation coefficient (ICC) using the 
complete cases. Because data on stillbirth was missing for less than 
5% of women (Jakobsen 2017), a complete case analysis was performed for this 
outcome.
putdocx textblock end

`newpara'
We used logistic regression to estimate the relative odds of each of the process 
outcomes under the treatment versus control conditions. For outcomes measured at 
multiple time points, we modelled clustering within each pregnancy using 
random-effects, and computed cluster-robust standard errors to account for the 
cluster-randomized design. For outcomes measured at only one time point within 
each pregnancy, we accounted for the cluster-randomized design using random 
effects. For each of the process outcomes, we plotted marginal predictive 
probabilities of attendance or successful screening and management with respect 
to cluster size, age, laboratory availability, and parity. Age was either 
incorrectly coded or missing for no more than 
<<dd_docx_display: string(${max_miss_age_pc}, "`pc_fmt'")>>% of women across 
the process outcomes. Because process outcome data were missing for less than 
5% of women, we performed complete case analyses.
putdocx textblock end

`newpara'
We adjusted for the stratification variable (CHMP 2015) as a fixed effect in all 
analyses except that for severe hypertension (due to chance, this relatively 
rare outcome could be predicted perfectly by that variable for a small 
proportion of the imputed data sets). We also adjusted for the variables used 
to constrain randomization (Li 2017) as fixed effects in all analyses, using 
individual- rather than cluster-level measurements where possible. We followed 
the intention-to-treat principle for all analyses: participants were 
analyzed in the arms to which they were randomized and — with the exception of 
the complete case analyses — all participants were included in the analyses. We 
computed 95% confidence intervals and used the significance criterion P<0.05 
throughout. Statistical analyses were performed using Stata 16 (StataCorp LLC, 
College Station, Texas, USA). The statistician was not involved in data 
extraction and was blinded to treatment allocation during analysis. Protocol 
deviations are documented in Appendix 1.
putdocx textblock end

// Results section
`heading'
putdocx text ("Results")

`subhead'
putdocx text ("Adverse pregnancy outcomes")

// Verify some assumptions in this section.
assert ${p_mcar} > 0.05
assert ${p_cdm}  > 0.05

`newpara'
Outcome data were missing for between 
<<dd_docx_display: string(${pc_min_miss}, "`pc_fmt'")>>% and 
<<dd_docx_display: string(${pc_max_miss}, "`pc_fmt'")>>% of the constituent 
outcomes, and <<dd_docx_display: string(${pc_miss_y}, "`pc_fmt'")>>% of the 
composite outcome. We were unable to reject the MCAR and CDM hypotheses 
(P=<<dd_docx_display: string(${p_mcar}, "`p_fmt'")>> and P=
<<dd_docx_display: string(${p_cdm}, "`p_fmt'")>>, respectively). Distributions 
of the original and the first five imputed data sets are shown in Appendix 2. 
Table 1 shows the result of the adverse pregnancy outcome analysis. The odds 
ratio was estimated to be <<dd_docx_display: string(${rr_b_y}, "`e_fmt'")>> 
(95% CI <<dd_docx_display: string(${rr_ll_y}, "`e_fmt'")>> to 
<<dd_docx_display: string(${rr_ul_y}, "`e_fmt'")>>, P = 
<<dd_docx_display: string(${rr_p_y}, "`p_fmt'")>>). This compares to the 
complete case odds ratio of <<dd_docx_display: string(${cc_or_b}, "`e_fmt'")>> 
(95% CI <<dd_docx_display: string(${cc_or_ll}, "`e_fmt'")>> to 
<<dd_docx_display: string(${cc_or_ul}, "`e_fmt'")>>, P = 
<<dd_docx_display: string(${cc_or_p}, "`p_fmt'")>>). Tables 2–6 show results for 
the constituent outcomes. The ICC was estimated to be close to zero and no 
greater than <<dd_docx_display: string(${icc_ub}, "%5.3f")>> (upper bound of 
95% CI). Table 7 shows the result for the stillbirth outcome.
putdocx textblock end

frame imputed {
  foreach var of varlist y y1-y5 {
    local ++tbl_num
    local var_label : variable label `var'
    local title "Table `tbl_num'. `var_label' (multiply-imputed result)"
    estimates replay `var'_estimates, eform
    putdocx table tbl_`tbl_num' = etable, title("`title'")
    putdocx table tbl_`tbl_num'(2, 1) = (" ") // Remove outcome var name.
    putdocx table tbl_`tbl_num'(2, 2) = ("Odds Ratio"), halign(right)
    local n_rows  23
    local n_start 5
    if "`var'" == "y2" local n_rows  16
    if "`var'" == "y2" local n_start 5
    forvalues i = `n_rows'(-1)`n_start' { // Drop rows not of interest.
      putdocx table tbl_`tbl_num'(`i', .), drop
    }
  }
}

tempname original
frame copy imputed `original'
frame `original' {
  mi extract 0, clear
  xtset clusterid
  local var stillbirth

  local ++tbl_num
  local var_label : variable label `var'
  local title "Table `tbl_num'. `var_label' (complete case result)"
  estimates replay `var'_estimates, or
  putdocx table tbl_`tbl_num' = etable, title("`title'")
  putdocx table tbl_`tbl_num'(2, 1) = (" ") // Remove outcome var name.
  putdocx table tbl_`tbl_num'(2, 2) = ("Odds Ratio"), halign(right)
  local n_rows  23
  local n_start 5
  forvalues i = `n_rows'(-1)`n_start' { // Drop rows not of interest.
    putdocx table tbl_`tbl_num'(`i', .), drop
  }
}

`subhead'
putdocx text ("Process outcomes — tables")

`newpara'
The following tables show odds ratios comparing treatment to control for each 
process outcome. Full regression results are presented in Appendix 3.
putdocx textblock end

foreach outcome of global process_outcomes {
  frame `outcome' {
    local ++tbl_num  
    local var_label : variable label y
    local title "Table `tbl_num'. `var_label' screening & management"
    estimates replay `outcome'_estimates, or
    putdocx table tbl_`tbl_num' = etable, title("`title'")
    putdocx table tbl_`tbl_num'(2, 1) = (" ") // Remove outcome var name.
    putdocx table tbl_`tbl_num'(2, 2) = ("Odds Ratio"), halign(right)
    putdocx table tbl_`tbl_num'(3, 2) = (""), halign(right) // Was "Coef."
    local n_rows  24
    local n_start 6
    if "`outcome'" == "malpresentation" local n_rows  23
    if "`outcome'" == "malpresentation" local n_start 5
    forvalues i = `n_rows'(-1)`n_start' { // Drop rows not of interest.
      putdocx table tbl_`tbl_num'(`i', .), drop
    }
  }
}

`subhead'
putdocx text ("Process outcomes — figures")

`newpara'
The following figures show marginal predictive probabilities for each process 
outcome.
putdocx textblock end

foreach outcome of global process_outcomes {
  putdocx image "${`outcome'_margins_fname}.png", linebreak
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
van Buuren, S. (2007). Multiple imputation of discrete and continuous data by 
fully conditional specification. Statistical methods in medical research, 
16(3), 219-242.
putdocx textblock end

`newpara'
Jakobsen, J. C., Gluud, C., Wetterslev, J., & Winkel, P. (2017). When and how 
should multiple imputation be used for handling missing data in randomised 
clinical trials–a practical guide with flowcharts. BMC medical research 
methodology, 17(1), 162.
putdocx textblock end

`newpara'
Li, F., Turner, E. L., Heagerty, P. J., Murray, D. M., Vollmer, W. M., & 
DeLong, E. R. (2017). An evaluation of constrained randomization for the design 
and analysis of group‐randomized trials with binary outcomes. Statistics in 
medicine, 36(24), 3791-3806.
putdocx textblock end

`newpara'
Little, R. J. (1988). A test of missing completely at random for multivariate 
data with missing values. Journal of the American statistical Association, 
83(404), 1198-1202.
putdocx textblock end

`newpara'
Rubin, D. B. (2004). Multiple imputation for nonresponse in surveys (Vol. 81). 
John Wiley & Sons.
putdocx textblock end

// Appendices

`heading'
putdocx text ("Appendix 1 — Protocol Deviations")

`newpara'
We planned to use generalized estimating equations (GEEs) but chose to use 
mixed-effects logistic regression throughout, which simplified the analyses. We 
planned to report risk ratios, but report odds ratios as provided by logistic 
regression. We did not plan to adjust for the stratification variable or the 
variables used as constraints in the randomization, but have done so based on 
guidance from the European Medicines Agency and research that was not available 
when the protocol was being developed. We planned to visually explore 
differences in process outcomes between clusters using spider graphs but judged 
that plots of marginal predictive probabilities show the required information 
more clearly and provide confidence intervals.
putdocx textblock end

`heading'
putdocx text ("Appendix 2 — Imputation")

`newpara'
The following figures show the distributions of the original and a selection of 
the imputed data.
putdocx textblock end

foreach var of newlist y1-y5 y $imputeds { // newlist as vars only exist in (other) frames.
  display "${`var'_plot_fname}"
  putdocx image "${`var'_plot_fname}.png", linebreak
}

`heading'
putdocx text ("Appendix 3 — Full Regression Results")

`subhead'
putdocx text ("Health outcomes")

`newpara'
The following tables show the full regression results for the health outcomes.
putdocx textblock end

frame imputed {
  foreach var of varlist y y1-y5 {
    local ++tbl_num
    local var_label : variable label `var'
    local title "Table `tbl_num'. `var_label' (multiply-imputed result)"
    estimates replay `var'_estimates, eform
    putdocx table tbl_`tbl_num' = etable, title("`title'")
    putdocx table tbl_`tbl_num'(2, 2) = ("Odds Ratio"), halign(right)
  }
}

tempname original
frame copy imputed `original'
frame `original' {
  mi extract 0, clear
  xtset clusterid
  local var stillbirth

  local ++tbl_num
  local var_label : variable label `var'
  local title "Table `tbl_num'. `var_label' (complete case result)"
  estimates replay `var'_estimates, or
  putdocx table tbl_`tbl_num' = etable, title("`title'")
  putdocx table tbl_`tbl_num'(2, 2) = ("Odds Ratio"), halign(right)
}

`subhead'
putdocx text ("Process outcomes")
`newpara'

The following tables show the full regression results for the process outcomes.
putdocx textblock end

foreach outcome of global process_outcomes {
  frame `outcome' {
    local ++tbl_num  
    local var_label : variable label y
    local title "Table `tbl_num'. `var_label' screening & management"
    estimates replay `outcome'_estimates, or
    putdocx table tbl_`tbl_num' = etable, title("`title'")
    putdocx table tbl_`tbl_num'(2, 2) = ("Odds Ratio"), halign(right)
    putdocx table tbl_`tbl_num'(3, 2) = (""), halign(right) // Was "Coef."
  }
}

// Save the report to the specified filename.
putdocx save `"`filename'"', replace
