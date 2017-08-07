#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <math.h>
#include <pthread.h>

#define THREAD_NUM 3
#define DATA_NUM 24

typedef struct _thread_arg {
    int id;
    bool *primes;
} thread_arg_t;

void thread_func(void *arg) {
    thread_arg_t* targ = (thread_arg_t *)arg;
    int c_start, c_end, range, limit;
    int i, j;

    /* ���̃X���b�h����������͈͂����߂� */
    range = DATA_NUM / THREAD_NUM;
    c_start = targ->id *range;
    c_end =(targ->id+1) *range;
    if (c_end > DATA_NUM) c_end = DATA_NUM;

    /* ���肷�� */
    for (i = c_start; i < c_end; i++) {
      printf("%d: %d \n ", targ->id, i);
    }
    return;
}

int main() {
    pthread_t handle[THREAD_NUM];
    thread_arg_t targ[THREAD_NUM];
    bool primes[DATA_NUM];
    int i;

    /* ������ */
    for (i = 0; i < DATA_NUM; i++)
        primes[i] = true;

    /* �����J�n */
    for (i = 0; i < THREAD_NUM; i++) {
        targ[i].id = i;
        targ[i].primes = primes;
        pthread_create(&handle[i], NULL, (void*)thread_func, (void*)&targ[i]);
    }

    /* �I����҂� */
    for (i = 0; i < THREAD_NUM; i++) 
        pthread_join(handle[i], NULL);

    /* ���ʂ̏o�� */
    /*
    for (i = 2; i < DATA_NUM; i++) 
        if (primes[i]) 
            printf("%d ", i);
    printf("\n");
    */
    return 0;
}
