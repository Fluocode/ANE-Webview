@echo off
REM Script para generar el Gradle Wrapper si no existe (Windows)

cd /d "%~dp0"

if not exist "gradlew.bat" (
    echo Generando Gradle Wrapper...
    
    REM Verificar si gradle está instalado
    where gradle >nul 2>&1
    if errorlevel 1 (
        echo Error: Gradle no está instalado.
        echo Instala Gradle o descarga el wrapper manualmente desde:
        echo https://gradle.org/releases/
        exit /b 1
    )
    
    gradle wrapper --gradle-version 7.6
    
    if errorlevel 1 (
        echo Error al generar el wrapper
        exit /b 1
    ) else (
        echo [OK] Gradle Wrapper generado exitosamente
        echo Ahora puedes usar: gradlew.bat buildANE
    )
) else (
    echo Gradle Wrapper ya existe
)

pause

