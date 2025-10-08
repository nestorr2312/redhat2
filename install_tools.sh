#!/bin/bash
# scripts/install_tools.sh
# Script para la instalación automatizada de herramientas adicionales (Adminer).

# Cargar las variables de entorno
source .env

echo "Iniciando la instalación de herramientas adicionales..."

# --- 1. INSTALAR UTILIDADES (wget/curl) ---
echo "Verificando e instalando wget para descargas..."
if ! command -v wget &> /dev/null
then
    sudo dnf install -y wget
    echo "wget instalado."
fi

# --- 2. INSTALAR ADMINER ---
echo "Descargando e instalando Adminer en el directorio web..."
# Asegurar que estamos en el directorio correcto
cd "${WEB_ROOT_DIR}" || exit

# Descargar el archivo Adminer usando wget y el nombre definido en .env
sudo wget -O "${ADMINER_FILENAME}" "https://www.adminer.org/latest.php"

# Establecer permisos correctos
sudo chown "${WEB_USER}:${WEB_GROUP}" "${ADMINER_FILENAME}"

echo "Adminer instalado y accesible en http://<TU_IP>/${ADMINER_FILENAME}"

# --- 3. CREAR PÁGINA DE PRUEBA DE PHP ---
echo "Creando página de prueba de PHP (info.php)..."
# Usamos un 'here document' para escribir el contenido
sudo tee "${WEB_ROOT_DIR}/info.php" > /dev/null <<EOF
<?php
phpinfo();
?>
EOF

# Ajustar permisos para la página de prueba
sudo chown "${WEB_USER}:${WEB_GROUP}" "${WEB_ROOT_DIR}/info.php"

echo "Página de prueba de PHP creada en http://<TU_IP>/info.php"

echo "Instalación de herramientas adicionales completada."
