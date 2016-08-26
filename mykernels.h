#ifndef MYKERNELS
#define MYKERNELS
#define _Q 9
#define _w0 0.444444f
#define _w1 0.111111f
#define _w2 0.277778f
#define _Nx 520
#define _Ny 180
#define _RAD ( _Ny/9.0)
#define _Cx ( _Nx/4.0)
#define _Cy ( _Ny/2.0)
#define _ULB  0.04
#define _REY   220.0
#define _VIS  (_ULB*_RAD/_REY)
#define _TAU   (3.0*_VIS+0.5)
#define _N (_Nx*_Ny)

__global__ void npRoll(float * arr1, float * arr2, int w, int h,int stepx, int stepy);
__global__ void equilibrium(float * rho, float * vel,float*feq);
__global__ void equilibriumInit(float*feq);
__global__ void findRhoAndMomentum(float* fin, float * rho, float* momentum);
__global__ void applyObstacle(float * fin, float *fout);
__global__ void findFout(float* fin, float * feq, float* fout);
void allocConstants();
__global__ void copyFirstRow(float*fin, float*feq);
__global__ void prepareResult(float* momentum, float*cresult);

#endif