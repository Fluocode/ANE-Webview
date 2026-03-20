#!/bin/bash

# Script para compilar el ANE WebViewANE
# Requiere: Adobe AIR SDK, Xcode (macOS), Android SDK

echo "=== Compilando WebViewANE ==="

# Configuración
ANE_NAME="WebViewANE"
EXTENSION_ID="com.fluocode.ane.Webview"
AIR_SDK_PATH="${AIR_SDK:-/path/to/air/sdk}"

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Verificar AIR SDK
if [ ! -d "$AIR_SDK_PATH" ]; then
    echo -e "${RED}Error: AIR SDK no encontrado en $AIR_SDK_PATH${NC}"
    echo "Configura la variable de entorno AIR_SDK o edita este script"
    exit 1
fi

ADT="$AIR_SDK_PATH/bin/adt"
AMXMLC="$AIR_SDK_PATH/bin/amxmlc"

# 1. Compilar ActionScript
echo -e "${YELLOW}1. Compilando ActionScript...${NC}"
mkdir -p build
    $AMXMLC -output build/actionscript.swc \
    -source-path actionscript \
    actionscript/com/fluocode/ane/webview/WebViewANE.as

if [ $? -ne 0 ]; then
    echo -e "${RED}Error al compilar ActionScript${NC}"
    exit 1
fi
echo -e "${GREEN}✓ ActionScript compilado${NC}"

# 2. Compilar iOS (requiere macOS y Xcode)
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo -e "${YELLOW}2. Compilando iOS...${NC}"
    
    # Crear directorio temporal para iOS
    mkdir -p build/ios
    
    # Nota: Esto requiere un proyecto Xcode configurado
    # Por ahora, asumimos que la librería ya está compilada
    if [ ! -f "ios/libWebViewANE.a" ]; then
        echo -e "${YELLOW}Advertencia: libWebViewANE.a no encontrado${NC}"
        echo "Compila el proyecto iOS manualmente con Xcode"
    else
        cp ios/libWebViewANE.a build/ios/
        echo -e "${GREEN}✓ Librería iOS copiada${NC}"
    fi
else
    echo -e "${YELLOW}2. Saltando compilación iOS (requiere macOS)${NC}"
fi

# 3. Compilar Android
echo -e "${YELLOW}3. Compilando Android...${NC}"
mkdir -p build/android

# Compilar Java
JAVA_SRC="android/src/com/fluocode/ane/webview/WebViewANE.java"
JAVA_LIB="android/libs/FlashRuntimeExtensions.jar"

if [ -f "$JAVA_SRC" ] && [ -f "$JAVA_LIB" ]; then
    javac -cp "$JAVA_LIB" -d build/android "$JAVA_SRC"
    if [ $? -eq 0 ]; then
        cd build/android
        jar cf WebViewANE.jar com/
        cd ../..
        echo -e "${GREEN}✓ Android compilado${NC}"
    else
        echo -e "${RED}Error al compilar Android${NC}"
        exit 1
    fi
else
    echo -e "${RED}Error: Archivos Java no encontrados${NC}"
    exit 1
fi

# 4. Extraer library.swf del SWC
echo -e "${YELLOW}4. Extrayendo library.swf...${NC}"
unzip -q -o build/actionscript.swc -d build/temp
cp build/temp/library.swf build/
echo -e "${GREEN}✓ library.swf extraído${NC}"

# 5. Empaquetar ANE
echo -e "${YELLOW}5. Empaquetando ANE...${NC}"

if [[ "$OSTYPE" == "darwin"* ]] && [ -f "build/ios/libWebViewANE.a" ]; then
    # Con iOS
    $ADT -package -target ane build/$ANE_NAME.ane extension.xml \
        -swc build/actionscript.swc \
        -platform iPhone-ARM -C build/ios libWebViewANE.a -C build library.swf \
        -platform Android-ARM -C build/android WebViewANE.jar -C build library.swf \
        -platform Android-x86 -C build/android WebViewANE.jar -C build library.swf
else
    # Solo Android
    $ADT -package -target ane build/$ANE_NAME.ane extension.xml \
        -swc build/actionscript.swc \
        -platform Android-ARM -C build/android WebViewANE.jar -C build library.swf \
        -platform Android-x86 -C build/android WebViewANE.jar -C build library.swf
fi

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ ANE empaquetado: build/$ANE_NAME.ane${NC}"
else
    echo -e "${RED}Error al empaquetar ANE${NC}"
    exit 1
fi

echo -e "${GREEN}=== Compilación completada ===${NC}"

