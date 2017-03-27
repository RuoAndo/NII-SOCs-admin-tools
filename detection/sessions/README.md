# session analysis with PCM + SVM

requirements

<pre>
g++ - GNU C++ compiler
libeigen3-dev - lightweight C++ template library for linear algebra
libsvm-tools - LIBSVM binary tools
python-scipy - scientific tools for Python

apt-get install g++
apt-get install python-scipy
apt-get install libeigen3-dev
apt-get install python-pip

pip install numpy
pip install sklearn
</pre>

sample session-data: test-100

<pre>
753594334,10044,***,***,112
753594335,10043,***,***,86
753594337,0,***,***,291
</pre>

dimension reduction

<pre>
# g++ pca.cpp -o pca
# ./a.out test-100 > tmp
6.12584e+19 -1.66509e+19
6.57824e+19 -1.33873e+19
8.33433e+18 -1.60842e+17
</pre>

one-class SVM 

<pre>
# python one-class-svm.py tmp > tmp2
None
6.12584e+19,-1.66509e+1,-1.0,
6.57824e+19,-1.33873e+1,-1.0,
8.33433e+18,-1.60842e+1,-1.0,
9.36857e+19,-2.43238e+1,-1.0,
6.1222e+19,2.09804e+1,-1.0,
9.39074e+19,3.18552e+1,-1.0,
</pre>

pre-precess for LibSVM

<pre>
# python preprocess.py tmp2 > tmp3
-1.0 1:6.12584e+19 2:-1.66509e+1
-1.0 1:6.57824e+19 2:-1.33873e+1
-1.0 1:8.33433e+18 2:-1.60842e+1
</pre>

LibSVM

<pre>

# svm-train tmp3
.*
optimization finished, #iter = 175
nu = 0.840000
obj = -46.963635, rho = 0.236362
nSV = 99, nBSV = 42
Total nSV = 99

# more tmp3.model
svm_type c_svc
kernel_type rbf
gamma 0.5
nr_class 2
total_sv 99
rho 0.236362
label -1 1
nr_sv 42 57
SV
1 1:6.12584e+19 2:-16.6509
1 1:6.57824e+19 2:-13.3873
1 1:8.33433e+18 2:-16.0842
1 1:9.36857e+19 2:-24.3238
1 1:6.1222e+19 2:20.9804
1 1:9.39074e+19 2:31.8552
1 1:1.46169e+20 2:-57.7948

</pre>