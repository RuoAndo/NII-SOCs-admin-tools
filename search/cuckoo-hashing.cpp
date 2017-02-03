#include<bits/stdc++.h>
 
#define MAXN 11
#define ver 2
 
int hashtable[ver][MAXN];
 
int pos[ver];
 
void initializeHashTable()
{
    for (int j=0; j<MAXN; j++)
        for (int i=0; i<ver; i++)
            hashtable[i][j] = INT_MIN;
}
 
int hash(int function, int key)
{
    switch (function)
    {
        case 1: return key%MAXN;
        case 2: return (key/MAXN)%MAXN;
    }
}

void place(int key, int tableID, int cnt, int n)
{
    /* avoiding recursive loop */
    if (cnt==n)
    {
        printf("%d unput \n", key);
        return;
    }
 
    for (int i=0; i<ver; i++)
    {
        pos[i] = hash(i+1, key);
        if (hashtable[i][pos[i]] == key)
           return;
    }
 
    if (hashtable[tableID][pos[tableID]]!=INT_MIN)
    {
        int dis = hashtable[tableID][pos[tableID]];
        hashtable[tableID][pos[tableID]] = key;
        place(dis, (tableID+1)%ver, cnt+1, n);
    }
    else // swap out
       hashtable[tableID][pos[tableID]] = key;
}
 
void displayTable()
{
    printf("Result:\n");
 
    for (int i=0; i<ver; i++, printf("\n"))
        for (int j=0; j<MAXN; j++)
            (hashtable[i][j]==INT_MIN)? printf("- "):
                     printf("%d ", hashtable[i][j]);
 
    printf("\n");
}
 
void cuckoo(int keys[], int n)
{
    initializeHashTable();
 
    for (int i=0, cnt=0; i<n; i++, cnt=0)
        place(keys[i], 0, cnt, n);
 
    displayTable();
}
 
int main()
{

    int keys_1[] = {20, 50, 53, 75, 100, 67, 105,
                    3, 36, 39};
 
    int n = sizeof(keys_1)/sizeof(int);
 
    cuckoo(keys_1, n);
 
    int keys_2[] = {20, 50, 53, 75, 100, 67, 105,
                    3, 36, 39, 6};
 
    int m = sizeof(keys_2)/sizeof(int);
 
    cuckoo(keys_2, m);
 
    return 0;
}
