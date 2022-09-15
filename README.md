# Causal estimands for effects in networks
Functions for estimation of causal effects under spillover on networks of PrEP on HIV risk
## Contents 
* [sim.R](/sim.R)
* [simpar.R](/simpar.R)
* [simnets.rmd](/simnets.rmd)
### sim.R
#### Description
The main function that generates the networks for each simulation run, computes the effect estimates and causal contrasts, and generates network plots.
Currently generates 4 networks and computes estimates the overall effect of 2 levels of PrEP allocation on HIV risk.
##### Scenarios
* Control: 
#### Usage
```{r}
sim<-function(N=20,eprob=0.1,phiv=0.1,PrEP1=0.1,PrEP2=0.2, p1=0.2,p2=0.1, plots=F, scale="additive")
```
#### Arguments
* N: the network size/graph order. Must be a positive integer. Default is 20.
* eprob
* phiv
* PrEP1
* PrEP2
* p1
* p2
* plots
* scale
#### Output 
"res": a 1 $\times$ 18 dataframe containing input parameters (N,eprob,phiv,PrEP1,PrEP2,p1,p2), effect estimates for each network/scenario 
### simpar.R
A wrapper for sim.R that does repeated sampling for a particular set of parameters, implemented in parallel and outputs all results in a combined dataframe object.
#### Usage
#### Arguments
#### Value

### simnets.rmd 
