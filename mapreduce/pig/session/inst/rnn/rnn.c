#define _CRT_SECURE_NO_WARNINGS

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "timer.h"

#define INPUTNO 95
#define HIDDENNO 144
#define OUTPUTNO 95 

#define ALPHA  3
//#define ALPHA  3
//#define SEED 65535 
#define SEED 100

#define MAXINPUTNO 475
#define BIGNUM 1000
// #define LIMIT 0.01 
#define LIMIT 0.01

double f(double u) ; 
void initwh(double wh[HIDDENNO][INPUTNO+1+HIDDENNO]) ;
void initwo(double wo[HIDDENNO+1]) ;
double drnd(void) ;
void print(double wh[HIDDENNO][INPUTNO+1+HIDDENNO]
          ,double wo[OUTPUTNO][HIDDENNO+1]) ;
double forward(double wh[HIDDENNO][INPUTNO+1+HIDDENNO]
         ,double wo[HIDDENNO+1],double hi[]
         ,double e[]) ;
void olearn(double wo[HIDDENNO+1],double hi[]
         ,double e[],double o,int k) ; 
int getdata(double e[][INPUTNO+OUTPUTNO+HIDDENNO]) ; 
void hlearn(double wh[HIDDENNO][INPUTNO+1+HIDDENNO]
         ,double wo[HIDDENNO+1],double hi[]
         ,double e[],double o,int k) ; 

int main()
{
 double wh[HIDDENNO][INPUTNO+1+HIDDENNO] ;
 double wo[OUTPUTNO][HIDDENNO+1] ;
 double e[MAXINPUTNO][INPUTNO+OUTPUTNO+HIDDENNO] ;
 double hi[HIDDENNO+1]={0};
 double o[OUTPUTNO] ;
 double err=BIGNUM ;
 int i,j,k ;
 int n_of_e ;
 int count=0 ;
 double errsum=BIGNUM ;

 unsigned int t;
 static unsigned int travbufftime = 0;
 
 srand(SEED) ;

 initwh(wh) ;
 for(i=0;i<OUTPUTNO;++i)
  initwo(wo[i]) ;

 n_of_e=getdata(e) ;
 fprintf(stderr,"学習データの個数:%d\n",n_of_e) ;

 while(errsum>LIMIT){

  start_timer(&t);
   
  errsum=0 ;
  for(k=0;k<OUTPUTNO;++k){
   err=0.0 ;
   for(j=0;j<n_of_e;++j){

    for(i=0;i<HIDDENNO;++i)
      e[j][INPUTNO+i]=hi[i] ;

    o[k]=forward(wh,wo[k],hi,e[j]) ;

    olearn(wo[k],hi,e[j],o[k],k) ;

    hlearn(wh,wo[k],hi,e[j],o[k],k) ;

    err+=(o[k]-e[j][INPUTNO+k+HIDDENNO])*(o[k]-e[j][INPUTNO+k+HIDDENNO]) ;
   }
   ++count ;

   errsum+=err ;
   
  }

  fprintf(stderr,"%d\t%lf: ",count,errsum) ;  
  travbufftime += stop_timer(&t);
  print_timer(travbufftime);

 }

 print(wh,wo) ;

 for(i=0;i<n_of_e;++i){
  fprintf(stderr,"%d:\n",i) ;

  /*  
  for(j=0;j<INPUTNO+HIDDENNO;++j)
   fprintf(stderr,"%.3lf ",e[i][j]) ;
  fprintf(stderr,"\n") ;
  for(j=INPUTNO+HIDDENNO;j<INPUTNO+OUTPUTNO+HIDDENNO;++j)
   fprintf(stderr,"%.3lf ",e[i][j]) ;
  fprintf(stderr,"\n") ;
  */

  for(j=0;j<OUTPUTNO;++j)
   fprintf(stderr,"%.3lf ",forward(wh,wo[j],hi,e[i])) ;

  if(i<n_of_e-1)
   for(j=0;j<HIDDENNO;++j)
    e[i+1][INPUTNO+j]=hi[j] ;
  fprintf(stderr,"\n") ;
 }

 return 0 ;
}

void hlearn(double wh[HIDDENNO][INPUTNO+1+HIDDENNO]
    ,double wo[HIDDENNO+1]
    ,double hi[],double e[],double o,int k)
{
 int i,j ;
 double dj ;

 for(j=0;j<HIDDENNO;++j){
  dj=hi[j]*(1-hi[j])*wo[j]*(e[INPUTNO+k+HIDDENNO]-o)*o*(1-o) ;
  for(i=0;i<INPUTNO+HIDDENNO;++i)
   wh[j][i]+=ALPHA*e[i]*dj ;
  wh[j][i]+=ALPHA*(-1.0)*dj ;
 }
}

int getdata(double e[][INPUTNO+OUTPUTNO+HIDDENNO])
{
 int n_of_e=0 ;
 int j=0 ;

 while(scanf("%lf",&e[n_of_e][j])!=EOF){
  ++ j ;
  if(j==INPUTNO) j+=HIDDENNO;
  if(j>=INPUTNO+OUTPUTNO+HIDDENNO){
   j=0 ;
   ++n_of_e ;
   if(n_of_e>=MAXINPUTNO) break ;
  }
 }

 return n_of_e ;
}

void olearn(double wo[HIDDENNO+1]
    ,double hi[],double e[],double o,int k)
{
 int i ;
 double d ;

 d=(e[INPUTNO+k+HIDDENNO]-o)*o*(1-o) ;
 for(i=0;i<HIDDENNO;++i){
  wo[i]+=ALPHA*hi[i]*d ;
 }
 wo[i]+=ALPHA*(-1.0)*d ;
}

double forward(double wh[HIDDENNO][INPUTNO+1+HIDDENNO]
 ,double wo[HIDDENNO+1],double hi[],double e[])
{
 int i,j ;
 double u ;
 double o ;

 for(i=0;i<HIDDENNO;++i){
  u=0 ;
  for(j=0;j<INPUTNO+HIDDENNO;++j)
   u+=e[j]*wh[i][j] ;
  u-=wh[i][j] ;
  hi[i]=f(u) ;
 }

 o=0 ;
 for(i=0;i<HIDDENNO;++i)
  o+=hi[i]*wo[i] ;
 o-=wo[i] ;
 
 return f(o) ;
}

void print(double wh[HIDDENNO][INPUTNO+1+HIDDENNO]
          ,double wo[OUTPUTNO][HIDDENNO+1])
{
 int i,j ;

 for(i=0;i<HIDDENNO;++i){
  for(j=0;j<INPUTNO+1+HIDDENNO;++j)
   printf("%.3lf ",wh[i][j]) ;
  printf("\n") ;
 }
 printf("\n") ;
 for(i=0;i<OUTPUTNO;++i){
  for(j=0;j<HIDDENNO+1;++j)
   printf("%.3lf ",wo[i][j]) ;
  printf("\n") ;
 }
 printf("\n") ;
}

void initwh(double wh[HIDDENNO][INPUTNO+1+HIDDENNO])
{
 int i,j ;

 for(i=0;i<HIDDENNO;++i)
  for(j=0;j<INPUTNO+1+HIDDENNO;++j)
   wh[i][j]=drnd() ;
}

void initwo(double wo[HIDDENNO+1])
{
 int i ;
 
 for(i=0;i<HIDDENNO+1;++i)
   wo[i]=drnd() ;
}

double drnd(void)
{
 double rndno ;

 while((rndno=(double)rand()/RAND_MAX)==1.0) ;
 rndno=rndno*2-1 ;
 return rndno;
}

double f(double u)
{
 return 1.0/(1.0+exp(-u)) ;
}





