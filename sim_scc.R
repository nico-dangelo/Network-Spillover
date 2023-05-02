require(igraph)
require(tidyverse)
require(purrr)
source("sim.R")
N<-100 #network population/ graph order
eprob<-0.1 #edge formation probability for ER model
phiv<-0.1 # underlying hiv prevalence
PrEP1<-0.2 # PrEP assignment coverage in control treatment (a)
PrEP2<-0.4 # PrEP assignment coverage in counterfactual treatment (a*)
# HIV risk by contact and PrEP allocation p
p1<-0.3 #P(HIV|Contact and -PrEP)
p2<-0.2 #P(HIV|Contact and PrEP)
nsim<-100
plots=F
set.seed(1000)
system.time({res<-nsim%>%rerun(sim(N=N,eprob=eprob,phiv=phiv,PrEP1=PrEP1,PrEP2=PrEP2, p1=p1,p2=p2))})
res_samp<-do.call("rbind",res)
res_samp<-cbind(res_samp,nsim=rep(nsim,nrow(res_samp)))
col_list=c("random","additive","regenerated")
means_samp<-res_samp%>%group_by(nsim,p1,p2)%>%summarise(across(all_of(col_list),mean))
var_samp<-res_samp%>%group_by(nsim,p1,p2)%>%summarise(across(all_of(col_list),var))
