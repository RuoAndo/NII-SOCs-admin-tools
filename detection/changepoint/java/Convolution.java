// weighted MA (moving average) with convolution.

public class Convolution {

	private double[] in;
	private double[] kernal;
	private double[] out;
	public Convolution(double[] _in,double[]_kernal) {
		setIn(_in);
		setKernal(_kernal);
	}
	private void setIn(double[] _in)throws IllegalArgumentException {

		// check the size of the datavector... 
		if(_in.length <= 3) {
			throw new IllegalArgumentException("Data length can't be zero or smaller than zero");
		}

		this.in = _in;
		//Our denoised singal is of same length as of our input raw signal...
		this.out = new double [_in.length];
	}
	private void setKernal(double[] _kernal)throws IllegalArgumentException {

		//Check length of Kernel vector if its greater than zero; or Length is not an odd number. 
		if(_kernal.length <= 0 || (_kernal.length%2) == 0) {
			throw new IllegalArgumentException("kernal length can't be zero or smaller than zero");
		}

		this.kernal = _kernal;
	}

	@SuppressWarnings("unused")
	public double[] colvoltionSeriess() {

		int kernalSize = kernal.length;
		int zerosToAppend = (int) Math.ceil(kernalSize/2);

		// Make a new dataVector by appending zeros.
		double[] dataVec = new double [kernalSize-1+in.length];

		// add data in dataVec by compansating the zeropadding
		for(int i = 0; i< in.length;i++) 
		{
			//Add data inbetween the padded zeros...
			dataVec[i+(int) Math.ceil(kernalSize/2)] = in[i];
		}
		// convolution begins here...
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

		// in = data to be denoised....
	    double [] data = new double[]{-2.28587274435061,-2.12347637779919,-1.87567054774034,-1.58019021907094,-1.29260457362077,-1.10696685446369,-0.982744107679446,-0.843631315071740,-0.736560491314242,-0.677912274889302,-0.647138879621174,-0.649335724701462,-0.650793504834992,-0.599567621033939,-0.531754702829124,-0.497148086933427,-0.483124682745386,-0.498600830379463,-0.535134018974560,-0.558081457170321,-0.577964606797936,-0.602148092708749,-0.608598879607319,-0.581683133217702,-0.504680329239356,-0.351363589740842,-0.172521061174983,-0.0481180287242626,-0.00586729355062232,-0.101188565355459,-0.292757482763319,-0.484025157332439,-0.687322876815657,-0.885981299014684,-1.24766197301035,-2.05779146558526,-2.80227736219721,-2.76709979709472,-2.40386674289251,-2.19792460580171,-1.74013490123590,-0.802271775994665,0.225744993196649,1.00668601296398,1.35159475339336,0.880388898662849,-0.0377301833186010,-0.713256612488619,-1.11987037044784,-0.998746357592658,-0.559677900092389,-0.422984748625749,-0.450814867914687,-0.630777262589517,-0.951918778898319,-1.11074725004137,-1.20596477421578,-1.33915599196434,-1.43276257913115,-1.51842473924884,-1.56055207684713,-1.47911461558070,-1.32712019661038,-1.16322674248176,-0.984212821450724,-0.821484035589338,-0.664977722188270,-0.474358621712620,-0.275466784759036,-0.0862886108974674,0.0741658616540679,0.160495959863637,0.153438268213812,0.0303890931829329,-0.155812041242628,-0.308102652034345,-0.391920328259463,-0.341439462192275,-0.151091480474776,0.141344705848017,0.601774013266484,1.28566605868044,2.08534852254627,2.86379771793588,3.53710947873466,3.95694119842369,4.12777792914558,4.12036631484661,3.81338236485836,3.11489541893583,2.17244483930781,1.16555469492323};

		double[] k = {1.0/9.0,2.0/9.0,3.0/9.0,2.0/9.0,1.0/9.0};
		Convolution conv = new Convolution(data,k);
		double[] out = conv.colvoltionSeries();

		for(int i = 0; i < out.length; i ++) {
		    System.out.print(out[i] + " ");
		}
		
	}
}
