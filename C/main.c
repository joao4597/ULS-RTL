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

#include<arpa/inet.h>
#include<sys/socket.h>

#include "setup.h"
#include "CONST.h"
#include "read_write.h"
#include "correlator_result.h"
#include "peak_adjustment.h"


struct sockaddr_in si_other;
int s, slen=sizeof(si_other);
struct sockaddr_in si_me;
int s_m;


void acquire_data(void *map_base, correlator_units_s *corr_u, brute_buff *buff_struct);
void read_buffer(void *map_base);
int sent_buff_to_socket(int32_t *buff);
int send_inter_to_socket(long double x, long double y);
int send_local_max(int32_t buff[][2]);

int main(int argc, char **argv) {
  
  int fd = -1, gps=-1;
  void* map_base = (void*)(-1);
  
  //STRUCTUR THAT SAVES SAMPLES ARROUND THE CORRELATION PEAK
  //SO IT CAN BE REFINED
  correlator_units_s corr_u[16];
  reset_struct(corr_u);

  brute_buff buff_struct;
  buff_struct.next_position = 0;
  buff_struct.max_pos[0] = 0;


  //RUN SETUP
  if (setup(&fd, &gps, &map_base) < 0) {
    printf("SETUP ERROR\n");
    return -1;
  }


  //OPEN DEVICE MOUNTING POINT
  if((fd = open("/dev/mem", O_RDWR | O_SYNC)) == -1) {
    printf("Cannot open the mem device\n");
    return -2;
  }

  //***********************************************************************************************************/
  //***********************************************************************************************************/
  //OPEN SOCKET   
  if ( (s=socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)) == -1){
    return -3;
  }
 
  memset((char *) &si_other, 0, sizeof(si_other));
  si_other.sin_family = AF_INET;
  si_other.sin_port = htons(PORT);
   
  if (inet_aton(SERVER , &si_other.sin_addr) == 0) {
    fprintf(stderr, "inet_aton() failed\n");
    return -4;
  }
  //***********************************************************************************************************/
  
   
  //create a UDP socket
  if ((s_m=socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)) == -1){
    return -1;
  }
   
  // zero out the structure
  memset((char *) &si_me, 0, sizeof(si_me));
   
  si_me.sin_family = AF_INET;
  si_me.sin_port = htons(15001);
  if (inet_aton("192.168.103.58" , &si_me.sin_addr) == 0) {
    fprintf(stderr, "inet_aton() failed\n");
    return -4;
  }
  si_me.sin_addr.s_addr = htonl(INADDR_ANY);
   
  //bind socket to port
  if( bind(s_m , (struct sockaddr*)&si_me, sizeof(si_me) ) == -1){
    printf("Server_socket bind ERROR\n");
    fflush(stdout);
    return -4;
  }
  

  //***********************************************************************************************************/
  //***********************************************************************************************************/

  map_base = mmap(0, MAP_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, fd, BASE_ADDR & ~MAP_MASK);  
  if(map_base == (void *) -1) {
    printf("Cannot map memory\n");
    return -4;
  }

  //RESET MPODULE
  fpga_write(RESET_DSP, 1, map_base);
  fpga_write(RESET_DSP, 0, map_base);


  //READ DATA FROM FPGA
  while(1){
    acquire_data(map_base, corr_u, &buff_struct);
  }


  //CLOSE SETUP
  setup_clear(&fd, &gps, map_base);
  
  return 0;
}






void acquire_data(void *map_base, correlator_units_s *corr_u, brute_buff *buff_struct) {
  int n_corr = 0;
  int i;
  //printf("+++++++++++++++++++++++++++++++++++++++\n");
  long double interssection_x;
  long double interssection_y;
  int32_t xy[13][2];
  uint32_t peak_value;
  uint32_t received_seq;
  uint32_t timestamp;
  long double distance;
  int32_t  corr_buff[128];
  int32_t  corr_buff_ordered[128];

  //WAIT FOR TRIGGER
  while(fpga_read(ARRIVAL_TRIGGER, map_base) != 1) {
    //n_corr = n_corr + save_correlators_values(corr_u, map_base, buff_struct);
    nanosleep(100);
  }


  //READ VALUES
  peak_value   = fpga_read(PEAK_VALUE  , map_base);
  received_seq = fpga_read(RECEIVED_SEQ, map_base);
  timestamp    = fpga_read(TIMESTAMP   , map_base);
  distance     = ((long double)(0x00000000FFFFFFFF & timestamp)) - 5288576;
  distance     = (distance / 125000000)*1500;


  printf("Peak Value   -> %lu\n", (unsigned long)peak_value  );
  //printf("Received Seq -> %lu\n", (unsigned long)received_seq);
  //printf("Distance     -> %lf\n", distance);
  //printf("Timestamp    -> %lu\n", (unsigned long)timestamp   );

  printf("SEQ -> %2lu   Distance -> %lf\n", (unsigned long)received_seq, distance);


  //peak_adjustment(corr_u, received_seq);
  //reset_struct(corr_u);

  fflush(stdout);
  
  //SIGNAL FPGA THAT THE RESULT HAS BEEN ACQUIRED
  fpga_write(RESULT_ACQUIRED, 1, map_base);
  //usleep(1);
  fpga_write(RESULT_ACQUIRED, 0, map_base);


  //READ SAMPLES FROM THE CORRELATOR BUFFER
  for (i = 0; i < 128; i = i + 1) {
    while(fpga_read(NEXT_SAMPLE_AVAILABLE_BUFF, map_base) != 1);
    
    corr_buff[i] = (int32_t)fpga_read(SAMPLE_FROM_BUFFER, map_base);
    //printf("%d\n", (int32_t)fpga_read(SAMPLE_FROM_BUFFER, map_base));
    
    fpga_write(REQUERST_NEXT_SAMPLE, 1, map_base);
    fpga_write(REQUERST_NEXT_SAMPLE, 0, map_base);
  }

  fpga_write(ALL_SAMPLES_ACQUIRED, 1, map_base);

  order_buff(corr_buff, corr_buff_ordered, peak_value);

  peak_adjustment(corr_buff_ordered, &interssection_x, &interssection_y, xy);

  //for (i = 0; i < 13; i++) {
  //  printf("Local Max = X -> %d Y -> %d\n", xy[i][0], xy[i][1]);
  //}

  printf("Intersection = X-> %lf Y-> %lf\n", interssection_x, interssection_y);

  write_to_file("corr_buffer.csv", corr_buff_ordered, 128);
  

  sent_buff_to_socket(corr_buff_ordered);
  send_inter_to_socket(interssection_x, interssection_y);
  send_local_max(xy);


  printf("\n\n");
  fflush(stdout);
}


int send_inter_to_socket(long double x, long double y){
  int i;
  char aux[BUFFLEN];

  //if (sendto(s_m, "INTERSECTION\0", strlen("START\0") , 0 , (struct sockaddr *) &si_other, slen)==-1){
  //    return -1;
  //}

  sprintf(aux, "%f\0", x);
  if (sendto(s_m, aux, strlen(aux) , 0 , (struct sockaddr *) &si_other, slen)==-1){
    return -1;
  }

  sprintf(aux, "%f\0", y);
  if (sendto(s_m, aux, strlen(aux) , 0 , (struct sockaddr *) &si_other, slen)==-1){
    return -1;
  }

  return 0;
}

int sent_buff_to_socket(int32_t *buff){
  int i;
  char aux[BUFFLEN];

  if (sendto(s_m, "START\0", strlen("START\0") , 0 , (struct sockaddr *) &si_other, slen)==-1){
      return -1;
    }

  for (i = 0; i < 128; i++){
    sprintf(aux, "%d\0", buff[i]);
    if (sendto(s_m, aux, strlen(aux) , 0 , (struct sockaddr *) &si_other, slen)==-1){
      return -1;
    }
  }

  return 0;
}


int send_local_max(int32_t buff[][2]){
  int i;
  char aux[BUFFLEN];


  for (i = 0; i < 13; i++){
    sprintf(aux, "%d\0", buff[i][0]);
    if (sendto(s_m, aux, strlen(aux) , 0 , (struct sockaddr *) &si_other, slen)==-1){
      return -1;
    }

    sprintf(aux, "%d\0", buff[i][1]);
    if (sendto(s_m, aux, strlen(aux) , 0 , (struct sockaddr *) &si_other, slen)==-1){
      return -1;
    }
  }

  return 0;
}