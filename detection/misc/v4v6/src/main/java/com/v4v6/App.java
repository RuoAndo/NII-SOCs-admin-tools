package com.v4v6;

import java.io.FileReader;
import java.io.BufferedReader;
import java.io.IOException;

public class App 
{
    /*
    public static void main( String[] args )
    {
        System.out.println( "Hello World!" );
    }
    */

    public static int v4_sum = 0;
    public static int v4_counter = 0;
    public static double v4_mean = 0;

    public static int v6_sum = 0;
    public static int v6_counter = 0;
    public static double v6_mean = 0;

    public static boolean isMatch(String str1, String str2) {
	if(str1.matches(".*" + str2 + ".*")) {
	    return true;
	}
	else {
	    return false;
	}
    }
    
    public static void main(String args[]) {

	try {
	    FileReader fr = new FileReader("/home/ec2-user/nii-cyber-security-admin/detection/misc/v4v6/src/main/java/com/v4v6/address");
	    BufferedReader br = new BufferedReader(fr);

	    String line;
	    int count = 0;
	    while ((line = br.readLine()) != null) {
		System.out.println(++count + "行目：" + line);

		String[] addr = line.split(",", 0);

		for (int i = 0 ; i < addr.length ; i++){
		    // System.out.println(addr[i]);

		    // int v6_sum = 0;
		    // int v6_counter = 0;
		    if(isMatch(addr[i], ":") == true)
		    {
				      String[] addr2 = addr[i].split(":", 0);

				      int tmp = 0;
				      for (int j = 0 ; j < addr2.length ; j++){
					  // System.out.println(addr2[j]);
					  tmp = tmp + Integer.parseInt(addr2[j],16);
					  // System.out.println(Integer.parseInt(addr2[j],16));
				      }
				      // System.out.println(tmp);

				      v6_sum = v6_sum + tmp;
				      v6_counter++;
		    }
		    
		    if(isMatch(addr[i], ":") == false)
			{
			              //System.out.println("test:"+ addr[i]);
		    		      String[] addr3 = addr[i].split("\\.", 0);

				      int tmp2 = 0;
				      for (int k = 0 ; k < addr3.length ; k++){
					  // System.out.println("split" + addr3[k]);
					  tmp2 = tmp2 +  Integer.parseInt(addr3[k]);
					  //System.out.println(Integer.parseInt(addr2[j],16));
				      }
				      // System.out.println(tmp2);

				      v4_sum = v4_sum +tmp2;
				      v4_counter++;
				      // System.out.println("v4_counter" + v4_counter);
			}

		}
		
		// v4_mean = v4_sum / v4_counter;
	        // System.out.println("v4 mean:" + v4_mean);

	        // System.out.println("the number of v6 address:" + v6_counter);
		// System.out.println("v6 sum:" + v6_sum);

	        // v6_mean = v6_sum / v6_counter;
		// System.out.println("v6 mean:" + v6_mean);

		
	    } // while ((line = br.readLine()) != null) {


	    System.out.println("the number of v4 address:" + v4_counter);
	    System.out.println("v4 sum:" + v4_sum);
	    v4_mean = v4_sum / v4_counter;
	    System.out.println("v4 mean:" + v4_mean);

	    System.out.println("the number of v6 address:" + v6_counter);
	    System.out.println("v6 sum:" + v6_sum);
	    v6_mean = v6_sum / v6_counter;
	    System.out.println("v6 mean:" + v6_mean);

	    br.close();
	    fr.close();

	    FileReader fr2 = new FileReader("/home/ec2-user/nii-cyber-security-admin/detection/misc/v4v6/src/main/java/com/v4v6/address");
	    BufferedReader br2 = new BufferedReader(fr2);
	    String line2;
	    count = 0;
	    while ((line2 = br2.readLine()) != null) {
		System.out.println(++count + "行目：" + line2);

		String[] addr21 = line2.split(",", 0);

		for (int i = 0 ; i < addr21.length ; i++){

		if(isMatch(addr21[i], ":") == true)
		    {
			String[] addr41 = addr21[i].split(":", 0);

			int tmp = 0;
			for (int j = 0 ; j < addr41.length ; j++){
			    tmp = tmp + Integer.parseInt(addr41[j],16);
			}

			v6_sum = v6_sum + tmp;
			System.out.println("Re: v6 sum:" + v6_sum + ":distance:" + (v6_sum - v6_mean));			
		    }
		   
		if(isMatch(addr21[i], ":") == false)
		    {
		    	String[] addr51 = addr21[i].split("\\.", 0);

			int tmp2 = 0;
			for (int k = 0 ; k < addr51.length ; k++){
			    tmp2 = tmp2 +  Integer.parseInt(addr51[k]);
			}

			v4_sum = v4_sum + tmp2;
			System.out.println("Re: v4 sum:" + v4_sum + ":distance:" + (v4_sum - v4_mean));			
		    }

		}

	    } // while ((line2 = br.readLine()) != null) {

	    br2.close();
	    fr2.close();
     
	} catch (IOException ex) {
	    ex.printStackTrace();
	}
    }
}
