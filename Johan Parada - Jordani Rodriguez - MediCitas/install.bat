@echo off
REM Script para instalar pnpm y dependencias del proyecto

echo ============================================
echo  Instalando pnpm...
echo ============================================
call npm install -g pnpm

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ERROR: No se pudo instalar pnpm
    echo Asegurate de que Node.js este instalado
    pause
    exit /b 1
)

echo.
echo ============================================
echo  Instalando dependencias del proyecto...
echo ============================================
call pnpm install

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ERROR: Fallo la instalacion de dependencias
    pause
    exit /b 1
)

echo.
echo ============================================
echo  Instalacion completada exitosamente!
echo ============================================
echo.
echo Proximos pasos:
echo   - Para web:  pnpm web:dev
echo   - Para mobile: pnpm mobile:start
echo.
pause
