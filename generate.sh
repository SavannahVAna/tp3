#!/bin/bash

# Chemin du fichier source
SOURCE_FILE="router.unix"

# Répertoire cible
TARGET_DIR="conf"

# Copie du fichier 10 000 fois
for i in $(seq 1 40000); do
    cp "$SOURCE_FILE" "$TARGET_DIR/router.unix.$i"
done
