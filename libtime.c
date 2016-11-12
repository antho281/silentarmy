#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <dlfcn.h>
#include <assert.h>
#include <time.h>

/*
Temprorary fix for silentarmy - nvidia
The MIT License (MIT) Copyright (c) 2016 krnlx, kernelx at me.com
*/


int inited=0;

void *libc = NULL;

int (*libc_clock_gettime)(clockid_t clk_id, struct timespec *tp) = NULL;

static void __attribute__ ((constructor)) lib_init(void)  {
  if(inited)
    return;

  libc = dlopen("libc.so.6", RTLD_LAZY);
  assert(libc);

  libc_clock_gettime = dlsym(libc, "clock_gettime");
  assert(libc_clock_gettime);

  inited++;
}


useconds_t sleep_time = 100;
//const long INTERVAL_MS = 500 * 100;

//struct timespec sleepValue = {0};

//sleepValue.tv_nsec = INTERVAL_MS;
//nanosleep(&sleepValue, NULL);

int clock_gettime(clockid_t clk_id, struct timespec *tp){
  lib_init();
  //printf(".");
  usleep(sleep_time);
//	sleepValue.tv_nsec = INTERVAL_MS;
//	nanosleep(&sleepValue, NULL);
// sched_yield();
  int r = (*libc_clock_gettime)(clk_id, tp);
  return r;
}
