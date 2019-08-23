#! /bin/bash
# Sistema de monitoreo versio 0.1 
printf "Bienvenido al sistema de monitoreo: \n"
printf "*************************************************************************************************************************\n" |& tee -a  LogMonitoreo.txt | tee  Notificacion.txt 
timestamp=$(date +"%Y-%m-%d / %H:%M")
printf "Obteniendo información del Dispositivo... \n"
printf "Fecha de la información: $timestamp \n" |& tee -a  LogMonitoreo.txt |& tee -a Notificacion.txt
printf "\n"

## Definicion de variables: 
## V3 SNMPget="snmpget -u bootstrap -l authPriv -a MD5 -x DES -A temp_password -X temp_password"
SNMPget="snmpwalk -v2c -c "
Com="public"

#IP="10.0.0.49"
IP=$1

##Interface de red
ired=2

##Nombre del Dispositivo 
MIBnombre=".1.3.6.1.2.1.1.5.0" 
##Informacion del Dispositivo
MIBinfo=".1.3.6.1.2.1.1.1"
##Tiempo de Actividad 
MIBuptime=".1.3.6.1.2.1.1.3" 
## Memoria real + swap 
#MIBram=".1.3.6.1.4.1.2021.4.11.0"
##Memoria Total Fisica 
MIBramtotal=".1.3.6.1.4.1.2021.4.5.0"
##Memoria Disponible Fisica 
MIBram=".1.3.6.1.4.1.2021.4.6.0"

##Memorias Libres"
MIBshared=".1.3.6.1.4.1.2021.4.13.0"
MIBbuffer=".1.3.6.1.4.1.2021.4.14.0"
MIBcached=".1.3.6.1.4.1.2021.4.15.0"

#CPU 
#% CPU Usado por el usuario 
MIBcpuuser=".1.3.6.1.4.1.2021.11.9.0"
#% CPU Usado por el sistema 
MIBcpusis=".1.3.6.1.4.1.2021.11.10.0"
#% CPU LIbre
MIBcpufree=".1.3.6.1.4.1.2021.11.11.0"

##Disco duro 
MIBdiskdir=".1.3.6.1.4.1.2021.9.1.2.1"
##Espacio total del disco duro 
MIBETD1=".1.3.6.1.4.1.2021.9.1.6.1"
##Espacio sobrante del disco duro
MIBESD1=".1.3.6.1.4.1.2021.9.1.7.1"
##Porcentaje de disco duro usado
MIBdiskuseperc=".1.3.6.1.4.1.2021.9.1.9.1"
## % de espcio usado en el disco 
#MIBESD1=".1.3.6.1.4.1.2021.9.1.9.1"

##RED 
##Interfaces de red 
MIBINTN=".1.3.6.1.2.1.31.1.1.1.1"
##Valicidad en Interfaz de Red 
MIBINTV=".1.3.6.1.2.1.31.1.1.1.15"

##Ancho de banda 
### ifInOctets
MIBifinOct=".1.3.6.1.2.1.2.2.1.10."
###ifOutOcts
MIBifoutOct=".1.3.6.1.2.1.2.2.1.16."
### Speed 
MIBOctspeed=".1.3.6.1.2.1.2.2.1.5." 

eol=$'\n'


### Funcion para valida informacion de salida 
function valInfo(){
	local valid=$1
	 if [[ $valid == *"No more variables left"* ]]; then
	    return 1
	 fi
 	return 0
}

### Funcion para Calcular memoria libre
function memfreecalc(){
	local query_memshared="$SNMPget $Com $IP $MIBshared" 
	local result_memshared=$(${query_memshared})
	result_memshared=${result_memshared#'UCD-SNMP-MIB::memShared.0 = INTEGER: '}
	result_memshared=${result_memshared/kB/}
	local query_membuffer="$SNMPget $Com $IP $MIBbuffer" 
        local result_membuffer=$(${query_membuffer})
        result_membuffer=${result_membuffer#'UCD-SNMP-MIB::memBuffer.0 = INTEGER: '}
        result_membuffer=${result_membuffer/kB/}
	local query_memcached="$SNMPget $Com $IP $MIBcached" 
        local result_memcached=$(${query_memcached})
        result_memcached=${result_memcached#'UCD-SNMP-MIB::memCached.0 = INTEGER: '}
        result_memcached=${result_memcached/kB/}
	result_totalfreemem=$((result_memshared+result_membuffer+result_memcached))
}

function memporc(){
	memporcfree=$(( (result_totalfreemem*100)/result_ram_total))

}

function bandwith(){

        local query_ifinfoct="$SNMPget $Com $IP $MIBifinOct$ired" 
        local result_ifinfoct=$(${query_ifinfoct})
        result_ifinfoct=${result_ifinfoct#'IF-MIB::ifInOctets.2 = Counter32:'}

        local query_ifoutoct="$SNMPget $Com $IP $MIBifoutOct$ired" 
        local result_ifoutoct=$(${query_ifoutoct})
        result_ifoutoct=${result_ifoutoct#'IF-MIB::ifOutOctets.2 = Counter32:'}

        local query_speed="$SNMPget $Com $IP $MIBOctspeed$ired" 
        local result_speed=$(${query_speed})
        result_speed=${result_speed#'IF-MIB::ifSpeed.2 = Gauge32: '}

        result_bandwith=$(( (((result_ifinfoct+result_ifoutoct)*8)*100)/result_speed ))
        
}

## llamado de funciones 
bandwith
printf  "Datos Generales : \n"
printf  "_____________________________________________________________________________________________________\n" 
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

# Descripcion  del Dispositivo: ################################
printf "Descripcion del dispositivo:           " |& tee -a  LogMonitoreo.txt |& tee -a Notificacion.txt
query_info="$SNMPget $Com $IP $MIBinfo" 
result_info=$(${query_info})
result_info=${result_info#'SNMPv2-MIB::sysDescr.0 = STRING:'}
if valInfo "$result_info" ;then 
	echo $result_info |& tee -a  LogMonitoreo.txt |& tee -a Notificacion.txt
else 
	echo "Informacion no disponible" 
fi
###################################################################

# Descripcion  del Dispositivo: ################################
printf "Tiempo de actividad HR/MIN/SEG:        " |& tee -a  LogMonitoreo.txt |& tee -a Notificacion.txt
query_uptime="$SNMPget $Com $IP $MIBuptime" 
result_uptime=$(${query_uptime})
result_uptime=${result_uptime#'DISMAN-EVENT-MIB::sysUpTimeInstance = Timeticks:'}
if valInfo "$result_uptime" ;then 
        echo $result_uptime |& tee -a  LogMonitoreo.txt |& tee -a Notificacion.txt
else 
        echo "Informacion no disponible" 
fi

################################################################
printf "\n"
printf "RAM:\n"
printf  "_____________________________________________________________________________________________________\n" 

### Memoria RAM  Diponible #############################################################
printf "Memoria RAM total del dispositivo:     " |& tee -a  LogMonitoreo.txt |& tee -a Notificacion.txt
query_ram_total="$SNMPget $Com $IP $MIBramtotal"
result_ram_total=$(${query_ram_total})
result_ram_total=${result_ram_total#'UCD-SNMP-MIB::memTotalReal.0 = INTEGER:'}
result_ram_total=${result_ram_total//kB/}
result_ram_total="${result_ram_total/ = STRING: /}" 
if valInfo "$result_ram_total" ;then 
        echo "$result_ram_total kB" |& tee -a  LogMonitoreo.txt |& tee -a Notificacion.txt
else 
        echo "Informacion no disponible" 
fi

### Memoria RAM  Diponible #############################################################
printf "Memoria RAM Disponible:                 " |& tee -a  LogMonitoreo.txt |& tee -a Notificacion.txt
memfreecalc
if valInfo "$result_totalfreemem" ;then 
        echo "$result_totalfreemem kB" |& tee -a  LogMonitoreo.txt |& tee -a Notificacion.txt
else 
        echo "Informacion no disponible" 
fi

### Memoria RAM  Diponible % ###########################################################
memporc
printf "Porcentaje disponible de RAM:           "
if valInfo "$memporcfree" ;then 
        echo "$memporcfree %" |& tee -a  LogMonitoreo.txt |& tee -a Notificacion.txt
else 
        echo "Informacion no disponible" 
fi
########################################################################################
printf "\n"
printf "CPU:\n"
printf  "_____________________________________________________________________________________________________\n" 
### CPU utilizado por el usuario  ######################################################
printf "CPU utilizado por el usuario:     " |& tee -a  LogMonitoreo.txt |& tee -a Notificacion.txt
query_cpu_user="$SNMPget $Com $IP $MIBcpuuser"
result_cpu_user=$(${query_cpu_user})
result_cpu_user=${result_cpu_user#'UCD-SNMP-MIB::ssCpuUser.0 = INTEGER: '}
result_cpu_user="${result_cpu_user/ = STRING: /}" 
if valInfo "$result_cpu_user" ;then 
        echo "$result_cpu_user %" |& tee -a  LogMonitoreo.txt |& tee -a Notificacion.txt
else 
        echo "Informacion no disponible" 
fi
### CPU utilizado por el sistema  ######################################################
printf "CPU utilizado por el sistema:     " |& tee -a  LogMonitoreo.txt |& tee -a Notificacion.txt
query_cpu_sys="$SNMPget $Com $IP $MIBcpusis"
query_cpu_sys=$(${query_cpu_sys})
query_cpu_sys=${query_cpu_sys#'UCD-SNMP-MIB::ssCpuSystem.0 = INTEGER: '}
query_cpu_sys="${query_cpu_sys/ = STRING: /}" 
if valInfo "$query_cpu_sys" ;then 
        echo "$query_cpu_sys %" |& tee -a  LogMonitoreo.txt |& tee -a Notificacion.txt
else 
        echo "Informacion no disponible" 
fi
### CPU Libre  ######################################################################
printf "CPU libre:                       " |& tee -a  LogMonitoreo.txt |& tee -a Notificacion.txt
query_cpu_free="$SNMPget $Com $IP $MIBcpufree"
query_cpu_free=$(${query_cpu_free})
query_cpu_free=${query_cpu_free#'UCD-SNMP-MIB::ssCpuIdle.0 = INTEGER:'}
query_cpu_free="${query_cpu_free/ = STRING: /}" 
if valInfo "$query_cpu_free" ;then 
        echo "$query_cpu_free %" |& tee -a  LogMonitoreo.txt |& tee -a Notificacion.txt
else 
        echo "Informacion no disponible" 
fi



########################################################################################
printf "\n"
printf "Discos duro:\n"
printf  "_____________________________________________________________________________________________________\n" 
### Ubicacion del disco duro #########################################################
printf "Ubicacion del disco duro:                 " |& tee -a  LogMonitoreo.txt |& tee -a Notificacion.txt
query_discloc="$SNMPget $Com $IP $MIBdiskdir"
query_discloc=$(${query_discloc})
query_discloc=${query_discloc#'UCD-SNMP-MIB::dskPath.1 = STRING:'}
if valInfo "$query_discloc" ;then 
        echo $query_discloc |& tee -a  LogMonitoreo.txt |& tee -a Notificacion.txt
else 
        echo "Informacion no disponible" 
fi


### Tamano total del disco duro #########################################################
printf "Tamano del disco duro:                 " |& tee -a  LogMonitoreo.txt |& tee -a Notificacion.txt
query_discot="$SNMPget $Com $IP $MIBETD1"
disk_total=$(${query_discot})
disk_total=${disk_total#'UCD-SNMP-MIB::dskTotal.1 = INTEGER:'}
if valInfo "$disk_total" ;then 
        echo $disk_total kB|& tee -a  LogMonitoreo.txt |& tee -a Notificacion.txt
else 
        echo "Informacion no disponible" 
fi

#########################################################################################

### Tamano sobrante del disco duro ######################################################
printf "Espacio disponible en disco duro:      " |& tee -a  LogMonitoreo.txt |& tee -a Notificacion.txt
query_discost="$SNMPget $Com $IP $MIBESD1"
disk_totals=$(${query_discost})
disk_totals=${disk_totals#'UCD-SNMP-MIB::dskAvail.1 = INTEGER: '}
disk_totals="${disk_totals/ = STRING: /}"
if valInfo "$disk_totals" ;then 
        echo "$disk_totals kB" |& tee -a  LogMonitoreo.txt |& tee -a Notificacion.txt
else 
        echo "Informacion no disponible" 
fi
#########################################################################################

### Porcentaje usado en el disco  ######################################################
printf "Porcentaje usado:                      " |& tee -a  LogMonitoreo.txt |& tee -a Notificacion.txt
query_disco_percu="$SNMPget $Com $IP $MIBdiskuseperc"
result_disco_percu=$(${query_disco_percu})
result_disco_percu=${result_disco_percu#'UCD-SNMP-MIB::dskPercent.1 = INTEGER: '}
if valInfo "$result_disco_percu" ;then 
        echo "$result_disco_percu %" |& tee -a  LogMonitoreo.txt |& tee -a Notificacion.txt
else 
        echo "Informacion no disponible" 
fi
#########################################################################################



printf "\n"
printf "Network:\n"
printf  "_____________________________________________________________________________________________________\n" 
### Interfaces de Red disponibles ########################################################
printf "Interfaces de Red disponibles:        \n " |& tee -a  LogMonitoreo.txt |& tee -a Notificacion.txt
query_nameint="$SNMPget $Com $IP $MIBINTN"
result_nameint=$(${query_nameint})
result_nameint=${result_nameint//'IF-MIB::ifName.'/ \//}
result_nameint=${result_nameint//'= STRING:'/# Nombre =}
#echo $result_nameint |& tee -a  LogMonitoreo.txt |& tee -a Notificacion.txt
if valInfo "$result_info" ;then 
        echo $result_nameint |& tee -a  LogMonitoreo.txt |& tee -a Notificacion.txt
else 
        echo "Informacion no disponible" 
fi
printf "\n"



#########################################################################################

### Velocidad Maxima en la interfaz de red ########################
printf "Velocidad en Interfaz de red:(MB)      \n" |& tee -a  LogMonitoreo.txt |& tee -a Notificacion.txt
query_velint="$SNMPget $Com $IP $MIBINTV"
result_velint=$(${query_velint})
result_velint=${result_velint//'IF-MIB::ifHighSpeed.'/ \//}
result_velint=${result_velint//' = Gauge32:'/# Velocidad =}
#result_ram="${result_ram/ = STRING: /}" 
#echo $result_velint |& tee -a  LogMonitoreo.txt |& tee -a Notificacion.txt
if valInfo "$result_velint" ;then 
        echo $result_velint |& tee -a  LogMonitoreo.txt |& tee -a Notificacion.txt
else 
        echo "Informacion no disponible" 
fi

### Bandwith % ###########################################################
bandwith
printf "Ancho de banda:           "
if valInfo "$result_bandwith" ;then 
        echo "$result_bandwith " |& tee -a  LogMonitoreo.txt |& tee -a Notificacion.txt
else 
        echo "Informacion no disponible" 
fi

#########################################################################################
printf "\n"
printf "\n"
printf "*************************************************************************************************************************\n" |& tee -a  LogMonitoreo.txt | tee  Notificacion.txt 
printf "Advertencias:\n" |& tee -a Notificacion.txt

### Manejo de notificaciones ########################
if (( "$memporcfree" < 40 )); then
	echo " Se esta usando DEMASIADA RAM" |& tee -a Notificacion.txt
	##Configuracion para Envio de correo electronico 
	mail -s "AUTOMENSAJE: ALERTA IMPORTANTE!" robin@robin < Notificacion.txt
fi
printf "\n"
printf "*************************************************************************************************************************\n" |& tee -a  LogMonitoreo.txt | tee  Notificacion.txt 




