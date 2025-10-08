#!/bin/bash
# scripts/install_lamp.sh
# Script para la instalación automatizada de la pila LAMP en RHEL/CentOS/Amazon Linux.

# Cargar las variables de entorno
source .env

echo "Iniciando la instalación de la pila LAMP..."

# --- 1. INSTALACIÓN DEL SERVIDOR WEB (Apache) ---
echo "Instalando y habilitando Apache (httpd)..."
sudo dnf install -y httpd
sudo systemctl enable httpd
sudo systemctl start httpd
echo "Apache instalado y activo."

# --- 2. INSTALACIÓN DEL SERVIDOR DE BASE DE DATOS (MariaDB) ---
echo "Instalando y habilitando MariaDB..."
sudo dnf install -y mariadb-server
sudo systemctl enable mariadb
sudo systemctl start mariadb

# 2.1. Configuración de seguridad inicial de MariaDB
echo "Configurando seguridad de MariaDB y contraseña root de forma automática."
# El script mysql_secure_installation no se automatiza fácilmente,
# pero podemos establecer la contraseña de root de esta forma:
sudo mysql -u root <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
EOF

echo "MariaDB instalado y asegurado con la contraseña ROOT de .env."

# --- 3. INSTALACIÓN DE PHP Y MÓDULOS ---
echo "Instalando PHP y módulos esenciales (php-mysqlnd, php-gd, php-mbstring)..."
sudo dnf install -y php php-mysqlnd php-pdo php-gd php-mbstring
echo "PHP instalado. Reiniciando Apache para cargar los módulos."
sudo systemctl restart httpd

# --- 4. CONFIGURACIÓN DEL FIREWALL (Si firewalld existe) ---
echo "Configurando firewall para tráfico HTTP (Puerto 80)..."
if command -v firewall-cmd &> /dev/null
then
    sudo firewall-cmd --permanent --add-service=http
    sudo firewall-cmd --reload
    echo "Puerto 80 abierto en firewalld."
else
    echo "Advertencia: 'firewall-cmd' no encontrado. Confíe en los Grupos de Seguridad de AWS."
fi

echo "Instalación de la pila LAMP completada."
