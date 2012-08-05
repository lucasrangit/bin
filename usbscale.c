#include <stdlib.h>
#include <stdio.h>
#include <sys/ioctl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <asm/types.h>
#include <fcntl.h>
#include <unistd.h>
#include <linux/hiddev.h>

#define EV_NUM 8

int get_input(int argc, char **argv,int input_type) {
  int fd = -1;
  int i;
  struct hiddev_event ev[EV_NUM];
  char name[100];
  int input_small;
  int input_large;

  if (argc != 2) {
    fprintf(stderr, "usage: %s hiddevice - probably /dev/usb/hiddev0\n", argv[0]);
    exit(1);
  }
  if ((fd = open(argv[1], O_RDONLY)) < 0) {
    perror("hiddev open");
    exit(1);
  }

  ioctl(fd, HIDIOCGNAME(100), name);
  read(fd, ev, sizeof(struct hiddev_event) * EV_NUM);
  input_large = ev[6].value;
  input_small = ev[7].value;
  close(fd);
  if (input_type == 1) {return input_small;}
  if (input_type == 0) {return input_large;}
}

int tare(int input[5]) {
	int input_small = 1;
	int input_large = 0;
	int i;
	int largest_value = input[0];
	//Just returns the largest value from the array.. for now.
	for ( i = 0; i < 5; i++)
	{
	if (largest_value > input[i]) {largest_value = input[i];}
	}
	//printf("%i Largest Value?\n",largest_value);
	return largest_value;
}


int main (int argc, char **argv) {
	int input_small = 1; // Just for easy viewing
	int input_large = 0; // Input selection

	int small_array[5]; // Array of values to be tared
	int large_array[5]; //

	unsigned char base_small;// Tared Values to work with
	unsigned char base_large;//

	unsigned char  weight_small_char;
	unsigned char  weight_large_char;
	int final_weight;
	int last_status = 0;
	float weight_small;
	float weight_large;
	float constant = 2.6666667;

	int i;

	// Get Input
	for ( i = 0; i < 5; i++){
	small_array[i] = get_input(argc,argv,input_small);
	large_array[i] = get_input(argc,argv,input_large);
	}
	// Basic Tare
	base_small = tare(small_array);
	base_large = tare(large_array);
	printf("Tared! Ready to Weigh\n");
	while (1) {
        
	weight_small_char = get_input(argc,argv,input_small);
	weight_large_char = get_input(argc,argv,input_large);

	weight_small = weight_small_char;
	weight_large = weight_large_char;
	
	if (weight_large < (base_large + 1)) { weight_large = 0; } 
	
	else { weight_large = (((weight_large - (base_large + 1)) * 94) + ((256 - base_small) / constant)); }
	
	if (weight_large == 0)	
		{
		if (weight_small >= base_small){ 
			weight_small = ( ( (weight_small) - (base_small)  ) / constant);}
		else 
			{weight_small = 0;}
		}
	
	if (weight_large > 0) { weight_small = ((weight_small) / constant); }
	
        final_weight = (weight_large + weight_small);
      
        if (final_weight != last_status) {
		printf("Weight: %d grams \n", final_weight);
        }
      
        last_status = final_weight;
    }
  exit(0);  
  return 0;
}
