# PCA

<pre>
# javac Data.java Matrix.java
# java Data 
</pre>

# Matrix Manipulation

<pre>
# global -f Matrix.java
Matrix              1 Matrix.java      class Matrix {
main                5 Matrix.java       public static void main(String[] args) {
singularValueDecomposition   24 Matrix.java             static double[][][] singularValueDecomposition(double[][] input) {
eigenDecomposition   42 Matrix.java             static EigenSet eigenDecomposition(double[][] input) {
extractDiagonalEntries   72 Matrix.java         static double[] extractDiagonalEntries(double[][] input) {
QRFactorize        80 Matrix.java       static double[][][] QRFactorize(double[][] input) {
gramSchmidt        94 Matrix.java       static double[][] gramSchmidt(double[][] input) {
GivensRotation    107 Matrix.java       static double[][] GivensRotation(int size, int i, int j, double th) {
transpose         123 Matrix.java       static double[][] transpose(double[][] matrix) {
add               133 Matrix.java       static double[][] add(double[][] a, double[][] b) {
subtract          146 Matrix.java       static double[][] subtract(double[][] a, double[][] b) {
add               159 Matrix.java       static double[] add(double[] a, double[] b) {
subtract          170 Matrix.java       static double[] subtract(double[] a, double[] b) {
multiply          181 Matrix.java       static double[][] multiply(double[][] a, double[][] b) {
scale             196 Matrix.java       static double[][] scale(double[][] mat, double coeff) {
dot               206 Matrix.java       static double dot(double[] a, double[] b) {
copy              218 Matrix.java       static double[][] copy(double[][] input) {
getColumn         228 Matrix.java       static double[] getColumn(double[][] matrix, int i) {
getRow            232 Matrix.java       static double[] getRow(double[][] matrix, int i) {
proj              240 Matrix.java       static double[] proj(double[] vec, double[] proj) {
normalize         249 Matrix.java       static double[] normalize(double[] vec) {
norm              258 Matrix.java       static double norm(double[] vec) {
mean              262 Matrix.java       static double mean(double[] entries) {
print             270 Matrix.java       static void print(double[][] matrix) {
MatrixException   285 Matrix.java      class MatrixException extends RuntimeException {
EigenSet          291 Matrix.java      class EigenSet {
</pre>