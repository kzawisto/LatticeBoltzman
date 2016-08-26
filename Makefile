
CC=/usr/local/cuda-7.0/bin/nvcc
CFLAGS=-I.


main: main.o mykernels.o
	$(CC) -std=c++11 -I/usr/local/cuda-7.0/include -g -I$(shell pwd) -o main mykernels.o main.o -I../pngwriter-master/src -I/usr/include/freetype2 -L../pngwriter-master/src -lpng -lpngwriter -lz -lfreetype -lpng

main.o: main.cu
	$(CC) -std=c++11 -I/usr/local/cuda-7.0/include -g -I$(shell pwd) -o main.o -c main.cu -I../pngwriter-master/src -I/usr/include/freetype2
	
mykernels.o: mykernels.cu
	$(CC) -std=c++11 -I/usr/local/cuda-7.0/include -g -I$(shell pwd) -o mykernels.o -c mykernels.cu
	
.PHONY: clean

clean: 
	rm -f main main.o mykernels.o
