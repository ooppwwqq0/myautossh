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

CHOOSE_1=$1
CHOOSE_2=$2
CHOOSE_3=$3

FILE="/tmp/.login.sh"
SSH_DIR="$(echo ~/.ssh)"
BACK_DIR="$(echo ~/.sshkeybak)"
SSH_CONFIG="${SSH_DIR}/autosshrc"
KNOWN_CONFIG="$SSH_DIR/known_hosts"
CUSTOM_CONFIG="$SSH_DIR/config"
AUTO_SSH_CONFIG="$(cat ${SSH_CONFIG})"


function CONFIG() {
    if [ ! -d "${SSH_DIR}" ]; then
        mkdir -p ${SSH_DIR}
        chmod 600 ${SSH_DIR}
    fi
    if [ ! -d "${BACK_DIR}" ]; then
        mkdir -p ${BACK_DIR}
    fi
    if [ ! -f "${SSH_CONFIG}" ]; then
        echo "server name|192.168.1.1|${My_user}|${My_pass}|${My_port}|1" > ${SSH_CONFIG}
    fi
    if [ ! -f "${CUSTOM_CONFIG}" ]; then
        cat > $CUSTOM_CONFIG << E0F
Host *
    ControlMaster auto
    ControlPath ~/.ssh/%h-%p-%r
    ControlPersist yes
E0F
    fi
    find ${SSH_DIR} -type f | xargs -J % cp -rp % ${BACK_DIR}
    #cp ${SSH_DIR}/* ${BACK_DIR}/
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
            AUTOSUDO=$(echo $server | awk -F\| '{ print $6 }')
            if [ "$PORT" == "" ]; then
                PORT=${My_port}
            fi
            echo '#!/usr/bin/expect -f' > $FILE
            echo 'set timeout 30' >> $FILE
            echo "spawn ssh -p$PORT -l $NAME $IP" >> $FILE
            if ! grep ${IP} ${KNOWN_CONFIG} &> /dev/null ; then
                echo 'expect "(yes/no)?"' >> $FILE
                echo 'send   'yes"\r" >> $FILE
                #echo "#!/bin/bash" > $FILE
                #echo "ssh -p$PORT -l $NAME $IP" >> $FILE
            fi
                #rmip=$(ls ${SSH_DIR}/$IP* | head 1)
            if [ "$PASS" != "" ] && [ ! -S ${SSH_DIR}/$IP* ]; then
                #[ -S ${rmip} ] && rm -f ${rmip}
                echo 'expect "password:"' >> $FILE
                echo 'send   '$PASS"\r" >> $FILE
            fi
            if [ "${CHOOSE_2}" == "sudo" ]; then
                echo 'expect "@"' >> $FILE
                echo 'send   "sudo su - \r"' >> $FILE
            else
                if [ "${AUTOSUDO}" == 1 ] && [ "${NAME}" != "root" ] && [ "${CHOOSE_2}" == "" ]; then
                    echo 'expect "@"' >> $FILE
                    echo 'send   "sudo su - \r"' >> $FILE
                fi
            fi
            echo 'interact' >> $FILE
            chmod a+x $FILE
            $FILE
            break;
        fi
    done
}

function INPUT() {
    # GET INPUT CHOSEN OR GET PARAM
    if [ "${CHOOSE_1}" != "" ]; then
        if [ "${CHOOSE_1}" == "c" ]; then
            find ${SSH_DIR} -type s | xargs rm
            exit 0
        fi
        if [ "${CHOOSE_1}" == "d" ]; then
            if [ "${CHOOSE_2}" != ""  ]; then
                xip=${CHOOSE_2}
                if grep "|${xip}|" ${SSH_CONFIG} &> /dev/null; then
                    sed -i "" "/\|${xip}\|/d"  ${SSH_CONFIG}
                fi
                exit 0
            else
                echo "wrong choose"
                exit 0
            fi
        fi
        if [ "${CHOOSE_1}" == "x" ]; then
            if [ "${CHOOSE_2}" != ""  ]; then
                xip=${CHOOSE_2}
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
        elif [ "${CHOOSE_1}" == "!" ]; then
            xip=$(grep "ssh" $FILE | awk '{print $NF}')
            no=$(awk '{print NR,$0}' ${SSH_CONFIG} | grep "|${xip}|" | awk '{print $1}')
        elif [ "${CHOOSE_1}" == "$" ]; then
            no=$(wc -l ${SSH_CONFIG} | awk '{print $1}')
        elif [ -z "$(echo ${CHOOSE_1}| sed 's/[0-9]*//')" ] || [ "${CHOOSE_1}" == '!' ]; then
            no=${CHOOSE_1}
        else
            echo "wrong choose"
            exit 0
        fi
    else
        clear
        LISTS
        no=0
        until [ $no -gt 0 -a $no -le $i ] &> /dev/null
        do
            read -p 'Server Number: ' no
            if [ "$no" == "q" ]; then
                exit 0 
            fi
        done
    fi
    clear
    SSHD
}

function MAIN() {
    #find ${SSH_DIR} -type s -mmin +600 | xargs -J % rm %
    find ${SSH_DIR} -type s -mmin +600 | xargs rm
    CONFIG
    INPUT
}

MAIN
