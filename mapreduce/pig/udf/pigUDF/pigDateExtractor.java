package pigUDF;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

import org.apache.pig.EvalFunc;
import org.apache.pig.data.Tuple;

public class pigDateExtractor extends EvalFunc<String> {
  
  private SimpleDateFormat datetimeFormatAccesslog
    = new SimpleDateFormat("dd/MMM/yyyy:HH:mm:ss Z", Locale.US);

  private SimpleDateFormat dateFormatOutput
    = new SimpleDateFormat("yyyyMMddHH", Locale.JAPAN);
  
  @Override
  public String exec(Tuple input) throws IOException {	
    if(input == null || input.size() == 0) 
      return null;
    try{
      String str = (String)input.get(0);   
      Date datetimeAccesslog = datetimeFormatAccesslog.parse(str); 
      return dateFormatOutput.format(datetimeAccesslog);           
    }catch(Exception e) {
      throw new IOException(e);
    }
  }
    
}
