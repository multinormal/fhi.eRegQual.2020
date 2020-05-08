version 16.1

args filename

// Some locals to make this file a little more readable.
local heading putdocx paragraph, style(Heading1)
local newpara putdocx textblock begin
local putdocx textblock end putdocx textblock end

local p_fmt %5.2f

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
This is some more text.
putdocx textblock end

// Methods section
`heading'
putdocx text ("Methods")

`newpara'
We used Little's tests of the null hypotheses that the constituent outcomes are 
jointly missing completely at random (MCAR) and covariate-dependent missing 
(CDM) using the significance criterion P < 0.05 (Little 1988).
putdocx textblock end

// Results section
`heading'
putdocx text ("Results")

`newpara'
We were unable to reject the MCAR and CDM hypotheses 
(P = <<dd_docx_display: string(${p_mcar}, "`p_fmt'")>> and P = 
<<dd_docx_display: string(${p_cdm}, "`p_fmt'")>>, respectively).
putdocx textblock end


// Appendix
`heading'
putdocx text ("Appendix")

`newpara'
This is some more text.
putdocx textblock end


// References
`heading'
putdocx text ("References")

`newpara'
Little, R. J. A.  1988.  A test of missing completely at random for multivariate 
data with missing values.  Journal of the American Statistical Association 83:
1198-1202.
putdocx textblock end


// Save the report to the specified filename.
putdocx save `"`filename'"', replace

