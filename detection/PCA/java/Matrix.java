class Matrix {
	
	static int numMults = 0; //Keeps track of the number of multiplications performed
	
	public static void main(String[] args) {
		System.out.println("Original matrix:");
		double[][] test = {{5, -1}, {5, 7}}; //C
		Matrix.print(test);
		double[][][] SVD = Matrix.singularValueDecomposition(test);
		double[][] U = SVD[0];
		double[][] S = SVD[1];
		double[][] V = SVD[2];
		System.out.println("U: Unitary matrix:");
		Matrix.print(U);
		System.out.println("Sigma-matrix:");
		Matrix.print(S);
		System.out.println("V: orthogonal matrix:");
		Matrix.print(V);
		System.out.println("Decomposition product (C = US(V^T)):");
		Matrix.print(Matrix.multiply(U, Matrix.multiply(S, Matrix.transpose(V)))); 
	}
	
        /* singular value decomposition */	
	static double[][][] singularValueDecomposition(double[][] input) {
		double[][] C = Matrix.copy(input);
		double[][] CTC = multiply(transpose(C), C); //(C^T)C = V(S^T)S(V^T)
		EigenSet eigenC = eigenDecomposition(CTC);
		double[][] S = new double[C.length][C.length]; //Diagonal matrix
		for(int i = 0; i < S.length; i++) {
			S[i][i] = Math.sqrt(eigenC.values[i]); 
		}
		double[][] V = eigenC.vectors;
		double[][] CV = multiply(C, V); //CV = US
		double[][] invS = copy(S); //Inverse of S
		for(int i = 0; i < invS.length; i++) {
			invS[i][i] = 1.0/S[i][i];
		}
		double[][] U = multiply(CV, invS); //U = CV(S^-1)
		return new double[][][] {U, S, V};
	}
	
	static EigenSet eigenDecomposition(double[][] input) {
		if(input.length != input[0].length) {
			throw new MatrixException("Eigendecomposition not defined on nonsquare matrices.");
		}
		double[][] copy = copy(input);
		double[][] Q = new double[copy.length][copy.length];
		for(int i = 0; i < Q.length; i++) {
			Q[i][i] = 1; //Q starts as an identity matrix
		}
		boolean done = false;
		while(!done) {
			double[][][] fact = Matrix.QRFactorize(copy);
			double[][] newMat = Matrix.multiply(fact[1], fact[0]);
			Q = Matrix.multiply(fact[0], Q);

			for(int i = 0; i < copy.length; i++) {
				if(Math.abs(newMat[i][i] - copy[i][i]) > 0.00001) {
					copy = newMat;
					break;
				} else if(i == copy.length - 1) { //End of copy table
					done = true;
				}
			}
		}
		EigenSet ret = new EigenSet();
		ret.values = Matrix.extractDiagonalEntries(copy); //Eigenvalues lie on diagonal
		ret.vectors = Q; 
		return ret;
	}
	
	static double[] extractDiagonalEntries(double[][] input) {
		double[] out = new double[input.length];
		for(int i = 0; i<input.length; i++) {
			out[i] = input[i][i];
		}
		return out;
	}
	
	static double[][][] QRFactorize(double[][] input) {
		double[][][] out = new double[2][][];
		double[][] orthonorm = gramSchmidt(input);
		out[0] = orthonorm; 
		double[][] R = new double[orthonorm.length][orthonorm.length];
		for(int i = 0; i < R.length; i++) {
			for(int j = 0; j <= i; j++) {
				R[i][j] = dot(input[i], orthonorm[j]);
			}
		}
		out[1] = R;
		return out;
	}
	
	static double[][] gramSchmidt(double[][] input) {
		double[][] out = new double[input.length][input[0].length];
		for(int outPos = 0; outPos < out.length; outPos++) {
			double[] v = input[outPos];
			for(int j = outPos - 1; j >= 0; j--) {
				double[] sub = proj(v, out[j]);
				v = subtract(v, sub); //Subtract off non-orthogonal components
			}
			out[outPos] = normalize(v); //return an orthonormal list
		}
		return out;
	}
	
	static double[][] GivensRotation(int size, int i, int j, double th) {
		double[][] out = new double[size][size];
		double sine = Math.sin(th);
		double cosine = Math.cos(th);
		for(int x = 0; x < size; x++) {
			if(x != i && x != j) {
				out[x][x] = cosine;
			} else {
				out[x][x] = 1;
			}
		}
		out[i][j] = -sine;//ith column, jth row
		out[j][i] = sine;
		return out;
	}
	
	static double[][] transpose(double[][] matrix) {
		double[][] out = new double[matrix[0].length][matrix.length];
		for(int i = 0; i < out.length; i++) {
			for(int j = 0; j < out[0].length; j++) {
				out[i][j] = matrix[j][i];
			}
		}
		return out;
	}
	
	static double[][] add(double[][] a, double[][] b) {
		if(a.length != b.length || a[0].length != b[0].length) {
			throw new MatrixException("Matrices not same size.");
		}
		double[][] out = new double[a.length][a[0].length];
		for(int i = 0; i < out.length; i++) {
			for(int j = 0; j < out[0].length; j++) {
				out[i][j] = a[i][j] + b[i][j];
			}
		}
		return out;
	}
	
	static double[][] subtract(double[][] a, double[][] b) {
		if(a.length != b.length || a[0].length != b[0].length) {
			throw new MatrixException("Matrices not same size.");
		}
		double[][] out = new double[a.length][a[0].length];
		for(int i = 0; i < out.length; i++) {
			for(int j = 0; j < out[0].length; j++) {
				out[i][j] = a[i][j] - b[i][j];
			}
		}
		return out;
	}
	
	static double[] add(double[] a, double[] b) {
		if(a.length != b.length) {
			throw new MatrixException("Vectors are not same length.");
		}
		double[] out = new double[a.length];
		for(int i = 0; i < out.length; i++) {
			out[i] = a[i] + b[i];
		}
		return out;
	}
	
	static double[] subtract(double[] a, double[] b) {
		if(a.length != b.length) {
			throw new MatrixException("Vectors are not same length.");
		}
		double[] out = new double[a.length];
		for(int i = 0; i < out.length; i++) {
			out[i] = a[i] - b[i];
		}
		return out;
	}
	
	static double[][] multiply(double[][] a, double[][] b) {
		if(a.length != b[0].length) {
			throw new MatrixException("Matrices not compatible for multiplication.");
		}
		double[][] out = new double[b.length][a[0].length];
		for(int i = 0; i < out.length; i++) {
			for(int j = 0; j < out[0].length; j++) {
				double[] row = getRow(a, j);
				double[] column = getColumn(b, i);
				out[i][j] = dot(row, column);
			}
		}
		return out;
	}
	
	static double[][] scale(double[][] mat, double coeff) {
		double[][] out = new double[mat.length][mat[0].length];
		for(int i = 0; i < out.length; i++) {
			for(int j = 0; j < out[0].length; j++) {
				out[i][j] = mat[i][j] * coeff;
			}
		}
		return out;
	}
	
	static double dot(double[] a, double[] b) {
		if(a.length != b.length) {
			throw new MatrixException("Vector lengths not equal: " + a.length + "=/=" + b.length);
		}
		double sum = 0;
		for(int i = 0; i < a.length; i++) {
			numMults++;
			sum += a[i] * b[i];
		}
		return sum;
	}
	
	static double[][] copy(double[][] input) {
		double[][] copy = new double[input.length][input[0].length];
		for(int i = 0; i < copy.length; i++) {
			for(int j = 0; j < copy[i].length; j++) {
				copy[i][j] = input[i][j];
			}
		}
		return copy;
	}
	
	static double[] getColumn(double[][] matrix, int i) {
		return matrix[i];
	}
	
	static double[] getRow(double[][] matrix, int i) {
		double[] vals = new double[matrix.length];
		for(int j = 0; j < vals.length; j++) {
			vals[j] = matrix[j][i];
		}
		return vals;
	}
	
	static double[] proj(double[] vec, double[] proj) {
		double constant = dot(proj, vec)/dot(proj, proj);
		double[] projection = new double[vec.length];
		for(int i = 0; i < proj.length; i++) {
			projection[i] = proj[i]*constant;
		}
		return projection;
	}
	
	static double[] normalize(double[] vec) {
		double[] newVec = new double[vec.length];
		double norm = norm(vec);
		for(int i = 0; i < vec.length; i++) {
			newVec[i] = vec[i]/norm;
		}
		return newVec;
	}
	
	static double norm(double[] vec) {
		return Math.sqrt(dot(vec,vec));
	}

	static double mean(double[] entries) {
		double out = 0;
		for(double d: entries) {
			out += d/entries.length;
		}
		return out;
	}

	static void print(double[][] matrix) {
		for(int j = 0; j < matrix[0].length; j++) {
			for(int i = 0; i < matrix.length; i++) {
				double formattedValue = Double.parseDouble(String.format("%.4g%n", matrix[i][j]));
				if(Math.abs(formattedValue) < 0.00001) { //Hide negligible values
					formattedValue = 0;
				}
				System.out.print(formattedValue + "\t");
			}
			System.out.print("\n");
		}
		System.out.println("");
	}
}

class MatrixException extends RuntimeException {
	MatrixException(String string) {
		super(string);
	}
}

class EigenSet {
	double[] values;
	double[][] vectors;
}
