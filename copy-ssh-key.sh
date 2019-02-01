#!/bin/bash
#set -x

COPY_SSH_RSA_PUB_NODE=(10.121.123.1 10.121.123.2 10.121.123.3 10.121.123.4 10.121.123.5 10.121.123.6 10.121.123.7 10.121.123.8 10.121.123.9 10.121.123.10 10.121.123.11 10.121.123.12 10.121.123.13 10.121.123.14 10.121.123.15 10.121.123.16 10.121.123.17 10.121.123.18 10.121.123.19 10.121.123.20 10.121.123.21 10.121.123.22 10.121.123.23 10.121.123.24 10.121.123.25 10.121.123.26 10.121.123.27 10.121.123.28 10.121.123.29 10.121.123.30 10.121.123.31 10.121.123.32 10.121.123.33 10.121.123.34 10.121.123.35 10.121.123.36)

MACHINE_PASSWORD="password"

function copy_ssh_rsa_pub() {
        for data in ${COPY_SSH_RSA_PUB_NODE[@]}
        do
                expect -c "
                set timeout 2000
                spawn ssh-copy-id root@${data}
                expect {
                        \"*Are you sure you want to continue connecting (yes/no)*\" { send \"yes\r\";exp_continue }
                        \"*root@10.121.* password:*\" { send \"${MACHINE_PASSWORD}\r\";exp_continue }
                }
                expect eof
                "
        done
}

yum install -y expect
copy_ssh_rsa_pub
