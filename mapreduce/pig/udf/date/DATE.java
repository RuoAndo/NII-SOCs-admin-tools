package date;
import java.io.IOException;
import org.apache.pig.EvalFunc;
import org.apache.pig.data.Tuple;

import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.text.ParsePosition;

public class DATE extends EvalFunc<String>
{
    public String exec(Tuple input) throws IOException {
        if (input == null || input.size() == 0)
            return null;
        try{
            String str = (String)input.get(0);
            return dateToLong(str);
        }catch(Exception e){
            throw new IOException("Caught exception processing input row ", e);
        }
    }

    /**
     * String to Date to Long
     * @param date
     * @return
    */

    // 2017-03-05 06:18:26
    
    private static String dateToLong(String datestr) throws Exception {
	
	Date date = null;
	DateFormat df = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");
	ParsePosition pos = new ParsePosition(0);

	long datelong = 0;

	date = df.parse(datestr, pos);

	if(pos.getErrorIndex()==-1)
	    {
		datelong = date.getTime();
	    }
	else
	    {
	        datelong = 0;
	    }

	return String.valueOf(datelong);
    }
}
