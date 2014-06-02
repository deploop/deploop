#!/bin/bash

PRINCIPALS="hdfs yarn mapred HTTP vagrant zookeeper flume oozie"

REALM=BUILDOOP.ORG
SECURITY_PATH="/root/principals"

for host in hadoop-manager \
		hadoop-node1 \
		hadoop-node2 \
		hadoop-node3 \
		hadoop-node4 \
		hadoop-node5; do

	sudo rm -fr  ${SECURITY_PATH}/$host
	sudo mkdir -p ${SECURITY_PATH}/$host

	for princ in $PRINCIPALS; do
		sudo kadmin.local -q "delprinc -force ${princ}/${host}.buildoop.org@${REALM}"
		sudo kadmin.local -q "ank -randkey ${princ}/${host}.buildoop.org@${REALM}"
		sudo kadmin.local -q "xst -norandkey -k ${SECURITY_PATH}/${host}/${princ}.keytab ${princ}/${host}.buildoop.org@${REALM}"
		sudo kadmin.local -q "xst -norandkey -k ${SECURITY_PATH}/${host}/${princ}.keytab HTTP/${host}.buildoop.org@${REALM}"
	done
done
