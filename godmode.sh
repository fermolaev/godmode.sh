#!/bin/bash

###############  W  A  R  N  I  N  G #################################
# Файл скрипта godmode, внес новый функционал ---> заполни help      #
# Добавил использование новых утилит или файлов, добавь в инсталятор #
######################################################################

#######################################
# help - помощь по работе скрипта     #
#######################################

help() {
    echo "Использование: godmode [-key/--key][key]"
    echo
    echo "  -p, --proc          |  Работа с виртулаьной файловой системой PROC"
    echo "  godmode -p name     |  Посомтреть информацю об ОС"
    echo "  godmode -p mounts   |  Посомтреть все точки монтирвоания"
    echo "  godmode -p devices     |  Посомтреть информацию о подключенных внешних устросвах"
    echo
    echo "   -c, --cpu          |  Информация о процессоре"
    echo "   godmode -c full    |  Посомтреть полную информацию о процессоре"
    echo "   godmode -c info    |  Краткая информация о процессоре  "
    echo "   godmode -c wtf     |  Cостояниe процессорa, перегружен или все ок"   
    echo   
    echo "   -m, --memory       |  Информация о ОЗУ"
    echo "   godmode -m all     |  Вывевести все данные по ОЗУ"
    echo "   godmode -m free    |  Вывести объем свободной ОЗУ"
    echo "   godmode -m total   |  Вывести сколкьо всего ОЗУ"    
    echo
    echo "   -n, --network      |  Работа с сетью"
    echo "   godmode -n wanip   |  Посомтерть свой внешний IP-адрес"
    echo "   godmode -n 80      |  ПРоверить открыт или закрыт- порт"
    echo
    echo "   -la, --loadaverage |  Информация о загруженности системы"
    echo "   godmode -la        |  Введите загрузку системы зы 1, 5, 15 минут"
    echo  
    echo "   -d, --disks        |  Информация по дискам в системе"
    echo "   godmode -d info    |  Информация о свободном и занятом дисковом простарнстве"
    echo "   godmode -d speed   |  Замер скорости диска"

    echo "   -k, --kill         |  Посомтреть топ процессов потребляющих ресурсы системы"
    echo "   godmode -k  ozy    |  Топ 10 процессов, потребляющих памят"
    echo "   godmode -k  all    |  Топ 10 процессоров с максимальным потреблением ресурсов системы"
    echo
    echo "   -o, --output       |  Логирование работы скрипта"
    echo "   godmode -o         |  Вывести лог рабоыт скрипта"
    echo "   godmode [-key] -o  |  Логтровать выполняемую команду"
    echo
    echo "   godmode [-key] -debug   | Выполнение команды в дебаг режиме, для траблшутинга "
    echo "                               " 
    echo "   -h, --help         |  Вопросы?"
    echo "   godmode -h         |  Вывести данный мануал"
}

#########################
# proc - работа с       # 
# директорией /proc     #
#########################
proc() {
    case "$1" in
      name) cat /proc/version ;;
      mounts) cat /proc/mounts ;;
      devices) grep "Name" /proc/bus/input/devices ;;
      *) help | grep "godmode -p"
         echo "Для полной справки используйте godmode -h" ;;
    esac
}

##############################
# cpu - работа с процессором #
##############################
cpu() {
    case "$1" in
     full) cat /proc/cpuinfo ;;
     info) lscpu | egrep 'Model name|Socket|Thread|NUMA|CPU\(s\)';;
      wtf) 
      a=$(uptime | grep -o 'load average.*' | cut -c 15)
      b=$(nproc)
      if [ $a -lt $b ]
      then
        echo "Все в порядке, спи спокойно"
      else
        echo "Wake up samurai!! Yuor cpu is burn"
      fi ;;
      *)
      help | grep "godmode -c"
      echo "Для полной справки используйте godmode -h" ;;
    esac
}

#############################
# memory - работа с памятью # 
#############################
memory() {
  case $1 in
    all) free -h ;;
    free) cat /proc/meminfo | grep "MemFree" ;;
    total) cat /proc/meminfo | grep "MemTotal" ;;
    *) help | grep "godmode -m"
       echo "Для полной справки используйте godmode -h" ;;
  esac
}

############################
# disks - работа с дисками #
############################
disks() {
  case $1 in
      info) df -h ;;
     speed) dd if=/dev/zero of=testfile bs=4k count=131072 ;;
         *) help | grep "godmode -d"
            echo "Для полной справки используйте godmode -h" ;;
  esac
}

###############################
# loadaverage - вывод средней #  
# нагрузки на систему         #
###############################
loadaverage() {
echo "1 minutes loadavarege = $(uptime | grep -o 'load average.*' | cut -c 15-18)" 
echo "5 minutes loadavarege = $(uptime | grep -o 'load average.*' | cut -c 21-24)" 
echo "15 minutes loadavarege = $(uptime | grep -o 'load average.*' | cut -c 27-30)" 
}

#############################
# kill - отправка сигналов  #
# процессам (простой аналог # 
# утилиты kill)             #
#############################
kill() {
if [ "$1" = "ozy" ]
then 
ps -auxf | sort -nr -k 4 | head -10 | nl
elif [ "$1" = "all" ]
then
ps -auxf | sort -nr -k 3 | head -10 | nl
else
help | grep "godmode -k"
echo "Для полной справки используйте godmode -h"
fi
}

#################################
# 1csrv  - работа с сервером 1с # 
#################################
1csrv() {
echo "Включить\выключить режим дебаг сервера 1С?"
select yn in "On" "Off"; do
  case $yn in
    On) sed -i -e 's/#SRV1CV8_DEBUG=1/SRV1CV8_DEBUG=1/g' /opt/1cv8/x86_64/*.*.*.*/srv1cv83
        systemctl daemon-reload 
        sudo service srv1cv83 restart 2>/dev/null || echo "Сервер 1с не установлен или не запущен"
        exit ;;
   Off) sed -i -e 's/SRV1CV8_DEBUG=1/#SRV1CV8_DEBUG=1/g' /opt/1cv8/x86_64/*.*.*.*/srv1cv83
        systemctl daemon-reload
        sudo service srv1cv83 restart 
        exit ;;
  esac
done
}

############################
# network - работа с сетью #
############################
network() {
if [ "$1" = "wanip" ]
then 
echo "Ваш внешний IP-адрес" 
dig ANY +short @resolver2.opendns.com myip.opendns.com
elif [[ $1 =~ ^[0-9]+$ ]]
then
    if [ -z "$(netstat -tupln | grep $1)" ]
    then
    echo "Порт $1 закрыт"
    else
    echo "Порт $1 открыт"
    fi
else
help | grep "godmode -n"
echo "Что-то пошло не так ((("
echo "Для полной справки используйте godmode -h"
fi
}

################################
# Check parameters \ options   #
################################
while :
do
  # Блок дебага и логирования ----------
  if [ "$2" = "-debug" ] || [ "$3" = "-debug" ] 
  then 
  trap 'echo "# $BASH_COMMAND"' DEBUG 
  elif [ "$2" = "-o" ] || [ "$3" = "-o" ]
  then
  date  >> /tmp/godmode.sh.log
  exec > >(tee -a /tmp/godmode.sh.log)
  fi
  # Конец блока логирвоания ----------
    case "$1" in
      -h | --help)
          help  # показываем хелп
          exit 0 ;;
      -p | --proc)
          proc $2 # работа с директорией /proc
          exit 0 ;;
      -c | --cpu)
          cpu $2 # работа с процессором
          exit 0 ;;
      -m | --memory)
          memory $2 # работа с памятью
          exit 0 ;;
      -n | --network)
          network $2 # работа с сетью
          exit 0 ;;
      -la | --loadaverage)
          loadaverage  # вывод средней нагрузки на систему
          exit 0 ;;
      -k | --kill)
          kill $2 # отправка сигналов процессам
          exit 0 ;;
      -o | --output)
          cat /tmp/godmode.sh.log # просмотр лога
          exit 0 ;;    
      -d | disks )
          disks $2
          exit 0 ;;
      1с) 1csrv
          exit 0 ;;
     --*) echo "Do you whant use full name of key? JUST DO IT!!!"
          help 
          exit 1 ;;
      -*) echo "Xe Xe Boy it's E R O R R"
          help
          exit 1 ;;
      *)  echo "Xe Xe Boy, use any key"
          help
          exit 1 ;;
    esac
done