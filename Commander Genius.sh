#!/bin/bash

PORT_LOG_FILE="/roms/logs/cgenius.log"

echo "Commander Genius: " | tee $PORT_LOG_FILE

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

$ESUDO rm -rf ~/.CommanderGenius
ln -sfv /$directory/ports/cgenius/.CommanderGenius/ ~/
cd /$directory/ports/cgenius

$ESUDO chmod 666 /dev/tty1

oc_path="$controlfolder"
if [ "$is_RetroOZ" -eq 1 ]; then
  oc_path="/opt/.retrooz/bin"
fi

echo "OGA_CONTROLS command: $ESUDO $oc_path/oga_controls CGeniusExe $param_device 2>&1 | tee -a $PORT_LOG_FILE &" | tee -a $PORT_LOG_FILE
$ESUDO $oc_path/oga_controls CGeniusExe $param_device 2>&1 | tee -a $PORT_LOG_FILE &
echo "Launch command: ./CGeniusExe 2>&1 | tee -a $PORT_LOG_FILE" | tee -a $PORT_LOG_FILE
./CGeniusExe 2>&1 | tee -a $PORT_LOG_FILE

$ESUDO kill -9 $(pidof oga_controls)
$ESUDO systemctl restart $oga_events &

unset LD_LIBRARY_PATH
unset SDL_GAMECONTROLLERCONFIG
unset SDL_GAMECONTROLLERCONFIG_FILE

printf "\n\nExiting Commander Genius\n\n" | tee -a $PORT_LOG_FILE
printf "\033c" >> /dev/tty1
