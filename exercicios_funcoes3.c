#include <stdio.h>
#include <string.h>

void SINAL (int n);
char * SINAL2 (int n);



float funcao (int n);
int funcao2 (int n);
float funcao3 (int n);
float funcao4 (int b, int e);



void main(){
    int b, e;
    scanf("%d %d", &b, &e);
    printf("%f", funcao4(b, e));
}

float funcao3(int n){
    int i;
    float r = 0;

    for (i = 1; i <= n; i++){
        r += (float)1/i;
    }
    return r;
}


float funcao4 (int b, int e){
    int i;
    float r = 1;
    if (e > 0){
        for (i = 1; i <= e; i++)
            r *= b;
        return r;
    }
    else if (e == 0)
        return 1;
    else{
        for (i = 1; i <= -1 * e; i++)
            r *= b;
        return 1/r;
    }
}



int funcao2(int n){
    int i, r = 1;

    for (i = n; i >= 1; i--){
        r *= i;
    }
}



float funcao (int n){
    int i;
    float r = 0;
    
    for (i = 1; i <= n; i++){
        r += (float)1/i;
    }
    return r;
}









char * SINAL2 (int n){
    if (n == 0)
        return ", 0";
    else if (n > 0)
        return ", positivo";
    else
        return ", negativo";
}



void SINAL (int n){
    if (n == 0)
        puts("0");
    else if (n > 0)
        puts("positivo");
    else
        puts("negativo");
}