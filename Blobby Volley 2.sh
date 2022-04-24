#!/bin/bash

PORT_LOG_FILE="/roms/logs/blobbyvolley2.log"

echo "Blobby Volley 2: " | tee $PORT_LOG_FILE

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

cd /$directory/ports/blobbyvolley2

$ESUDO rm -rf ~/.blobby
ln -sfv /$directory/ports/blobbyvolley2/conf/.blobby ~/

$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput

echo "GPTOKEYB command: $GPTOKEYB \"blobby\" -c \"./blobby.gptk.$ANALOGSTICKS\" 2>&1 | tee -a $PORT_LOG_FILE &" | tee -a $PORT_LOG_FILE
$GPTOKEYB "blobby" -c "./blobby.gptk.$ANALOGSTICKS" 2>&1 | tee -a $PORT_LOG_FILE &
echo "Launch command: LD_LIBRARY_PATH=\"$PWD/libs\" SDL_GAMECONTROLLERCONFIG=\"$sdl_controllerconfig\" ./blobby 2>&1 | tee -a $PORT_LOG_FILE" | tee -a $PORT_LOG_FILE
LD_LIBRARY_PATH="$PWD/libs" SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" ./blobby 2>&1 | tee -a $PORT_LOG_FILE

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart $oga_events &

unset LD_LIBRARY_PATH
unset SDL_GAMECONTROLLERCONFIG
unset SDL_GAMECONTROLLERCONFIG_FILE

printf "\n\nExiting Blobby Volley 2\n\n" | tee -a $PORT_LOG_FILE
printf "\033c" >> /dev/tty1
