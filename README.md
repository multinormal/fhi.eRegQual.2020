# eRegQual Trial Analysis

## Introduction

This repository contains analyses for the eRagQual trial. See Venkateswaran 
et al. *eRegQual—an electronic health registry with interactive 
checklists and clinical decision support for improving quality of antenatal 
care: study protocol for a cluster randomized trial*. Trials, 2018, 19(1), 54.

## Setup

The analysis is implemented using Stata 16. This analysis embeds the current 
git revision hash in the generated reports. To do this, the code shells out
to the `git` program. It is assumed that `git` is installed on your system
and is on whatever search path Stata uses. The analysis will change the path
of the `PERSONAL` directory to the `packages` directory.

## Running the analyses

Once the above setup is complete, the analyses can be run by setting the
repository's directory as Stata's current working directory and running `do all`.
The reports and figures will be written to the `products` directory, replacing
the versions of those files that already exist. Note that becuase the analysis
used multiple imputation and computes multiple sets of marginal predictive
probabilities over relatively large data sets, the full analysis takes about
20 minutes to run on a 2017-vintage MacBook Pro.