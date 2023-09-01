sim_par<-function(N=20,phiv=0.1,PrEP1=0.1,PrEP2=0.2, p1=0.2,p2=0.1, scale="additive",model="ER",eprob=0.1,pow=1,nb=5,rprob=0.05,nsim=100){
  res<-future_map_dfr(1:nsim,~sim(N=N,phiv=phiv,PrEP1=PrEP1,PrEP2=PrEP2,p1=p1,p2=p2,scale=scale,model=model,eprob=eprob,pow=pow,nb=nb,rprob=rprob))
  res<-cbind(res,nsim)
  return(res)}