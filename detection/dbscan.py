def dbscan(Pts , distance , eps , minPts):
  visited = set([])
  Noise = set([])
  clusters = []
  for P in Pts:
    if P in visited:continue
    visited.add(P)
    seeds = [q for q in Pts if distance(P,q)<eps and P!=q]
    if len(seeds)<minPts:
       Noise.add(P)
    else:
       cluster = [P]
       while 1:
         if len(seeds)==0:break
         Q = seeds.pop()
         if not (Q in visited):
            N = [q for q in Pts if distance(Q,q)<eps and Q!=q]
            if len(N)>=minPts:
               seeds += N
         if not (Q in visited) or (Q in Noise):
            cluster.append(Q)
            visited.add(Q)
            if Q in Noise:Noise.remove(Q)
       clusters.append( cluster )
  return (clusters,Noise)

if__name__=="__main__":
   sqrt = __import__("math").sqrt
   S0 = [(0.0 , 0.0)]
   S1 = [(0.99+0.1*n , 0) for n in xrange(10)]
   S2 = [(-0.99-0.1*n , 0) for n in xrange(10)]
   S=S0+S1+S2
   dbscan(S , lambda x,y:sqrt((x[0]-y[0])**2+(x[1]-y[1])**2) , 1.0 , 3)

