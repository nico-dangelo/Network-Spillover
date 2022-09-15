# Causal estimands for effects in networks
Functions for estimation of causal effects under spillover on networks of PrEP on HIV risk
## Contents 
* [sim.R](/sim.R)
* [simpar.R](/simpar.R)
* [simnets.rmd](/simnets.rmd)
### sim.R
#### Description
The main function that generates the networks for each simulation run, computes the effect estimates and causal contrasts, and generates network plots.
##### Usage
#### Output 

### simpar.R
A wrapper for sim.R that does repeated sampling for a particular set of parameters, implemented in parallel and outputs all results in a combined dataframe object.

### simnets.rmd 
