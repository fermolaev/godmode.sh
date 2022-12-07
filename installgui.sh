#!/bin/bash

checkapp() {
echo "Проверка установленных пакетов из списка для рабоыт скрипта"

lstapp="grep free srv1cv83"

dpkg -l 2>/dev/null > lsapp.tmp

for apps in $lstapp
do
  cmd=$(grep "\ $apps\ " lsapp.tmp)
  if [ $? == 0 ]
    then
      echo "$apps установлен"
    else
      echo "$apps НЕ установлен"
  fi
done
rm lsapp.tmp
echo "Если какой-то пакет не установлен, неокторые функции скрипта могут не работать!!!"
echo "  "
}

checkfile() {
echo "Проверка на наличие фапйлов используемых в скрипте" 

lstfile="version devices devices cpuinfo devices 
meminfo srv1cv83"

ls -lR / > lsf.tmp 2>/dev/null

for files in $lstfile
do
  cmd=$(grep "$files" lsf.tmp)
  if [ $? == 0 ]
    then
      echo "$files файл обнаружен"
    else
      echo "$files такого файла НЕТ"
  fi
done
rm lsf.tmp
echo "   "
}

install() {
echo "Усанавливаем скрипт для всех пользователей"

find / -iname 'godmode.sh' -exec cp {} /opt/ \; 2>/dev/null

echo "godmode() {
  /opt/godmode.sh \$1 \$2 \$3
}" >> /etc/bash.bashrc
echo "  "

echo "Выдаем права на работу скрипта"
chmod 777 /opt/godmode.sh
chmod +x /opt/godmode.sh
echo "   "
echo "Установка завершена"
}

HEIGHT=15
WIDTH=60
CHOICE_HEIGHT=4
BACKTITLE="GodMode Install"
TITLE="GodMode"
MENU="Для продолжения выбирите действие:
      При виборе Устанвоить GodMode, будет проведена проверка 
      установленных приложений и наличия файлов"

OPTIONS=(1 "Проверить установленные приложения"
         2 "Проверить наличие файлов"
         3 "Установить GodMode")

CHOICE=$(dialog --clear \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear
case $CHOICE in
        1)  checkapp ;;
        2)  checkfile ;;
        3)  checkapp
            checkfile
            install ;;
esac