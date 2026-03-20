@echo off
REM Script para compilar el ANE WebViewANE en Windows
REM Requiere: Adobe AIR SDK, Android SDK, Java JDK

echo === Compilando WebViewANE ===

REM Configuración
set ANE_NAME=WebViewANE
set EXTENSION_ID=com.fluocode.ane.Webview
set AIR_SDK_PATH=%AIR_SDK%
if "%AIR_SDK_PATH%"=="" set AIR_SDK_PATH=C:\AIRSDK

REM Verificar AIR SDK
if not exist "%AIR_SDK_PATH%\bin\adt.bat" (
    echo Error: AIR SDK no encontrado en %AIR_SDK_PATH%
    echo Configura la variable de entorno AIR_SDK
    exit /b 1
)

set ADT=%AIR_SDK_PATH%\bin\adt.bat
set AMXMLC=%AIR_SDK_PATH%\bin\amxmlc.bat

REM 1. Compilar ActionScript
echo 1. Compilando ActionScript...
if not exist build mkdir build
"%AMXMLC%" -output build\actionscript.swc -source-path actionscript actionscript\com\fluocode\ane\webview\WebViewANE.as
if errorlevel 1 (
    echo Error al compilar ActionScript
    exit /b 1
)
echo [OK] ActionScript compilado

REM 2. Compilar Android
echo 2. Compilando Android...
if not exist build\android mkdir build\android

set JAVA_SRC=android\src\com\fluocode\ane\webview\WebViewANE.java
set JAVA_LIB=android\libs\FlashRuntimeExtensions.jar

if exist "%JAVA_SRC%" if exist "%JAVA_LIB%" (
    javac -cp "%JAVA_LIB%" -d build\android "%JAVA_SRC%"
    if errorlevel 1 (
        echo Error al compilar Android
        exit /b 1
    )
    cd build\android
    jar cf WebViewANE.jar com\
    cd ..\..
    echo [OK] Android compilado
) else (
    echo Error: Archivos Java no encontrados
    exit /b 1
)

REM 3. Extraer library.swf
echo 3. Extrayendo library.swf...
if not exist build\temp mkdir build\temp
powershell -command "Expand-Archive -Path build\actionscript.swc -DestinationPath build\temp -Force"
copy build\temp\library.swf build\ >nul
echo [OK] library.swf extraído

REM 4. Empaquetar ANE
echo 4. Empaquetando ANE...
"%ADT%" -package -target ane build\%ANE_NAME%.ane extension.xml ^
    -swc build\actionscript.swc ^
    -platform Android-ARM -C build\android WebViewANE.jar -C build library.swf ^
    -platform Android-x86 -C build\android WebViewANE.jar -C build library.swf

if errorlevel 1 (
    echo Error al empaquetar ANE
    exit /b 1
)

echo === Compilación completada ===
echo ANE generado: build\%ANE_NAME%.ane

pause

