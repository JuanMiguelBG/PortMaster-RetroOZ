#!/bin/bash

PORT_LOG_FILE="/roms/logs/hurrican.log"

echo "Hurrican: " | tee $PORT_LOG_FILE

DATA="https://github.com/drfiemost/Hurrican/archive/refs/heads/master.zip"

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

CONFIGFOLDER=$directory/ports/hurrican
DATAFOLDER=$directory/ports/hurrican/data

WGET="wget"

if [ -f "/storage/.config/.OS_ARCH" ]; then
  WGET="/roms/ports/hurrican/wget"
  export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/$CONFIGFOLDER/libs"
fi

$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput

if [ ! -e "/${DATAFOLDER}/levels/levellist.dat" ]; then
  clear > /dev/tty1
  cat /etc/motd > /dev/tty1
  echo "Downloading Hurrican data, please wait..." > /dev/tty1
  rm -rf "/${DATAFOLDER}"
  rm -rf "/${CONFIGFOLDER}/lang"
  $WGET "${DATA}" -q --show-progress > /dev/tty1 2>&1
  echo "Installing Hurrican data, please wait..." > /dev/tty1
  unzip "master.zip" "Hurrican-master/Hurrican/data/*" -d "/${CONFIGFOLDER}"
  unzip "master.zip" "Hurrican-master/Hurrican/lang/*.lng" -d "/${CONFIGFOLDER}"
  mv "/${CONFIGFOLDER}/Hurrican-master/Hurrican/data" "/${CONFIGFOLDER}"
  mv "/${CONFIGFOLDER}/Hurrican-master/Hurrican/lang" "/${CONFIGFOLDER}"
  rm -rf "/${CONFIGFOLDER}/Hurrican-master" > /dev/tty1 2>&1
  rm "master.zip" > /dev/tty1 2>&1
fi

cd "/${CONFIGFOLDER}"

$ESUDO rm -rf ~/.config/hurrican
ln -sfv /${CONFIGFOLDER}/conf/hurrican/ ~/.config/
$ESUDO rm -rf ~/.local/share/hurrican
ln -sfv /${CONFIGFOLDER}/highscores/hurrican/ ~/.local/share/

echo "GPTOKEYB command: $GPTOKEYB \"hurrican\" -c \"./hurrican.gptk\" 2>&1 | tee -a $PORT_LOG_FILE &" | tee -a $PORT_LOG_FILE
$GPTOKEYB "hurrican" -c "./hurrican.gptk" 2>&1 | tee -a $PORT_LOG_FILE &
echo "Launch command: SDL_GAMECONTROLLERCONFIG=\"$sdl_controllerconfig\" ./hurrican --depth 16 2>&1 | tee -a $PORT_LOG_FILE" | tee -a $PORT_LOG_FILE
SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" ./hurrican --depth 16 2>&1 | tee -a $PORT_LOG_FILE

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart $oga_events &

unset LD_LIBRARY_PATH
unset SDL_GAMECONTROLLERCONFIG
unset SDL_GAMECONTROLLERCONFIG_FILE

printf "\n\nExiting Hurrican\n\n" | tee -a $PORT_LOG_FILE
printf "\033c" >> /dev/tty1
