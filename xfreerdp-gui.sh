  #!/bin/bash


  #####################################################################################
  #### FEDERAL UNIVERSITY OF SANTA CATARINA -- UFSC
  #### Prof. Wyllian Bezerra da Silva


  #####################################################################################
  #### Dependencies: freerdp-x11 gawk x11-utils yad zenity

  string=""
  if ! hash xfreerdp 2>/dev/null; then
      string="\nfreerdp-x11"
  fi
  if ! hash awk 2>/dev/null; then
      string="\ngawk" 
  fi
  if ! hash xdpyinfo 2>/dev/null; then
      string="${string}\nx11-utils"
  fi
  if ! hash yad 2>/dev/null; then
      string="${string}\nyad"
  fi
  if [ -n "$string" ]; then
    if hash amixer 2>/dev/null; then
      amixer set Master 80% > /dev/null 2>&1; 
    else
      pactl set-sink-volume 0 80%
    fi
    if hash speaker-test 2>/dev/null; then
      ((speaker-test -t sine -f 880 > /dev/null 2>&1)& pid=$!; sleep 0.2s; kill -9 $pid) > /dev/null 2>&1 
    else 
      if hash play 2>/dev/null; then
        play -n synth 0.1 sin 880 > /dev/null 2>&1 
      else
        cat /dev/urandom | tr -dc '0-9' | fold -w 32 | sed 60q | aplay -r 9000 > /dev/null 2>&1
      fi
    fi
    (zenity --info --title="Requirements" --width=300 --text="You need to install this(ese) package(s):

    <b>$string</b>

    ") > /dev/null 2>&1 
    exit
  fi


  #####################################################################################
  #### Get informations
  dim=$(xdpyinfo | grep dimensions | sed -r 's/^[^0-9]*([0-9]+x[0-9]+).*$/\1/')
  wxh1=$(echo $dim | sed -r 's/x.*//')"x"$(echo $dim | sed -r 's/.*x//')
  wxh2=$(($(echo $dim | sed -r 's/x.*//')-70))"x"$(($(echo $dim | sed -r 's/.*x//')-70))

  while true
  do
    IP=$(hostname -I)
    LOGIN=$(cat /home/tonk/login)
    PASSWORD=
    DOMAIN=
    SERVER=
    PORT=
    RESOLUTION=
    GEOMETRY=
    CERTIGNORE=
    BPP=  
    NAMEDIR=
    DIR=
    OPTIONS=  
      varFull="TRUE"
    varLog=
    [ -n "$USER" ] && until xdotool search "xfreerdp-gui" windowactivate key Right Tab 2>/dev/null ; do sleep 0.03; done &
      FORMULARY=$(yad --center --width=380 \
          --window-icon="gtk-execute" --image="debian-logo" --item-separator=","                                              \
          --title "Подключение...Мой IP:  $IP"                                                                                              \
          --form                                                                                                              \
          --field="Имя пользователя " $LOGIN ""                                                                            \
          --field="Пароль ":H $PASSWORD ""                                                                                  \
          --button="Выключить":1 --button="Войти":0)
      [ $? != 0 ] && poweroff
      LOGIN=$(echo $FORMULARY      | awk -F '|' '{ print $1 }')
      PASSWORD=$(echo $FORMULARY   | awk -F '|' '{ print $2 }')
      if [ "$varFull" = "TRUE" ]; then
          GEOMETRY="/f"
      else
          GEOMETRY=""
      fi  
      varLog=$(echo $FORMULARY | awk -F '|' '{ print $12 }')

#      echo $LOGIN > /home/tonk/login

      RES=$(xfreerdp                            \
                      /v:terminal4.ed.corp /cert-ignore /u:"$LOGIN" /p:"$PASSWORD" /f -compression +fonts /sound /smartcard +drives /gfx-h264 /multimon /auto-reconnect 2>&1 )
    
      echo $RES | grep -q "Authentication failure" &&                                                  \
      yad --center --image="error" --window-icon="error" --title "Ошибка"              \
      --text="<b>Не возможно соединиться с сервером\!</b>\n\n<i>Проверьте правильность ввода логина/пароля.</i>"         \
        --text-align=center --width=320 --button=gtk-ok --buttons-layout=spread && continue 
      echo $RES | grep -q "ERRCONNECT_LOGON_FAILURE" &&                                                  \
      yad --center --image="error" --window-icon="error" --title "Ошибка"              \
      --text="<b>Не возможно соединиться с сервером\!</b>\n\n<i>Проверьте правильность ввода логина/пароля.</i>"         \
        --text-align=center --width=320 --button=gtk-ok --buttons-layout=spread && continue 
      echo $RES | grep -q "connection failure" &&                                                      \
      yad --center --image="error" --window-icon="error" --title "Connection failure"                  \
      --text="<b>Не возможно соединиться с сервером\!</b>\n\n<i>Возможно сеть не подключена.</i>" \
      --text-align=center --width=320 --button=gtk-ok --buttons-layout=spread && continue
      
      if [ "$varLog" = "TRUE" ]; then
          yad --text "$RES" --title "Log of Events" --width=600 --wrap --no-buttons
      fi
      echo $LOGIN > /home/tonk/login      
###      break
  done


  #####################################################################################
  #### Reference:
  #### Adapted from: https://github.com/FreeRDP/FreeRDP/issues/1358#issuecomment-175075061
