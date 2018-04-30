
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

#include "CONST.h"
#include "read_write.h"

void fpga_write(uint32_t address, unsigned long a_values, void *map_base) {
  void* virt_addr = map_base + (address & MAP_MASK);

  *((unsigned long *) virt_addr) = a_values;
}

int fpga_read(uint32_t address, void *map_base) {

  void* virt_addr;
  
  virt_addr = map_base + (address & MAP_MASK);
  
  uint32_t read_result = 0;
  read_result = *((uint32_t *) virt_addr);

  return read_result;
}