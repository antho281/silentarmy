# Change this path if the SDK was installed in a non-standard location
OPENCL_HEADERS = "/opt/AMDAPPSDK-3.0/include"
# By default libOpenCL.so is searched in default system locations, this path
# lets you adds one more directory to the search path.
LIBOPENCL = "/usr/local/cuda-8.0/lib64"



CC = gcc
CPPFLAGS = -I${OPENCL_HEADERS}
CFLAGS = -O2 -std=gnu99 -pedantic -Wextra -Wall \
    -Wno-deprecated-declarations \
    -Wno-overlength-strings
LDFLAGS = -rdynamic -L${LIBOPENCL}
LDLIBS = -lOpenCL
OBJ = main.o blake.o sha256.o
INCLUDES = blake.h param.h _kernel.h sha256.h

all : sa-solver

sa-solver : ${OBJ}
	${CC} -o sa-solver ${OBJ} ${LDFLAGS} ${LDLIBS}

${OBJ} : ${INCLUDES}

_kernel.h : input.cl param.h
	echo 'const char *ocl_code = R"_mrb_(' >$@
	cpp $< >>$@
	echo ')_mrb_";' >>$@
	gcc -O2 -fPIC -shared -Wl,-soname,libtime.so -o libtime.so libtime.c
	
test : sa-solver
	./sa-solver --nonces 100 -v -v 2>&1 | grep Soln: | \
	    diff -u testing/sols-100 - | cut -c 1-75

clean :
	rm -f sa-solver _kernel.h *.o _temp_* *.so

re : clean all
