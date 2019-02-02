#!/bin/bash
#set -x

COPY_SSH_RSA_PUB_NODE=(10.121.136.116 10.121.136.117 10.121.136.118)
COPY_CEPH_EXPORTER_NODE=(10.121.136.116 10.121.136.117 10.121.136.118)
PROMETHEUS_EXPORTER_DIR="/home/prometheus"
MACHINE_PASSWORD="root"

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

function create_exporter_dir() {
	for data in ${COPY_SSH_RSA_PUB_NODE[@]}
	do
		ssh "root@${data}" "mkdir -p ${PROMETHEUS_EXPORTER_DIR}"
	done
}

function copy_node_exporter() {
	for data in ${COPY_SSH_RSA_PUB_NODE[@]}
	do
		scp node_exporter root@${data}:${PROMETHEUS_EXPORTER_DIR}
	done
}

function copy_node_exporter_systemd_conf() {
	for data in ${COPY_SSH_RSA_PUB_NODE[@]}
	do
		scp node_exporter.service root@${data}:/usr/lib/systemd/system
	done
}

function start_node_exporter() {
        for data in ${COPY_SSH_RSA_PUB_NODE[@]}
        do
		ssh "root@${data}" "systemctl daemon-reload"
                ssh "root@${data}" "systemctl disable node_exporter.service"
                ssh "root@${data}" "systemctl enable node_exporter.service"
		ssh "root@${data}" "systemctl start node_exporter.service"
        done
}

function copy_ceph_exporter() {
        for data in ${COPY_CEPH_EXPORTER_NODE[@]}
        do
                scp ceph_exporter root@${data}:${PROMETHEUS_EXPORTER_DIR}
        done
}

function copy_ceph_exporter_systemd_conf() {
        for data in ${COPY_CEPH_EXPORTER_NODE[@]}
        do
                scp ceph_exporter.service root@${data}:/usr/lib/systemd/system
        done
}

function start_ceph_exporter() {
        for data in ${COPY_CEPH_EXPORTER_NODE[@]}
        do
		ssh "root@${data}" "systemctl daemon-reload"
                ssh "root@${data}" "systemctl disable ceph_exporter.service"
                ssh "root@${data}" "systemctl enable ceph_exporter.service"
                ssh "root@${data}" "systemctl start ceph_exporter.service"
        done
}

#yum install -y expect
#copy_ssh_rsa_pub
#create_exporter_dir
#copy_node_exporter
#copy_node_exporter_systemd_conf
start_node_exporter

#copy_ceph_exporter
#copy_ceph_exporter_systemd_conf
start_ceph_exporter
