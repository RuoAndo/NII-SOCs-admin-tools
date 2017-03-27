# pig: User Defined Function

building jar file

<pre>
# cd pigUDF
# javac -cp pig-core.jar pigDateExtractor.java
# cd ..
# jar cf pigUDF.jar pigUDF/
</pre>

pig -x local 1.pig

