version 16.1

args filename

// Some locals to make this file a little more readable.
local heading putdocx paragraph, style(Heading1)
local newpara putdocx textblock begin, halign(both)
local putdocx textblock end putdocx textblock end

local p_fmt   %5.2f // Format used for P-values.
local pc_fmt  %8.1f // Format used for percentages.

// Start the document.
putdocx begin

// Title.
putdocx paragraph, style(Title)
putdocx text ("eRegQual analysis")

// Author and revision information.
`newpara'
Chris Rose, Norwegian Institute of Public Health 
(<<dd_docx_display: c(current_time) c(current_date)>>)
putdocx textblock end
`newpara'
Git revision: <<dd_docx_display: "${git_revision}">>
putdocx textblock end

// Introduction section.
`heading'
putdocx text ("Introduction")

`newpara'
TODO: Write this
putdocx textblock end

// Methods section
`heading'
putdocx text ("Methods")

`newpara'
Because outcome data were missing for about a third of participants (see 
results), we used Little's tests (Little 1988) of the null hypotheses that 
missing values of the constituent outcomes were jointly missing completely at 
random (MCAR) and covariate-dependent missing (CDM). We then used multiple 
imputation via chained equations (van Buuren 2007) to create and analyze 
<<dd_docx_display: $m_imputations>> multiply-imputed datasets. Methodologists 
currently regard multiple imputation as a state-of-the-art technique that 
is expected to reduce bias and increase precision relative to other missing 
data techniques. We imputed each of the constituent outcomes using the auxiliary 
variables age, BMI, years of education, average monthly household income 
(transformed to the log scale due to the highly skewed distribution of income), 
and variables that indicated whether a laboratory or ultrasound were available 
at the clinics; the variables included in the analysis described below were also 
included. We were not able to include auxiliary variables that indicated previous 
pregnancy with pre-eclampsia and previous history of GDM due to collinearity. 
We evaluated the convergence of the imputation algorithm by inspecting trace 
plots and evaluated imputed data by inspecting kernel density and bar plots 
comparing the distributions of imputed and complete case data. For each imputed 
data set, we computed the composite outcome from the imputed constituent outcome 
data and estimated an odds ratio to compare treatment to control, adjusting for 
the stratification variable as a fixed effect, using generalized estimating 
equations (GEE; binomial errors and logit link) to account for the cluster 
design. Estimates were then combined using Rubin's rules. For comparison, we 
also performed a complete case analysis under the MCAR assumption. We followed 
the intention-to-treat principle: participants were analyzed in the arms to 
which they were randomized and — with the exception of the complete case 
analysis — all participants were included in the analyses. We computed 95% 
confidence intervals and used the significance criterion P<0.05 throughout. 
Statistical analyses were performed using Stata 16 (StataCorp LLC, College 
Station, Texas, USA).
putdocx textblock end

// Results section
`heading'
putdocx text ("Results")

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
<<dd_docx_display: string(${p_cdm}, "`p_fmt'")>>, respectively).
putdocx textblock end

//estimates restore est_main_result
estimates replay est_main_result, eform
putdocx table tbl_main_result = etable, title("TODO: Main result")

// Appendix
`heading'
putdocx text ("Appendix")

`newpara'
TODO: Write this
putdocx textblock end


// References
`heading'
putdocx text ("References")

`newpara'
Little, R. J. (1988). A test of missing completely at random for multivariate 
data with missing values. Journal of the American statistical Association, 
83(404), 1198-1202.
putdocx textblock end

`newpara'
van Buuren, S. (2007). Multiple imputation of discrete and continuous data by 
fully conditional specification. Statistical methods in medical research, 
16(3), 219-242.
putdocx textblock end


// Save the report to the specified filename.
putdocx save `"`filename'"', replace

