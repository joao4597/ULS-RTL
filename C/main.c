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
#include "read_write.h"
#include "correlator_result.h"
#include "peak_adjustment.h"

void acquire_data(void *map_base, correlator_units_s *corr_u);

int main(int argc, char **argv) {
  
  int fd = -1, gps=-1;
  void* map_base = (void*)(-1);
  
  
  //STRUCTUR THAT SAVES SAMPLES ARROUND THE CORRELATION PEAK
  //SO IT CAN BE REFINED
  correlator_units_s corr_u[16];
  reset_struct(corr_u);


  //RUN SETUP
  if (setup(&fd, &gps, &map_base) < 0) {
    printf("SETUP ERROR\n");
    return -1;
  }


  //RESET MPODULE


  //READ DATA FROM FPGA
  while(1){
    acquire_data(map_base, corr_u);
  }


  //CLOSE SETUP
  setup_clear(&fd, &gps, map_base);
  
  return 0;
}

void acquire_data(void *map_base, correlator_units_s *corr_u) {
  uint32_t peak_value;
  uint32_t received_seq;
  uint32_t timestamp;

  //WAIT FOR TRIGGER
  while(fpga_read(ARRIVAL_TRIGGER, map_base) != 1) {
    save_correlators_values(corr_u, map_base);
  }


  //READ VALUES
  peak_value   = fpga_read(PEAK_VALUE  , map_base);
  received_seq = fpga_read(RECEIVED_SEQ, map_base);
  timestamp    = fpga_read(TIMESTAMP   , map_base);


  peak_adjustment(corr_u, received_seq);
  reset_struct(corr_u);



  printf("Peak Value   -> %lu\n", (unsigned long)peak_value  );
  printf("Received Seq -> %lu\n", (unsigned long)received_seq);
  printf("Timestamp    -> %lu\n", (unsigned long)timestamp   );

  fflush(stdout);
  
  //SIGNAL FPGA THA THE RESULT HAS BEEN ACQUIRED
  fpga_write(RESULT_ACQUIRED, 1, map_base);
  usleep(100);
  fpga_write(RESULT_ACQUIRED, 0, map_base);
  usleep(100);
  
}