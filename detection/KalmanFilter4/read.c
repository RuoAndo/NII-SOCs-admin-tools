#include <stdio.h>
 
void main(int argc, char *argv[])
{
    int i, n;
    float siny[512];
 
    FILE *fp;
 
    fp = fopen(argv[1], "r");
    if(fp == NULL) {
        printf("cannot open fie \n");
        return;
    }
 
    n = 0;
 
    while ( ! feof(fp) && n < 512) {
        fscanf(fp, "%f", &(siny[n]));
        n++;
    }
 
    fclose(fp);
 
    n = n-1; 
 
    for(i=0; i<n; i++) {
        printf("%f\n", siny[i]);
    }
}
