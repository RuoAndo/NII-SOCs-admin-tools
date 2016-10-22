# nii-cyber-security-admin

# K-means 
  <pre>
   -bash-4.1# python km.py test.txt 
   0 739.828002664 
   1 364.390406921 
   2 361.377450751 
   3 359.252127268 
   4 355.706047096 
   5 349.6218553
   6 346.753583962 
   7 346.018573918
   8 345.671668541
   9 345.170391332 
   10 344.946493745
  </pre>

# Changepoint detection
  <pre>
  -bash-4.1# apt-get install scipy
  -bash-4.1# easy_install cython
  -bash-4.1# easy_install pandas
  -bash-4.1# easy_install -U statsmodels
  -bash-4.1# python cpd.py
  </pre>
  
  <img src="changepoint-detection-1.png">
  <img src="changepoint-detection-2.png">

# K-means with pylab plots
  <pre>
  -bash-4.1# apt-get install python-matplotlib
  -bash-4.1# python km2.py test.txt
  </pre>
  
  <img src="kmeans-1.png">