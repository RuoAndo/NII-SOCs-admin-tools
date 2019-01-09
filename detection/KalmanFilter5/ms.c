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

void displaynum(int *data, int size) {
    int i;
    for (i = 0; i < size; i++) 
        printf("%d ", data[i]);
    printf("\n");
    return;
}

void swap(int *pn1, int *pn2) {
    int tmp = *pn1; *pn1 = *pn2; *pn2 = tmp;
}

void quick_sort(int *pn, int left, int right) {
    int i, j;

    if (left >= right) return;

    j = left;
    for (i = left + 1; i <= right; i++) {
        if (*(pn + i) < *(pn + left)) 
            swap(pn + (++j), pn + i);
    }
    swap(pn + left, pn + j);

    /* recursive call */
    quick_sort(pn, left, j - 1);
    quick_sort(pn, j + 1, right);

}

void merge(int *pn1, int len1, int *pn2, int len2, int *pn) {
    int u1 = 0, u2 = 0;

    while (u1 < len1 || u2 < len2)
    {
        if ((u2 >= len2) || ((u1 < len1) && (pn1[u1] < pn2[u2]))) {
            pn[u1 + u2] = pn1[u1]; u1++;
        } else {
            pn[u1 + u2] = pn2[u2]; u2++;
        }
    }
}

void thread_merge_func(void *arg) {
    thread_arg_t *targ = (thread_arg_t *)arg;
    pthread_t handle[2];
    int len1, len2;
    thread_arg_t c_targ[2];

    if (targ->length <= 1) {
    }else if (targ->divided_count >= MAX_DIV) {
        quick_sort(targ->pn, 0, targ->length - 1); 
    } else {

        len1 = targ->length / 2;
        len2 = targ->length - len1;

        c_targ[0].pn = (int *)malloc(sizeof(int) * len1);
        c_targ[1].pn = (int *)malloc(sizeof(int) * len2);
        memcpy(c_targ[0].pn, targ->pn, len1 * sizeof(int));
        memcpy(c_targ[1].pn, targ->pn + len1, len2 * sizeof(int));

        c_targ[0].length = len1;
        c_targ[0].divided_count = targ->divided_count + 1;

        c_targ[1].length = len2;
        c_targ[1].divided_count = targ->divided_count + 1;

        pthread_create(&handle[0], NULL, (void *)thread_merge_func,
                (void *)&c_targ[0]);
        pthread_create(&handle[1], NULL, (void *)thread_merge_func,
                (void *)&c_targ[1]);

        pthread_join(handle[0], NULL);
        pthread_join(handle[1], NULL);

        merge(c_targ[0].pn, len1, c_targ[1].pn, len2, targ->pn);

        free(c_targ[0].pn);
        free(c_targ[1].pn);
    }
    return;
}

int main(int argc, char *argv[]) {
    int i,n;
    thread_arg_t targ;

    targ.pn = (int *)malloc(sizeof(int) * DATA_SIZE);

    /*
    srand((unsigned int)time(NULL));
    for (i = 0; i < DATA_SIZE; i++)
        targ.pn[i] = rand();
    */

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

    printf("before\n");
    displaynum(targ.pn, DATA_SIZE);

    targ.divided_count = 0; 
    targ.length = DATA_SIZE;

    thread_merge_func(&targ);

    printf("after\n");
    displaynum(targ.pn, DATA_SIZE);

    return 0;
}

