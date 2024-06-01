# Causal estimands for effects in networks
Functions for estimation of causal effects under spillover on networks of PrEP on HIV risk
## Contents 
* [sim.R](/sim.R)
* [sim_par.R](/sim_par.R)
* [sim_scc.R](/sim_scc.R)
* [simnets.rmd](/simnets.rmd)
* [sim_submit.sh](sim_submit.sh)
* [sim_submit_ER_only.sh](sim_submit_ER_only.sh)
* [Figures](/Figures)
* [Data](/Data)
### sim.R
#### Description
The main function that generates the networks for each simulation run, computes the causal contrasts, and generates network plots.
Currently generates 4 [Erdős–Rényi random graph](https://en.wikipedia.org/wiki/Erd%C5%91s%E2%80%93R%C3%A9nyi_model), [Barabási-Albert scale-free](https://en.wikipedia.org/wiki/Barab%C3%A1si%E2%80%93Albert_model), or [Watts-Strogatz small-world](https://en.wikipedia.org/wiki/Watts%E2%80%93Strogatz_model) networks and computes estimates the overall effect of 2 levels of PrEP allocation on HIV risk.
#### Usage
```{r}
sim(N=20,phiv=0.1,PrEP1=0.1,PrEP2=0.2, p1=0.2,p2=0.1, plots=F,model=c("ER","BA","WS"),eprob=0.1,pow=1,nb=5,rprob=0.05)
```
#### Arguments
* N: the network size/graph order. Must be a positive integer. Default is 20.
* eprob: the edge formation probability for each graph. Must be a double in $(0,1]$. Default is 3/N.
* phiv: the HIV prevalence on each network. Must be a double in $(0,1)$. Default is 0.1.
* PrEP1: The control PrEP allocation coverage. Must be a double in $(0,1)$. Default is 0.1.
* PrEP2: The counterfactual PrEP allocation coverage. Must be a double in $(0,1]$. Default is 0.2.
* p1: The probability of a node being infected with HIV given an infectious contact and not being assigned to PrEP. Must be a double in $(0,1]$. Default is 0.2.
* p2: The probability of a node being infected with HIV given an infectious contact and being assigned to PrEP. Must be a double in $(0,1]$. Default is 0.1.
* plots: A flag indicating whether to display network plots for each scenario. Must be a logical. Default is FALSE.
* model: Indicates the generating model that should be used for the networks. Must be one of: "ER" for Erdos-Renyi random graphs, "BA" for Barabási-Albert scale-free, or "WS" for Watts-Strogatz small-world.  

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
* RD_random: On additive scale, the risk difference for the random allocation.
* RD_additive: On additive scale, the risk difference for the additive allocation.
* RD_regenerated: On additive scale, the risk difference for the regenerated scenario.
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
* Degree [Assortativity](https://en.wikipedia.org/wiki/Assortativity)
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
### sim_scc.R
#### Description
R script for use on a Shared Computing Cluster (SCC). Essentially a batch alternative to parallel computation with [sim_par](/sim_par.R). 
#### Usage
By default, only computes simulation results with nsim replications, but has optional lines to compute summary statistics and export them.
#### Value
CSV files of tables containing outputs of sim function. See [sim.R](/sim.R).

### simnets.rmd 
#### Description
An Rmarkdown file that implements simulations across combinations of all parameters. Controls parallel implementation via future arguments, generates dataframes of results for each manipulated parameter, as well as summary statistics and plots/figures.

### Data 
#### Description 
A folder containing RData files for all results, computed means, and variances for each parameter. Uses default arguments for non-graph-model parameters with ER graphs. For model-related parameters, uses $N=50$.

### sim_submit.sh
A shell script for submitting batches of jobs for a given combination of parameters on a shared computing cluster.
#### Arguments
For loops containing sequences of each parameter's input values. 
#### Usage
To restrict to a subset of inputs for a given parameter, change the sequence to a singleton. It is best to copy the "for" line of the loop and comment the original out. Be mindful of indentation.
### sim_submit_ER_only.sh
Shell script identical to sim_submit.sh, but restricted to Erdős–Rényi random graphs. Used for most parameter analyses.
### Shiny App
####  Interactive Network plots with options for generative model and allocation parameters are available via the Shiny App [simnets](http://nico-dangelo.shinyapps.io/simnets?_ga=2.198510827.570187884.1665692175-808405130.1665692175) 
