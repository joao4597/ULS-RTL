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


void save_correlators_values(correlator_units_s *corr_u, void *map_base){
  int i;


  //CHECK WHETHER NEW CORRELATION RESULT IS AVAILABLE
  //RETURN IF NO NEW RESULT IS AVAILABLE
  if (fpga_read(ARRIVAL_TRIGGER, map_base) != 1) {
  	return;
  }

  //FOR EACH OF THE 16 CORRELATORS SAVE SAMPLE EITHER TO BUFFER_0 OR BUFFER_1
  for (i = 0; i < 16; i++){
    if (corr_u[i].flag == 0) {
      save_to_buff_0(i ,&(corr_u[i]), map_base);
    } else {
      save_to_buff_1(i, &(corr_u[i]), map_base);
    }
  }
  
}


void save_to_buff_0(int correlatorN, correlator_units_s *corr_u, void *map_base){
  
  uint8_t next_position;
  int32_t int32;
  uint8_t missing_samples;
  int32_t max;

  //READ CORRELATION VALUE FROM FPGA
  int32 = (int32_t)fpga_read(VALUE_CORRELATOR_BASE + correlatorN, map_base);

  if (int32 < 0)
    int32 = -int32;
    	
  next_position   = corr_u->next_position_0;
  missing_samples = corr_u->buffer_0_missing_samples;
  max             = corr_u->max;
    
  corr_u->samples_buffer_0[next_position] = int32;
   
  //UPDATE NEXT BUFFER POSITION TO WRITE TO
  if (next_position < 89){
    	corr_u->next_position_0 = next_position + 1;
  } else {
    corr_u->next_position_0 = 0;
  }

  //-UPDATE MAX IF NECESSARY, IF NEW MAX IS RECEIVED 44 SAMPLES STIL IN THIS BUFFER
  //-IF MAX WAS FOUND AND THE FOLLOWING 44 SAMPLES HAVE BEEN STORED THEN CHANGE FLAG VALUE
  //SO THE FOLLOWING SAMPLES ARE STORED IN THE OTHER BUFFER
  if (int32 > max) {
    corr_u->max = int32;
    corr_u->buffer_0_missing_samples = 44;
  } else if ((missing_samples > 1) && (missing_samples < 45)) {
    corr_u->buffer_0_missing_samples = missing_samples - 1;
  } else if (missing_samples == 1) {
    corr_u->flag = 1;
    reset_buff_1(corr_u);
  }

	return;
}

void save_to_buff_1(int correlatorN, correlator_units_s *corr_u, void *map_base){
  
  uint8_t next_position;
  int32_t int32;
  uint8_t missing_samples;
  int32_t max;

  //READ CORRELATION VALUE FROM FPGA
  int32 = (int32_t)fpga_read(VALUE_CORRELATOR_BASE + correlatorN, map_base);

  if (int32 < 0)
    int32 = -int32;
      
  next_position   = corr_u->next_position_1;
  missing_samples = corr_u->buffer_1_missing_samples;
  max             = corr_u->max;
    
  corr_u->samples_buffer_1[next_position] = int32;
   
  //UPDATE NEXT BUFFER POSITION TO WRITE TO
  if (next_position < 89){
      corr_u->next_position_1 = next_position + 1;
  } else {
    corr_u->next_position_1 = 0;
  }

  //-UPDATE MAX IF NECESSARY, IF NEW MAX IS RECEIVED 44 SAMPLES STIL IN THIS BUFFER
  //-IF MAX WAS FOUND AND THE FOLLOWING 44 SAMPLES HAVE BEEN STORED THEN CHANGE FLAG VALUE
  //SO THE FOLLOWING SAMPLES ARE STORED IN THE OTHER BUFFER
  if (int32 > max) {
    corr_u->max = int32;
    corr_u->buffer_1_missing_samples = 44;
  } else if ((missing_samples > 1) && (missing_samples < 45)) {
    corr_u->buffer_1_missing_samples = missing_samples - 1;
  } else if (missing_samples == 1) {
    corr_u->flag = 0;
    reset_buff_0(corr_u);
  }

  return;
}


void reset_buff_0(correlator_units_s *corr_u){
  corr_u->next_position_0 = 0;
  corr_u->buffer_0_missing_samples = 89;
}


void reset_buff_1(correlator_units_s *corr_u){
  corr_u->next_position_1 = 0;
  corr_u->buffer_1_missing_samples = 89;
}



void reset_struct(correlator_units_s *corr_u){

  int iaux;

  for (iaux = 0; iaux < 16; iaux++){
    //RESET VALUES IN STRUCTURS
    corr_u[iaux].next_position_0 = 0;        
    corr_u[iaux].buffer_0_missing_samples = 0;

    corr_u[iaux].next_position_1 = 0;        
    corr_u[iaux].buffer_1_missing_samples = 0;

    corr_u[iaux].max = 0;
  }
}