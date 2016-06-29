#!/bin/bash

# AUTO SSH - Auto Login SSH Server (expect-based)
#
# @category Main
# @package  AutoSSH
# @author   Feei <kissingworld@163.com>
# @link     https://github.com/ooppwwqq0/myautossh
# @install
#
# $ git clone https://github.com/ooppwwqq0/myautossh.git
# $ sudo cp myautossh/myautossh /usr/local/bin/a
# $ echo 'server name|192.168.1.1|root|password|22|1' > ~/.ssh/autosshrc
#
# @usage
# $ a   // List Server and choose Num to login Server
# $ a 1 // Login Num n Server
# $ a ! // Login last login Server
# $ a x ip // Login the ip'Server, if the ip recode not exist ,auto add ip recode to your list
# $ a d ip // Delete the ip recode


# custom config
My_user="wangping"
My_pass=""
My_port="22"
# custon config

CHOOSE=$1
CHOOSE_IP=$2
SSH_DIR="$(echo ~/.ssh)"
SSH_CONFIG="${SSH_DIR}/autosshrc"
AUTO_SSH_CONFIG=$(cat ${SSH_CONFIG})
FILE='/tmp/.login.sh'
BACK_DIR="$(echo ~/.sshkeybak)"


function CONFIG() {
    if [ ! -d ${SSH_DIR} ]; then
        mkdir -p ${SSH_DIR}
        chmod 600 ${SSH_DIR}
    fi
    if [ ! -d "${BACK_DIR}" ]; then
        mkdir -p ${BACK_DIR}
    fi
    if [ ! -f ${SSH_CONFIG} ]; then
        echo "server name|192.168.1.1|${My_user}|${My_pass}|${My_port}|1" > ${SSH_CONFIG}
    fi
    cp ${SSH_DIR}/* ${BACK_DIR}/
}

function LISTS() {
    BORDER_LINE="\033[1;31m############################################################ \033[0m"
    echo -e $BORDER_LINE
    echo -e "\033[1;31m#                     [AUTO SSH]                           # \033[0m"
    echo -e "\033[1;31m#                                                          # \033[0m"
    echo -e "\033[1;31m#                                                          # \033[0m"
    i=0;

    if [ "$AUTO_SSH_CONFIG" == "" ]; then
        echo -e "\033[1;31m#            Config(~/.ssh/autosshrc) Not Found            # \033[0m";
        echo -e "\033[1;31m#                                                          # \033[0m"
        echo -e "\033[1;31m#                                                          # \033[0m"
        echo -e $BORDER_LINE
    else
        for server in $AUTO_SSH_CONFIG; do
            i=$(expr $i + 1)
            SERVER=$(echo $server | awk -F\| '{ print $1 }')
            IP=$(echo $server | awk -F\| '{ print $2 }')
            NAME=$(echo $server | awk -F\| '{ print $3 }')
            LINE="\033[1;31m#"\ [$i]\ $SERVER\ -\ $IP':'$NAME
            MAX_LINE_LENGTH=$(expr ${#BORDER_LINE})
            CURRENT_LINE_LENGTH=$(expr "${#LINE}")
            DIS_LINE_LENGTH=$(expr $MAX_LINE_LENGTH - $CURRENT_LINE_LENGTH - 9)
            echo -e $LINE"\c"
            for n in $(seq $DIS_LINE_LENGTH);
            do
                echo -e " \c"
            done
            echo -e "# \033[0m"
        done
        echo -e "\033[1;31m#                                                          # \033[0m"
        echo -e "\033[1;31m#                                                          # \033[0m"
        echo -e $BORDER_LINE
    fi
}

function SSHD() {
    i=0
    for server in $AUTO_SSH_CONFIG; do
        i=$(expr $i + 1)
        if [ $i -eq "$no" ] ; then
            IP=$(echo $server | awk -F\| '{ print $2 }')
            NAME=$(echo $server | awk -F\| '{ print $3 }')
            PASS=$(echo $server | awk -F\| '{ print $4 }')
            PORT=$(echo $server | awk -F\| '{ print $5 }')
            ISBASTION=$(echo $server | awk -F\| '{ print $6 }')
            if [ "$PORT" == "" ]; then
                PORT=${My_port}
            fi
            echo '' > $FILE
            if [ "$PASS" == "" ]; then
                echo "#!/bin/bash" > $FILE
                echo "ssh -p$PORT "$NAME@$IP >> $FILE
            else
                ls ${SSH_DIR}/$IP* &> /dev/null && rm -f ${SSH_DIR}/$IP*
                echo '#!/usr/bin/expect -f' > $FILE
                echo 'set timeout 30' >> $FILE
                echo "spawn ssh -p$PORT -l "$NAME $IP >> $FILE
                echo 'expect "password:"' >> $FILE
                echo 'send   '$PASS"\r" >> $FILE
                if [ "$2" == 'sudo' ]; then
                    echo 'expect "@"' >> $FILE
                    echo 'send   "sudo su\r"' >> $FILE
                    echo 'expect "password for"' >> $FILE
                    echo 'send   '$PASS"\r" >> $FILE
                else
                    if [ "$ISBASTION" == 1 ] && [ "$2" != "" ]; then
                        echo 'expect "IP>:"' >> $FILE
                        echo 'send   '$2"\r" >> $FILE
                        echo 'expect "password:"' >> $FILE
                        echo 'send   '$PASS"\r" >> $FILE
                        if [ "$3" == 'sudo' ]; then
                            echo 'expect "@"' >> $FILE
                            echo 'send   "sudo su\r"' >> $FILE
                            echo 'expect "password for"' >> $FILE
                            echo 'send   '$PASS"\r" >> $FILE
                        fi
                    fi
                fi
                echo 'interact' >> $FILE
            fi
            chmod a+x $FILE
            $FILE
            break;
        fi
    done
}

function FIRST() {
    # GET INPUT CHOSEN OR GET PARAM
    if [ "${CHOOSE}" != "" ]; then
        if [ "${CHOOSE}" == "!" ]; then
            IP=$(grep "ssh" $FILE | awk '{print $NF}')
            ls ${SSH_DIR}/$IP* &> /dev/null && rm -f ${SSH_DIR}/$IP*
            clear
            $FILE
            no=0
            exit 0
        fi
        if [ "${CHOOSE}" == "d" ]; then
            if [ "${CHOOSE_IP}" != ""  ]; then
                xip=${CHOOSE_IP}
                if grep "|${xip}|" ${SSH_CONFIG} &> /dev/null; then
                    sed -i "" "/\|${xip}\|/d"  ${SSH_CONFIG}
                fi
                exit 0
            else
                echo "wrong choose"
                exit 0
            fi
        fi
        if [ "${CHOOSE}" == "x" ]; then
            if [ "${CHOOSE_IP}" != ""  ]; then
                xip=${CHOOSE_IP}
                if ! grep "|${xip}|" ${SSH_CONFIG} &> /dev/null; then
                    My_recode="${xip}|${xip}|${My_user}|${My_pass}|${My_port}|1"
                    echo ${My_recode} >> ${SSH_CONFIG}
                fi
                no=$(awk '{print NR,$0}' ${SSH_CONFIG} | grep "|${xip}|" | awk '{print $1}')
                AUTO_SSH_CONFIG=$(cat ${SSH_CONFIG})
            else
                echo "wrong choose"
                exit 0
            fi
        elif [ -z "$(echo ${CHOOSE}| sed 's/[0-9]*//')" ]; then
            no=${CHOOSE}
        else
            echo "wrong choose"
            exit 0
        fi
    else
        clear
        LISTS
        no=0
        until [ $no -gt 0 -a $no -le $i ] 2>/dev/null
        do
            read -p 'Server Number: ' no
            if [ "$no" == "q" ]; then
                exit 0 
            fi
            #echo -e 'Server Number:\c'
        done
    fi
    clear
    SSHD
}

function MAIN() {
    CONFIG
    FIRST
}

MAIN
