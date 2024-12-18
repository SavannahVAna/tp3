#!/usr/bin/awk -f

# Programme awk pour détecter les interfaces sans "ip access-group"

BEGIN {
    filename = FILENAME
}

# Si on rencontre une définition d'interface
/^interface / {
    interface_name = $2  # Récupérer le nom de l'interface
    has_access_group = 0 # Réinitialiser le flag
    next
}

# Vérifier si "ip access-group" est dans la section courante
/ip access-group/ {
    has_access_group = 1
    next
}

# Si on rencontre "!" (fin d'une section d'interface)
/^!$/ {
    if (interface_name && !has_access_group) {
        print filename, "interface", interface_name, "missing ip access-group"
    }
    interface_name = ""
    has_access_group = 0
    next
}
