package com.v4v6;

import java.io.FileReader;
import java.io.BufferedReader;
import java.io.IOException;

/**
 * v4 - v6
 *
 */
public class App 
{

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
	    FileReader fr = new FileReader("/home/ec2-user/nii-cyber-security-admin/detection/misc/v6/src/main/java/com/v4v6/address");
	    BufferedReader br = new BufferedReader(fr);

	    String line;
	    int count = 0;
	    while ((line = br.readLine()) != null) {
		System.out.println(++count + "行目：" + line);

		String[] addr = line.split(",", 0);

		for (int i = 0 ; i < addr.length ; i++){

		    int tmp = 0;
		    if(isMatch(addr[i], ":") == true)
		    {
				      String[] addr2 = addr[i].split(":", 0);

				      for (int j = 0 ; j < addr2.length ; j++){
					  // System.out.print(addr2[j] + ":" );
					  System.out.print(addr2[j] + "(" + Integer.parseInt(addr2[j],16) + ")" + ":");
					  tmp = tmp + Integer.parseInt(addr2[j],16);
				      }

				      // System.out.println("\n");
				      System.out.println("SUM:" + tmp);
		    }
					  
		    if(isMatch(addr[i], ":") == false)
			{
			              System.out.print("fd00(" + Integer.parseInt("fd00",16) + "):0:");
				      tmp = tmp + Integer.parseInt("fd00",16);

		    		      String[] addr3 = addr[i].split("\\.", 0);

				      for (int k = 0 ; k < addr3.length ; k++){
					  // System.out.print(addr3[k] + ":");
					  System.out.print(addr3[k] + "(" + Integer.parseInt(addr3[k],16) + ")" + ":");
					  tmp = tmp + Integer.parseInt(addr3[k],16);
				      }
				      System.out.println("SUM:" + tmp);
			}

		}

		System.out.print("\n");

	    }

	    br.close();
	    fr.close();

	} catch (IOException ex) {
	    ex.printStackTrace();
	}
    }
}
