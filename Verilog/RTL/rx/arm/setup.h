
/** 
* -Installs FPGA device driver
* -Opens the mounting point
* -Opens the GPS
* -Creats a memory map for the FPGA file descriptor
**/

int setup(int *fd, int *gps, void **map_base);
void setup_clear(int *fd, int *gps, void **map_base);