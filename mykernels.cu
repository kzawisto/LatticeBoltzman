#include<mykernels.h>
#include <cstdio>
#include<cmath>
int dirArr[]={0,0,0,-1,0,1,-1,0,-1,-1,-1,1,1,0,1,-1,1,1};
int revArr[]={0, 2, 1, 6, 8, 7, 3, 5, 4};
float wArr[]={4.f/9.f,1.f/9.f,1.f/9.f,1.f/9.f,1.f/36.f,1.f/36.f,1.f/9.f,1.f/36.f,1.f/36.f};
__constant__ int cdirArr [18], crevArr[9];
__constant__ float cwArr[9];

__global__ void npRoll(float * arr1, float * arr2, int w, int h,int stepx, int stepy){
  int i =blockIdx.x;
   arr2[i*w+threadIdx.x] = arr1[((i+stepy+h)%h)*w + (threadIdx.x+stepx+w)%w];
  
}



__global__ void equilibrium(float * rho, float * vel,float * feq){
  const int b = blockIdx.x, t = threadIdx.x;
  float v;
  float usq =vel[b *_Nx + t] * vel[b *_Nx + t] + vel[_N+ b *_Nx + t]*vel[_N+ b *_Nx + t];
  #pragma unroll
  for(int i =0;i< 9;++i){
    v=cdirArr[2*i] *vel[b *_Nx + t] + cdirArr[2*i+1] *vel[_N+ b *_Nx + t];
    feq[i*_N+ b *_Nx + t]= rho[b *_Nx + t] * cwArr[i] *(1.f + 3* v +4.5f*v*v- 1.5f*usq);
  }
}
__global__ void equilibriumInit(float * feq){
  const int b = blockIdx.x, t = threadIdx.x;
  float v, vX =  _ULB *(1.0+1e-2f*sin((3*(float)blockIdx.x)/(_Ny-1)*M_PI));
 #pragma unroll
  for(int i =0;i< 9;++i){
    v=cdirArr[2*i] *vX;
   
    feq[i*_N+ b *_Nx + t]= cwArr[i] *(1.f + 3* v +4.5f*v*v- 1.5f*vX*vX);
  }
}


__global__ void findRhoAndMomentum(float* fin, float * rho, float* momentum){
    const int b = blockIdx.x, t = threadIdx.x;
    float r=0, m1=0,m2=0;
    #pragma unroll
    for(int i =0; i< 9;++i){
      r+=fin[i*_N+b*_Nx+t];
      m1 += fin[i*_N+b*_Nx+t]*cdirArr[2*i];
      m2 += fin[i*_N+b*_Nx+t]*cdirArr[2*i+1];
    }
    momentum[_N+b*_Nx+t] = m2/r;
    momentum[b*_Nx+t] = m1/r;
    rho[b*_Nx+t] = r;
    //rho[b*blockDim.x +t]=
  
}
__global__ void findFout(float* fin, float * feq, float* fout){
     const int b = blockIdx.x, t = threadIdx.x;
     #pragma unroll
    for(int i =0;i< 9;++i){
     fout[i * _N+b*  _Nx+t] = fin[i * _N+b * _Nx+t] - (fin[i*_N+b*_Nx+t] -feq[i*_N+b*_Nx+t])/ _TAU;
    }
}

__global__ void writeZeros(float* arr){
  const int b = blockIdx.x, t = threadIdx.x;
  arr[b*blockDim.x + t] =0;
}

__global__ void applyObstacle(float * fin, float *fout){
  const int i =blockIdx.x, j = threadIdx.x;
     if(( (i-_Cy)*(i-_Cy) + (j-_Cx)*(j-_Cx) < _RAD* _RAD)){
       #pragma unroll
       for(int k =0; k <9 ;++k){
	 fin[k*_N + i * _Nx + j]=fout[crevArr[k]*_N + i * _Nx + j];
       }
     }
}
__global__ void findResult(float * momentum, float * result){
 // const int i =blockIdx.x, j = threadIdx.x;
  
}
__global__ void prepareResult(float* momentum, float*cresult){
   const int b =blockIdx.x, t = threadIdx.x;
   cresult[b*_Nx+t]  = sqrt(momentum[_N+b*_Nx+t] * momentum[_N+b*_Nx+t] +momentum[b*_Nx+t] * momentum[b*_Nx+t]); 
}
__global__ void copyFirstRow(float *fin, float * feq){
  #pragma unroll
    for(int a =0 ;a <9;++a){
      fin[a*_N + threadIdx.x*_Nx] =feq[a*_N + threadIdx.x*_Nx] ;
    }
}
void allocConstants(){
   cudaMemcpyToSymbol (cdirArr,dirArr, 18*4 );  
   cudaMemcpyToSymbol (crevArr,revArr, 9*4 );
   cudaMemcpyToSymbol (cwArr,wArr, 9*4 );
}