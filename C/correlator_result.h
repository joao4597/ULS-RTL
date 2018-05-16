typedef struct correlator{
  int32_t samples_buffer_0[89];     //-BUFFER_0
  uint8_t next_position_0;          //-NEXT POSITION IN THE BUFFER TO WRITE TO
  uint8_t buffer_0_missing_samples; //-AFTER A PEAK IS DETECTED 44 SAMPLES STILL NEED TO 
                                    //WRITTEN, THIS VARIABLE HOLDS THE NUMBER OF SAMPLES YET MISSING
                                    //FROM THE 44
  
  int32_t samples_buffer_1[89];
  uint8_t next_position_1;
  uint8_t buffer_1_missing_samples;

  uint8_t flag;                     //-INDICATES WITCH BUFFER IS BEING USED TO STORE INCOMING SAMPLES
  int32_t max;                      //-HOLDS THE VALUE OF THE MAXIMUM
  uint8_t max_pos;

} correlator_units_s;

typedef struct brute_buff_struct{
  int32_t  buff[16][22000];
  uint32_t next_position;
  int32_t  max_pos[2];
}brute_buff;



int save_correlators_values(correlator_units_s *corr_u, void *map_base, brute_buff *buff_struct);
void save_to_buff_0(int correlatorN, correlator_units_s *corr_u, void *map_base);
void save_to_buff_1(int correlatorN, correlator_units_s *corr_u, void *map_base);
void reset_buff_0(correlator_units_s *corr_u);
void reset_buff_1(correlator_units_s *corr_u);
void reset_struct(correlator_units_s *corr_u);