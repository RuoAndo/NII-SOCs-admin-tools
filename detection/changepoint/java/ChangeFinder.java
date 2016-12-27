import java.util.LinkedList;

import java.util.Queue;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;

public class ChangeFinder {
    private final Queue<Double> window = new LinkedList<Double>();
    private final int period;
    private double sum;

    /* for convolution */
    private static double[] in;
    private static double[] kernal;
    private static double[] out;

    
    // public static final int[] windowSizes = {3,5};
    public static final int[] windowSizes = {3};
    
    public static final int conv_Window_Size = 4;
    public static final double[] k = {1.0/9.0,2.0/9.0,3.0/9.0,2.0/9.0,1.0/9.0};    
    public static final int data_Size = 50;

    public static void Convolution(double[] _in,double[]_kernal) {
	setIn(_in);
	setKernal(_kernal);
    }

    private static void setIn(double[] _in)throws IllegalArgumentException {

	if(_in.length <= 3) {
	    throw new IllegalArgumentException("Data length can't be zero or smaller than zero");
	}

	ChangeFinder.in = _in;
	ChangeFinder.out = new double [_in.length];
    }
    
    private static void setKernal(double[] _kernal)throws IllegalArgumentException {

	if(_kernal.length <= 0 || (_kernal.length%2) == 0) {
	    throw new IllegalArgumentException("kernal length can't be zero or smaller than zero");
	}
	ChangeFinder.kernal = _kernal;
    }

    @SuppressWarnings("unused")
    public static double[] colvoltionSeries(double[] in) {

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

    public ChangeFinder(int period) {
        assert period > 0 : "Period must be a positive integer";
        this.period = period;
    }
 
    public void newNum(double num) {
        sum += num;
        window.add(num);
        if (window.size() > period) {
            sum -= window.remove();
        }
    }
 
    public double getAvg() {
        if (window.isEmpty()) return 0; // technically the average is undefined
        return sum / window.size();
    }
 
    public static void main(String[] args) {

        double[] testData = new double[data_Size];
        double[] changePoint = new double[data_Size];
        double[] convData = new double[4];
	double[] score = new double[data_Size];
	double[] score_abs = new double[data_Size];
	
	int i;
	
	try{
	    File file = new File(args[0]);
	    BufferedReader br = new BufferedReader(new FileReader(file));
	    String str= null;
	    i=0;
	    while((str = br.readLine()) != null){
		//System.out.println(str);
		testData[i] = Double.parseDouble(str);
		i = i +1;
	    }
	    br.close();
	}catch(FileNotFoundException e){
	    System.out.println(e);
	}catch(IOException e){
	    System.out.println(e);
	}

	double tmp;
	int counter;

	counter = 0;
	
	for (int windSize : windowSizes) {
            ChangeFinder ma = new ChangeFinder(windSize);
            for (double x : testData) {
                ma.newNum(x);
                // System.out.println("Next number = " + x + ", SMA = " + ma.getAvg());
		tmp = x - ma.getAvg();
		score[counter] = tmp;
		score_abs[counter] = Math.abs(tmp);
		
		if(tmp > 0.5 || tmp < -0.5)
		    {
			changePoint[counter] = 1;
			//System.out.println("anomaly detected at point: " + counter + " value = " + tmp);
		    }
		else
		    {
			changePoint[counter] = 0;
		    }

		// System.out.println(tmp);
		counter = counter + 1;
            }
            // System.out.println();
        } // for (int windSize : windowSizes) {

	for(int j = 0; j < changePoint.length; j ++) {
	    if(changePoint[j] == 1)
		{
		    for(i = 0; i < conv_Window_Size ; i ++)
			{
			    convData[i] = score[j-2+i];
			}
		    
		    Convolution(convData, k);
		    double[] out = colvoltionSeries(convData);

		    for(i = 0; i < conv_Window_Size ; i ++)
			{
			    score[j-2+i] = out[i];
			    score_abs[j-2+i] = Math.abs(out[i]);
			    // score_abs[j-2+i] = score[j-2+i];
			}		    
		}
	}

	for(int j = 0; j < score.length; j ++) {
	    // System.out.print(score[j] + "\n");
	    System.out.print(score_abs[j] + "\n");
	}

	double max = score_abs[0];

	for (int j =0; j < score_abs.length; j++) {
	    if (max < score_abs[j]) {
		max = score_abs[j];		
	    }
 	}

	// System.out.print("max: " + max + "\n");

    }
}

