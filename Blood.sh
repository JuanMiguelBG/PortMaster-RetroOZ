#!/bin/bash

PORT_LOG_FILE="/roms/logs/blood.log"

echo "Blood: " | tee $PORT_LOG_FILE

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

export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/storage/roms/ports/Blood/lib:/usr/lib"
GAMEDIR="/$directory/ports/Blood"

GPTOKEYB_CONFIG="$GAMEDIR/nblood.gptk"

$ESUDO rm -rf ~/.config/nblood
$ESUDO ln -s $GAMEDIR/conf/nblood ~/.config/
cd $GAMEDIR

$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput

echo "GPTOKEYB command: $GPTOKEYB \"nblood\" -c $GPTOKEYB_CONFIG 2>&1 | tee -a $PORT_LOG_FILE &" | tee -a $PORT_LOG_FILE
$GPTOKEYB "nblood" -c $GPTOKEYB_CONFIG 2>&1 | tee -a $PORT_LOG_FILE &
echo "Launch command: ./nblood 2>&1 | tee -a $PORT_LOG_FILE" | tee -a $PORT_LOG_FILE
./nblood 2>&1 | tee -a $PORT_LOG_FILE

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart $oga_events &

unset LD_LIBRARY_PATH
unset SDL_GAMECONTROLLERCONFIG
unset SDL_GAMECONTROLLERCONFIG_FILE

printf "\n\nExiting Blood\n\n" | tee -a $PORT_LOG_FILE
printf "\033c" >> /dev/tty1
