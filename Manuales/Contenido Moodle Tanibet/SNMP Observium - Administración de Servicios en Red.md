
###Practica SNMP observium 
Objetivo:
Configuración de Gestor observium  en los siguientes dispositivos: 
- Win (SNMP)
- Linux (SNMP)
- sw 

    

-Configurarlo con algo 
8.12.0.X

Notas: 
Tienen que estar dentro de la misma red 

Proceso de Instalación:  
- Igual al Tuto... 

En Windows:
- Panel de control
- Programas 
- Protocolo simple de administracion de red SNMP 

Servicios Locales:
- Captura SNMP 
- Servicio SNMP click derecho propiedades 
- pestaña de captura 
- pestaña de seguridad 
Nombre de la comunidad es como un password, se hacen peticiones pero es importante que el gestor sepa la comunidad a la que pertenece el agente.
"SNMPcom"

-Pestaña de seguridad
Tenemos que agregar la comunidad  establecer permisos 

8.12.0.90

En observium darle Quit al menu de configuracion para llega a consola 
para poder dar de alta un host necesitamos editar un archivo :
nano /etc/hosts 
chmod +s /usr/bin/fping


Agregar un
windows 
v1
udp 
usar nombre de la comunidad "SNMPcom"
add device

usar v1 


----------
###Segunda sesión 

Instrucciones para configurar un agente SNMP en linux (ubuntu) usando NET-SNMP.

 1. Instalar NET-SNMP
```linux
sudo apt-get install snmpd snmp
```
 2. Configurar el archivo **/etc/snmp/snmpd.conf**, es recomendable crear una copia del archivo original con el comando
 3. Editar el archivo snmpd.conf de manera manual o usando un script de perl incluido en la instalación de NET-SNMP usando el comando:
 
```linux
 snmpconf -r none -g basic_setup
```




Creación del archivo de configuración snmp.conf
Colocar el archivo de configuración en la carpeta etc/smnp/snmpd.conf

revisar el documento en la plataforma pff 
> Written with [StackEdit](https://stackedit.io/).