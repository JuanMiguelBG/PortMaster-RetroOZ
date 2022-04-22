#!/bin/bash

PORT_LOG_FILE="/roms/logs/devilutionx.log"

echo "Devilutionx: " | tee $PORT_LOG_FILE

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

echo "PortMaster folder: $controlfolder" | tee -a $PORT_LOG_FILE

source $controlfolder/control.txt >> $PORT_LOG_FILE 2>&1

get_controls >> $PORT_LOG_FILE 2>&1

cd /$directory/ports/devilution

$ESUDO chmod 666 /dev/tty1

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/lib32:/$directory/ports/devilution/libs"
cd /$directory/ports/devilution

echo "Launch command: ./devilutionx --config-dir /$directory/ports/devilution --data-dir /$directory/ports/devilution --save-dir /$directory/ports/devilution 2>&1 | tee -a $PORT_LOG_FILE" | tee -a $PORT_LOG_FILE
./devilutionx --config-dir /$directory/ports/devilution --data-dir /$directory/ports/devilution --save-dir /$directory/ports/devilution 2>&1 | tee -a $PORT_LOG_FILE

unset LD_LIBRARY_PATH
unset SDL_GAMECONTROLLERCONFIG
unset SDL_GAMECONTROLLERCONFIG_FILE

printf "\n\nExiting Devilutionx\n\n" | tee -a $PORT_LOG_FILE
printf "\033c" >> /dev/tty1
