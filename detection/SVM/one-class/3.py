import numpy as np
import matplotlib.pyplot as plt
import matplotlib.font_manager
from scipy import stats

from sklearn import svm
from sklearn.covariance import EllipticEnvelope

n_samples = 400 
outliers_fraction = 0.05

#clusters_separation = [0, 1, 2]
clusters_separation = [0]

xx, yy = np.meshgrid(np.linspace(-7, 7, 500), np.linspace(-7, 7, 500))

n_inliers = int((1. - outliers_fraction) * n_samples) 
n_outliers = int(outliers_fraction * n_samples) 
ground_truth = np.ones(n_samples, dtype=int) 
ground_truth[-n_outliers:] = 0

for i, offset in enumerate(clusters_separation): 
    np.random.seed(42)

    X1 = 0.3 * np.random.randn(0.25 * n_inliers, 2) - offset 
    X2 = 0.3 * np.random.randn(0.25 * n_inliers, 2) + offset 

    X3 = np.c_[
            0.3 * np.random.randn(0.25 * n_inliers, 1) - 3*offset, 
            0.3 * np.random.randn(0.25 * n_inliers, 1) + 3*offset  
        ]

    X4 = np.c_[
            0.3 * np.random.randn(0.25 * n_inliers, 1) + 3*offset, 
            0.3 * np.random.randn(0.25 * n_inliers, 1) - 3*offset  
        ]

    X = np.r_[X1, X2, X3, X4] 
    X = np.r_[X, np.random.uniform(low=-6, high=6, size=(n_outliers, 2))] 

    #plt.figure(figsize=(10, 12))
    #plt.figure(figsize=(5, 6))
    #plt.scatter(X[:-n_outliers, 0], X[:-n_outliers, 1], c='white')
    #plt.scatter(X[-n_outliers:, 0], X[-n_outliers:, 1], c='black')
    #plt.show()

    print X
