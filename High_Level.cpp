#include <stdio.h>

int main()
{
	printf("Salam\n");

   	int i=0, j=0;
	int img_in[5][5] = {{1,2,3,1,4},{5,8,9,2,1},{5,0,1,2,7},{8,6,4,1,0},{6,2,0,5,4}};
	int kernel[3][3]={{1,-1,4},{-2,1,0},{0,2,3}};
	int img_out[3][3];

    for(i=0; i < (5-2); i++){
	   for(j=0; j < (5-2); j++){
	       int tempOut=0;
		   img_out[i][j] = img_in[i][j]*kernel[0][0]+img_in[i+1][j]*kernel[1][0]+img_in[i+2][j]*kernel[2][0]+
		   img_in[i][j+1]*kernel[0][1]+img_in[i+1][j+1]*kernel[1][1]+img_in[i+2][j+1]*kernel[2][1]+
		   img_in[i][j+2]*kernel[0][2]+img_in[i+1][j+2]*kernel[1][2]+img_in[i+2][j+2]*kernel[2][2]; 
	   }
	}
	
	for(i=0; i<3; i++)
		for(j=0; j<3; j++)
			printf("%x\n", img_out[i][j]);

	return 0;	
}
