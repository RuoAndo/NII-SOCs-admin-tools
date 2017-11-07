#include<fstream>
#include<iostream>
#include<string>
#include<sstream> //文字ストリーム

using namespace std;

int main(int argc, char *argv[])
{
  int counter = 0;
  
  //ファイルの読み込み
  ifstream ifs(argv[1]);
  if(!ifs){
    cout<<"入力エラー";
    return 1;
  }

  //csvファイルを1行ずつ読み込む
  string str;
  while(getline(ifs,str)){
    string token;
    istringstream stream(str);

    //1行のうち、文字列とコンマを分割する
    while(getline(stream,token,',')){
      //すべて文字列として読み込まれるため
      //数値は変換が必要
      //int temp=stof(token); //stof(string str) : stringをfloatに変換
      std::cout<< token << "(" << counter << "),";
      counter = counter + 1;
    }
    cout<<endl;
  }
  return 0;
}
