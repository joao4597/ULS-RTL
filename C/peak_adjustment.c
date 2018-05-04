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
#include "output.h"


void peak_adjustment(correlator_units_s *corr_u, uint8_t seq){
  int32_t aux[89];
  float interssection;
  int32_t xy[13][2];
  float slope1, slope2;
  float constant1, constant2;
  float time_e, distance_e;


  //ESTABLISH WHICH BUFFER HOLDS THS SAMPLES OF INTEREST AND STORE THEM ORDERES INVECTOR AUX 
  if (corr_u[seq].flag == 0) {
    order_buff(corr_u[seq].samples_buffer_1, corr_u[seq].next_position_1, aux);
  } else {
    order_buff(corr_u[seq].samples_buffer_0, corr_u[seq].next_position_0, aux);
  }
  

  //SEARCH FOR THE 13 PEAKS NECESSARY TO COMPUTE TRIANGLE AND INTERSSECTION
  search_for_peaks(aux, xy);


  //COMPUTE THE LEAST SQUARES REGRESSION FOR THE LEFT SIDE OF THE TRIANGLE
  compute_linear_equation(&(xy[0]), &slope1, &constant1);


  //COMPUTE THE LEAST SQUARE RERGRESSION FOR THE RIGHT SIDE OF THE TRIANGLE
  compute_linear_equation(&(xy[6]), &slope2, &constant2);

  //COMPUTE INTERSSECTION OF THE SLOPES OF EACH SIDE OF THE TRIANGLE
  interssection = compute_linear_interssection(slope1, slope2, constant1, constant2);


  //COMPUTE SPACIAL EM TEMPORAL ERROR BETTEEN THE CORRELATION PEAK AND THE TRIANGLE PEAK
  compute_error(interssection, &time_e, &distance_e);

  printf("Temporal_deviation -> %fs\n", time_e);
  printf("Spacial_deviation  -> %fm\n", distance_e);

}

void compute_error(float x, float *time_e, float *distance_e) {
  *time_e = (45 - x) * SAMPLING_PERIODE;
  *distance_e = (*time_e) * SOUND_SPEED;
}


float compute_linear_interssection(float slope1, float slope2, float constant1, float constant2) {
  //COPUTE X AXIS INTERCECTION OF THE TO LINEAR EQUATIONS
  return (constant2 - constant1) / (slope1 - slope2);
}


void compute_linear_equation(int32_t xy[][2], float *slope, float *constant) {
  int i;

  float x_avg;
  float y_avg;

  float sum1;
  float sum2;


  //COPUTE AVERAGE OF X AXIS AND Y AXIS VALUES
  for (i = 0, x_avg = 0, y_avg = 0; i < 7; i++){
    x_avg = x_avg + xy[i][0];
    y_avg = y_avg + xy[i][1];
  }

  x_avg = x_avg / 7;
  y_avg = y_avg / 7;


  //COPUTE [Y = (SLOPE * X) + CONSTANT]  
  for (i = 0, sum1 = 0, sum2 = 0; i < 7; i++) {
    sum1 = sum1 + ((xy[i][0] - x_avg) * (xy[i][1] - y_avg));
    sum2 = sum2 + ((xy[i][0] - x_avg) * (xy[i][0] - x_avg));
  }

  *slope = sum1 / sum2;
  *constant = y_avg - ((*slope) * x_avg);
}


void search_for_peaks(int32_t *buffer, int32_t xy[][2]){
  int32_t aux[89];
  int i, q, w;


  int32_t local_max;
  uint8_t local_max_pos;

  //SAVE CORRELATION PEAK VALUE AND POSITION
  xy[6][0] = 45        ;
  xy[6][1] = buffer[45];

  
  //SEARCHE AND STORE THE 6 LOCAL PEAKS AFTER THE CORRELATION MAXIMUM (VALUE AND POSITION) 
  for (i = 45, q = 7; q < 13; q++) {
    i = i + 3;
    for (w = 0, local_max = 0, local_max_pos = 0; w < 5; w++){
      if (buffer[i + w] > local_max){
        local_max = aux[i + w];
        local_max_pos = i + w;
      }
    }
    i = local_max_pos;
  
    xy[q][0] = local_max_pos;
    xy[q][1] = local_max    ;
  }


  //SEARCHE AND STORE THE 6 LOCAL PEAKS BEFORE THE CORRELATION MAXIMUM (VALUE AND POSITION) 
  for (i = 45, q = 5; q > 0; q--) {
    i = i - 3;
    for (w = 0, local_max = 0, local_max_pos = 0; w < 5; w++){
      if (buffer[i - w] > local_max){
        local_max = aux[i - w];
        local_max_pos = i - w;
      }
    }
    i = local_max_pos;
    
    xy[q][0] = local_max_pos;
    xy[q][1] = local_max    ;
  }

  return;
}

void order_buff(int32_t *buff, uint8_t order, int32_t *ordered_vector){
  int i;


  for (i = 0; i < 89; i++){
    ordered_vector[i] = buff[order];

    if (order == 89) {
      order = 0;
    } else{
      order = order + 1;
    }
  }

  write_to_file("samples_surrounding_peak.csv", ordered_vector, 89);

  return;
}