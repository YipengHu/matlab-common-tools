
// Yipeng - Nov.30th,2009 


#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include "mex.h"
#define	max(A, B)	((A) > (B) ? (A) : (B))
#define	min(A, B)	((A) < (B) ? (A) : (B))

void cpd_comp(double* x, double* y, double* sigma2, double* outlier, int K, double* ss2,
double* P1, double* Pt1, double* Px, double* E,
int N,int M,int D )
{
    int		n, m, d, k;
    double	ksig, diff, razn, outlier_tmp, sp, kw;
    double	*P, *temp_x;
    
    P = (double*) calloc(M, sizeof(double));
    temp_x = (double*) calloc(D, sizeof(double));
    
    ksig = -2.0 * *sigma2;
    outlier_tmp=(*outlier*(M-K)*pow(-ksig*3.14159265358979,0.5*D))/((1-*outlier)*(N-K));
	kw = *sigma2/(*ss2);  // entries for known x-y
	
	// debug:
	// printf ("kw = %lf\n", kw);    
	// N-=K;
	// M-=K;
    // printf ("M=%d, N=%d, K=%d\n", M,N,K);
	
    for (n=0; n<N; n++)
    {
        sp=0;
        for (m=0; m<M; m++)
        {
            
			if (n>(N-K-1) || m>(M-K-1)) 
			{
				*(P+m)=0;  // for computing original P, do not replace kw here as it is the P directly
			}				
			else
			{
				razn=0;
				for (d=0; d<D; d++)
				{
					diff=*(x+n+d*N)-*(y+m+d*M);  
					diff=diff*diff;
					razn+=diff;
				}
				*(P+m)=exp(razn/ksig);
				sp+=*(P+m);
			}
        }
        
        sp+=outlier_tmp;
        *(Pt1+n)=1-outlier_tmp/ sp;
        
        for (d=0; d<D; d++) 
        {
            *(temp_x+d)=*(x+n+d*N)/ sp;
        }
        
        for (m=0; m<M; m++)
        {
            *(P1+m)+=*(P+m)/ sp;
            for (d=0; d<D; d++)
            {
				if (n>(N-K-1) && m>(M-K-1) && (m-M)==(n-N)) 
				{
					*(Px+m+d*M)+= *(temp_x+d)*kw*sp;
				}
				else
				{
					*(Px+m+d*M)+= *(temp_x+d)**(P+m);
				}
            }
        }
		
		if  (n<(N-K))  // NB. as in the m file - only contribution from the non-correspondent (non-landmark) point sets added here
		{			
			*E += -log(sp);
		}  
        
    }
    *E += D*(N-K)*log(*sigma2)/2;    
	
	
	// adding contribution from the corresponding landmarks
	for (k=0; k<K; k++)
	{		
        *(Pt1+N-K+k) = kw;
		*(P1+M-K+k) = kw;
	}
	
    free((void*)P);
    free((void*)temp_x);
    return;
}

// Input arguments
#define IN_x		prhs[0]
#define IN_y		prhs[1]
#define IN_sigma2	prhs[2]
#define IN_outlier	prhs[3]
#define IN_K    	prhs[4]
#define IN_ss2  	prhs[5]

// Output arguments 
#define OUT_P1		plhs[0]
#define OUT_Pt1		plhs[1]
#define OUT_Px		plhs[2]
#define OUT_E		plhs[3]


// gateway routine 
void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )
{
    double  *x, *y, *sigma2, *outlier, *ss2, *P1, *Pt1, *Px, *E;
	int     N, M, D, K;
    
  // Get the sizes of each input argument 
    N = mxGetM(IN_x);
    M = mxGetM(IN_y);
    D = mxGetN(IN_x);
    
  /* Create the new arrays and set the output pointers to them */
    OUT_P1  = mxCreateDoubleMatrix(M, 1, mxREAL);
    OUT_Pt1 = mxCreateDoubleMatrix(N, 1, mxREAL);
    OUT_Px  = mxCreateDoubleMatrix(M, D, mxREAL);
    OUT_E   = mxCreateDoubleMatrix(1, 1, mxREAL);
    
    /* Assign pointers to the input arguments */
    x       = mxGetPr(IN_x);
    y       = mxGetPr(IN_y);
    sigma2  = mxGetPr(IN_sigma2);
    outlier = mxGetPr(IN_outlier);
    K       = mxGetScalar(IN_K);
    ss2     = mxGetPr(IN_ss2);
    
  /* Assign pointers to the output arguments */
    P1  = mxGetPr(OUT_P1);
    Pt1 = mxGetPr(OUT_Pt1);
    Px  = mxGetPr(OUT_Px);
    E   = mxGetPr(OUT_E);
    
	/*
	// debug
	printf ("M=%d, N=%d, K=%d\n", M,N,K);
	printf ("sigma2=%1f, ss2=%1f, outlier=%1f\n", *sigma2,*ss2,*outlier);
	*/
	
  /* Do the actual computations in a subroutine */
    cpd_comp(x, y, sigma2, outlier, K, ss2, P1, Pt1, Px, E, N, M, D);
    
    return;
}


