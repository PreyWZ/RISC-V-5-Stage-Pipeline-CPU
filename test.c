#include<stdlib.h>
#include<stdio.h>
#define N 5
void swap(int* a,int* b){
    int tmp;
    tmp=*a;
    *a=*b;
    *b=tmp;
}


void bubble_sort(int *data){
    for(int i=0;i<N;i++){
        for(int j=N-1;j>i;j--){
            if (data[j]<data[j-1]){
                swap(&data[j],&data[j-1]);
            }
        }
    }
}

int main(void){
    int data[]={5,4,3,2,1};
    bubble_sort(data);
    for(int i=0;i<N;i++){
        printf("%d ",data[i]);
    }
    return 0;
}