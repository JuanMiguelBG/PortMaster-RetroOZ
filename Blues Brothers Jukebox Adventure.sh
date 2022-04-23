#!/bin/bash

PORT_LOG_FILE="/roms/logs/jukeboxadventure.log"

echo "Blues Brothers Jukebox Adventure: " | tee $PORT_LOG_FILE

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

$ESUDO chmod 666 /dev/tty1

GAMEDIR=/$directory/ports/jukeboxadventure

cd $GAMEDIR
echo "Launch command: LD_LIBRARY_PATH=./lib:$LD_LIBRARY_PATH SDL_GAMECONTROLLERCONFIG=\"$sdl_controllerconfig\" ./bbja --fullscreen --filter=nearest --datapath=\"$GAMEDIR/gamedata\" 2>&1 | tee -a $PORT_LOG_FILE" | tee -a $PORT_LOG_FILE
LD_LIBRARY_PATH=./lib:$LD_LIBRARY_PATH SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" ./bbja --fullscreen --filter=nearest --datapath="$GAMEDIR/gamedata" 2>&1 | tee -a $PORT_LOG_FILE

unset LD_LIBRARY_PATH
unset SDL_GAMECONTROLLERCONFIG
unset SDL_GAMECONTROLLERCONFIG_FILE

printf "\n\nExiting Blues Brothers Jukebox Adventure\n\n" | tee -a $PORT_LOG_FILE
printf "\033c" >> /dev/tty1
