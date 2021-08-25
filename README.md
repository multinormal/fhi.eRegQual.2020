# eRegQual Trial Analysis

## Introduction

This repository contains analyses for the eRegQual and eRegTime triasl.
See:

* Venkateswaran et al. *eRegQual—An electronic health registry with interactive 
checklists and clinical decision support for improving quality of antenatal 
care: study protocol for a cluster randomized trial*. Trials, 2018, 19(1), 54.
* Lindberg et al. *eRegTime, efficiency of health information management
using an electronic registry for maternal and child health: Protocol for a
time-motion study in a cluster randomized trial*. JMIR Research Protocols,
2019, 8(8), e13653.

## Setup

The analysis is implemented using Stata 16. This analysis embeds the current 
git revision hash in the generated reports. To do this, the code shells out
to the `git` program. It is assumed that `git` is installed on your system
and is on whatever search path Stata uses. A Mac or UNIX environment is
assumed; shelling out to `git` may not work on Windows (this has not been
tested).

The data are not included in this repository. The names of the required files
are specified in the `data/birth_outcomes.do` and `globals/globals.do` files,
along with the expected data signatures of those files. The analysis checks
that the data being analyzed is as expected.

## Running the analyses

Once the above setup is complete, the analyses can be run by setting the
repository's directory as Stata's current working directory and running `do all`.
Note that the analysis will change the path of the `PERSONAL` directory to the
`packages` directory.

The reports and figures will be written to the `products` directory, replacing
the versions of those files that already exist. Note that becuase the analysis
used multiple imputation and computes multiple sets of marginal predictive
probabilities over relatively large data sets, the full analysis takes about
20 minutes to run on a 2017-vintage MacBook Pro.
