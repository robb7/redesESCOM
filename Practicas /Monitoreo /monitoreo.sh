#! /bin/bash
# Sistema de monitoreo versio 0.1 
printf "Bienvenido al sistema de monitoreo: \n"
printf "**************************************************************\n" |& tee -a  LogMonitoreo.txt | tee  Notificacion.txt 
timestamp=$(date +"%Y-%m-%d / %H:%M")
printf "Obteniendo información del Dispositivo... \n"
printf "Fecha de la información: $timestamp \n" |& tee -a  LogMonitoreo.txt |& tee -a Notificacion.txt
printf "\n"

## Definicion de variables: 
## V3 SNMPget="snmpget -u bootstrap -l authPriv -a MD5 -x DES -A temp_password -X temp_password"
SNMPget="snmpwalk -v2c -c "
Com="public"
IP="localhost"

MIBnombre=".1.3.6.1.2.1.1.5.0" 

## Memoria real + swap 
#MIBram=".1.3.6.1.4.1.2021.4.11.0"
##Memoria Total Fisica 
#MIBram=".1.3.6.1.4.1.2021.4.5.0"
##Memoria Disponible Fisica 
MIBram=".1.3.6.1.4.1.2021.4.6.0"
##Espacio total del disco duro 
MIBETD1=".1.3.6.1.4.1.2021.9.1.6.1"
##Espacio sobrante del disco duro
MIBESD1=".1.3.6.1.4.1.2021.9.1.7.1"
## % de espcio usado en el disco 
#MIBESD1=".1.3.6.1.4.1.2021.9.1.9.1"
##Interfaces de red 
MIBINTN=".1.3.6.1.2.1.31.1.1.1.1"
##Valicidad en Interfaz de Red 
MIBINTV=".1.3.6.1.2.1.31.1.1.1.15"


# Obtener  nombre del Dispositivo: ################################
#snmpget -u bootstrap -l authPriv -a MD5 -x DES -A temp_password -X temp_password 10.0.0.49 1.3.6.1.2.1.1.5.0
#snmpget -v2c -c public 192.168.1.67 1.3.6.1.2.1.1.5.0
printf "Nombre del dispositivo:               " |& tee -a  LogMonitoreo.txt |& tee -a Notificacion.txt
query_nombre="$SNMPget $Com $IP $MIBnombre" 
result_nombre=$(${query_nombre})
result_nombre=${result_nombre#'SNMPv2-MIB::sysName.0 = STRING:'}
echo "${result_nombre/ = STRING: /}" |& tee -a  LogMonitoreo.txt |& tee -a Notificacion.txt
#result_nombre=$(snmpget -u bootstrap -l authPriv -a MD5 -x DES -A temp_password -X temp_password)
#result_nombre=${result_nombre#'SNMPv2-MIB::sysName.0 = STRING:'}
#echo "${result_nombre/ = STRING: /}" |& tee -a  LogMonitoreo.txt
###################################################################

### Memoria RAM  Diponible #######################################
#snmpget -v2c -c public 192.168.1.67  .1.3.6.1.4.1.2021.4.5.0
printf "Memoria RAM Disponible:                " |& tee -a  LogMonitoreo.txt |& tee -a Notificacion.txt
query_ram="$SNMPget $Com $IP $MIBram"
result_ram=$(${query_ram})
result_ram=${result_ram#'UCD-SNMP-MIB::memTotalFree.0 = INTEGER:'}
result_ram="${result_ram/ = STRING: /}" 
echo $result_ram |& tee -a  LogMonitoreo.txt |& tee -a Notificacion.txt

### Tamano total del disco duro ##################################
printf "Tamano del disco duro:                 " |& tee -a  LogMonitoreo.txt |& tee -a Notificacion.txt
query_discot="$SNMPget $Com $IP $MIBETD1"
disk_total=$(${query_discot})
disk_total=${disk_total#'UCD-SNMP-MIB::dskTotal.1 = INTEGER: '}
disk_total="${disk_total/ = STRING: /}"
disk_total=$(( disk_total / 1000 ))
echo $(( disk_total / 1000 )) " GB" |& tee -a  LogMonitoreo.txt |& tee -a Notificacion.txt
###################################################################

### Tamano sobrante del disco duro ##################################
printf "Espacio disponible en disco duro:      " |& tee -a  LogMonitoreo.txt |& tee -a Notificacion.txt
query_discost="$SNMPget $Com $IP $MIBESD1"
disk_totals=$(${query_discost})
disk_totals=${disk_totals#'UCD-SNMP-MIB::dskAvail.1 = INTEGER: '}
disk_totals="${disk_totals/ = STRING: /}"
disk_totals=$(( disk_totals / 1000 ))
echo $(( disk_totals / 1000 )) " GB" |& tee -a  LogMonitoreo.txt |& tee -a Notificacion.txt
###################################################################

### Interfaces de Red disponibles ########################
printf "Interfaces de Red disponibles:         " |& tee -a  LogMonitoreo.txt |& tee -a Notificacion.txt
query_nameint="$SNMPget $Com $IP $MIBINTN"
result_nameint=$(${query_nameint})
result_nameint=${result_nameint//'IF-MIB::ifName.'/#Interfaz=}
result_nameint=${result_nameint//'= STRING:'/ nombre = }
echo $result_nameint |& tee -a  LogMonitoreo.txt |& tee -a Notificacion.txt
###################################################################

### Velocidad Maxima en la interfaz de red ########################
printf "Velocidad en Interfaz de red:(MB)      " |& tee -a  LogMonitoreo.txt |& tee -a Notificacion.txt
query_velint="$SNMPget $Com $IP $MIBINTV"
result_velint=$(${query_velint})
result_velint=${result_velint//'IF-MIB::ifHighSpeed.'/#Interfaz=}
result_velint=${result_velint//' = Gauge32:'/}
#result_ram="${result_ram/ = STRING: /}" 
echo $result_velint |& tee -a  LogMonitoreo.txt |& tee -a Notificacion.txt
###################################################################
printf "\n"
printf "**************************************************************\n" |& tee -a  LogMonitoreo.txt |& tee -a Notificacion.txt
printf "Advertencias:\n" |& tee -a Notificacion.txt

### Manejo de notificaciones ########################
result_ramnum=${result_ram//'kB'/}
echo $(( result_ramnum/1000)) " MB"
if (( "$result_ramnum" > 1000)); then
	echo " Se esta usando DEMASIADA RAM" |& tee -a Notificacion.txt
fi
##Configuracion para Envio de correo electronico 
##mail -s "AUTOMENSAJE: IMPORTANTE!" robin@redes.com < LogMonitoreo.txt
printf "**************************************************************\n" |& tee -a  LogMonitoreo.txt |& tee -a Notificacion.txt
