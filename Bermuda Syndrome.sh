#!/bin/bash

PORT_LOG_FILE="/roms/logs/bermuda.log"

echo "Bermuda Syndrome: " | tee $PORT_LOG_FILE

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

GAMEDIR=/$directory/ports/bermuda/
cd $GAMEDIR

$ESUDO chmod 666 /dev/tty1

if [ $LOWRES == 'N' ]; then
  $ESUDO chmod 666 /dev/uinput

  echo "GPTOKEYB command: $GPTOKEYB \"bs\" 2>&1 | tee -a $PORT_LOG_FILE &" | tee -a $PORT_LOG_FILE
  $GPTOKEYB "bs" 2>&1 | tee -a $PORT_LOG_FILE &
  echo "Launch command: SDL_GAMECONTROLLERCONFIG=\"$sdl_controllerconfig\" ./bs --fullscreen --widescreen=4:3 --datapath=\"/roms/ports/bermuda/DATA\" 2>&1 | tee -a $PORT_LOG_FILE" | tee -a $PORT_LOG_FILE
  SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" ./bs --fullscreen --widescreen=4:3 --datapath="/roms/ports/bermuda/DATA" 2>&1 | tee -a $PORT_LOG_FILE

  $ESUDO kill -9 $(pidof gptokeyb)
  $ESUDO systemctl restart $oga_events &

  unset LD_LIBRARY_PATH
  unset SDL_GAMECONTROLLERCONFIG
  unset SDL_GAMECONTROLLERCONFIG_FILE
else
  printf "$This game requires 640x480 resolution" | tee -a /dev/tty1 $PORT_LOG_FILE
  sleep 5
fi

printf "\n\nExiting Bermuda Syndrome\n\n" | tee -a $PORT_LOG_FILE
printf "\033c" >> /dev/tty1
