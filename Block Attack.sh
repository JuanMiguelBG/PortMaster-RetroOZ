#!/bin/bash

PORT_LOG_FILE="/roms/logs/blockattack.log"

echo "Block Attack: " | tee $PORT_LOG_FILE

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

cd /$directory/ports/blockattack

$ESUDO rm -rf ~/.local/share/blockattack
ln -sfv /$directory/ports/blockattack/ ~/.local/share

$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput

gptokeyb_params=""
if [ "$is_RetroOZ" -eq 1 ]; then
  gptokeyb_params="$param_device -ccm \"$sdl_controllerconfig\""
  echo "gptokeyb_params: $gptokeyb_params" | tee -a $PORT_LOG_FILE
fi

echo "GPTOKEYB command: $GPTOKEYB \"blockattack\" $gptokeyb_params 2>&1 | tee -a $PORT_LOG_FILE &" | tee -a $PORT_LOG_FILE
$GPTOKEYB "blockattack" $gptokeyb_params 2>&1 | tee -a $PORT_LOG_FILE &
echo "Launch command: LD_LIBRARY_PATH=\"$PWD/libs\" SDL_GAMECONTROLLERCONFIG=\"$sdl_controllerconfig\" ./blockattack 2>&1 | tee -a $PORT_LOG_FILE" | tee -a $PORT_LOG_FILE
LD_LIBRARY_PATH="$PWD/libs" SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" ./blockattack 2>&1 | tee -a $PORT_LOG_FILE

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart $oga_events &

unset LD_LIBRARY_PATH
unset SDL_GAMECONTROLLERCONFIG
unset SDL_GAMECONTROLLERCONFIG_FILE

printf "\n\nExiting Block Attack\n\n" | tee -a $PORT_LOG_FILE
printf "\033c" > /dev/tty1