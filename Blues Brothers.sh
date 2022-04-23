#!/bin/bash

PORT_LOG_FILE="/roms/logs/bluesbrothers.log"

echo "Blues Brothers: " | tee $PORT_LOG_FILE

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

GAMEDIR="/$directory/ports/bluesbrothers/"
cd $GAMEDIR

$ESUDO chmod 666 /dev/tty1

oc_path="$controlfolder"
if [ "$is_RetroOZ" -eq 1 ]; then
  oc_path="/opt/.retrooz/bin"
fi

echo "OGA_CONTROLS command: $ESUDO $oc_path/oga_controls blues $param_device 2>&1 | tee -a $PORT_LOG_FILE &" | tee -a $PORT_LOG_FILE
$ESUDO $oc_path/oga_controls blues $param_device 2>&1 | tee -a $PORT_LOG_FILE &
echo "Launch command: SDL_GAMECONTROLLERCONFIG=\"$sdl_controllerconfig\" ./blues --fullscreen --filter=nearest --datapath=\"$GAMEDIR/gamedata\" 2>&1 | tee -a $PORT_LOG_FILE" | tee -a $PORT_LOG_FILE
SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" ./blues --fullscreen --filter=nearest --datapath="$GAMEDIR/gamedata" 2>&1 | tee -a $PORT_LOG_FILE

$ESUDO kill -9 $(pidof oga_controls)
$ESUDO systemctl restart $oga_events &

unset LD_LIBRARY_PATH
unset SDL_GAMECONTROLLERCONFIG
unset SDL_GAMECONTROLLERCONFIG_FILE

printf "\n\nExiting Blues Brothers\n\n" | tee -a $PORT_LOG_FILE
printf "\033c" > /dev/tty1
