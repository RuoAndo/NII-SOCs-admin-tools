// weighted MA (moving average) with convolution.

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;

public class Convolution {

	private double[] in;
	private double[] kernal;
	private double[] out;
        
	public Convolution(double[] _in,double[]_kernal) {
		setIn(_in);
		setKernal(_kernal);
	}
	private void setIn(double[] _in)throws IllegalArgumentException {

		if(_in.length <= 3) {
			throw new IllegalArgumentException("Data length can't be zero or smaller than zero");
		}

		this.in = _in;
		this.out = new double [_in.length];
	}
	private void setKernal(double[] _kernal)throws IllegalArgumentException {

		if(_kernal.length <= 0 || (_kernal.length%2) == 0) {
			throw new IllegalArgumentException("kernal length can't be zero or smaller than zero");
		}

		this.kernal = _kernal;
	}

	@SuppressWarnings("unused")
	public double[] colvoltionSeries() {

		int kernalSize = kernal.length;
		int zerosToAppend = (int) Math.ceil(kernalSize/2);

		double[] dataVec = new double [kernalSize-1+in.length];

		for(int i = 0; i< in.length;i++) 
		{
			dataVec[i+(int) Math.ceil(kernalSize/2)] = in[i];
		}

		int end = 0;
		while (end < in.length) {
			double sum = 0.0;
			for (int i = 0; i <kernalSize; i++)
			{		
				sum += kernal[i]*dataVec[end+i];
			}
			out[end]= sum;
			end = end+1;
		}
		return out;		
	}

	public static void main(String[] args) {

	    double [] data = new double[50];
	    int j = 0;

	    try{
		File file = new File(args[0]);
		BufferedReader br = new BufferedReader(new FileReader(file));
		String str= null;

		j=0;
		while((str = br.readLine()) != null){
		    data[j] = Double.parseDouble(str);
		    j = j + 1;
		}
		br.close();
	    }catch(FileNotFoundException e){
		System.out.println(e);
	    }catch(IOException e){
		System.out.println(e);
	    }
		
		double[] k = {1.0/9.0,2.0/9.0,3.0/9.0,2.0/9.0,1.0/9.0};
		Convolution conv = new Convolution(data,k);
		double[] out = conv.colvoltionSeries();

		for(int i = 0; i < out.length; i ++) {
		    System.out.print(out[i] + "\n");
		}
		
	}
}
