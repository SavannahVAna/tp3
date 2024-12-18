%{
    #include <stdio.h>
    char filename[100];
%}

%option noyywrap
%x INTERFACE


%%

^interface.*$ {
    printf("%s:%s\n",filename,yytext);
    BEGIN INTERFACE;
}

<INTERFACE>^[ ]ip[ ]address.*$ {
    printf("IP %s\n", yytext);
}

<INTERFACE>^!$ {
    BEGIN INITIAL;
}


<INTERFACE>(.|\n); 
(.|\n); 

%%

int main(int argc, char **argv ) {

    strncpy(filename,argv[1],strlen(argv[1]));
    filename[strlen(argv[1])] = '\0';

    yyin = fopen(filename, "r" );
    yylex();
    fclose(yyin);
}