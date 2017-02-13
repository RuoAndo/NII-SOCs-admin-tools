import matplotlib.pyplot as plt
import random
import numpy as np

x1 = []
y1 = []

x2 = []
y2 = []

xx = []
yy = []

def dbscan(Points , distance , eps , minPts):

  visited = set([])
  Noise = set([])
  clusters = []

  for P in Points:
    if P in visited:continue
    visited.add(P)
    seeds = [q for q in Points if distance(P,q)<eps and P!=q]

    print "distance:" + str(distance(P,q))
    if len(seeds)<minPts:
       Noise.add(P)
    else:
       cluster = [P]
       while 1:
         if len(seeds)==0:break
         Q = seeds.pop()
         if not (Q in visited):
            N = [q for q in Points if distance(Q,q)<eps and Q!=q]
            if len(N)>=minPts:
               seeds += N
         if not (Q in visited) or (Q in Noise):
            cluster.append(Q)
            visited.add(Q)
            if Q in Noise:Noise.remove(Q)
       clusters.append( cluster )
  #print "clusters:" + str(clusters)
  print "noise:" + str(Noise)

  clusters2 = [flatten for inner in Noise for flatten in inner]
  
  for i in Noise:
    #print "i:" + str(i)
    x1.append(int(i[0]))
    y1.append(int(i[1]))

  #print "x1:" + str(x1)
  #print "y1: " + str(y1)
 
  return (clusters,Noise)

if __name__ == '__main__':
   sqrt = __import__("math").sqrt
   S0 = [(0.0 , 0.0)]
   #S1 = [(0.99+0.1*n , 0) for n in xrange(10)]
   #S2 = [(-0.99-0.1*n , 0) for n in xrange(10)]

   S1 = [(random.uniform(1,100) , random.uniform(1,100)) for n in xrange(10)]
   S2 = [(random.uniform(1,100) , random.uniform(1,100)) for n in xrange(10)]
   
   S=S0+S1+S2

   print random.uniform(1,100)

   for i in S:
     xx.append(int(i[0]))
     yy.append(int(i[1]))
        
   dbscan(S , lambda x,y:sqrt((x[0]-y[0])**2+(x[1]-y[1])**2) , 30 , 2)
   
   print "xx:" + str(xx)
   print "yy: " + str(yy)

   plt.scatter(np.array(xx),np.array(yy), linewidth=10 , c = 'blue', alpha=0.1)

   print "x1:" + str(np.array(x1))
   print "y1: " + str(np.array(y1))
   
   plt.scatter(np.array(x1),np.array(y1), c='green')
   plt.scatter(np.array(x1),np.array(y1))
   plt.show()
