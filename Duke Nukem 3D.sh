#!/bin/bash

PORT_LOG_FILE="/roms/logs/rednukem-dn3d-atomic.log"

echo "DUKE NUKEM 3D - Rednukem: " | tee $PORT_LOG_FILE

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

GAMEDIR=/$directory/ports/rednukem-dn3d-atomic

# if [[ ! -e $GAMEDIR/conf/rednukem/rednukem.cfg ]]; then
  if   [[ $LOWRES == 'Y' && $ANALOGSTICKS == '1' ]]; then
    mv -f $GAMEDIR/conf/rednukem/rednukem.cfg.480 $GAMEDIR/conf/rednukem/rednukem.cfg
    rm -f $GAMEDIR/conf/rednukem/rednukem.cfg.640
    rm -f $GAMEDIR/conf/rednukem/rednukem.cfg.480.2analogs
    rm -f $GAMEDIR/conf/rednukem/rednukem.cfg.640.2analogs
  elif [[ $LOWRES == 'Y' && $ANALOGSTICKS == '2' ]]; then
    mv -f $GAMEDIR/conf/rednukem/rednukem.cfg.480.2analogs $GAMEDIR/conf/rednukem/rednukem.cfg
    rm -f $GAMEDIR/conf/rednukem/rednukem.cfg.640
    rm -f $GAMEDIR/conf/rednukem/rednukem.cfg.480
    rm -f $GAMEDIR/conf/rednukem/rednukem.cfg.640.2analogs
  elif [[ $LOWRES == 'N' && $ANALOGSTICKS == '1' ]]; then
    mv -f $GAMEDIR/conf/rednukem/rednukem.cfg.640 $GAMEDIR/conf/rednukem/rednukem.cfg
    rm -f $GAMEDIR/conf/rednukem/rednukem.cfg.480
    rm -f $GAMEDIR/conf/rednukem/rednukem.cfg.480.2analogs
    rm -f $GAMEDIR/conf/rednukem/rednukem.cfg.640.2analogs
  elif [[ $LOWRES == 'N' && $ANALOGSTICKS == '2' ]]; then
    mv -f $GAMEDIR/conf/rednukem/rednukem.cfg.640.2analogs $GAMEDIR/conf/rednukem/rednukem.cfg
    rm -f $GAMEDIR/conf/rednukem/rednukem.cfg.480
    rm -f $GAMEDIR/conf/rednukem/rednukem.cfg.480.2analogs
    rm -f $GAMEDIR/conf/rednukem/rednukem.cfg.640
  fi
# fi

$ESUDO rm -rf ~/.config/rednukem
$ESUDO ln -s $GAMEDIR/conf/rednukem ~/.config/
cd $GAMEDIR

$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput

echo "GPTOKEYB command: $GPTOKEYB \"rednukem\" &" | tee -a $PORT_LOG_FILE
$GPTOKEYB "rednukem" &
echo "Launch command: LD_LIBRARY_PATH=./lib:$LD_LIBRARY_PATH SDL_GAMECONTROLLERCONFIG=\"$sdl_controllerconfig\" ./rednukem -game_dir $GAMEDIR/gamedata 2>&1 | tee -a $PORT_LOG_FILE" | tee -a $PORT_LOG_FILE
LD_LIBRARY_PATH=./lib:$LD_LIBRARY_PATH SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" ./rednukem -game_dir $GAMEDIR/gamedata 2>&1 | tee -a $PORT_LOG_FILE

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart $oga_events &

unset LD_LIBRARY_PATH
unset SDL_GAMECONTROLLERCONFIG
unset SDL_GAMECONTROLLERCONFIG_FILE

printf "\n\nExiting DUKE NUKEM 3D - Rednukem\n\n" | tee -a $PORT_LOG_FILE
printf "\033c" >> /dev/tty1
