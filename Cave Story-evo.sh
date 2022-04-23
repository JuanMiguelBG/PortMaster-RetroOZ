#!/bin/bash

PORT_LOG_FILE="/roms/logs/cavestoryevo.log"

echo "Cave Story-evo: " | tee $PORT_LOG_FILE

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

if [[ $LOWRES == "Y" ]]; then
  if [ ! -f "/roms/ports/nxengine-evo/conf/nxengine/settings.dat" ]; then
    mv -f /roms/ports/nxengine-evo/conf/nxengine/settings.dat.480 /roms/ports/nxengine-evo/conf/nxengine/settings.dat
    rm -f /roms/ports/nxengine-evo/conf/nxengine/settings.dat.*
  fi
elif [[ "$(cat /sys/firmware/devicetree/base/model)" == "Anbernic RG552" ]] || [[ -e "/dev/input/by-path/platform-singleadc-joypad-event-joystick" ]]; then
  if [ ! -f "/roms/ports/nxengine-evo/conf/nxengine/settings.dat" ]; then
    mv -f /roms/ports/nxengine-evo/conf/nxengine/settings.dat.rg552 /roms/ports/nxengine-evo/conf/nxengine/settings.dat
    rm -f /roms/ports/nxengine-evo/conf/nxengine/settings.dat.*
  fi
elif [[ $param_device == "ogs" ]] || [[ $param_device == *"rgb10max"* ]]; then
  if [ ! -f "/roms/ports/nxengine-evo/conf/nxengine/settings.dat" ]; then
    mv -f /roms/ports/nxengine-evo/conf/nxengine/settings.dat.ogs /roms/ports/nxengine-evo/conf/nxengine/settings.dat
    rm -f /roms/ports/nxengine-evo/conf/nxengine/settings.dat.*
  fi
else
  if [ ! -f "/roms/ports/nxengine-evo/conf/nxengine/settings.dat" ]; then
    mv -f /roms/ports/nxengine-evo/conf/nxengine/settings.dat.640 /roms/ports/nxengine-evo/conf/nxengine/settings.dat
    rm -f /roms/ports/nxengine-evo/conf/nxengine/settings.dat.*
  fi
fi

$ESUDO rm -rf ~/.local/share/nxengine
$ESUDO ln -s /$directory/ports/nxengine-evo/conf/nxengine ~/.local/share/
cd /$directory/ports/nxengine-evo

$ESUDO chmod 666 /dev/tty1

oc_path="$controlfolder"
if [ "$is_RetroOZ" -eq 1 ]; then
  oc_path="/opt/.retrooz/bin"
fi

echo "OGA_CONTROLS command: $ESUDO $oc_path/oga_controls nxengine-evo $param_device 2>&1 | tee -a $PORT_LOG_FILE &" | tee -a $PORT_LOG_FILE
$ESUDO $oc_path/oga_controls nxengine-evo $param_device 2>&1 | tee -a $PORT_LOG_FILE &
echo "Launch command: LD_LIBRARY_PATH=\"$LD_LIBRARY_PATH:/$directory/ports/nxengine-evo/libs\" SDL_GAMECONTROLLERCONFIG=\"$sdl_controllerconfig\" ./nxengine-evo 2>&1 | tee -a $PORT_LOG_FILE" | tee -a $PORT_LOG_FILE
LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/$directory/ports/nxengine-evo/libs" SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" ./nxengine-evo 2>&1 | tee -a $PORT_LOG_FILE

$ESUDO kill -9 $(pidof oga_controls)
$ESUDO systemctl restart $oga_events &

unset LD_LIBRARY_PATH
unset SDL_GAMECONTROLLERCONFIG
unset SDL_GAMECONTROLLERCONFIG_FILE

printf "\n\nExiting Cave Story-evo\n\n" | tee -a $PORT_LOG_FILE
printf "\033c" >> /dev/tty1
