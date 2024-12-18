%{
    #include <stdio.h>
    char filename[100];
    char current_interface[100];
    int access_group_found = 0;
    char path[100];
    FILE* f_out;
%}

%option noyywrap
%x INTERFACE

%%

^interface.*$ {
    strcpy(current_interface, yytext + 10); // Skip "interface"

    access_group_found = 0;
    
    BEGIN INTERFACE;
}

<INTERFACE>^[ ]ip[ ]access-group.*$ {
    access_group_found = 1;
}

<INTERFACE>^!$ {
    if (!access_group_found) {
        fprintf(f_out, "%s interface %s missing ip access-group\n", filename, current_interface);
        access_group_found = 0;
    }
    BEGIN INITIAL;
}


<INTERFACE>(.|\n)   {} 
(.|\n)  {}

%%

int main(int argc, char **argv ) {

    snprintf(path, sizeof(path), "tmp/%d", getpid());
    f_out = fopen(path, "a");

    if (!f_out) {
        perror("Error creating temporary file");
        return 1;
    }

    for (int i = 1; i < argc; i++) {
        strncpy(filename,argv[i],strlen(argv[i]));
        filename[strlen(argv[i])] = '\0';

        yyin = fopen(filename, "r" );
        yylex();
        fclose(yyin);
    }
    fclose(f_out);
    
}