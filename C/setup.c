
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>
#include <signal.h>
#include <fcntl.h>
#include <ctype.h>
//#include <termios.h>
#include <sys/types.h>
#include <sys/mman.h>
#include <stdint.h>
#include <unistd.h>
#include <math.h>

#include "setup.h"
#include "CONST.h"

int setup(int *fd, int *gps, void **map_base) {

  //INATLL FPGA MODULE
  if(system("./progfpga red_pitaya_top.bit")==-1) {
    printf("Cannot install FPGA module\n");
    return -1;
  }

  /*//OPEN DEVICE MOUNTING POINT
  if((*fd = open("/dev/mem", O_RDWR | O_SYNC)) == -1) {
    printf("Cannot open the mem device\n");
    return -2;
  }*/

/*
  //OPEN GPS
  if((*gps = open("/dev/ttyACM0", O_RDONLY  | O_NONBLOCK)) == -1){
    printf("Cannot open the GPS device\n");
    return -3;
  }
*/
 
  //MAP ONE PAGE
  /**map_base = mmap(0, MAP_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, *fd, BASE_ADDR & ~MAP_MASK);  
  if(map_base == (void *) -1) {
    printf("Cannot map memory\n");
    return -4;
  }*/

  return 0;
}


void setup_clear(int *fd, int *gps, void **map_base) {
  int fd_func = (int)*fd;
  int gps_func = (int)*gps;

  if (fd_func != -1) {
    close(fd_func);
  }

  if (gps_func != -1) {
    close(gps_func);
  }

  if (map_base != (void*)(-1)) {
    if(munmap(*map_base, MAP_SIZE) == -1) 
      printf("Cannot unmap memory\n");
  }
}