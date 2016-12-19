import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;


public class FileRead {

    public static void main(String[] args) {

	String[] strarray = new String[1000];


	int i = 0;


	try{
	    File file = new File("zzz.txt");

	    BufferedReader br = new BufferedReader(new FileReader(file));

	    String str= null;
	    i=0;
	    while((str = br.readLine()) != null){
		System.out.println(str);

		strarray[i]=str;
		i = i +1;

	    }

	    br.close();


	}catch(FileNotFoundException e){
	    System.out.println(e);
	}catch(IOException e){
	    System.out.println(e);
	}
    }

}
