#!/bin/bash

PORT_LOG_FILE="/roms/logs/exhumed.log"

echo "Exhumed: " | tee $PORT_LOG_FILE

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

GAMEDIR=/$directory/ports/Exhumed

if   [[ $ANALOGSTICKS == '1' ]]; then
  if [ ! -f "/$directory/ports/Exhumed/conf/pcexhumed/pcexhumed.cfg" ]; then
     mv -f /$directory/ports/Exhumed/conf/pcexhumed/pcexhumed.cfg.1analog /$directory/ports/Exhumed/conf/pcexhumed/pcexhumed.cfg
     rm -f /$directory/ports/Exhumed/conf/pcexhumed/pcexhumed.cfg.2analog
  fi
  if [ ! -f "/$directory/ports/Exhumed/oga_controls_settings.txt" ]; then
     mv -f /$directory/ports/Exhumed/oga_controls_settings.txt.1analog /$directory/ports/Exhumed/oga_controls_settings.txt
     rm -f /$directory/ports/Exhumed/oga_controls_settings.txt.2analog
  fi
elif [[ $ANALOGSTICKS == '2' ]]; then
  if [ ! -f "/$directory/ports/Exhumed/conf/pcexhumed/pcexhumed.cfg" ]; then
     mv -f /$directory/ports/Exhumed/conf/pcexhumed/pcexhumed.cfg.2analog /$directory/ports/Exhumed/conf/pcexhumed/pcexhumed.cfg
     rm -f /$directory/ports/Exhumed/conf/pcexhumed/pcexhumed.cfg.1analog
  fi
  if [ ! -f "/$directory/ports/Exhumed/oga_controls_settings.txt" ]; then
     mv -f /$directory/ports/Exhumed/oga_controls_settings.txt.2analog /$directory/ports/Exhumed/oga_controls_settings.txt
     rm -f /$directory/ports/Exhumed/oga_controls_settings.txt.1analog
  fi
fi

$ESUDO rm -rf ~/.config/pcexhumed
$ESUDO ln -s /roms/ports/Exhumed/conf/pcexhumed ~/.config/
cd $GAMEDIR

export TEXTINPUTINTERACTIVE="Y"

$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput

echo "GPTOKEYB command: $GPTOKEYB \"pcexhumed\" -c \"./pcexhumed.gptk\" &" | tee -a $PORT_LOG_FILE
$GPTOKEYB "pcexhumed" -c "./pcexhumed.gptk" &
echo "Launch command: LD_LIBRARY_PATH=./lib:$LD_LIBRARY_PATH SDL_GAMECONTROLLERCONFIG=\"$sdl_controllerconfig\" ./pcexhumed 2>&1 | tee -a $PORT_LOG_FILE" | tee -a $PORT_LOG_FILE
LD_LIBRARY_PATH=./lib:$LD_LIBRARY_PATH SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" ./pcexhumed 2>&1 | tee -a $PORT_LOG_FILE

$ESUDO kill -9 $(pidof oga_controls)
$ESUDO systemctl restart $oga_events &
pgrep -f pcexhumed | $ESUDO xargs kill -9

unset LD_LIBRARY_PATH
unset SDL_GAMECONTROLLERCONFIG
unset SDL_GAMECONTROLLERCONFIG_FILE

printf "\n\nExiting Exhumed\n\n" | tee -a $PORT_LOG_FILE
printf "\033c" >> /dev/tty1
