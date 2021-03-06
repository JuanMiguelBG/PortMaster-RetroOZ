#!/bin/bash

PORT_LOG_FILE="/roms/logs/am2r.log"

echo "AM2R: " | tee $PORT_LOG_FILE

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

export LD_LIBRARY_PATH=/$directory/ports/am2r/libs:/usr/lib:/usr/lib32
$ESUDO rm -rf ~/.config/am2r
ln -sfv /$directory/ports/am2r/conf/am2r/ ~/.config/
cd /$directory/ports/am2r

$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput

gptokeyb_params=""
if [ "$is_RetroOZ" -eq 1 ]; then
  gptokeyb_params="$param_device -ccf $SDL_GAMECONTROLLERCONFIG_FILE"
  echo "gptokeyb_params: $gptokeyb_params" | tee -a $PORT_LOG_FILE
fi

echo "GPTOKEYB command: $GPTOKEYB \"gmloader\" -c \"./am2r.gptk\" 2>&1 | tee -a $PORT_LOG_FILE &" | tee -a $PORT_LOG_FILE
$GPTOKEYB "gmloader" -c "./am2r.gptk" 2>&1 | tee -a $PORT_LOG_FILE &
echo "Launch command: ./gmloader gamedata/am2r.apk 2>&1 | tee -a $PORT_LOG_FILE" | tee -a $PORT_LOG_FILE
./gmloader gamedata/am2r.apk 2>&1 | tee -a $PORT_LOG_FILE

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart $oga_events &

unset LD_LIBRARY_PATH
unset SDL_GAMECONTROLLERCONFIG
unset SDL_GAMECONTROLLERCONFIG_FILE

printf "\n\nExiting AM2R\n\n" | tee -a $PORT_LOG_FILE
printf "\033c" > /dev/tty1
