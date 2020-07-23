#!/bin/bash
################################################################################
##                                                                            ##
##   Copyright [2020] [Moisés Serrano Samudio]                                ##
##                                                                            ##
##   Licensed under the Apache License, Version 2.0 (the "License");          ##
##   you may not use this file except in compliance with the License.         ##
##   You may obtain a copy of the License at                                  ##
##                                                                            ##
##       http://www.apache.org/licenses/LICENSE-2.0                           ##
##                                                                            ##
##   Unless required by applicable law or agreed to in writing, software      ##
##   distributed under the License is distributed on an "AS IS" BASIS,        ##
##   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. ##
##   See the License for the specific language governing permissions and      ##
##   limitations under the License.                                           ##
##                                                                            ##
################################################################################
##                                                                            ##
##   Este modifica un registro de un nombre de dominio asociado a una         ##
##	 cuenta de Digital Ocean, usando la API v2. Este script depende de curl,  ##
##   por lo que hay que instalarlo antes de ejecutarlo. Lo que hace es        ##
##   comparar la IP pública vs la IP almacenada en el registro del dominio    ##
##   de Digital Ocean, si la condición no se cumple, entonces actualiza       ##
##   el registro usando la API de Digital Ocean y notifica a través de        ##
##   Slack sobre la actualización y cual es la IP nueva.                      ##
##                                                                            ##
################################################################################

## Estas variables son obtenidas de Digital Ocean
ACCESS_TOKEN=      ## Token de la API de Digital Ocean
DOMAIN=            ## Nombre de dominio a editar
RECORD_ID=         ## ID del registro que editaremos

## Estas son las variables relacionadas con la IP
PUBLIC_IP=$(curl -s http://checkip.amazonaws.com/)  ## IP pública
RECORD_IP=$(curl -s -X GET -H "Content-Type: application/json" -H "Authorization: Bearer "$ACCESS_TOKEN"" "https://api.digitalocean.com/v2/domains/"$DOMAIN"/records/"$RECORD_ID"" | sed -e 's/^.*"data":"\([^"]*\)".*$/\1/')  ## IP almacenada en el registro

## Notificaciones en Slack
SLACKURL=          ## URL de la API de Slack para notificaciones

if ping -q -w 1 -c 1 1.1.1.1 >/dev/null 2>&1
then
	if [ "$PUBLIC_IP" != "$RECORD_IP" ]
	then
		curl -s -X PUT -H "Content-Type: application/json" -H "Authorization: Bearer "$ACCESS_TOKEN"" -d '{"data":"'${PUBLIC_IP}'"}' "https://api.digitalocean.com/v2/domains/"$DOMAIN"/records/"$RECORD_ID""
		curl -X POST -H 'Content-type: application/json' --data '{"text":"La IP del homelab ha cambiado. Ahora es: '${PUBLIC_IP}'"}' ${SLACKURL}
	fi
fi
