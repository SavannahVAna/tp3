%{
    #include <stdio.h>
    #include <string.h>
    #include <stdlib.h>

    #define MAX_ACLS 1000
    char text[100];
    // Tableaux pour stocker les ACL référencées et définies
    char *acl_ref[MAX_ACLS];
    char *acl_def[MAX_ACLS];
    int acl_ref_count = 0;
    int acl_def_count = 0;

    // Fonction pour vérifier si une ACL existe déjà dans un tableau
    int exists(char *list[], int count, const char *value) {
        for (int i = 0; i < count; i++) {
            if (strcmp(list[i], value) == 0) {
                return 1;
            }
        }
        return 0;
    }

    // Fonction pour ajouter une ACL dans un tableau
    void add_acl(char *list[], int *count, const char *value) {
        if (*count >= MAX_ACLS) {
            fprintf(stderr, "Error: Too many ACLs\n");
            exit(1);
        }
        if (!exists(list, *count, value)) {
            list[*count] = strdup(value);
            (*count)++;
        }
    }

    // Nettoyage des ACL pour éviter les fuites de mémoire
    void cleanup_acl_list(char *list[], int count) {
        for (int i = 0; i < count; i++) {
            free(list[i]);
        }
    }

    // Comparer les ACL définies et référencées
    void compare_acls(FILE *f_out, const char *filename) {
        // Vérifier les ACL définies mais non référencées
        for (int i = 0; i < acl_def_count; i++) {
            if (!exists(acl_ref, acl_ref_count, acl_def[i])) {
                fprintf(f_out, "%s: DEF pas référencée : %s\n", filename, acl_def[i]);
            }
        }

        // Vérifier les ACL référencées mais non définies
        for (int i = 0; i < acl_ref_count; i++) {
            if (!exists(acl_def, acl_def_count, acl_ref[i])) {
                fprintf(f_out, "%s: REF pas définie : %s\n", filename, acl_ref[i]);
            }
        }
    }

%}

%option noyywrap

%%

^snmp-server[ ]community {
    strncpy(text, yytext + strlen(yytext) -2,2);
    // Capture les ACL référencées par SNMP
    add_acl(acl_ref, &acl_ref_count, text);
}

^[ ]access-class[ ] {
    strncpy(text, yytext + 14,2);
    // Capture les ACL référencées par "access-class"
    add_acl(acl_ref, &acl_ref_count, text );
}

^access-list[ ] {
    // Capture les ACL définies dans "access-list"
    strncpy(text, yytext + 24,2); 
    add_acl(acl_def, &acl_def_count, text);
}

^ip[ ]access-list[ ]extended[ ] {
    // Capture les ACL définies dans "ip access-list extended"
    strcpy(text, yytext + 24); // Skip "access list"
    add_acl(acl_def, &acl_def_count, text);
}

(.|\n) {
    // Ignorer tout autre texte
}

%%

int main(int argc, char **argv) {
    char path[256];  // Chemin du fichier temporaire
    FILE *f_out;
    
    // Crée un fichier temporaire unique
    snprintf(path, sizeof(path), "/tmp/%d_output.txt", getpid());
    f_out = fopen(path, "a");

    if (!f_out) {
        perror("Error creating temporary file");
        return 1;
    }

    // Traitement des fichiers passés en argument
    for (int i = 1; i < argc; i++) {
        // Ouvrir le fichier à analyser
        FILE *yyin = fopen(argv[i], "r");
        if (!yyin) {
            fprintf(stderr, "Error opening file: %s\n", argv[i]);
            continue;
        }

        // Réinitialiser les ACL avant chaque fichier
        acl_ref_count = 0;
        acl_def_count = 0;

        // Lancer l'analyse
        yyin = fopen(argv[i], "r");
        if (!yyin) {
            fprintf(stderr, "Error opening file: %s\n", argv[i]);
            continue;
        }
        yylex();  // Lance l'analyse Flex

        // Comparer les ACL et écrire dans le fichier temporaire
        compare_acls(f_out, argv[i]);

        fclose(yyin);
    }

    fclose(f_out);  // Fermer le fichier temporaire

    return 0;
}
