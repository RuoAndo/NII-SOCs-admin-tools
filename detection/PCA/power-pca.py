import sys
import numpy as np

magic_data = np.genfromtxt(sys.argv[1], delimiter=',')

X = magic_data[:,range(8)]

X_cen = X-np.mean(X, axis=0)
cov_est = np.dot(X_cen.T, X_cen)/X_cen.shape[0]
cov_true = np.cov(X.T)

eps = 0.0001
dif = 1

w = np.ones(X.shape[1])
w_new = np.ones(X.shape[1])
while (dif > eps):
    w = w_new
    w_tmp = np.dot(cov_est, w)
    ind = np.abs(w_tmp).argmax()
    w_new = w_tmp/w_tmp[ind]
    dif = np.dot(w_new-w, w_new-w)

eig_val = np.dot(np.dot(cov_est, w_new), w_new)/np.dot(w_new, w_new)
eig_vec = w_new/np.sqrt(np.dot(w_new, w_new))

eig_val_true, eig_vec_true = np.linalg.eig(cov_est)

X_proj = np.dot(X_cen, eig_vec_true[:,[0,1]])
var1 = np.var(X_proj[:,0])
var2 = np.var(X_proj[:,1])

def calPCA(sigma, comp):
    eig_vals, eig_vecs = np.linalg.eig(sigma)
    return {'eig_val': eig_vals[comp-1], 'eig_vec': eig_vecs[:,comp-1]}


total_var = 0
for i in range(X.shape[1]):
    total_var = total_var + calPCA(cov_est, i+1)['eig_val']
    
prop = 0
comp = 1 
cur_var = 0
comp_vecs = np.zeros([X.shape[1], X.shape[1]])   
while (prop < 0.9):
    cur_var = cur_var + calPCA(cov_est, comp)['eig_val']
    prop = cur_var/total_var
    comp_vecs[:,comp-1] = calPCA(cov_est, comp)['eig_vec']
    comp = comp+1

X_new = np.dot(X, comp_vecs[:,range(comp-1)]) 

for x in X_new:
    print x

