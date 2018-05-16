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


int save_correlators_values(correlator_units_s *corr_u, void *map_base, brute_buff *buff_struct){
  int i;
  int32_t int32;


  //CHECK WHETHER NEW CORRELATION RESULT IS AVAILABLE
  //RETURN IF NO NEW RESULT IS AVAILABLE
  if (fpga_read(CORRELATOR_TRIGGER, map_base) != 1) {
    //printf("No correlation result!\n");
  	return 0;
  }


  for(i = 0; i < 8; i++) {
    //int32 = (int32_t)fpga_read(VALUE_CORRELATOR_BASE + (i * 4), map_base);
    //buff_struct->buff[i][buff_struct->next_position];
    /*if (buff_struct->max_pos[0] < int32) {
      buff_struct->max_pos[0] = int32;
      buff_struct->max_pos[1] = buff_struct->next_position;
    }*/
  }
  //buff_struct->next_position = buff_struct->next_position + 1;


  //printf("Correlation result!\n");
  //fflush(stdout);


  //FOR EACH OF THE 16 CORRELATORS SAVE SAMPLE EITHER TO BUFFER_0 OR BUFFER_1
/*  for (i = 0; i < 16; i++) {
    if (corr_u[i].flag == 0) {
      save_to_buff_0(i ,&(corr_u[i]), map_base);
    } else {
      save_to_buff_1(i, &(corr_u[i]), map_base);
    }
  }
*/
  //SET THE TRIGGER TO ZERO
  fpga_write(CORRELATOR_TRIGGER, 0, map_base);
  return 1;
}


void save_to_buff_0(int correlatorN, correlator_units_s *corr_u, void *map_base){
//printf("entrou na save_to_buff_0\n");
//fflush(stdout);
  uint8_t next_position;
  int32_t int32 = 0;
  uint8_t missing_samples;
  int32_t max;

  //READ CORRELATION VALUE FROM FPGA
  int32 = (int32_t)fpga_read(VALUE_CORRELATOR_BASE + (correlatorN * 4), map_base);

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

//printf("saiu da save_to_buff_0\n");
//fflush(stdout);
	return;
}

void save_to_buff_1(int correlatorN, correlator_units_s *corr_u, void *map_base){
//printf("entrou na save_to_buff_1\n");
//fflush(stdout); 
  uint8_t next_position;
  int32_t int32 = 0;
  uint8_t missing_samples;
  int32_t max;

  //READ CORRELATION VALUE FROM FPGA
  int32 = (int32_t)fpga_read(VALUE_CORRELATOR_BASE + (correlatorN * 4), map_base);

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
//printf("entrou na reset_buff_0\n");
//fflush(stdout);
  corr_u->next_position_0 = 0;
  corr_u->buffer_0_missing_samples = 89;
}


void reset_buff_1(correlator_units_s *corr_u){
//printf("entrou na reset_buff_1\n");
//fflush(stdout);
  corr_u->next_position_1 = 0;
  corr_u->buffer_1_missing_samples = 89;
}



void reset_struct(correlator_units_s *corr_u){
//printf("entrou na reset_struct\n");
//fflush(stdout);
  
  int iaux;

  for (iaux = 0; iaux < 16; iaux++){
    //RESET VALUES IN STRUCTURS
    corr_u[iaux].next_position_0 = 0;        
    corr_u[iaux].buffer_0_missing_samples = 89;

    corr_u[iaux].next_position_1 = 0;        
    corr_u[iaux].buffer_1_missing_samples = 89;

    corr_u[iaux].max = 0;
    corr_u[iaux].flag = 0;
  }
}