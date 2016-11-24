#!/bin/bash -x
# :args => [
#   node['name'],
#   node['managementip'],
#   node['ucpsan'],
#   ucpip,
#   ucpuser,
#   ucppasswd,
#   dtrurl
#
nodename=$1
ucpip=$2
ucpuser=$3
ucppasswd=$4
ucpurl=$5
dtrurl=$6
#dtrurl="https://${ucpip}"
#ucpurl="${ucpip}:8443"

VAGRANT_PROVISION_DIR=/tmp_deploying_stage
VAGRANT_LICENSES_DIR=/licenses

#UCP admin/PASSWORD

DTR_INFO=${VAGRANT_PROVISION_DIR}/dtr_info
UCP_INFO=${VAGRANT_PROVISION_DIR}/ucp_info


DTR_NODE_PROVISIONED=${VAGRANT_PROVISION_DIR}/dtr_${nodename}.provisioned

[ ! -f ${UCP_INFO} ] && echo "UCP isn't provisioned yet ... can not install DTR" && exit 0

if [ ! -f ${DTR_NODE_PROVISIONED} ]
then
	echo "---- DTR INSTALL ----"
	#echo 	curl -k https://${ucpurl}/ca > ${VAGRANT_PROVISION_DIR}/ucp-ca.pem

	curl -o ${VAGRANT_PROVISION_DIR}/ucp-ca.pem -sSk ${ucpurl}/ca
	sleep 5
	cat ${VAGRANT_PROVISION_DIR}/ca.pem
  #wget -q --no-check-certificate https://10.0.100.10/ca -O -wget -q --no-check-certificate https://10.0.100.10/ca -O - > ${VAGRANT_PROVISION_DIR}/ucp-ca.pem

	docker run --rm --name simple-ucp-tools -v /tmp_deploying_stage:/OUTDIR frjaraur/simple-ucp-tools -n ${ucpurl}

	# export DOCKER_TLS_VERIFY=1
	# export DOCKER_CERT_PATH="/tmp_deploying_stage"
	# export DOCKER_HOST=tcp://${ucpurl}

		docker run --rm \
		  docker/dtr install \
		  --ucp-url ${ucpurl} \
		  --ucp-node ${nodename} \
		  --dtr-external-url ${dtrurl} \
          --replica-https-port 7443 \
		  --ucp-username ${ucpuser} --ucp-password ${ucppasswd} \
		  --ucp-ca "$(cat ${VAGRANT_PROVISION_DIR}/ucp-ca.pem)"

		if [ $? -eq 0 ]
		then
			echo ${dtrurl} > ${DTR_INFO}
			touch ${DTR_NODE_PROVISIONED}
		fi

fi
