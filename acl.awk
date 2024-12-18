#!/usr/bin/gawk -f

BEGINFILE {
    delete acl_ref;
    delete acl_def;
}

/^snmp-server community/ && $5 != ""{

    acl_ref[$5] = 1;
}

/^ access-class/ && $2 != "" {
    acl_ref[$2] = 1;
}

/^ ip access-group/ && $3 != "" {
    acl_ref[$3] = 1;
}

/^access-list/ && $2 != ""{
    acl_def[$2] = 1;
}

/^ip access-list extended/ && $4 != "" {
    acl_def[$4] = 1;
}


ENDFILE {
    for (id in acl_def) {
        if(!(id in acl_ref)) {
            print("DEF pas définit ", id);

        }
    }

    for(id in acl_ref) {
        if(!(id in acl_def)) {
            print("REF pas définit ", id);
        }
    }
}