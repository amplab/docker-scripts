#!/bin/bash

if [[ "$USER" != "root" ]]; then
    echo "please run as: sudo $0"
    exit 1
fi

BASEDIR=$(cd $(dirname $0); pwd)"/.."
service_list=("spark:0.9.0" "shark:0.8.0" "spark:0.8.0" "spark:0.7.3" "shark:0.7.0" )

IMAGE_PREFIX=""
#"amplab/"

START=$(date)
echo "starting tests at $START" > tests.log

RESULT=0
FAILED=0

check_screen_session_alive() {
    screen -q -ls > /dev/null
    if (( $? < 10 )); then
        SCREEN_ALIVE=1
    fi 
}

function wait_for_prompt() {
    service=$1
    OUTFILE=$2
    SCREEN_ALIVE=0
    
    if [[ "$service" == "spark" ]]; then
        query_string="scala>\s$"
    else
        query_string="^shark>\s$\|\s\s\s\s\s>\s$"
    fi
    
    tail -n 1 $OUTFILE | tr -d $'\r' | grep "$query_string" > /dev/null
    STOP="$?"
    until [[ "$STOP" == "0" ]]; do
        sleep 1
        check_screen_session_alive
        if [[ "$SCREEN_ALIVE" == "0" ]]; then
            sudo screen -S tmpshell -p 0 -X stuff $'\n'
            tail -n 1 $OUTFILE | tr -d $'\r' | grep "$query_string" > /dev/null
            STOP="$?"
        else
            break
        fi
    done
}

function check_result() {
    service=$1
    outfile=$2

    if [[ "$service" == "spark" ]]; then
        grep "Array(this is a test, more test, one more line)" $outfile > /dev/null
        RESULT="$?"
    elif [[ "$service" == "shark" ]]; then
        cat $outfile | tr -d $'\r' | grep "^500$" > /dev/null
        RESULT="$?"
    fi
}

# NOTE: the order matters but this is the right one
for i in ${service_list[@]}; do
    service=$(echo $i | awk -F ":" '{print $1}')
    version=$(echo $i | awk -F ":" '{print $2}')
    dirname=${service}-${version}
    LOGFILE=${BASEDIR}/test/${dirname}.log
    OUTFILE=${BASEDIR}/test/${dirname}.out
    rm -f "$LOGFILE" "$OUTFILE"
    START=$(date)
    echo "starting tests at $START" > $LOGFILE
    $BASEDIR/deploy/deploy.sh -i ${IMAGE_PREFIX}${i} 1>>$LOGFILE 2>&1
    NAMESERVER_IP=$(grep NAMESERVER_IP ${dirname}.log | awk '{print $2}')
    MASTER_IP=$(grep MASTER_IP ${dirname}.log | awk '{print $2}')

    # we need this to set screen's output logfile
    cat << EOF >/tmp/screenrc
logfile $OUTFILE
EOF
    cat > cmd.sh <<EOF
#!/bin/bash
sudo docker run -i -dns $NAMESERVER_IP ${service}-shell:${version} $MASTER_IP
EOF
    sleep 3
    chmod u+x cmd.sh
    sudo screen -c /tmp/screenrc -L -S tmpshell -d -m -s ./cmd.sh

    sleep 5
    wait_for_prompt $service $OUTFILE

    TESTDATA=$(cat ${BASEDIR}/${dirname}/${service}-shell/files/test.${service})
    sudo screen -S tmpshell -p 0 -X stuff "$TESTDATA"
    sudo screen -S tmpshell -p 0 -X stuff $'\n'

    sleep 10
    wait_for_prompt $service $OUTFILE
    # the shell session should be in shoutdown already since we
    # always include an exit command; however, because of timing
    # issues it may take a while and conflict with the following
    # test. So let's wait one second and then kill the screen
    # session from the outside
    sleep 1
    sudo screen -S tmpshell -p 0 -X quit > /dev/null 2>&1

    $BASEDIR/deploy/kill_all.sh $service 1>> $LOGFILE 2>&1
    $BASEDIR/deploy/kill_all.sh nameserver 1>> $LOGFILE 2>&1
    check_result "$service" "$OUTFILE"
    echo "RESULT: $RESULT" >> $LOGFILE
    END=$(date)
    echo "ending tests at $END" >> $LOGFILE
    let "FAILED=FAILED+RESULT"
done

echo "FAILED: $FAILED"

if [[ "$FAILED" == "0" ]]; then
    exit 0
else
    exit 1
fi
