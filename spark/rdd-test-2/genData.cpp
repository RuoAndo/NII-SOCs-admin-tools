#include <stdio.h>
#include <stdlib.h>

#include <iostream>
#include <vector>
#include <random>
#include <vector>
#include <bitset>
#include<fstream>

#include <random>

#include <functional> //for std::function
#include <algorithm>  //for std::generate_n
 
typedef std::vector<char> char_array;
char_array charset()
{
    //Change this to suit
    return char_array( 
	{'0','1','2','3','4',
	'5','6','7','8','9',
	'A','B','C','D','E','F',
	'G','H','I','J','K',
	'L','M','N','O','P',
	'Q','R','S','T','U',
	'V','W','X','Y','Z',
	'a','b','c','d','e','f',
	'g','h','i','j','k',
	'l','m','n','o','p',
	'q','r','s','t','u',
	'v','w','x','y','z'
	});
};    
 
std::string random_string( size_t length, std::function<char(void)> rand_char )
{
    std::string str(length,0);
    std::generate_n( str.begin(), length, rand_char );
    return str;
}

int GetRandom(int min,int max);

using namespace std;

std::vector<std::string> split_string_2(std::string str, char del) {
  int first = 0;
  int last = str.find_first_of(del);

  std::vector<std::string> result;

  while (first < str.size()) {
    std::string subStr(str, first, last - first);

    result.push_back(subStr);

    first = last + 1;
    last = str.find_first_of(del, first);

    if (last == std::string::npos) {
      last = str.size();
    }
  }

  return result;
}

int main( int argc, char* argv[] )
{
  int i;
  int N = atoi(argv[1]);  
  
  /*
  for (i = 0;i < 10;i++) {
		printf("%d\n",GetRandom(1,6));
  }
  */

  std::random_device rnd;
  std::mt19937 mt(rnd());
  std::uniform_int_distribution<long> randD(20190702, 20190702);
  std::uniform_int_distribution<long> randH(0, 23);
  std::uniform_int_distribution<long> randM(0, 59);
  std::uniform_int_distribution<long> randS(0, 59);
  std::uniform_int_distribution<long> randMS(0, 1000);

  long date;
  long hour;
  long minute;
  long second;
  long msec;
  
  std::vector<long> tms;

  string tmpstring;
  string tmp_hour;
  string tmp_minute;
  string tmp_second;
  string tmp_msec;
  
  long long r;
  
  for (int i = 0; i < N; ++i) {
    date = randD(mt);
    hour = randH(mt);
    minute = randM(mt);
    second = randS(mt);
    msec = randMS(mt);

    if(hour < 10)
      tmp_hour = "0" + to_string(hour);
    else
      tmp_hour = to_string(hour);

    if(minute < 10)
      tmp_minute = "0" + to_string(minute);
    else
      tmp_minute = to_string(minute);

    if(second < 10)
      tmp_second = "0" + to_string(second);
    else
      tmp_second = to_string(second);

    if(msec < 10)
      tmp_msec = "00" + to_string(msec);
    else if(msec < 100)
      tmp_msec = "0" + to_string(msec);
    else
      tmp_msec = to_string(msec);

    // cout << tmp_msec << endl;
    
    tmpstring = to_string(date) + tmp_hour + tmp_hour + tmp_minute + tmp_msec;
    // cout << tmpstring << endl;
    r = stoll(tmpstring);
    tms.push_back(r);
  }

  std::sort(tms.begin(), tms.end());

  ofstream outputfile("random_data.txt");
  
  for (int i = 0; i < N; ++i) {    

    tmpstring = to_string(tms[i]);

    outputfile << "\"" << tmpstring.substr( 0, 4 )
	       << "/"
	       << tmpstring.substr( 4, 2 ) 
	       << "/"
	       << tmpstring.substr( 6, 2 )
	       << " "
	       << tmpstring.substr( 8, 2 )
	       << ":"
	       << tmpstring.substr( 10, 2 )
	       << ":"
	       << tmpstring.substr( 12, 2 )
	       << "."
	       << tmpstring.substr( 14, 3 )
	       << "\"" << "," ;

    outputfile << "\"" << tmpstring.substr( 0, 4 )
	       << "/"
	       << tmpstring.substr( 4, 2 ) 
	       << "/"
	       << tmpstring.substr( 6, 2 )
	       << " "
	       << tmpstring.substr( 8, 2 )
	       << ":"
	       << tmpstring.substr( 10, 2 )
	       << ":"
	       << tmpstring.substr( 12, 2 )
	       << "\"" << "," ;

    outputfile << "\"" << tmpstring.substr( 0, 4 )
	       << "/"
	       << tmpstring.substr( 4, 2 ) 
	       << "/"
	       << tmpstring.substr( 6, 2 )
	       << " "
	       << tmpstring.substr( 8, 2 )
	       << ":"
	       << tmpstring.substr( 10, 2 )
	       << ":"
	       << tmpstring.substr( 12, 2 )
	       << "\"" << "," ;

    outputfile << "\"" << GetRandom(1,1000) << "\"" << ",";

    std::random_device rnd;
    std::mt19937 mt(rnd());
    std::uniform_int_distribution<long long> randN(0, 4294967295);

    char del = '.';
  
    r = randN(mt);
    tmpstring = to_string(r);
    
    std::bitset<32> s = std::bitset<32>(stoull(tmpstring));
    string bs = s.to_string();

    string bs1 = bs.substr(0,8);
    int bi1 =  bitset<8>(bs1).to_ulong();
    
    string bs2 = bs.substr(8,8);
    int bi2 =  bitset<8>(bs2).to_ulong();

    string bs3 = bs.substr(16,8);
    int bi3 =  bitset<8>(bs3).to_ulong();
    
    string bs4 = bs.substr(24,8);
    int bi4 =  bitset<8>(bs4).to_ulong();

    string sourceIP = to_string(bi1) + "." + to_string(bi2) + "." + to_string(bi3) + "." + to_string(bi4);

    outputfile << "\"" << sourceIP << "\"";

    outputfile << "," << "\"" << GetRandom(1,65535) << "\"" << ",";

    const auto ch_set = charset();
    std::default_random_engine rng(std::random_device{}()); 
    std::uniform_int_distribution<> dist(0, ch_set.size()-1);
    auto randchar = [ ch_set,&dist,&rng ](){return ch_set[ dist(rng) ];};
    auto length = 2;
    
    outputfile<< "\"" << random_string(length,randchar)<< "\"";

    r = randN(mt);
    tmpstring = to_string(r);

    r = randN(mt);
    tmpstring = to_string(r);
    
    std::bitset<32> s_dst = std::bitset<32>(stoull(tmpstring));
    string bs_dst = s_dst.to_string();

    string bs1_dst = bs_dst.substr(0,8);
    int bi1_dst =  bitset<8>(bs1_dst).to_ulong();
    
    string bs2_dst = bs_dst.substr(8,8);
    int bi2_dst =  bitset<8>(bs2_dst).to_ulong();

    string bs3_dst = bs_dst.substr(16,8);
    int bi3_dst =  bitset<8>(bs3_dst).to_ulong();
    
    string bs4_dst = bs_dst.substr(24,8);
    int bi4_dst =  bitset<8>(bs4_dst).to_ulong();

    string destIP = to_string(bi1_dst) + "." + to_string(bi2_dst) + "." + to_string(bi3_dst) + "." + to_string(bi4_dst);

    outputfile << "," << "\"" << destIP << "\"";
    
    outputfile << "," << "\"" << GetRandom(1,65535) << "\"";

    // country code
    outputfile<< "," << "\"" << random_string(2,randchar)<< "\"";

    // protocol
    outputfile<< "," << "\"" << random_string(3,randchar)<< "\"";

    // application
    outputfile<< "," << "\"" << random_string(9,randchar)<< "\"";

    // subtype
    outputfile<< "," << "\"" << random_string(3,randchar)<< "\"";

    // action
    outputfile<< "," << "\"" << random_string(5,randchar)<< "\"";

    // session-end-reason
    outputfile<< "," << "\"" << random_string(8,randchar)<< "\"";

    // repeat-count
    outputfile << "," << "\"" << GetRandom(1,9) << "\"";

    // category
    outputfile<< "," << "\"" << random_string(26,randchar)<< "\"";

    // repeat-count
    outputfile << "," << "\"" << GetRandom(1,1000) << "\"";

    // repeat-count
    outputfile << "," << "\"" << GetRandom(1,1000) << "\"";

    // repeat-count
    outputfile << "," << "\"" << GetRandom(1,1000) << "\"";

    // repeat-count
    outputfile << "," << "\"" << GetRandom(1,1000) << "\"";

    // repeat-count
    outputfile << "," << "\"" << GetRandom(1,1000) << "\"";

    // repeat-count
    outputfile << "," << "\"" << GetRandom(1,1000) << "\"";

    // device name
    int rnd_tmp = rnd();
    
    // std::random_device rnd;
    if (rnd_tmp % 3 == 0)   
      outputfile<< "," << "\"" << "rand-pa1" << "\"";

    else if (rnd_tmp % 3 == 1)   
      outputfile<< "," << "\"" << "rand-pa2" << "\"";

    else if (rnd_tmp % 3 == 2)   
      outputfile<< "," << "\"" << "rand-pa3" << "\"";

    else
      outputfile<< "," << "\"" << "rand-pa3" << "\"";

    outputfile << endl;
  }

  outputfile.close();
  
  return 0;
}

int GetRandom(int min,int max)
{
	return min + (int)(rand()*(max-min+1.0)/(1.0+RAND_MAX));
}


