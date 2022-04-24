#!/bin/bash

PORT_LOG_FILE="/roms/logs/abuse.log"

echo "Bermuda Syndrome Port: " | tee $PORT_LOG_FILE

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

GAMEDIR="/$directory/ports/Abuse"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$GAMEDIR/libs"

GPTOKEYB_CONFIG="abuse.gptk"

if [[ -e "/dev/input/by-path/platform-ff300000.usb-usb-0:1.2:1.0-event-joystick" ]]; then
  GPTOKEYB_CONFIG="abuse.gptk.rg351p.rightanalog"
  sed -i '/ctr_left_stick_aim\=1/s//ctr_left_stick_aim\=0/' $GAMEDIR/user/config.txt
elif [[ -e "/dev/input/by-path/platform-odroidgo2-joypad-event-joystick" ]]; then
    GPTOKEYB_CONFIG="abuse.gptk.leftanalog" # it's also necessary to modify ./user/config.txt ctr_left_stick_aim=1 to enable left stick aiming
  sed -i '/ctr_left_stick_aim\=0/s//ctr_left_stick_aim\=1/' $GAMEDIR/user/config.txt
elif [[ -e "/dev/input/by-path/platform-odroidgo3-joypad-event-joystick" ]]; then
  sed -i '/ctr_left_stick_aim\=1/s//ctr_left_stick_aim\=0/' $GAMEDIR/user/config.txt
else
  sed -i '/ctr_left_stick_aim\=1/s//ctr_left_stick_aim\=0/' $GAMEDIR/user/config.txt
fi

if [ -f "/boot/rk3326-rg351v-linux.dtb" ] || [ $(cat "/storage/.config/.OS_ARCH") == "RG351V" ]; then
  GPTOKEYB_CONFIG="abuse.gptk.rg351p.leftanalog"
  sed -i '/ctr_left_stick_aim\=0/s//ctr_left_stick_aim\=1/' $GAMEDIR/user/config.txt
fi

cd $GAMEDIR

$ESUDO rm -rf ~/.abuse
ln -sfv /$GAMEDIR/conf/.abuse ~/

$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput

echo "GPTOKEYB command: $GPTOKEYB \"abuse\" -c \"$GAMEDIR/$GPTOKEYB_CONFIG\" 2>&1 | tee -a $PORT_LOG_FILE &" | tee -a $PORT_LOG_FILE
$GPTOKEYB "abuse" -c "$GAMEDIR/$GPTOKEYB_CONFIG" 2>&1 | tee -a $PORT_LOG_FILE &
echo "Launch command: SDL_GAMECONTROLLERCONFIG=\"$sdl_controllerconfig\" ./abuse 2>&1 | tee -a $PORT_LOG_FILE" | tee -a $PORT_LOG_FILE
SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" ./abuse 2>&1 | tee -a $PORT_LOG_FILE

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart $oga_events &

unset LD_LIBRARY_PATH
unset SDL_GAMECONTROLLERCONFIG
unset SDL_GAMECONTROLLERCONFIG_FILE

printf "\n\nExiting Bermuda Syndrome Port\n\n" | tee -a $PORT_LOG_FILE
printf "\033c" >> /dev/tty1
