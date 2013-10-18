#!/bin/bash

if [[ "$USER" != "root" ]]; then
    echo "please run as: sudo $0"
    exit 1
fi

BASEDIR=$(cd $(dirname $0); pwd)"/.."
service_list=( "spark:0.8.0" "spark:0.7.3" "shark:0.7.0" )

IMAGE_PREFIX=""
#"amplab/"

START=$(date)
echo "starting tests at $START" > tests.log

RESULT=0
FAILED=0

function wait_for_prompt() {
    service=$1
    OUTFILE=$2
    if [[ "$service" == "spark" ]]; then
        tail -n 6 $OUTFILE | grep "^scala> " > /dev/null
        until [[ "$?" == "0" ]]; do
            sleep 1
            tail -n 6 $OUTFILE | grep "^scala> " > /dev/null
        done
    else
        tail -n 6 $OUTFILE | grep "^shark> " > /dev/null
        until [[ "$?" == "0" ]]; do
            sleep 1
            tail -n 6 $OUTFILE | grep "^shark> " > /dev/null
        done
    fi
}

function check_result() {
    service=$1
    outfile=$2

    if [[ "$service" == "spark" ]]; then
        grep "Array(this is a test, more test, one more line)" $outfile > /dev/null
        RESULT="$?"
    elif [[ "$service" == "shark" ]]; then
        grep "^500" $outfile > /dev/null
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
    # shark prints the prompt even though it's not idle
    # so let's sleep a little longer
    if [[ "$service" == "shark" ]]; then
        sleep 15
    fi
    wait_for_prompt $service $OUTFILE

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
