#include"mykernels.h"
#include"pngwriter.h"
#include <iostream>
#include<string>
#include<algorithm> 
#include<cmath>
#include<sstream>
#include<iomanip>
int dirArr2[]={0,0,0,-1,0,1,-1,0,-1,-1,-1,1,1,0,1,-1,1,1};
const int fsize = sizeof(float);
using namespace std;
float * feq, *fin, *feq0,*rho,*momentum,*cresult, * fout,*result;
void preparations(){
  allocConstants();
  cudaMalloc(&feq,_N*_Q*fsize);
  cudaMalloc(&feq0,_N*_Q*fsize);
  cudaMalloc(&fin,_N*_Q*fsize);
  result = new float[_N];
  cudaMalloc(&fout,_N*_Q*fsize);
  cudaMalloc(&rho,_N*fsize);
   cudaMalloc(&momentum,_N*2*fsize);
   cudaMalloc(&cresult,_N*fsize);
  equilibriumInit<<<_Ny,_Nx>>>(feq);
  cudaMemcpy(feq0,feq,_N*_Q*fsize,cudaMemcpyDeviceToDevice);
  cudaMemcpy(fin,feq,_N*_Q*fsize,cudaMemcpyDeviceToDevice);
  
  
}
void cleaning(){
  cudaFree(feq);
  cudaFree(fout);
  cudaFree(feq0);
  cudaFree(fin);
  cudaFree(rho);
  cudaFree(momentum);
  delete [] result;
  cudaFree(cresult);
}

string itoswithzeros(int i1, int len){
stringstream ss;
ss << setw(len) << setfill('0') << i1;
return ss.str();
}


void step(){
  

  findRhoAndMomentum<<<_Ny,_Nx>>>(fin,rho, momentum);
  prepareResult<<<_Ny,_Nx>>>(momentum,cresult);
  cudaMemcpy(result, cresult, _N*fsize, cudaMemcpyDeviceToHost);
  equilibrium<<<_Ny,_Nx>>>(rho,momentum, feq);
  findFout<<<_Ny,_Nx>>>(fin, feq, fout);
  for(int a =0;a<9;++a){
    npRoll<<<_Ny,_Nx>>>(fout+a*_N,fin+a*_N,_Nx,_Ny,-dirArr2[2*a],-dirArr2[2*a+1]);
   copyFirstRow<<<1,_Ny>>>(fin, feq0);
  }
  applyObstacle<<<_Ny,_Nx>>>(fin,fout);
  
}
void printArray(float* arr){
  cout<<"\n";
  for(int a=0;a< _Ny;++a){
    cout<<"\n";
    for(int b =0;b< _Nx;++b)
      cout<<" "<<arr[a*_Nx+b];
  }
}
int main(){
  string s = "images/img";
 preparations();
 for(int a =0;a<700000;++a) {
   step();
   if(a %200 == 0){
    cout<<a<<" ";
     prepareResult<<<_Ny,_Nx>>>(momentum,cresult);
     cudaMemcpy(result, cresult, _N*fsize, cudaMemcpyDeviceToHost);
   // printArray(result);
     pngwriter out(_Nx, _Ny, 0, (s+itoswithzeros(a/200,4)+".png").c_str());
     float max1=0;
     for(int b =0 ;b< _N;++b) if(max1 < abs(result[b])) max1 = abs(result[b]);
     for(int i = 0; i<_Ny; ++i)
       for(int j = 0;j< _Nx;++j)
	 out.plot(j, i, 0.0, 1.0-result[i*_Nx+j] /(max1),1.0-result[i*_Nx+j] /(max1));
     out.close();
  }
 }
 
 cleaning();
}

void drawPng(string path, float * result){
  
}
