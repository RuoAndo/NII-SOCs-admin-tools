/*********************************************************/
/*                  calccnn.c�@                          */
/* cnn.c�v���O�����̊w�K���ʂ��g����CNN���v�Z����        */
/* �g�����@                                              */
/*  \Users\odaka\ch3>calccnn < data.txt                  */
/*********************************************************/

/*Visual Studio�Ƃ̌݊����m�� */
#define _CRT_SECURE_NO_WARNINGS

/* �w�b�_�t�@�C���̃C���N���[�h*/
#include <stdio.h>
#include <stdlib.h>
#include <math.h>


/*�L���萔�̒�`*/
#define VOCSIZE 12  /*1-of-N�\���̌�b���i�����j*/ 
#define WORDLEN 7   /*1-of-N�\���̒P��̘A����*/
#define FILTERSIZE 3 /*�t�B���^�̑傫��*/
#define POOLSIZE 3 /*�v�[�����O�T�C�Y*/
#define FILTERNO 2 /*�t�B���^�̌�*/

#define INPUTNO 12 /*���͑w�̃Z����*/
  /*��b���ƒP��A�������猈��i(12-2-2)*(7-2-2))*FILTERNO*/ 
#define HIDDENNO 12  /*���ԑw�̃Z����*/ 
#define ALPHA  10  /*�w�K�W��*/ 
#define SEED 7    /*�����̃V�[�h*/ 
#define MAXINPUTNO 100    /*�w�K�f�[�^�̍ő��*/ 

/*�֐��̃v���g�^�C�v�̐錾*/
void convpool(double s[WORDLEN][VOCSIZE],
              double mfilter[FILTERNO][FILTERSIZE][FILTERSIZE],
              double se[INPUTNO+1]) ;/*��ݍ��݂ƃv�[�����O*/
void conv(double filter[][FILTERSIZE]
   ,double sentence[][VOCSIZE]
   ,double convout[][VOCSIZE]) ; /*��ݍ��݂̌v�Z*/
double calcconv(double filter[][FILTERSIZE]
               ,double sentence[][VOCSIZE],int i,int j) ;
                               /*  �t�B���^�̓K�p  */
void convres(double convout[][VOCSIZE]) ;
              /*��ݍ��݂̌��ʏo��*/
int getdata(double sentence[MAXINPUTNO][WORDLEN][VOCSIZE]);
                                     /*�f�[�^�ǂݍ���*/ 
void poolres(double poolout[][VOCSIZE]) ;/*�v�[�����O�o��*/
void pool(double convout[][VOCSIZE]
         ,double poolout[][VOCSIZE]) ; 
             /*�v�[�����O�̌v�Z*/           
double maxpooling(double convout[][VOCSIZE]
                 ,int i,int j) ;/* �ő�l�v�[�����O */
         
double f(double u) ; /*�`�B�֐��i�V�O���C�h�֐��j*/
void readwh(double wh[HIDDENNO][INPUTNO+1]) ;
                         /*���ԑw�̏d�݂̏�����*/
void readwo(double wo[HIDDENNO+1]) ;/*�o�͑w�̏d�݂̏�����*/

void print(double wh[HIDDENNO][INPUTNO+1]
          ,double wo[HIDDENNO+1]) ; /*���ʂ̏o��*/
double forward(double wh[HIDDENNO][INPUTNO+1]
         ,double wo[HIDDENNO+1],double hi[]
         ,double e[INPUTNO+1]) ; /*�������̌v�Z*/

/*******************/ 
/*    main()�֐�   */ 
/*******************/ 
int main()
{
 double mfilter[FILTERNO][FILTERSIZE][FILTERSIZE]
      ={
        {{1,0,0},{0,1,0},{0,0,1}} ,
        {{1,0,0},{1,0,0},{1,0,0}} 
       };/*�t�B���^�Q*/
 double sentence[MAXINPUTNO][WORDLEN][VOCSIZE] ;/*���̓f�[�^*/
 double convout[WORDLEN][VOCSIZE]={0} ;/*��ݍ��ݏo��*/
 double poolout[WORDLEN][VOCSIZE]={0} ;/*�o�̓f�[�^*/

 double wh[HIDDENNO][INPUTNO+1] ;/*���ԑw�̏d��*/
 double wo[HIDDENNO+1] ;/*�o�͑w�̏d��*/
 double e[MAXINPUTNO][INPUTNO+1] ;/*�w�K�f�[�^�Z�b�g*/
 double hi[HIDDENNO+1] ;/*���ԑw�̏o��*/
 double o ;/*�o��*/
 int i,j ;/*�J��Ԃ��̐���*/
 int n_of_e ;/*�w�K�f�[�^�̌�*/
 int count=0 ;/*�J��Ԃ��񐔂̃J�E���^*/

 /*�d�݂̓ǂݍ���*/
 readwh(wh) ;/*���ԑw�̏d�݂̓ǂݍ���*/
 readwo(wo) ;/*�o�͑w�̏d�݂̓ǂݍ���*/
 print(wh,wo) ; /*���ʂ̏o��*/

 /*�����f�[�^�̓ǂݍ���*/
 n_of_e=getdata(sentence) ;
 printf("�����f�[�^�̌�:%d\n",n_of_e) ;

 /*��ݍ��݂ƃv�[�����O�̌v�Z*/
 for(i=0;i<n_of_e;++i){
  convpool(sentence[i],mfilter,e[i]) ;
 }

 /*�����׏d�̏o��*/
 print(wh,wo) ; 

 /*�w�K�f�[�^�ɑ΂���o��*/
 for(i=0;i<n_of_e;++i){
  printf("%d\n",i) ;
  for(j=0;j<INPUTNO;++j)
   printf("%lf ",e[i][j]) ;
  printf("\n") ;
  o=forward(wh,wo,hi,e[i]) ;
  printf("%lf\n\n",o) ;
 }

 return 0 ;
}
/**********************/
/*  poolres()�֐�     */
/* �@���ʏo��         */
/**********************/
void poolres(double poolout[][VOCSIZE]) 
{
 int i,j ;/*�J��Ԃ��̐���*/
 int startpoint=FILTERSIZE/2+POOLSIZE/2 ;
               /*�v�[�����O�v�Z�͈͂̉���*/

 for(i=startpoint;i<WORDLEN-startpoint;++i){
  for(j=startpoint;j<VOCSIZE-startpoint;++j)
   printf("%.3lf ",poolout[i][j]) ;  
  printf("\n") ;
 }
 printf("\n") ;	
} 

/**********************/
/*  pool()�֐�        */
/* �v�[�����O�̌v�Z   */
/**********************/
void pool(double convout[][VOCSIZE]
         ,double poolout[][VOCSIZE]) 
{
 int i,j ;/*�J��Ԃ��̐���*/
 int startpoint=FILTERSIZE/2+POOLSIZE/2 ;
                /*�v�[�����O�v�Z�͈͂̉���*/

 for(i=startpoint;i<WORDLEN-startpoint;++i)
  for(j=startpoint;j<VOCSIZE-startpoint;++j)
   poolout[i][j]=maxpooling(convout,i,j) ;
}

/**********************/
/* maxpooling()�֐�   */
/* �ő�l�v�[�����O   */
/**********************/
double maxpooling(double convout[][VOCSIZE]
                 ,int i,int j)
{
 int m,n ;/*�J��Ԃ��̐���p*/
 double max ;/*�ő�l*/
 
 max
 =convout[i+POOLSIZE/2][j+POOLSIZE/2];
 for(m=i-POOLSIZE/2;m<=i+POOLSIZE/2;++m)
  for(n=j-POOLSIZE/2;n<=j+POOLSIZE/2;++n)
   if(max<convout[m][n]) max=convout[m][n] ;

 return max ;
}
 

/**********************/
/*  convres()�֐�     */
/* ��ݍ��݂̌��ʏo�� */
/**********************/
void convres(double convout[][VOCSIZE]) 
{
 int i,j ;/*�J��Ԃ��̐���*/
 int startpoint=FILTERSIZE/2 ;/*�o�͔͈͂̉���*/
 
 for(i=startpoint;i<WORDLEN-1;++i){
  for(j=startpoint;j<VOCSIZE-1;++j){
   printf("%.3lf ",convout[i][j]) ;
  }
  printf("\n") ;
 }
 printf("\n") ;	
} 

/**********************/
/*  conv()�֐�        */
/*  ��ݍ��݂̌v�Z    */
/**********************/
void conv(double filter[][FILTERSIZE]
         ,double sentence[][VOCSIZE],double convout[][VOCSIZE])
{
 int i=0,j=0 ;/*�J��Ԃ��̐���p*/
 int startpoint=FILTERSIZE/2 ;/*��ݍ��ݔ͈͂̉���*/

 for(i=startpoint;i<WORDLEN-startpoint;++i)
  for(j=startpoint;j<VOCSIZE-startpoint;++j)
   convout[i][j]=calcconv(filter,sentence,i,j) ;
}

/**********************/
/*  calcconv()�֐�    */
/*  �t�B���^�̓K�p    */
/**********************/
double calcconv(double filter[][FILTERSIZE]
             ,double sentence[][VOCSIZE],int i,int j)
{
 int m,n ;/*�J��Ԃ��̐���p*/
 double sum=0 ;/*�a�̒l*/
 
 for(m=0;m<FILTERSIZE;++m)
  for(n=0;n<FILTERSIZE;++n)
   sum+=sentence[i-FILTERSIZE/2+m][j-FILTERSIZE/2+n]*filter[m][n];
   
 return sum ;
}

/************************/
/*  convpool()�֐�      */
/*  ��ݍ��݂ƃv�[�����O*/
/************************/
void convpool(double s[WORDLEN][VOCSIZE],
              double mfilter[FILTERNO][FILTERSIZE][FILTERSIZE],
              double se[INPUTNO+1])
{
 int i,j,k;
 int startpoint=FILTERSIZE/2+POOLSIZE/2 ;
               /*�v�[�����O�v�Z�͈͂̉���*/
 /*�e�t�B���^��p���ď�ݍ��݂ƃv�[�����O�����s*/
 for(i=0;i<FILTERNO;++i){ 
  double convout[WORDLEN][VOCSIZE]={0} ;/*��ݍ��ݏo��*/
  double poolout[WORDLEN][VOCSIZE]={0} ;/*�o�̓f�[�^*/
  /*��ݍ��݂̌v�Z*/
  conv(mfilter[i],s,convout) ;

  /*��ݍ��݉��Z�̌��ʏo��*/
  convres(convout) ;

  /*�v�[�����O�̌v�Z*/
  pool(convout,poolout) ;

  /*���ʂ̏o��*/
  poolres(poolout) ;

  /*��ݍ��݌v�Z�̌��ʂ��A�S�������ւ̓��͂Ƃ��đ��*/
  for(j=startpoint;j<WORDLEN-startpoint;++j){
   for(k=startpoint;k<VOCSIZE-startpoint;++k)
    se[i*INPUTNO/FILTERNO+(j-startpoint)*(VOCSIZE-startpoint*2)+(k-startpoint)]
      =poolout[j][k];  
  }
 } 

}

/**********************/
/*  getdata()�֐�     */
/*�w�K�f�[�^�̓ǂݍ���*/
/**********************/
int getdata(double sentence[MAXINPUTNO][WORDLEN][VOCSIZE])
{
 int i=0,j=0,k=0 ;/*�J��Ԃ��̐���p*/

 /*�f�[�^�̓���*/
 while(scanf("%lf",&sentence[i][j][k])!=EOF){
  ++ k ;
  if(k>=VOCSIZE){/*���̃f�[�^*/
   k=0 ;
   ++j ;
   if(j>=WORDLEN){/*���̃f�[�^�Z�b�g*/
    j=0 ;
    ++i ;
   }
  }
  if(i>MAXINPUTNO) break ;/*���͏I��*/
 }
 return i ;

}

/**********************/
/*  forward()�֐�     */
/*  �������̌v�Z      */
/**********************/
double forward(double wh[HIDDENNO][INPUTNO+1]
 ,double wo[HIDDENNO+1],double hi[],double e[INPUTNO+1])
{
 int i,j ;/*�J��Ԃ��̐���*/
 double u ;/*�d�ݕt���a�̌v�Z*/
 double o ;/*�o�͂̌v�Z*/

 /*hi�̌v�Z*/
 for(i=0;i<HIDDENNO;++i){
  u=0 ;/*�d�ݕt���a�����߂�*/
  for(j=0;j<INPUTNO;++j)
   u+=e[j]*wh[i][j] ; 
  u-=wh[i][j] ;/*�������l�̏���*/
  hi[i]=f(u) ;
 }
 /*�o��o�̌v�Z*/
 o=0 ;
 for(i=0;i<HIDDENNO;++i)
  o+=hi[i]*wo[i] ;
 o-=wo[i] ;/*�������l�̏���*/
 
 return f(o) ;
} 

/**********************/
/*   print()�֐�      */
/*   ���ʂ̏o��       */
/**********************/
void print(double wh[HIDDENNO][INPUTNO+1]
          ,double wo[HIDDENNO+1])
{
 int i,j ;/*�J��Ԃ��̐���*/

 for(i=0;i<HIDDENNO;++i)
  for(j=0;j<INPUTNO+1;++j)
   printf("%lf ",wh[i][j]) ;
 printf("\n") ;
 for(i=0;i<HIDDENNO+1;++i)
  printf("%lf ",wo[i]) ;
 printf("\n") ;
} 

/************************/
/*    readwh()�֐�      */
/*���ԑw�̏d�݂̓ǂݍ���*/
/************************/
void readwh(double wh[HIDDENNO][INPUTNO+1])
{
 int i,j ;/*�J��Ԃ��̐���*/

 /*�d�݂̓ǂݍ���*/ 
 for(i=0;i<HIDDENNO;++i)
  for(j=0;j<INPUTNO+1;++j)
   scanf("%lf",&(wh[i][j])) ;
} 

/************************/
/*    readwo()�֐�      */
/*�o�͑w�̏d�݂̓ǂݍ���*/
/************************/
void readwo(double wo[HIDDENNO+1])
{
 int i ;/*�J��Ԃ��̐���*/

 /*�d�݂̓ǂݍ���*/
 for(i=0;i<HIDDENNO+1;++i)
   scanf("%lf",&(wo[i])) ;
} 


/*******************/
/* f()�֐�         */
/* �`�B�֐�        */
/*(�V�O���C�h�֐�) */
/*******************/
double f(double u)
{
 return 1.0/(1.0+exp(-u)) ;
}



