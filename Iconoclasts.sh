#!/bin/bash

PORT_LOG_FILE="/roms/logs/iconoclasts.log"

echo "Iconoclasts: " | tee $PORT_LOG_FILE

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
elif [ -d "/roms/ports" ]; then
  controlfolder="/roms/ports/PortMaster"
else
  controlfolder="/storage/roms/ports/PortMaster"
fi

echo "PortMaster folder: $controlfolder" | tee -a $PORT_LOG_FILE

source $controlfolder/control.txt >> $PORT_LOG_FILE 2>&1

get_controls >> $PORT_LOG_FILE 2>&1

GAMEDIR="/$directory/ports/iconoclasts"

cd $GAMEDIR/gamedata

export CHOWDREN_FPS=30
export LIBGL_FB_TEX_SCALE=0.5
export LIBGL_SKIPTEXCOPIES=1
export LIBGL_ES=2
export LIBGL_GL=21
export LIBGL_FB=4
export BOX86_LOG=1
export BOX86_ALLOWMISSINGLIBS=1
export BOX86_DLSYM_ERROR=1
export SDL_DYNAMIC_API=libSDL2-2.0.so.0
export BOX86_LD_PRELOAD=$GAMEDIR/libIconoclasts.so
export SDL_VIDEO_GL_DRIVER=$GAMEDIR/box86/native/libGL.so.1
export SDL_VIDEO_EGL_DRIVER=$GAMEDIR/box86/native/libEGL.so.1
export BOX86_DYNAREC=1
export BOX86_FORCE_ES=31
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# load user settings
source $GAMEDIR/settings.txt

$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput

if [ ! -f 'bin32/Chowdren' ]; then
	# No game found, check for installers...
	for installer in iconoclasts_*.sh; do break; done;
	if [[ -z "$installer" ]] || [[ "$installer" == "iconoclasts_*.sh" ]]; then
		echo "No data, no installer... nothing to do :("
		printf "\033c" > /dev/tty1
		exit -1
	fi

	echo "Installing from $installer..." > /dev/tty1

	# extract the installer, but make sure we got the Chowdren binary present!
	python3 ../extract.py "$installer" "data/noarch/game/bin32/Chowdren" > /dev/tty1
	if [ $? != 0 ]; then
		echo "Install failed..." > /dev/tty1
		wait 5
		printf "\033c" > /dev/tty1
		exit -1
	fi
fi

gptokeyb_params=""
if [ "$is_RetroOZ" -eq 1 ]; then
  export LD_LIBRARY_PATH=$GAMEDIR/box86/lib:/usr/lib32:$GAMEDIR/box86/native
  export BOX86_LD_LIBRARY_PATH=$GAMEDIR/box86/lib:$GAMEDIR/box86/native:/usr/lib32/:./:lib/:lib32/:x86/
else
  export LD_LIBRARY_PATH=$GAMEDIR/box86/native:/usr/lib/arm-linux-gnueabihf/:/usr/lib32:/usr/config/emuelec/lib32
  export BOX86_LD_LIBRARY_PATH=$GAMEDIR/box86/lib:/usr/lib/arm-linux-gnueabihf/:./:lib/:lib/bin32/:x86/
fi

rm -f ./gamecontrollerdb.txt
cp -f $controlfolder/gamecontrollerdb.txt .

echo "GPTOKEYB command: $GPTOKEYB \"box86\" -c \"$GAMEDIR/iconoclasts.gptk\" $gptokeyb_params 2>&1 | tee -a $PORT_LOG_FILE &" | tee -a $PORT_LOG_FILE
$GPTOKEYB "box86" -c "$GAMEDIR/iconoclasts.gptk" $gptokeyb_params 2>&1 | tee -a $PORT_LOG_FILE &
echo "Loading, please wait... (might take a while!)" > /dev/tty1
echo "Launch command: $GAMEDIR/box86/box86 bin32/Chowdren 2>&1 | tee -a $PORT_LOG_FILE" | tee -a $PORT_LOG_FILE
$GAMEDIR/box86/box86 bin32/Chowdren 2>&1 | tee -a $PORT_LOG_FILE

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart $oga_events &

unset CHOWDREN_FPS
unset LIBGL_FB_TEX_SCALE
unset LIBGL_SKIPTEXCOPIES
unset LIBGL_ES
unset LIBGL_GL
unset LIBGL_FB
unset BOX86_LOG
unset BOX86_ALLOWMISSINGLIBS
unset BOX86_DLSYM_ERROR
unset SDL_DYNAMIC_API
unset BOX86_LD_PRELOAD
unset SDL_VIDEO_GL_DRIVER
unset SDL_VIDEO_EGL_DRIVER
unset BOX86_LD_LIBRARY_PATH
unset BOX86_DYNAREC
unset BOX86_FORCE_ES
unset LD_LIBRARY_PATH
unset SDL_GAMECONTROLLERCONFIG
unset SDL_GAMECONTROLLERCONFIG_FILE

printf "\n\nExiting Iconoclasts\n\n" | tee -a $PORT_LOG_FILE
printf "\033c" >> /dev/tty1
