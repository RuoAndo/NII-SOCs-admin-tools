#!/usr/bin/perl


my $filein = $ARGV[0];
open(FILEHANDLE, $filein);
@list = <FILEHANDLE>;
my $data = join('', @list);

#正規表現（単語を抽出する）
$regex = "[^ \n\r\t,;]+";

#単語を配列へ代入する
@temp = $data =~m/$regex/g;

#ハッシュ配列を初期化
%words = ();

#単語を全てスキャン、そして単語をキーにして同じ単語をカウントする
foreach(@temp){
    $words{$_}++;

}

#単語と使われた頻度を表示する
foreach $key ( keys( %words ) ) {
    print "$key,$words{$key}\n";
}

#while(<STDIN>){
#    while(/([a-z0-9']+)/gi){
#        $wc{lc($1)}++;
#    }
#}
#@sorted=sort {$wc{$b}<=>$wc{$a}} keys(%wc);
#foreach(@sorted){
#    print "$_ $wc{$_}\n";
#}


