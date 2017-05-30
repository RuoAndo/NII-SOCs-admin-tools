# pig: User Defined Function

building jar file

<pre>
# cd pigUDF
# javac -cp pig-core.jar pigDateExtractor.java
# cd ..
# jar cf pigUDF.jar pigUDF/
</pre>

pig -x local 1.pig

<pre>
# cd myudfs
# javac -cp pig.jar UPPER.java
# cd ..
# jar -cf myudfs.jar myudfs
</pre>


<pre>
# cd addr
# javac -cp addr.jar ADDR.java
# cd ..
# jar -cf addr.jar addr
</pre>

<pre>
REGISTER addr.jar;

s_addr = FOREACH s_filtered GENERATE
      sid,
      ct,
      addr.ADDR(dip),
      addr.ADDR(sip);
</pre>

<pre>
# cd date/
# javac -cp pig-core.jar DATE.java
# cd ..
# jar -cf date.jar date
</pre>