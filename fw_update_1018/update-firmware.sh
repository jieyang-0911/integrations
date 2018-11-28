#!/bin/bash
#sudo -k
#mima="caros"
#echo $mima | sudo -S echo " " &> /dev/null
videohome=/home/caros/fw_update_1018
cd /dev
ls video* >/$videohome/videolist
for i in $(ls /dev/video*)
do 
$HOME/plat-sw/bin/adv_cam_tool -d $i -r reg=8002 > /$videohome/reg8002 2>/dev/null
$HOME/plat-sw/bin/adv_cam_tool -d $i -r reg=8000 > /$videohome/reg8000 2>/dev/null
video8002=`cat $videohome/reg8002 | grep "Camera register read" |awk -F "=" '{print $2}' |awk -F "x" '{print $2}'`
echo $i reg8002=${video8002}
video8000=`cat $videohome/reg8000 | grep "Camera register read" |awk -F "=" '{print $2}' |awk -F "x" '{print $2}'`
echo "           " reg8000=${video8000}
	if [[ $video8002 -eq 2002 ]]
	then
		echo "Firmware truly is the latest "
		#$HOME/plat-sw/bin/adv_cam_tool -d $i -f $videohome/
	elif [[ $video8002 -eq 2142 ]]
	then 
		echo "Firmware wissen is the latest"
        elif  [[ $video8002 -eq 2001 ]]
        then
                $HOME/plat-sw/bin/adv_cam_tool -d $i -f $videohome/truly_wb_1018_${video8000}_2002.bin
        elif  [[ $video8002 -eq 2141 ]]
        then
                   
                $HOME/plat-sw/bin/adv_cam_tool -d $i -f $videohome/wissen_wb_1018_${video8000}_2142.bin
	else
		exit 0
	fi

done
#sudo reboot