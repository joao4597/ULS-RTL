
#define _GNU_SOURCE

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

 
#define MAP_SIZE 4096UL
#define MAP_MASK (MAP_SIZE - 1)

#define DEFAULT_DELAY 0x7FFFFFFF

#define RDAC_A_ADDR            	   0x2c
#define RDAC_B_ADDR            	   0x2d
#define I2C_SLAVE_FORCE 		   0x0706

#define BASE_ADDR 0x40100000
#define DECIMATION_FACTOR 0x40100014

#define SELECT_SCOPE_IN 0X40100200
#define CONFIG_WL_S_L_A 0X40100204
#define CONFIG_WL_S_H_A 0X40100208
#define CONFIG_N_ZEROS 0X4010020c
#define CONFIG_WAITING_TIME 0X40100210
#define RESET_DSP 0X40100214
#define CONFIG_WL_S_L_B 0X40100218
#define CONFIG_WL_S_H_B 0X4010021c
#define config_MAX_DELAY 0X40100220
#define config_RESET_TIME_AMPLITUDE 0X40100224

#define DELAY_OUT_0 0X40100300
#define DELAY_OUT_1 0X40100304
#define DELAY_OUT_2 0X40100308
#define DELAY_OUT_3 0X4010030C
#define DELAY_COUNTER_0 0X40100310
#define DELAY_COUNTER_1 0X40100314
#define DELAY_COUNTER_2 0X40100318
#define DELAY_COUNTER_3 0X4010031C
#define AMPLITUDE_1 0X40100320
#define AMPLITUDE_2 0X40100324
#define START_AMPLITUDE_1 0X40100328
#define START_AMPLITUDE_2 0X4010032C

#define MAX_DELAY 200
#define N_MODULES 4
#define N_DELAYS 16 
#define AMP_TH 50000 // of 65536
#define AMP_TH_S 30000

//#define WL 56
#define WL 52
#define R 3
#define dist 0.03f
#define PI 3.14159265
 
uint32_t read_value(uint32_t a_addr);
void write_values(unsigned long a_addr, unsigned long a_values);
int gain(int channel, float* gain1, float* gain2);
int adjust_gain(uint32_t amp1, uint32_t amp2, uint32_t amp_th);
float decision_maker(int32_t* delay, int32_t true_delay);
float matrix_delay(int32_t* delay);
void swap(int32_t* a, int32_t* b);
float calc_angle(float delay_s);
float filter_angle(float angle_fa);
int filter_delay(int delay_fd);

void* map_base = (void*)(-1);

char help[]= {"\n\nUsage: mux   mux1  mux2\n\n\tmux1\t	Choose if the channel 1 as the top or the bottom signal [t, b].\n\tmux2\t	Choose if the channel 2 as the top or the bottom signal [t, b].\n\n"};

uint32_t addr, sample_counter;
int32_t first=1, last_delay=0, delay_array[N_DELAYS];
	
float gain1[2] ={1}, gain2[2]={1};



int main(int argc, char **argv) {
	
	int fd = -1, gps=-1, i,j, file_angle, file_counter, file_aux, save2file=0;;
	uint32_t N_ZEROS, WL_S_L, last_counter[4]= {0}, amplitude_1=0, amplitude_2=0, WL_S_L_A=48, WL_S_L_B=44;			
	int32_t delay[4]={0};
	float decision_delay=MAX_DELAY, true_delay, angle;
	double r, aux;
	FILE *file;
	char str[128], NMEA[128], number[10], name_file[15];
	int n_str=1;
	
		
	if(argc == 3){
		WL_S_L_A = atoi(argv[1]);
		WL_S_L_B = atoi(argv[2]);
		printf("WL_S_L_A: %d  WL_S_L_B: %d\n", WL_S_L_A, WL_S_L_B);
	}
		
	if(system("/home/test/script.sh")==-1){
        printf("Cannot install FPGA module\n");
        return 1;
    }		
	
	if((fd = open("/dev/mem", O_RDWR | O_SYNC)) == -1){
        printf("Cannot open the mem device\n");
        return 1;
    }

	
	
	// Map one page 
	map_base = mmap(0, MAP_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, fd, BASE_ADDR & ~MAP_MASK);	
	if(map_base == (void *) -1) printf("Cannot map memory\n");
	
	 // Config parameters____________________________________________________________________________________________________________
	
	write_values(DECIMATION_FACTOR, 32); 			// decimation 64
	
	write_values(SELECT_SCOPE_IN, 1); 				// 1 filtered signal, 0 direct from de decimator
	write_values(CONFIG_WL_S_L_A, WL_S_L_A); 				// 0 for default value
	write_values(CONFIG_WL_S_H_A, 70); 				// 0 for default value
	write_values(CONFIG_WL_S_L_B, WL_S_L_B); 				// 0 for default value
	write_values(CONFIG_WL_S_H_B, 70); 				// 0 for default value
	write_values(CONFIG_N_ZEROS, 12); 				// 0 for default value, number of zero to valid detection
	write_values(CONFIG_WAITING_TIME, 0); 			// 0 for default value, number of samples number of samples that the system ignores after a valid detection
	write_values(RESET_DSP, 0); 					// 1 to reset the dsp module
	write_values(config_MAX_DELAY, MAX_DELAY); 				// 0 for default value, maximum delay possible in samples
	write_values(config_RESET_TIME_AMPLITUDE, 39000000); 	// 0 for default value, period in samples to measure the signal amplitude
	
	
	// Calibrating Gain____________________________________________________________________________________________________________
	
	// gain1[0]=4; gain1[1]=5;
	// gain2[0]=4; gain2[1]=20;

	gain1[0]=1; gain1[1]=10;
	gain2[0]=1; gain2[1]=10;
	
	gain(1, &gain1[0], &gain1[1]);
	gain(2, &gain2[0], &gain2[1]);
	
		
	amplitude_1 = read_value(AMPLITUDE_1);
	amplitude_2 = read_value(AMPLITUDE_2);
	
	printf("Waiting");
	fflush(stdout);
	while(read_value(AMPLITUDE_1)==amplitude_1 && read_value(AMPLITUDE_2) == amplitude_2 ){
		printf(".");
		fflush(stdout);
		usleep(500000);
		
	}		
	amplitude_1 = read_value(AMPLITUDE_1);
	amplitude_2 = read_value(AMPLITUDE_2);	
	
		
	if(adjust_gain(amplitude_1, amplitude_2, AMP_TH))
		printf("Gain adjusted! channel 1 - %3.1f  %3.1f\tchannel 2 - %3.1f  %3.1f\n", gain1[0], gain1[1], gain2[0], gain2[1]);fflush(stdout);
	
	printf("Waiting");
	while(read_value(AMPLITUDE_1)==amplitude_1 && read_value(AMPLITUDE_2) == amplitude_2 ){
		printf(".");
		fflush(stdout);
		usleep(500000);
		
	}	
	amplitude_1 = read_value(AMPLITUDE_1);
	amplitude_2 = read_value(AMPLITUDE_2);	
	
	
	if(adjust_gain(amplitude_1, amplitude_2, AMP_TH))
		printf("Gain adjusted! channel 1 - %3.1f  %3.1f\tchannel 2 - %3.1f  %3.1f\n", gain1[0], gain1[1], gain2[0], gain2[1]);fflush(stdout);	
			
	
	// Reading Delay____________________________________________________________________________________________________________
	
	file_angle = 60;
	file_counter = 0;
	
	sprintf(number, "%d", file_angle);
	strcpy (str,"angle_");
	strcat (str, number);
	strcat (str, ".txt");
	file = fopen(str, "w");	
	
	
	
	while(1){	
	
		
		if(file_counter<20){
		
			while(	(read_value(DELAY_COUNTER_0) == last_counter[0]) &&
					(read_value(DELAY_COUNTER_1) == last_counter[1]) &&
					(read_value(DELAY_COUNTER_2) == last_counter[2]) &&
					(read_value(DELAY_COUNTER_3) == last_counter[3])   ) usleep(1000); //wait for 4 new values and sleeps for 1ms
					
			last_counter[0] = read_value(DELAY_COUNTER_0); 
			last_counter[1] = read_value(DELAY_COUNTER_1);
			last_counter[2] = read_value(DELAY_COUNTER_2);
			last_counter[3] = read_value(DELAY_COUNTER_3);
			
			delay[0] = read_value(DELAY_OUT_0);
			delay[1] = read_value(DELAY_OUT_1);
			delay[2] = read_value(DELAY_OUT_2);
			delay[3] = read_value(DELAY_OUT_3);
			

			
			if(read_value(AMPLITUDE_1) != amplitude_1 && read_value(AMPLITUDE_2) != amplitude_2 ){
				amplitude_1 = read_value(AMPLITUDE_1);
				amplitude_2 = read_value(AMPLITUDE_2);	
				
				if(adjust_gain(amplitude_1, amplitude_2, AMP_TH)){
					printf("Gain adjusted! channel 1 - %3.1f  %3.1f\tchannel 2 - %3.1f  %3.1f\n", gain1[0], gain1[1], gain2[0], gain2[1]);fflush(stdout);	
				}else{
					printf("Gain channel 1 - %3.1f  %3.1f\tchannel 2 - %3.1f  %3.1f\n", gain1[0], gain1[1], gain2[0], gain2[1]);fflush(stdout);	
				}
			}
						
			for ( i=0; i<N_MODULES; i++)
				if(abs(delay[i]) > MAX_DELAY)
					delay[i] = (i+1)*2*MAX_DELAY;
			
			printf("delay: %3d  %3d  %3d  %3d  ", delay[0], delay[1], delay[2], delay[3]);fflush(stdout);
			
			fprintf(file, "%3d  %3d  %3d  %3d  \n", delay[0], delay[1], delay[2], delay[3]);
			/*
			true_delay = matrix_delay(delay);
			
			if(true_delay!=MAX_DELAY){
				
				fprintf(file, "%3d  %3d  %3d  %3d  ", delay[0], delay[1], delay[2], delay[3]);
				
				printf("matrix_delay: %d  ", (int)true_delay);fflush(stdout);
				
				true_delay = filter_delay((int)true_delay);			
				
				printf("filter_delay: %d ", (int)true_delay);fflush(stdout);
				fprintf(file, "%3d", (int)true_delay);
				
				true_delay = decision_maker(delay,(int)true_delay)/2;
				
				// printf("delay: %3d  %3d  %3d  %3d ", delay[0], delay[1], delay[2], delay[3]);fflush(stdout);
			
			
				angle = calc_angle(true_delay);
				angle = angle>90?90:angle;
				angle = angle<-90?-90:angle;
							
				
				fprintf(file, "  %5.2f\n", angle );
				printf("angle: %5.2f  \n",angle);fflush(stdout);
				angle = filter_angle(angle);
				
				
				
				// printf("avg angle: %5.2f\n",angle);			
				// fflush(stdout);
				
				// fprintf(file, "%5.2f\n", angle );
				
				
			
			}
			*/
			file_counter++;		
			
		}else{
			fclose(file);
			
			file_angle -=10;
			
	
			sprintf(number, "%d", file_angle);	
			strcpy (str,"angle_");
			strcat (str, number);
			strcat (str, ".txt");
			
			file = fopen(str, "w");
			
			printf("Next angle: %d\n", file_angle);
			scanf("%d", &file_aux);
			file_counter = 0;		
			
		}
				
	}
	
	if (map_base != (void*)(-1)) {
		if(munmap(map_base, MAP_SIZE) == -1) printf("Cannot map memory\n");;
		map_base = (void*)(-1);
	}

	if (map_base != (void*)(-1)) {
		if(munmap(map_base, MAP_SIZE) == -1) printf("Cannot map memory\n");;
	}
	
	
	return EXIT_SUCCESS;
}

uint32_t read_value(uint32_t a_addr) {
	void* virt_addr = map_base + (a_addr & MAP_MASK);
	uint32_t read_result = 0;
	read_result = *((uint32_t *) virt_addr);
	//printf("0x%08x\n", read_result);
	//fflush(stdout);
	return read_result;
}

void write_values(unsigned long a_addr, unsigned long a_values) {
	void* virt_addr = map_base + (a_addr & MAP_MASK);

	*((unsigned long *) virt_addr) = a_values;
	
}

int gain(int channel, float* gain1, float* gain2){
	ssize_t bytes_written;
	uint8_t write_buffer[4], res1, res2, addr;
	float aux1, aux2;
	int fd;

	fd = open("/dev/i2c-0", O_RDWR); //Open the device.

    if(fd < 0){
        printf("Cannot open the IIC device\n");
        return 1;
    }
	
	if(channel==1){
		addr = RDAC_A_ADDR;
	}else
	if(channel==2){
		addr = RDAC_B_ADDR;
	}
	

    if(ioctl(fd, I2C_SLAVE_FORCE, addr) < 0){
        printf("Unable to set the address\n");
        return 1;
    }
	
	aux1 = ((float)(*gain1*1000-75)*0.0051);
	aux2 = ((float)(*gain2*1000-75)*0.0051);
	
	res1 = (uint8_t)aux1 + (uint8_t)((aux1 - (uint8_t)aux1)*2);//round
	res2 = (uint8_t)aux2 + (uint8_t)((aux2 - (uint8_t)aux2)*2);
	
	*gain1 = (((float)res1/0.0051)+75)/1000;
	*gain2 = (((float)res2/0.0051)+75)/1000;
	//printf("Gain1: %f\t Gain2: %f\n", (((float)res1/0.0051)+75)/1000, (((float)res2/0.0051)+75)/1000 );
	
	write_buffer[0] = 0x01;
	write_buffer[1] = res1;	
	write_buffer[2] = 0x55;//dummy
	write_buffer[3] = res2;
		
	bytes_written = write(fd, write_buffer, 4);
	
	if(bytes_written < 0){		
        printf("Unable to wirte in the RDAC\n");
	}
	
    close(fd);	
	
	return 0;

}

int adjust_gain(uint32_t amp1, uint32_t amp2, uint32_t amp_th){
	
	float aux_gain;
	int changed=0;
	
	if(gain1[0]>=50 && gain1[1]>=50)
		amp_th=	amp1;
	
	if(gain2[0]>=50 && gain2[1]>=50)
		amp_th=	amp2;
	
	aux_gain = (float) amp_th / amp1;
	
	printf("amp1:%u  amp2:%u  aux_gain:%f  amp_th: %u\n", amp1, amp2, aux_gain, amp_th);fflush(stdout);
	
	if(aux_gain>=1.05 || aux_gain <=0.95 ){
		changed++;
		
		if(aux_gain>1){
			if(gain1[1]*aux_gain<=50)
				gain1[1] *= aux_gain;
			else
			if(gain1[0]*aux_gain<=50)
				gain1[0] *= aux_gain;				
			else{
				aux_gain = (gain1[1] * gain1[0] * aux_gain)/50;
				gain1[1] = 50;
				gain1[0] = (aux_gain<50)?aux_gain:50;
			}
			
		}else{
			
			if(gain1[1]*aux_gain>=0.2)
				gain1[1] *= aux_gain;
			else
			if(gain1[0]*aux_gain>=0.2)
				gain1[0] *= aux_gain;				
			else{
				aux_gain = (gain1[1] * gain1[0] * aux_gain);
				gain1[0] = (aux_gain<50)?aux_gain:50;					
				gain1[1] = (aux_gain<50)?1:aux_gain/50;
			}
			
		}
		
	}
	
	gain(1, &gain1[0], &gain1[1]);
	
	aux_gain = (float) amp_th / amp2;
	
	if(aux_gain>=1.05 || aux_gain <=0.95 ){
		
		changed++;
		
		if(aux_gain>1){
	
			if(gain2[1]*aux_gain<=50)
				gain2[1] *= aux_gain;
			else
			if(gain2[0]*aux_gain<=50)
				gain2[0] *= aux_gain;				
			else{
				aux_gain = (gain2[1] * gain2[0] * aux_gain)/50;
				gain2[1] = 50;
				gain2[0] = (aux_gain<50)?aux_gain:50;
			}
			
		}else{
			
			if(gain2[1]*aux_gain>=0.2)
				gain2[1] *= aux_gain;
			else
			if(gain2[0]*aux_gain>=0.2)
				gain2[0] *= aux_gain;				
			else{
				aux_gain = (gain2[1] * gain2[0] * aux_gain);
				gain2[0] = (aux_gain<50)?aux_gain:50;					
				gain2[1] = (aux_gain<50)?1:aux_gain/50;
			}
			
		}
	}
	
	gain(2, &gain2[0], &gain2[1]);
	
	return changed;
	
}

float matrix_delay(int32_t* delay){
	int32_t i, j, iMin, diff[N_DELAYS-1], diff_counter=0, k, min, error=0, last_valid_delay=0;
	float avg[3]={0};
	
	
	for ( i=0; i<N_MODULES; i++){
		if((abs(delay[i]) > 84) && (delay[i] < MAX_DELAY))	{
			delay[i] -= (delay[i])>0?52:-52;			
		}
		if((abs(delay[i]) > 84) && (delay[i] < MAX_DELAY))	{
			delay[i] -= (delay[i])>0?52:-52;			
		}		
	}
	

	for ( i=0; i<N_DELAYS/N_MODULES; i++)
		delay_array[(last_delay*4)+i] = delay[i];
	last_delay++;
	
	if(first && last_delay==4)
		first=0;
	
	if(first)
		return MAX_DELAY;
	
	if(last_delay==N_DELAYS/N_MODULES)
		last_delay=0;

	for (j = 0; j < N_DELAYS-1; j++) {
		iMin = j;
		for ( i = j+1; i < N_DELAYS; i++) {
			if (delay_array[i] < delay_array[iMin])
				iMin = i;
		}

		if(iMin != j) 
			swap(&delay_array[j], &delay_array[iMin]);
	}
	
	for ( i=0; i<N_DELAYS; i++){
		if(delay_array[i]<84)
			last_valid_delay =i;
		else
			break;		
	}
	
	if(last_valid_delay==0)
		return MAX_DELAY;
	
	for ( i=0; i<last_valid_delay-1; i++){
		diff[i]= abs(delay_array[i]-delay_array[i+1]);
		
		if (diff[i]>25){
			diff_counter++;
			j=k;
			k=i;
		}
	} 
		
	if(diff_counter ==2){
		for ( i=0; i<=j+1; i++)
			avg[0] += delay_array[i];
		
		avg[0] /= (j+1);
		
		for ( i=j+1; i<=k+1; i++)
			avg[1] += delay_array[i];
		
		avg[1] /=(k-j);
		
		for ( i=k+1; i<last_valid_delay+1; i++)
			avg[2] += delay_array[i];
		
		avg[2] /=(last_valid_delay-k);
		
		return (avg[0] + avg[1] + avg[2])/3;
	}else
		
	if(diff_counter ==1){	
		for ( i=0; i<=k+1; i++)
			avg[0] += delay_array[i];
		
		avg[0] /= (k+1);
		
		for ( i=k+1; i<last_valid_delay+1; i++)
			avg[1] += delay_array[i];
		
		avg[1] /=(last_valid_delay-k);
		
		
		if( k+1>last_valid_delay-k)
			return avg[0];
		else
			return  avg[1];
	}else	
	
	if(diff_counter ==0){	
		
		
		for ( i=0; i<last_valid_delay+1; i++)
			avg[0] += delay_array[i];
		
		return avg[0]/(last_valid_delay+1);
	}
	else
		return MAX_DELAY;

	
	
	
}

float decision_maker(int32_t* delay, int32_t true_delay){
	int32_t i, j, iMin, diff[N_MODULES-1], diff_counter=0, k, min;
	float avg=0,  avg2=0;
		
			
	for ( i=0; i<N_MODULES; i++){
		if((abs(delay[i]) > 84) && (delay[i] < MAX_DELAY))	{
			delay[i] -= (delay[i])>0?52:-52;			
		}
		if((abs(delay[i]) > 84) && (delay[i] < MAX_DELAY))	{
			delay[i] -= (delay[i])>0?52:-52;			
		}		
	}
	
	for ( i=0; i<N_MODULES; i++){
		if(abs(abs(delay[i] - true_delay)-52) < 25)	{
			delay[i] += (delay[i] < true_delay)?52:-52;			
		}				
	}
			

	for (j = 0; j < N_MODULES-1; j++) {
		iMin = j;
		for ( i = j+1; i < N_MODULES; i++) {
			if (delay[i] < delay[iMin])
				iMin = i;
		}

		if(iMin != j) 
			swap(&delay[j], &delay[iMin]);
	}
	
	for ( i=0; i<N_MODULES-1; i++){
		diff[i]= abs(delay[i]-delay[i+1]);
		
		if (diff[i]<=4){
			diff_counter++;
			k=i;
		}else
			j=i;
	} 
	
	// printf("diff[0]=%d  diff[1]=%d  diff[2]=%d   diff_counter=%d   j=%d\n",diff[0], diff[1], diff[2], diff_counter, j );
	
	if(diff_counter==N_MODULES-1){
		for (i=0; i<N_MODULES; i++)
			avg+=delay[i];
		avg = (float)avg/N_MODULES;
	}else
		
	if(diff_counter==2){
		if(j==0){
			for (i=1; i<N_MODULES; i++)
				avg+=delay[i];
			avg = (float)avg/3;
		}else
		if(j==2){
			for (i=0; i<N_MODULES-1; i++)
				avg+=delay[i];
			avg = (float)avg/3;
		}else
		if(j==1){
			avg = (float)(delay[0]+delay[1])/2;
			avg2 = (float)(delay[2]+delay[3])/2;			
			avg = (abs(avg-true_delay)<abs(avg2-true_delay))?avg:avg2;			
		}
	}else
	
	if(diff_counter==1){
		avg = (float)(delay[k]+delay[k+1])/2;
	}else
	
	if(diff_counter==0 && true_delay!=MAX_DELAY ){
		j=0;
		min = abs(delay[0]-true_delay);
		for (i=1; i<N_MODULES; i++)
			j=(abs(delay[i]-true_delay)<min)?i:j;
		avg=delay[j];
	}
	
	if(abs(avg) > MAX_DELAY){
		return MAX_DELAY;		
	}else
		return (float)avg;
	
}

void swap(int32_t* a, int32_t* b){
	int32_t aux=*b;
	*b=*a;
	*a=aux;	
}

float calc_angle(float delay_s){
	float poly[5][6] = {{-8.157323955525607e+01,    -7.975699123989219e+01,     1.491072935952871e+00, 
					3.589332652581985e+02,     2.880462728089563e+04,       7.705479379337916e+05},
					{-7.975699123989219e+01,    -5.967297001347709e+01,     1.843962300618957e-03,
					3.514417468367267e-01,     2.344845698010284e+01,      4.928285117983203e+02},
					{-5.967297001347709e+01,     5.967297001347709e+01,     2.446863117039909e-05,
					0,    						6.962154147366660e-01,                         0},
					{5.967297001347709e+01,     7.975699123989219e+01,      1.843962448031523e-03,
					-3.514417745907826e-01,     2.344845871233657e+01,     -4.928285489202396e+02},
					{7.975699123989219e+01,    8.157323955525607e+01,       1.491073023092589e+00, 
					-3.589332862256362e+02,    2.880462896280357e+04,     -7.705479829110042e+05}};
	int i;
	
	
			
	if( delay_s<=poly[0][1])
		return poly[0][2]*delay_s*delay_s*delay_s + poly[0][3]*delay_s*delay_s + poly[0][4]*delay_s + poly[0][5];
	else
	if( delay_s<=poly[1][1])
		return poly[1][2]*delay_s*delay_s*delay_s + poly[1][3]*delay_s*delay_s + poly[1][4]*delay_s + poly[1][5];
	else	
	if( delay_s<=poly[2][1])
		return poly[2][2]*delay_s*delay_s*delay_s + poly[2][3]*delay_s*delay_s + poly[2][4]*delay_s + poly[2][5];
	else	
	if( delay_s<=poly[3][1])
		return poly[3][2]*delay_s*delay_s*delay_s + poly[3][3]*delay_s*delay_s + poly[3][4]*delay_s + poly[3][5];
		
	else // if( delay_s<=poly[4][1]):
		return poly[4][2]*delay_s*delay_s*delay_s + poly[4][3]*delay_s*delay_s + poly[4][4]*delay_s + poly[4][5];
		
	
	
}

int fd[7]={0}, last_fd=0,  first_fd=1;
int filter_delay(int delay_fd){
	
	int32_t i, j,k, iMin, diff[7-1], diff_counter=0;
	
	
	fd[last_fd] = delay_fd;
	last_fd++;
	
	
	if(last_fd==7){
		first_fd=0;
		last_fd=0;
	}
	
	if(first_fd){
		return delay_fd;
	}
	
	for (j = 0; j < 7-1; j++) {
		iMin = j;
		for ( i = j+1; i < 7; i++) {
			if (fd[i] < fd[iMin])
				iMin = i;
		}

		if(iMin != j) 
			swap(&fd[j], &fd[iMin]);
	}
	// for(i=0;i<5;i++)
		// printf("%d ",fd[i]);
	// printf("\n");
		
	
	for ( i=0; i<7-1; i++){
		diff[i]= abs(fd[i]-fd[i+1]);
		
		if (diff[i]>15){
			diff_counter++;
			j=k;
			k=i;
		}
	} 
	
	if(diff_counter==0){
		return delay_fd;
	}else
		
	if(diff_counter==1){
		if(k<3)
			return fd[6];
		else
			return fd[0];
	}else
		return delay_fd;
	
}

int last_fa=0,  first_fa=1;
float fa[3]={0};
float filter_angle(float angle_fa){
	
	int32_t i;
	float avg=0;;
	
	
	fa[last_fa] = angle_fa;
	last_fa++;
	
	if(last_fa==3){
		first_fa=0;
		last_fa=0;
	}
	
	if(first_fa){
		return angle_fa;
	}
	
	for ( i=0; i<3; i++)
		avg+=fa[i];
	
	return avg/3;
	
	
}






















