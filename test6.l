%{
	#include <stdio.h>
	char filename[100];
    int ip_count = 0;  // Compteur pour "ip"
    int any_count = 0; // Compteur pour "any"
%}

%option noyywrap

%%


ip     { ip_count++; }   // Incrémente le compteur pour "ip"
any    { any_count++; }

(.|\n)  {}

%%

int main(int argc, char **argv ) {

    strncpy(filename,argv[1],strlen(argv[1]));
    filename[strlen(argv[1])] = '\0';
    
    yyin = fopen(filename, "r" );
    yylex();
    
    fclose(yyin);
    printf("Number of 'ip': %d\n", ip_count);
    printf("Number of 'any': %d\n", any_count);
}
