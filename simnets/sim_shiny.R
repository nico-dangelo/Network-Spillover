library(igraph)
library(multinet)
set.seed(1000)
sim_shiny<-function(N=20,phiv=0.1,PrEP1=0.1,PrEP2=0.2,model=c("ER","BA","WS"),eprob=0.1,pow=1,nb=5,rprob=0.05){
  model<-match.arg(model)
  # plot a random graph, 3 color options
  #control scenario graph, 10% assignment prob
  g<-if(model=="ER"){sample_gnp(N,eprob)} else if(model=="BA"){sample_pa(N,power=pow,directed=FALSE)} else if(model=="WS"){sample_smallworld(dim=1,size=N,nei=nb,p=rprob)}
  l_hiv_g<-round((gorder(g)*phiv),0)
  l_PrEP1_g<-round(((gorder(g)-l_hiv_g)*PrEP1),0)
  l_sus_g<-round((gorder(g)-(l_hiv_g+l_PrEP1_g)),0)
  vertex_attr(g) <- list(color=c(rep("red", l_hiv_g), rep("blue",l_PrEP1_g), rep("black",l_sus_g)))
  inf_contact_g<-setdiff(unlist(adjacent_vertices(g,v=V(g)[color=="red"])), V(g)[color=="red"])
  #Label infectious contacts
  treat_g<-V(g)[V(g)$color=="blue"]
  treat_inf_contact_g<- V(g)[inf_contact_g][which(V(g)[inf_contact_g]$color=="blue")]
  g<-set_vertex_attr(g,name="color",index=inf_contact_g,value="orange")
  g<-set_vertex_attr(g, name="color",index=treat_inf_contact_g,value="purple")
  #Randomly assign 20% overall (shuffle attributes)
  l_hiv_h<-round((gorder(g)*phiv),0)
  l_PrEP2_h<-round(((gorder(g)-l_hiv_h)*PrEP2),0)
  l_sus_h<-round((gorder(g)-(l_hiv_h+l_PrEP2_h)),0)
  h<-set_vertex_attr(g,"color",value=c(rep("red",l_hiv_h), sample(c(rep("blue",l_PrEP2_h), rep("black", l_sus_h)))))
  inf_contact_h<-setdiff(unlist(adjacent_vertices(h,v=V(h)[color=="red"])), V(h)[color=="red"])
  treat_h<-V(h)[V(h)$color=="blue"]
  treat_inf_contact_h<-V(h)[inf_contact_h][which(V(h)[inf_contact_h]$color=="blue")]
  h<-set_vertex_attr(h,name="color",index=inf_contact_h,value="orange")
  h<-set_vertex_attr(h, name="color",index=treat_inf_contact_h,value="purple")
  #duplicate network structure, additional 10% treated
  l_hiv_j<-round((gorder(g)*phiv),0)
  l_PrEP2_j<-round(((gorder(g)-l_hiv_j)*PrEP2),0)
  l_sus_j<-round((gorder(g)-(l_hiv_j+l_PrEP2_j)),0)
  j<-set_vertex_attr(g,"color",value=c(rep("red", l_hiv_j), rep("blue",l_PrEP2_j), rep("black", l_sus_j)))
  inf_contact_j<-setdiff(unlist(adjacent_vertices(j,v=V(j)[color=="red"])), V(j)[color=="red"])
  #Label infectious contacts
  treat_j<-V(j)[V(j)$color=="blue"]
  treat_inf_contact_j<-V(j)[inf_contact_j][which(V(j)[inf_contact_j]$color=="blue")]
  j<-set_vertex_attr(j,name="color",index=inf_contact_j,value="orange")
  j<-set_vertex_attr(j, name="color",index=treat_inf_contact_j,value="purple")
  # plot a random graph, 3 color options
  k <- if(model=="ER"){sample_gnp(N,eprob)} else if(model=="BA"){sample_pa(N,power=pow,directed=FALSE)} else if(model=="WS"){sample_smallworld(dim=1,size=N,nei=nb,p=rprob)}
  l_hiv_k<-round((gorder(k)*phiv),0)
  l_PrEP2_k<-round(((gorder(k)-l_hiv_k)*PrEP2),0)
  l_sus_k<-round((gorder(k)-(l_hiv_k+l_PrEP2_k)),0)
  vertex_attr(k) <- list(color =c(rep("red", l_hiv_k), rep("blue",l_PrEP2_k), rep("black", l_sus_k)))
  inf_contact_k<-setdiff(unlist(adjacent_vertices(k,v=V(k)[color=="red"])), V(k)[color=="red"])
  #Label infectious contacts
  treat_k<-V(k)[V(k)$color=="blue"]
  treat_inf_contact_k<-V(k)[inf_contact_k][which(V(k)[inf_contact_k]$color=="blue")]
  k<-set_vertex_attr(k,name="color",index=inf_contact_k,value="orange")
  k<-set_vertex_attr(k, name="color",index=treat_inf_contact_k,value="purple")
  #add vertex names
  g<-set_vertex_attr(g,"name",value=V(g))
  h<-set_vertex_attr(h,"name",value=V(h))
  j<-set_vertex_attr(j,"name",value=V(j))
  k<-set_vertex_attr(k,"name",value=V(k))
  n<-ml_empty()
  add_igraph_layer_ml(n,g,"control")
  add_igraph_layer_ml(n,h,"random")
  add_igraph_layer_ml(n,j,"additive")
  add_igraph_layer_ml(n,k,"regenerated")
  colors<-get_values_ml(n, "color", vertices=vertices_ml(n,layers=c("control","random","additive","regenerated")))
  pcols<-gplots::col2hex(t(colors))
  l2 <- layout_multiforce_ml(n, w_inter = 1, w_in = c(1, 0, 0, 0), gravity = c(1, 0, 0, 0))
  plot(n,layout=l2,vertex.color = pcols,vertex.labels = "",grid=c(1,5))
  legend("bottomright",pch=20,legend=c("HIV+","PrEP+ Contact-","PrEP+ Contact+","PrEP- Contact-","PrEP- Contact+"),col=c("red","blue","purple","black","orange"),pt.cex = 1, cex = 0.75, inset = c(0.05, 0.05))
  return()
}
