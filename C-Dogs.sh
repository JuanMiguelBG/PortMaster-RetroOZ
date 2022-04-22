#!/bin/bash

PORT_LOG_FILE="/roms/logs/cdogs.log"

echo "C-Dogs: " | tee $PORT_LOG_FILE

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
      if [ ! -f "/$directory/ports/cdogs/conf/cdogs-sdl/options.cnf" ]; then
        mv -f /$directory/ports/cdogs/conf/cdogs-sdl/options.cnf.480 /roms/ports/cdogs/conf/cdogs-sdl/options.cnf
        rm -f /$directory/ports/cdogs/conf/cdogs-sdl/options.cnf.*
      fi
elif [[ "$(cat /sys/firmware/devicetree/base/model)" == "Anbernic RG552" ]] || [[ -e "/dev/input/by-path/platform-singleadc-joypad-event-joystick" ]]; then
  if [ ! -f "/$directory/ports/cdogs/conf/cdogs-sdl/options.cnf" ]; then
    mv -f /$directory/ports/cdogs/conf/cdogs-sdl/options.cnf.rg552 /roms/ports/cdogs/conf/cdogs-sdl/options.cnf
    rm -f /$directory/ports/cdogs/conf/cdogs-sdl/options.cnf.*
  fi
elif [[ $param_device == "ogs" ]] || [[ $param_device == *"rgb10max"* ]]; then
  if [ ! -f "/$directory/ports/cdogs/conf/cdogs-sdl/options.cnf" ]; then
    mv -f /$directory/ports/cdogs/conf/cdogs-sdl/options.cnf.ogs /roms/ports/cdogs/conf/cdogs-sdl/options.cnf
    rm -f /$directory/ports/cdogs/conf/cdogs-sdl/options.cnf.*
  fi
else
  if [ ! -f "/$directory/ports/cdogs/conf/cdogs-sdl/options.cnf" ]; then
    mv -f /$directory/ports/cdogs/conf/cdogs-sdl/options.cnf.640 /roms/ports/cdogs/conf/cdogs-sdl/options.cnf
    rm -f /$directory/ports/cdogs/conf/cdogs-sdl/options.cnf.*
  fi
fi

rm -rf ~/.config/cdogs-sdl
ln -sfv /$directory/ports/cdogs/conf/cdogs-sdl/ ~/.config/
cd /$directory/ports/cdogs/data

$ESUDO chmod 666 /dev/tty1

oc_path="$controlfolder"
if [ "$is_RetroOZ" -eq 1 ]; then
  oc_path="/opt/.retrooz/bin"
fi

echo "OGA_CONTROLS command: $ESUDO $oc_path/oga_controls cdogs-sdl $param_device 2>&1 | tee -a $PORT_LOG_FILE &" | tee -a $PORT_LOG_FILE
$ESUDO $oc_path/oga_controls cdogs-sdl $param_device 2>&1 | tee -a $PORT_LOG_FILE &
echo "Launch command: ./cdogs-sdl 2>&1 | tee -a $PORT_LOG_FILE" | tee -a $PORT_LOG_FILE
./cdogs-sdl 2>&1 | tee -a $PORT_LOG_FILE

$ESUDO kill -9 $(pidof oga_controls)
$ESUDO systemctl restart $oga_events &

unset LD_LIBRARY_PATH
unset SDL_GAMECONTROLLERCONFIG
unset SDL_GAMECONTROLLERCONFIG_FILE

printf "\n\nExiting C-Dogs\n\n" | tee -a $PORT_LOG_FILE

printf "\033c" > /dev/tty1
