import java.util.LinkedList;

import java.util.Queue;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;

public class MovingAverage {
    private final Queue<Double> window = new LinkedList<Double>();
    private final int period;
    private double sum;
 
    public MovingAverage(int period) {
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
    	
        double[] testData = new double[50];
	// int[] windowSizes = {3,5};
	int[] windowSizes = {3};
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
            MovingAverage ma = new MovingAverage(windSize);
            for (double x : testData) {
                ma.newNum(x);
                // System.out.println("Next number = " + x + ", SMA = " + ma.getAvg());
		tmp = x - ma.getAvg();

		/*
		if(tmp > 0.5 || tmp < -0.5)
		    {
			System.out.println("anomaly detected at point: " + counter + " value = " + tmp);
		    }
		*/

		System.out.println(tmp);
		counter = counter + 1;
            }
            // System.out.println();
        }
    }
    
}

