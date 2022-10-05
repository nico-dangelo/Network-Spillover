# Causal estimands for effects in networks
Functions for estimation of causal effects under spillover on networks of PrEP on HIV risk
## Contents 
* [sim.R](/sim.R)
* [sim_par.R](/sim_par.R)
* [simnets.rmd](/simnets.rmd)
### sim.R
#### Description
The main function that generates the networks for each simulation run, computes the effect estimates and causal contrasts, and generates network plots.
Currently generates 4 [Erdős–Rényi random graph](https://en.wikipedia.org/wiki/Erd%C5%91s%E2%80%93R%C3%A9nyi_model) or [Barabási-Albert scale-free](https://en.wikipedia.org/wiki/Barab%C3%A1si%E2%80%93Albert_model) networks and computes estimates the overall effect of 2 levels of PrEP allocation on HIV risk.
#### Usage
```{r}
sim(N=20,eprob=0.1,phiv=0.1,PrEP1=0.1,PrEP2=0.2, p1=0.2,p2=0.1, plots=F, scale="additive")
```
#### Arguments
* N: the network size/graph order. Must be a positive integer. Default is 20.
* eprob: the edge formation probability for each graph. Must be a double in $(0,1]$. Default is 0.1.
* phiv: the HIV prevalence on each network. Must be a double in $(0,1)$. Default is 0.1.
* PrEP1: The control PrEP allocation coverage. Must be a double in $(0,1)$. Default is 0.1.
* PrEP2: The counterfactual PrEP allocation coverage. Must be a double in $(0,1]$. Default is 0.2.
* p1: The probability of a node being infected with HIV given an infectious contact and not being assigned to PrEP. Must be a double in $(0,1]$. Default is 0.2.
* p2: The probability of a node being infected with HIV given an infectious contact and being assigned to PrEP. Must be a double in $(0,1]$. Default is 0.1.
* plots: A flag indicating whether to display network plots for each scenario. Must be a logical. Default is FALSE.
* scale: Indicates whether to compute effect estimates on an additive or multiplicative scale. Must be a string in {"additive", "multiplicative"}. Default is "addtive".
#### Output 
"res": a 1 $\times$ 36 dataframe containing input parameters (N,eprob,phiv,PrEP1,PrEP2,p1,p2), 
effect estimate vectors (prep, no_prep) and causal contrast estimates (ran, add, regen) for each network/scenario.
##### Scenarios
* g: Control network with HIV prevalence phiv, with random allocation of PrEP1 coverage to susceptible nodes. 
* h: Random assignment of PrEP2 coverage on the control network.
* j: Fix the PrEP1 assignment from g, assign the remaining (PrEP2-PrEP1) coverage at random to additional susceptible nodes.
* k: Regenerate a new network with phiv prevalence and assign PrEP2 coverage at random to susceptible nodes. 
##### Counterfactual estimates
* prep vector contains hiv_given_prep_.: the estimated probability of hiv given a node is assigned to PrEP.
* no_prep vector contains hiv_given_no_prep_.:  the estimated probability of hiv given a node is not assigned to PrEP.

##### Causal Contrast Estimates
* ran: On additive scale, the difference (prep[h]+no_prep[h])-(prep[g]+no_prep[g]).
* add: On additive scale, the difference (prep[j]+no_prep[j])-(prep[g]+no_prep[g]).
* regen: On additive scale, the difference (prep[k]+no_prep[k])-(prep[g]+no_prep[g]).
##### Network Summary Statistics
* Number of [Connected Components](https://en.wikipedia.org/wiki/Component_(graph_theory))
* Largest Component Size
* Average [Betweenness Centrality](https://en.wikipedia.org/wiki/Betweenness_centrality)
* Edge [Density](https://en.wikipedia.org/wiki/Dense_graph)
* [Degree Centralization](https://en.wikipedia.org/wiki/Centrality#Degree_centrality)
* Average [Geodesic Distance](https://en.wikipedia.org/wiki/Distance_(graph_theory))
* [Graph Diameter](https://en.wikipedia.org/wiki/Distance_(graph_theory))
* Transitivity:The proportion of all triads that exhibit closure/ form a complete triangle.
* Proportion of nodes in [2-cores](https://en.wikipedia.org/wiki/Degeneracy_(graph_theory)#k-Cores) \
For graphs g (control) and k (regenerated)
### sim_par.R
A wrapper for sim.R that performs repeated sampling for a particular set of parameters, implemented in parallel (using the "furrr" package) and outputs all results in a combined dataframe object.
#### Usage
```{r}
sim_par(...)
```
#### Arguments
* ... arguments to be passed to sim()
* nsim: the number of simulations to be run for each combination of other parameters. Must be a positive integer. Default is 100.
#### Value
An nsim $\times$ 37 dataframe containing the same outputs as sim() with an index nsim for the set (number of simulations) to which an output row belongs.
### simnets.rmd 
#### Description
An Rmarkdown file that implements simulations across combinations of all parameters. Controls parallel implementation via future arguments, generates dataframes of results for each manipulated parameter, as well as summary statistics and plots/figures.

