#!/bin/bash

PORT_LOG_FILE="/roms/logs/freedomplanet.log"

echo "Freedom Planet: " | tee $PORT_LOG_FILE

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

$ESUDO chmod 666 /dev/tty1

GAMEDIR="/$directory/ports/freedomplanet"

cd $GAMEDIR/gamedata

export LIBGL_ES=2
export LIBGL_GL=21
export LIBGL_FB=4
export BOX86_ALLOWMISSINGLIBS=1
export BOX86_DLSYM_ERROR=1
export BOX86_LOG=1
export SDL_DYNAMIC_API=libSDL2-2.0.so.0
export BOX86_DYNAREC=1
export BOX86_FORCE_ES=31

if [ ! -f "$GAMEDIR/gamedata/freedomplanet/bin32/oga_controls" ]; then
  cp -f $GAMEDIR/oga_controls* .
  cp -f $controlfolder/gamecontrollerdb.txt .
fi

oc_path="$controlfolder"
if [ "$is_RetroOZ" -eq 1 ]; then
  oc_path="/opt/.retrooz/bin"
  export LD_LIBRARY_PATH=$GAMEDIR/box86/lib:/usr/lib32:$GAMEDIR/box86/native
  export BOX86_LD_LIBRARY_PATH=$GAMEDIR/box86/lib:$GAMEDIR/box86/native:/usr/lib32/:./:lib/:lib32/:x86/
  export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
else
  export LD_LIBRARY_PATH=$GAMEDIR/box86/lib:/usr/lib/arm-linux-gnueabihf/:/usr/lib32
  export BOX86_LD_LIBRARY_PATH=$GAMEDIR/box86/lib:/usr/lib/arm-linux-gnueabihf/:./:lib/:libbin32/:x86/
fi

echo "OGA_CONTROLS command: $ESUDO $oc_path/oga_controls box86 $param_device 2>&1 | tee -a $PORT_LOG_FILE &" | tee -a $PORT_LOG_FILE
$ESUDO $oc_path/oga_controls box86 $param_device 2>&1 | tee -a $PORT_LOG_FILE &
echo "Launch command: $GAMEDIR/box86/box86 bin32/Chowdren 2>&1 | tee -a $PORT_LOG_FILE" | tee -a $PORT_LOG_FILE
$GAMEDIR/box86/box86 bin32/Chowdren 2>&1 | tee -a $PORT_LOG_FILE

$ESUDO kill -9 $(pidof oga_controls)
$ESUDO systemctl restart $oga_events &

unset LIBGL_ES
unset LIBGL_GL
unset LIBGL_FB
unset BOX86_ALLOWMISSINGLIBS
unset BOX86_DLSYM_ERROR
unset BOX86_LOG
unset SDL_DYNAMIC_API
unset LD_LIBRARY_PATH
unset BOX86_LD_LIBRARY_PATH
unset BOX86_DYNAREC
unset BOX86_FORCE_ES
unset LD_LIBRARY_PATH
unset SDL_GAMECONTROLLERCONFIG
unset SDL_GAMECONTROLLERCONFIG_FILE

printf "\n\nExiting Freedom Planet\n\n" | tee -a $PORT_LOG_FILE
printf "\033c" >> /dev/tty1