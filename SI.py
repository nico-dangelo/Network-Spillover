import queue
import igraph
import random
def SI(graph,beta=1):
  Q=queue.Queue()
  BT=igraph.Graph()
  s=random.choice(graph.vs)
  graph.vs[~s]["state"]="S"
  graph.vs[~s]["asc"]=None
  graph.vs[s]["state"]="I"
  Q.put(s)
  while len(Q)!=0:
    u=Q.get()
    SN=False
    for v in neighbors(u).sort:
      if graph.vs[v]["state"]=="S":
        if random()<= beta:
          graph.vs[v]["state"]="I"
          graph.vs[u]["asc"]=u
          BT.add_vertices(v)
          BT.add_edges([(u,v)])
          Q.put(v)
        else:
          SN=True
      if SN==True:
        Q.put(u)
  return(BT)

