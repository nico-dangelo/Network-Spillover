require(igraph)
require(tidyverse)
require(purrr)
source("sim.R")
#get arguments from command line. These will be all be characters in a vector, and need to be coerced to the corrected type
argv <- commandArgs(TRUE)
N<-as.numeric(argv[1]) #network population/ graph order
eprob<-3/N #edge formation probability for ER model 
phiv<-as.numeric(argv[2]) # underlying hiv prevalence
PrEP1<-as.numeric(argv[3]) # PrEP assignment coverage in control treatment (a) 
PrEP2<-as.numeric(argv[4]) # PrEP assignment coverage in counterfactual treatment (a*)
#HIV risk by contact and PrEP allocation p
p1<-as.numeric(argv[5]) #P(HIV|Contact and -PrEP)
p2<-as.numeric(argv[6]) #P(HIV|Contact and PrEP)
model<-argv[7]
nsim<-as.numeric(argv[8])
plots=F
set.seed(1000)
system.time({res<-nsim%>%rerun(sim(N=N,eprob=eprob,phiv=phiv,PrEP1=PrEP1,PrEP2=PrEP2,p1=p1,p2=p2, model=model, nsim=nsim))})
res<-do.call("rbind",res)
res<-cbind(res,nsim=rep(nsim,nrow(res)))
# col_list=c("random_contrast","additive_contrast","regenerated_contrast")
#Uncomment these lines to run summary analyses
#means<-res%>%group_by(nsim,p1,p2)%>%summarise(across(all_of(col_list),mean))
#vars<-res%>%group_by(nsim,p1,p2)%>%summarise(across(all_of(col_list),var))
#Check directory
setwd("/restricted/projectnb/causal/Nico/output")
write.table(res,file=paste0("SCC Results","N_",N,"phiv_",phiv,"PrEP1_",PrEP1,"PrEP2_",PrEP2,"p1_",p1,"p2_",p2,"model_",model,"nsim_",nsim,".csv"))
#If summary dataframes are created, use this save line instead
#write.table(res,means, vars,file=paste0("SCC Results","N_",N,"p1_",p1,"p2_",p2,"nsim_",".csv"))
