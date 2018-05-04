
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

#include "../setup.h"
#include "../CONST.h"
#include "../read_write.h"
#include "../correlator_result.h"

void main() {

  char line[100];
  
  FILE *input_file;

  input_file = fopen("correlation_samples.csv", "r");

  while ((read = getline(line, 99, input_file)) != -1) {
    
  }


  return;
}