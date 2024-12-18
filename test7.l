%{
	#include <stdio.h>
	char filename[100];
    int has_access_class_in = 0;  // Flag pour vérifier "access-class in"
    int has_access_class_out = 0;
    char current_line[100]; 
%}

%option noyywrap
%x VTY
%%

^line[ ]vty.*$ {
    // Détecte le début d'une section "line vty"
    strncpy(current_line, yytext, sizeof(current_line) - 1);
    current_line[sizeof(current_line) - 1] = '\0';

    has_access_class_in = 0;  // Réinitialiser les flags
    has_access_class_out = 0;

    BEGIN VTY;
}

<VTY>^[ ]*access-class[ ]+in.*$ {
    has_access_class_in = 1; // Trouvé "access-class in"
}

<VTY>^[ ]*access-class[ ]+out.*$ {
    has_access_class_out = 1; // Trouvé "access-class out"
}

<VTY>^!$ {
    // Fin de la section de configuration pour une ligne vty
    if (!has_access_class_in || !has_access_class_out) {
        if (!has_access_class_in) {
            printf("%s missing access-class in\n", current_line);
        }
        if (!has_access_class_out) {
            printf("%s missing access-class out\n", current_line);
        }
    }
    BEGIN INITIAL; // Revenir au contexte global
}

<VTY>(.|\n) {} // Ignorer tout autre texte dans le contexte VTY
(.|\n) {} // Ignorer tout autre texte dans le contexte global


%%

int main(int argc, char **argv ) {

    strncpy(filename,argv[1],strlen(argv[1]));
    filename[strlen(argv[1])] = '\0';

    yyin = fopen(filename, "r" );
    yylex();
    fclose(yyin);
}
