# v4-v6 unique number assignment

<pre>
bash# mvn compile
bash# mvn exec:java
</pre>

# building maven project 

<pre>
mvn archetype:generate \
      -DarchetypeArtifactId=maven-archetype-quickstart \
      -DinteractiveMode=false \
      -DgroupId=com.sample \
      -DartifactId=hello
</pre>

# result

<pre>

[INFO] --- exec-maven-plugin:1.5.0:java (default-cli) @ v4v6 ---
1行目：ABCD:2345:6789:ABCD:EF01:2345:6789,ABCE:EF01:2345:6789:ABCD:EF01:2345:6789
2行目：ABCD:3345:6789:ABCD:EF01:2345:6789,ABCD:EF01:2345:6789:ABCD:EF01:2345:6789
3行目：ABCE:4345:6789:ABCD:EF01:2345:6789,ABCF:EF01:2345:6789:ABCD:EF01:2345:6789
4行目：ABCD:2345:6789:ABCD:EF01:2345:6789,ABCD:EF01:2345:6789:ABCD:EF01:2345:6789
5行目：251.100.1.1,172.16.0.1
6行目：251.100.1.2,172.16.0.2
the number of v4 address:4
v4 sum:1086
v4 mean:271.0
the number of v6 address:8
v6 sum:2018752
v6 mean:252344.0
1行目：ABCD:2345:6789:ABCD:EF01:2345:6789,ABCE:EF01:2345:6789:ABCD:EF01:2345:6789
Re: v6 sum:2238967:distance:1986623.0
Re: v6 sum:2520368:distance:2268024.0
2行目：ABCD:3345:6789:ABCD:EF01:2345:6789,ABCD:EF01:2345:6789:ABCD:EF01:2345:6789
Re: v6 sum:2744679:distance:2492335.0
Re: v6 sum:3026079:distance:2773735.0
3行目：ABCE:4345:6789:ABCD:EF01:2345:6789,ABCF:EF01:2345:6789:ABCD:EF01:2345:6789
Re: v6 sum:3254487:distance:3002143.0
Re: v6 sum:3535889:distance:3283545.0
4行目：ABCD:2345:6789:ABCD:EF01:2345:6789,ABCD:EF01:2345:6789:ABCD:EF01:2345:6789
Re: v6 sum:3756104:distance:3503760.0
Re: v6 sum:4037504:distance:3785160.0
5行目：251.100.1.1,172.16.0.1
Re: v4 sum:1439:distance:1168.0
Re: v4 sum:1628:distance:1357.0
6行目：251.100.1.2,172.16.0.2
Re: v4 sum:1982:distance:1711.0
Re: v4 sum:2172:distance:1901.0

</pre>