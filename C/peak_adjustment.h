/**
*-GIVEN THE 89 POINTS SURROUNDING THE CORRELATION PEAK THIS FUNCTION APROXIMATES THE POINTS TO A TRIANGLE
*-COMPUTES THE TEMPORAL ERROR BETWEEN THE PEAK POSITION AND THE COMPUTED TRAINGLE PEAK
*
* INPUTS:
*-corr_u -> STRUCTUR CONTAINING BUFFERS THAT HOLD THE POINTS SURROUNDIG THE CORRELATION PEAK
*-seq    -> RECEIVED PSEUDO RANDOM BINARY SEQUENCE
**/
void peak_adjustment(int32_t *corr_u, long double *interssection_x, long double *interssection_y, int32_t xy[][2]);


/**
*-GIVEN THE POSITION ON THE X AXIS OF THE COMPUTED TRIANGLE PEAK THIS FUNCTION COMPUTES THE TEMPORAL AND 
*DISTANCE DEVIATION BETWEEN THE CORRELATION PEAK AND THE TRIANGLE APROXIMATION
*
* INPUTS:
*-X    -> X AXIS TRIANGLE PEAK POSITION
*
* OUTPUTS:
*-time_e -> TEMPORAL ERROR
*-distance_e -> DISTANCE DEVIATION
**/
void compute_error(float x, float *time_e, float *distance_e);


/**
*-GIVEN THE SLOPES AND THE CONSTANTS OF TO STRAIGHT LINES THIS FUNCTION COMPUTES THE X AXIS INTERCEPTION POINT
*
*RETURNS: X AXIS INTERCEPTION POINT
**/
float compute_linear_interssection(long double slope1, long double slope2, long double constant1, long double constant2);


/**
*-GIVEN 7 XY COORDENATES THIS FUNCTION COMPUTES THE LEAST SQUARES REGRESSION THAT FITS DOES POINTS
*
* INPUTS:
*-xy -> VECTOR CONTAINING 7 XY COORDNATES
*
* OUTPUTS:
*-slope    -> COMPUTED SLOPE 
*-constant -> COMKPUTED CONSTANT
**/
void compute_linear_equation(int32_t xy[][2], long double *slope, long double *constant);


/**
*-GIVEN THE BUFFER HOLDING THE 89 POINTS SURROUNDIND THE CORRELATION PEAK, THIS FUNCTION EXTRACTS THE MAXIMUM 
*AND THE 12 OTHER PEAKS THA FORM THE TRIANGLE
*
* INPUTS:
* -buffer -> ARRAY HOLDING THE 89 POINTS
*
* OUTPUTS:
* -xy     -> THERTEEN PEAKS THA FORM TRIANGLE 
**/
void search_for_peaks(int32_t *buffer, int32_t xy[][2]);


/**
*-RECEIVES A BUFFER WHOS FIRST ELEMENT IS IN ANY GIVEN POSITION AND RETURNS A VECTOR WITH THE ELEMENTS ORDERED, FIRST ELEMENT -> POSITION 0 ...
*
* INPUTS:
* -buff   -> ARRAY HOLDING THE 89 POINTS
* -order -> POSITION OF THE FIRST ELEMENT
*
* OUTPUTS:
* -ordered_vector -> VECTOR COUNTAINING ORDERED ELEMENTS FROM POS0 TO POS88 
**/
void order_buff(int32_t *buff, int32_t *ordered_vector, int32_t max);