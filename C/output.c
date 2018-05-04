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

#include "output.h"

void write_to_file (char *file_name, int32_t *vector, int length){
  int i;
  FILE *file = fopen(file_name, "w");
  
  if (file == NULL) {
    printf("Failed to open output file;\n");
    exit(0);
  }

  for (i = 0; i < length; i++){
    fprintf(file, "%d\n", vector[i]);
  }

  fclose(file);
}