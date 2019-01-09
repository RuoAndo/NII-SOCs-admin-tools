#include <stdio.h>
#include <stdlib.h>
#include <memory.h>
#include <pthread.h>

#define DATA_SIZE 100
#define MAX_DIV 2

typedef struct _thread_arg_t{
    int *pn;
    int length;
    int divided_count;
} thread_arg_t;

void printnum(int *data, int size) {
    int i;
    for (i = 0; i < size; i++) 
        printf("%d ", data[i]);
    printf("\n");
    return;
}

int main(int argc, char *argv[]) {
    int i,n;
    thread_arg_t targ;

    targ.pn = (int *)malloc(sizeof(int) * DATA_SIZE);

    FILE *fp;
    
    fp = fopen(argv[1], "r");
    if(fp == NULL) {
        printf("cannot open file \n");
        return;
    }
 
    n = 0;

    while ( ! feof(fp) && n < 512) {
        fscanf(fp, "%d", &(targ.pn[n]));
        n++;
    }
 
    fclose(fp);
    
    /*
    srand((unsigned int)time(NULL));
    
    for (i = 0; i < DATA_SIZE; i++)
        targ.pn[i] = rand();
    */

    printf("before\n");
    printnum(targ.pn, DATA_SIZE);

    targ.divided_count = 0; 
    targ.length = DATA_SIZE;

    return 0;
}

