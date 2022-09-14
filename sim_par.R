sim_par<-function(N=20,eprob=0.1,phiv=0.1,PrEP1=0.1,PrEP2=0.2, p1=0.2,p2=0.1, nsim=100, scale="additive"){
  res<-future_map_dfr(1:nsim,~sim(N=N,eprob=eprob,phiv=phiv,PrEP1=PrEP1,PrEP2=PrEP2, p1=p1,p2=p2, scale=scale))
  res<-cbind(res,nsim)
  return(res)}