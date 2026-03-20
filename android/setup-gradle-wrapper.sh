#!/bin/bash
# Script para generar el Gradle Wrapper si no existe

cd "$(dirname "$0")"

if [ ! -f "gradlew" ]; then
    echo "Generando Gradle Wrapper..."
    
    # Verificar si gradle está instalado
    if ! command -v gradle &> /dev/null; then
        echo "Error: Gradle no está instalado."
        echo "Instala Gradle o descarga el wrapper manualmente desde:"
        echo "https://gradle.org/releases/"
        exit 1
    fi
    
    gradle wrapper --gradle-version 7.6
    
    if [ $? -eq 0 ]; then
        echo "✓ Gradle Wrapper generado exitosamente"
        echo "Ahora puedes usar: ./gradlew buildANE"
    else
        echo "Error al generar el wrapper"
        exit 1
    fi
else
    echo "Gradle Wrapper ya existe"
fi

