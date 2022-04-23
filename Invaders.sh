#!/bin/bash

PORT_LOG_FILE="/roms/logs/invaders.log"

echo "Invaders: " | tee $PORT_LOG_FILE

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

cd /$directory/ports/Invaders/

if [[ "$LOWRES" == "Y" ]]; then
  AppToLaunch="si78c_lowres"
elif [[ "$(cat /sys/firmware/devicetree/base/model)" == "Anbernic RG552" ]] || [[ -e "/dev/input/by-path/platform-singleadc-joypad-event-joystick" ]]; then
  AppToLaunch="si78c_hires"
else
  AppToLaunch="si78c"
fi

$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput

echo "GPTOKEYB command: $GPTOKEYB \"$AppToLaunch\" -c \"./Invaders.gptk\" &" | tee -a $PORT_LOG_FILE
$GPTOKEYB "$AppToLaunch" -c "./Invaders.gptk" &
echo "Launch command: SDL_GAMECONTROLLERCONFIG=\"$sdl_controllerconfig\" ./bin/$AppToLaunch 2>&1 | tee -a $PORT_LOG_FILE" | tee -a $PORT_LOG_FILE
SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" ./bin/$AppToLaunch 2>&1 | tee -a $PORT_LOG_FILE

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart $oga_events &

unset LD_LIBRARY_PATH
unset SDL_GAMECONTROLLERCONFIG
unset SDL_GAMECONTROLLERCONFIG_FILE

printf "\n\nExiting Invaders\n\n" | tee -a $PORT_LOG_FILE
printf "\033c" >> /dev/tty1
