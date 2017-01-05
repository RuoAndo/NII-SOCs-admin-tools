import java.util.Arrays;
import java.util.List;

import org.apache.commons.math3.stat.descriptive.SummaryStatistics;
import com.google.common.collect.Lists;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;

public class AutoCorrelationTime

{
    public static final int data_Size = 500;
    public static final int shift_Size = 10;
    public static final	double[] ns = new double[data_Size];
    public static final double[] tmp = new double[data_Size];

    public static double EffectiveSampleSize(List<Double> values)
    {
	return ((double) values.size())/computeAutoCorrTime(values);
    }

    public static void main(String[]args)
    {

	//    Random rand = new Random(1);	
	//    for (int i = 0; i < 100; i++)
	//      ns[i] = rand.nextDouble();
	// String[] strarray = new String[1000];
	
	int i = 0;

	try{
	    File file = new File(args[0]);
	    BufferedReader br = new BufferedReader(new FileReader(file));
	    String str= null;
	    i=0;
	    while((str = br.readLine()) != null){
		//System.out.println(str);
		ns[i] = Double.parseDouble(str);
		i = i +1;
	    }
	    br.close();
	}catch(FileNotFoundException e){
	    System.out.println(e);
	}catch(IOException e){
	    System.out.println(e);
	}
 	
	List<Double> values = Lists.newArrayList();
	for (double n : ns) values.add(n);

	i = 0;
	for (double c : autocovariance(ns))
	    {
		// System.out.print(c);
		// System.out.print("\n");
		tmp[i] = c;
		i = i + 1;
	    }

	double t = 0;
	double s = 0;
	
	i = 0;
    	for (double d : autocovariance(ns, data_Size-1))
	    {
		if(i  < data_Size - shift_Size)
		    {
			t = ns[i+10]*d - ns[i]*d;
			// s = t - ns[i];
			// t = d;
			System.out.print(t);
			System.out.print("\n");
			i = i + 1;
		    }
	    }
	
	// System.out.println(estimateAutocorrelationFunction(values));
	// System.out.println(EffectiveSampleSize(values));
    }

    public static double computeAutoCorrTime(List<Double> values)
    {
	double sum = 0.0;
	List<Double> autocorrelationFunction = estimateAutocorrelationFunction(values);
	for (int i = 1; i < autocorrelationFunction.size(); i++)
	    sum += 2 * autocorrelationFunction.get(i);
	return 1.0 + sum;
    }

    public static List<Double> estimateAutocorrelationFunction(List<Double> series)
    {
	SummaryStatistics ss = new SummaryStatistics();
	for (double v : series) ss.addValue(v);
	final double sampleVar = ss.getVariance();
	double [] data = new double[series.size()];
	for (int i =0 ; i < series.size(); i++)
	    data[i] = series.get(i);
	double [] auto = autocovariance(data);
	List<Double> result = Lists.newArrayList();
	final double n = series.size();
	double factor = 1.0 / n / sampleVar;
	result.add(1.0);
	loop:for (int i = 1; i < n; i++)
	    {
		if (i > 1 && auto[i] + auto[i-1] < 0.0)
		    break loop;
		result.add( factor * auto[i]);
	    }
	return result;
    }

    public static double[] autocovariance(double[] x, int maxShift) {
	double total = 0;
	for (int i = 0; i < x.length; i++) {
	    total += x[i];
	}
	double mean = total / x.length;

	int stop = Math.min(x.length, maxShift);
	double[] auto = new double[stop];
	for (int i = 0; i < stop; i++) {
	    for (int j = 0; j < x.length - i; j++) {
		auto[i] += (x[j]-mean) * (x[j + i]-mean);
	    }
	}

	return auto;
    }

    public static double[] autocovariance(double[] x) {
	return autocovariance(x, x.length);
    }

}
