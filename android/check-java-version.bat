@echo off
REM Script para verificar la versión de Java

echo Verificando versión de Java...
echo.

java -version 2>&1 | findstr /i "version"
echo.

echo Versiones de Java soportadas por Gradle 7.6:
echo - Java 8 (1.8) - Recomendado
echo - Java 11
echo - Java 17
echo - Java 19
echo.
echo Si tienes Java 20 o superior, necesitas:
echo 1. Instalar Java 8, 11, 17 o 19
echo 2. O configurar Gradle para usar una versión específica
echo.
echo Para configurar Java en Android Studio:
echo File ^> Project Structure ^> SDK Location ^> JDK location
echo.

pause

