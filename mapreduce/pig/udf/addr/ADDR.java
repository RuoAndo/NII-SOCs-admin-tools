package addr;
import java.io.IOException;
import org.apache.pig.EvalFunc;
import org.apache.pig.data.Tuple;

public class ADDR extends EvalFunc<String>
{
    public String exec(Tuple input) throws IOException {
        if (input == null || input.size() == 0)
            return null;
        try{
            String str = (String)input.get(0);
	    long ipNum = ipToNum(str);
            return String.valueOf(ipNum);
        }catch(Exception e){
            throw new IOException("Caught exception processing input row ", e);
        }
    }
    
    /**
     * IPを数値に変換する
     * @param ip
     * @return
    */
    private static long ipToNum(String ip) {
	String[] ipParts = ip.split("\\.");
	long ipNum = multiplicationFromStr(ipParts[0], 1000 * 1000 * 1000) + multiplicationFromStr(ipParts[1], 1000 * 1000) + multiplicationFromStr(ipParts[2], 1000) + multiplicationFromStr(ipParts[3], 1);
	return ipNum;
    }

    /**
     * 指定された文字列xを数値に変換してyと掛け算を行う
     * @param xStr
     * @param y
     * @return
     */
    private static long multiplicationFromStr(String xStr, long y){
	Long x = Long.parseLong(xStr);
	return x * y;
}

}
