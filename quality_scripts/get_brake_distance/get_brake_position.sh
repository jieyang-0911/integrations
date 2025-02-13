#/bin/bash
SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

CARSTATUS_FILE=carstatus
BRAKE_POSITION=brake_position
BRAKE_POSITION1=brake_position1
OBSTACLES_FILE=obstacles
OBSTACLES_FILE2=obstacles2
OBSTACLES_POSITION=obstacles_position
OBSTACLES_POSITION1=obstacles_position1
cyber_channel echo /pnc/carstatus > ${SCRIPT_ROOT}/carstatus &
pid1=$!
cyber_channel echo /perception/obstacles > ${SCRIPT_ROOT}/obstacles &
pid2=$!
sleep 30
kill -SIGSTOP $pid1 && kill -SIGSTOP $pid2
if [ ! -s carstatus ]
then
    echo "Error: there is no data in /pnc/carstatus,please check the channel"
    exit 1
fi
if [ ! -s obstacles ]
then
    echo "Error: there is no data in /perception/obstacles,please check the channel"
    exit 1
fi
cp obstacles obstacles1
cp carstatus carstatus1


#sed -i '/pose {/,+27d' ${CARSTATUS_FILE}
#sed -i '/steering_percentage/,+38d' ${CARSTATUS_FILE}
#grep -A 3 "brake_percentage:" ${CARSTATUS_FILE} >${BRAKE_POSITION}
#sed -i '/--/d' ${BRAKE_POSITION}
#cat ${BRAKE_POSITION} | awk -F ":" '{print $2}' | awk '{print $1}' >${BRAKE_POSITION1}




grep -B 14 "acc: -" carstatus >carstatus2
sed -i '/world2vehicle/,+11d' carstatus2
sed -i '/}/d' carstatus2
cat carstatus2 | awk -F ":" '{print $2}' | awk '{print $1}' >${BRAKE_POSITION1}
sed -i 'N;N;N;s/\n/ /g' ${BRAKE_POSITION1}
#get obstacles_car position
sed -i '/polygon_point/,+4d' ${OBSTACLES_FILE}
sed -i '/position_covariance:/d' ${OBSTACLES_FILE}
sed -i '/velocity_covariance:/d' ${OBSTACLES_FILE}
sed -i '/acceleration_covariance:/d' ${OBSTACLES_FILE}
sed -i '/anchor_point {/,+4d' ${OBSTACLES_FILE}
sed -i '/bbox2d {/,+5d' ${OBSTACLES_FILE}
sed -i '/light_status {/,+7d' ${OBSTACLES_FILE}
sed -i '/height_above_ground:/d' ${OBSTACLES_FILE}
sed -i '/brake_light:/d' ${OBSTACLES_FILE}
sed -i '/acceleration {/,+4d' ${OBSTACLES_FILE}
sed -i '/box {/,+5d' ${OBSTACLES_FILE}
sed -i '/measurements {/,+18d' ${OBSTACLES_FILE}
#grep -B 17 "type: VEHICLE" ${OBSTACLES_FILE} >${OBSTACLES_FILE2}
grep -B 19 "sub_type: TRUCK" ${OBSTACLES_FILE} >${OBSTACLES_FILE2}
grep -A 3 "position {" ${OBSTACLES_FILE2} >${OBSTACLES_POSITION}
sed -i '/--/d' ${OBSTACLES_POSITION}
sed -i '/position {/d' ${OBSTACLES_POSITION}
cat ${OBSTACLES_POSITION} | awk -F ":" '{print $2}' | awk '{print $1}' >${OBSTACLES_POSITION1}
sed -i 'N;N;s/\n/ /g' ${OBSTACLES_POSITION1}
python get_brake_distance.py
