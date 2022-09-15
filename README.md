# Causal estimands for effects in networks
Functions for estimation of causal effects under spillover on networks of PrEP on HIV risk
## Contents 
* [simnets.rmd](/simnets.rmd) is an R Markdown file that contains working definitions of the simulation functions,implements simulations across a variety of parameter combinations, generates figures to visualize results. Refer to R scripts for current stable standalone versions of functions.
* [sim.R](/sim.R) is the main function that generates the networks for each simulation run, computes the effect estimates and causal contrasts, and generates network plots.
* [simpar.R](/simpar.R) is a wrapper for sim.R that does repeated sampling for a particular set of parameters, implemented in parallel and outputs all results in a combined dataframe object.
* 


