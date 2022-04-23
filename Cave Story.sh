#!/bin/bash

PORT_LOG_FILE="/roms/logs/cavestory.log"

echo "Cave Story: " | tee $PORT_LOG_FILE

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

GAMEDIR="/$directory/ports/cavestory"
if [ "$is_ArkOS" -eq 1 ]; then
  raloc="/opt/retroarch/bin"
  raconf=""
elif [[ -e "/storage/.config/.OS_ARCH" ]] || [ -z $ESUDO ]; then
  raloc="/usr/bin"
  raconf=""
elif [ "$is_RetroOZ" -eq 1 ]; then
  raloc="/opt/retroarch/bin"
  raconf="--config /home/odroid/.config/retroarch/retroarch.cfg"
else
  raloc="/usr/local/bin"
  raconf=""
fi

echo "Launch command: $raloc/retroarch $raconf -L $GAMEDIR/nxengine_libretro.so $GAMEDIR/Doukutsu.exe 2>&1 | tee -a $PORT_LOG_FILE" | tee -a $PORT_LOG_FILE
$raloc/retroarch $raconf -L $GAMEDIR/nxengine_libretro.so $GAMEDIR/Doukutsu.exe 2>&1 | tee -a $PORT_LOG_FILE

unset LD_LIBRARY_PATH
unset SDL_GAMECONTROLLERCONFIG
unset SDL_GAMECONTROLLERCONFIG_FILE

printf "\n\nExiting Cave Story\n\n" | tee -a $PORT_LOG_FILE
