import java.io.File;
import java.io.FileReader;
import java.io.BufferedReader;
import java.io.IOException;

class Data {
	double[][] matrix; //matrix[i] is the ith row; matrix[i][j] is the ith row, jth column
	
	/**
	 * Constructs a new data matrix.
	 * @param vals	data for new Data object; dimensions as columns, data points as rows.
	 */
	Data(double[][] vals) {
		matrix = Matrix.copy(vals);
	}

    public static void main(String[] args) {
	    double data3[][] = new double[1000][4];
	    
	    try{
	    
	        File f = new File("tmp");
	        BufferedReader br = new BufferedReader(new FileReader(f));
	        String line = br.readLine();
		
	        for (int row = 0; line != null; row++) {
		   String data2[] = line.split(",", 0);

		Integer count = 0;
		for(String elem : data2){
		    double tmp = Double.valueOf(elem);
		    data3[row][count] = tmp;
		    // System.out.println(elem);
		    count++;
		}
		   line = br.readLine();
	        }
	        br.close();

		Matrix.print(data3);
		
	    } catch (IOException e) {
		System.out.println(e);
	    }
		
	        double[][] data = {{4, 4.2, 3.9, 4.3, 4.1}, {2, 2.1, 2, 2.1, 2.2}, 
				{0.6, 0.59, 0.58, 0.62, 0.63}};
		System.out.println("Raw data:");
		Matrix.print(data3);
		Data dat = new Data(data3);
		dat.center();
		double[][] cov = dat.covarianceMatrix();
		System.out.println("Covariance matrix:");
		Matrix.print(cov);
		EigenSet eigen = dat.getCovarianceEigenSet();
		double[][] vals = {eigen.values};
		System.out.println("Eigenvalues:");
		Matrix.print(vals);
		System.out.println("Corresponding eigenvectors:");
		Matrix.print(eigen.vectors);
		// System.out.println("Two principal components:");
		// Matrix.print(dat.buildPrincipalComponents(2, eigen));
		// System.out.println("Principal component transformation:");
		// Matrix.print(Data.principalComponentAnalysis(data, 2));
	}
	
	static double[][] PCANIPALS(double[][] input, int numComponents) {
		Data data = new Data(input);
		data.center();
		double[][][] PCA = data.NIPALSAlg(numComponents);
		double[][] scores = new double[numComponents][input[0].length];
		for(int point = 0; point < scores[0].length; point++) {
			for(int comp = 0; comp < PCA.length; comp++) {
				scores[comp][point] = PCA[comp][0][point];
			}
		}
		return scores;
	}
	
	double[][][] NIPALSAlg(int numComponents) {
		final double THRESHOLD = 0.00001;
		double[][][] out = new double[numComponents][][];
		double[][] E = Matrix.copy(matrix);
		for(int i = 0; i < out.length; i++) {
			double eigenOld = 0;
			double eigenNew = 0;
			double[] p = new double[matrix[0].length];
			double[] t = new double[matrix[0].length];
			double[][] tMatrix = {t};
			double[][] pMatrix = {p};
			for(int j = 0; j < t.length; j++) {
				t[j] = matrix[i][j];
			}
			do {
				eigenOld = eigenNew;
				double tMult = 1/Matrix.dot(t, t);
				tMatrix[0] = t;
				p = Matrix.scale(Matrix.multiply(Matrix.transpose(E), tMatrix), tMult)[0];
				p = Matrix.normalize(p);
				double pMult = 1/Matrix.dot(p, p);
				pMatrix[0] = p;
				t = Matrix.scale(Matrix.multiply(E, pMatrix), pMult)[0];
				eigenNew = Matrix.dot(t, t);
			} while(Math.abs(eigenOld - eigenNew) > THRESHOLD);
			tMatrix[0] = t;
			pMatrix[0] = p;
			double[][] PC = {t, p}; //{scores, loadings}
			E = Matrix.subtract(E, Matrix.multiply(tMatrix, Matrix.transpose(pMatrix)));
			out[i] = PC;
		}
		return out;
	}
	
	static double[][] principalComponentAnalysis(double[][] input, int numComponents) {
		Data data = new Data(input);
		data.center();
		EigenSet eigen = data.getCovarianceEigenSet();
		double[][] featureVector = data.buildPrincipalComponents(numComponents, eigen);
		double[][] PC = Matrix.transpose(featureVector);
		double[][] inputTranspose = Matrix.transpose(input);
		return Matrix.transpose(Matrix.multiply(PC, inputTranspose));
	}
	
	double[][] buildPrincipalComponents(int numComponents, EigenSet eigen) {
		double[] vals = eigen.values;
		if(numComponents > vals.length) {
			throw new RuntimeException("Cannot produce more principal components than those provided.");
		}
		boolean[] chosen = new boolean[vals.length];
		double[][] vecs = eigen.vectors;
		double[][] PC = new double[numComponents][];
		for(int i = 0; i < PC.length; i++) {
			int max = 0;
			while(chosen[max]) {
				max++;
			}
			for(int j = 0; j < vals.length; j++) {
				if(Math.abs(vals[j]) > Math.abs(vals[max]) && !chosen[j]) {
					max = j;
				}
			}
			chosen[max] = true;
			PC[i] = vecs[max];
		}
		return PC;
	}
	
	EigenSet getCovarianceEigenSet() {
		double[][] data = covarianceMatrix();
		return Matrix.eigenDecomposition(data);
	}
	
	double[][] covarianceMatrix() {
		double[][] out = new double[matrix.length][matrix.length];
		for(int i = 0; i < out.length; i++) {
			for(int j = 0; j < out.length; j++) {
				double[] dataA = matrix[i];
				double[] dataB = matrix[j];
				out[i][j] = covariance(dataA, dataB);
			}
		}
		return out;
	}
	
	static double covariance(double[] a, double[] b) {
		if(a.length != b.length) {
			throw new MatrixException("Cannot take covariance of different dimension vectors.");
		}
		double divisor = a.length - 1;
		double sum = 0;
		double aMean = mean(a);
		double bMean = mean(b);
		for(int i = 0; i < a.length; i++) {
			sum += (a[i] - aMean) * (b[i] - bMean);
		}
		return sum/divisor;
	}
	
	void center() {
		matrix = normalize(matrix);
	}
	
	double[][] normalize(double[][] input) {
		double[][] out = new double[input.length][input[0].length];
		for(int i = 0; i < input.length; i++) {
			double mean = mean(input[i]);
			for(int j = 0; j < input[i].length; j++) {
				out[i][j] = input[i][j] - mean;
			}
		}
		return out;
	}
	
	static double mean(double[] entries) {
		double out = 0;
		for(double d: entries) {
			out += d/entries.length;
		}
		return out;
	}
}
