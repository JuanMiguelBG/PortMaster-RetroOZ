#!/bin/bash

PORT_LOG_FILE="/roms/logs/fheroes2.log"

echo "Heroes of Might & Magic II - The Succession Wars: " | tee $PORT_LOG_FILE

DATAFILE="h2demo.zip"
DATA="https://archive.org/download/HeroesofMightandMagicIITheSuccessionWars_1020/${DATAFILE}"
PORTNAME="Free Heroes of Might and Magic II"

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

CONFIGFOLDER=/$directory/ports/fheroes2

cd "${CONFIGFOLDER}"

if [ ! -e "${CONFIGFOLDER}/data/HEROES2.AGG" ]; then
  $ESUDO chmod 666 /dev/tty0
  clear > /dev/tty0
  cat /etc/motd > /dev/tty0
  echo "Downloading ${PORTNAME} data, please wait..." > /dev/tty0
  wget "${DATA}" -q --show-progress > /dev/tty0 2>&1
  echo "Installing ${PORTNAME} data, please wait..." > /dev/tty0
  unzip -o "${DATAFILE}" -d "${CONFIGFOLDER}/zip" > /dev/tty0
  mv ${CONFIGFOLDER}/zip/DATA/* "${CONFIGFOLDER}/data/" > /dev/tty0 2>&1
  mv ${CONFIGFOLDER}/zip/MAPS/* "${CONFIGFOLDER}/maps/" > /dev/tty0 2>&1
  rm "${DATAFILE}" > /dev/tty0 2>&1
  rm -rf "${CONFIGFOLDER}/zip" > /dev/tty0 2>&1
  echo "Starting ${PORTNAME} for the first time, please wait..." > /dev/tty0
fi

$ESUDO rm -rf ~/.config/fheroes2
ln -sfv /${CONFIGFOLDER}/conf/fheroes2/ ~/.config/
$ESUDO rm -rf ~/.local/share/fheroes2
ln -sfv /${CONFIGFOLDER}/save/fheroes2/ ~/.local/share/

$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput

gptokeyb_params=""
if [ "$is_RetroOZ" -eq 1 ]; then
  gptokeyb_params="$param_device -ccm \"$sdl_controllerconfig\""
  echo "gptokeyb_params: $gptokeyb_params" | tee -a $PORT_LOG_FILE
fi

echo "GPTOKEYB command: $GPTOKEYB \"fheroes2\" $gptokeyb_params 2>&1 | tee -a $PORT_LOG_FILE &" | tee -a $PORT_LOG_FILE
$GPTOKEYB "fheroes2" $gptokeyb_params 2>&1 | tee -a $PORT_LOG_FILE &
echo "Launch command: SDL_GAMECONTROLLERCONFIG=\"$sdl_controllerconfig\" ./fheroes2 2>&1 | tee -a $PORT_LOG_FILE" | tee -a $PORT_LOG_FILE
SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" ./fheroes2 2>&1 | tee -a $PORT_LOG_FILE

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart $oga_events &

unset LD_LIBRARY_PATH
unset SDL_GAMECONTROLLERCONFIG
unset SDL_GAMECONTROLLERCONFIG_FILE

printf "\n\nExiting Heroes of Might & Magic II - The Succession Wars\n\n" | tee -a $PORT_LOG_FILE
printf "\033c" >> /dev/tty1
