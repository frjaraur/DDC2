#!/bin/bash

# node['name'],
# node['ucprole'],
# node['managementip'],
# node['fqdn'],
# config['environment']['ucpip'],
# config['environment']['ucpuser'],
# config['environment']['ucppasswd'],

nodename=$1
ucprole=$2
nodeip=$3
fqdn=$4
ucpfqdn=$5
ucpip=$6
ucpuser=$7
ucppasswd=$8
ucpurl=$9

VAGRANT_PROVISION_DIR=/tmp_deploying_stage
VAGRANT_LICENSES_DIR=/licenses

UCP_INFO=${VAGRANT_PROVISION_DIR}/ucp_info
UCP_FINGERPRINT=""

echo "-----------------"
echo "PARAMETERS: [$*]"
echo "-----------------"



UCP_NODE_PROVISIONED=${VAGRANT_PROVISION_DIR}/ucp_${nodename}.${ucprole}.provisioned

case ${ucprole} in
	master)
		if [ ! -f ${UCP_INFO} ]
		then
			echo "---- UCP MASTER CONTROLLER INSTALL ----"

			docker run --rm \
			--name ucp -v ${VAGRANT_LICENSES_DIR}/docker_subscription.lic:/config/docker_subscription.lic \
			-v /var/run/docker.sock:/var/run/docker.sock  \
			docker/ucp install --host-address ${nodeip} --san ${fqdn} --san 127.0.0.1 --san 0.0.0.0 --san localhost --san ${ucpfqdn} \
			--controller-port 8443 --admin-username ${ucpuser}  --admin-password ${ucppasswd}

			if [ $? -eq 0 ]
			then
				#echo "---- Preparing UCP Fingerprint ----"
				#ucpfingerprint=$(docker run --rm --name ucp -v /var/run/docker.sock:/var/run/docker.sock docker/ucp fingerprint )
				echo "${ucpurl}" > ${UCP_INFO}
				#echo "${ucpfingerprint}" >> ${UCP_INFO}
				#service docker restart
                echo "manager.token $(docker swarm join-token manager -q )" >> ${UCP_INFO}
                echo "worker.token $(docker swarm join-token worker -q )" >> ${UCP_INFO}
				touch ${UCP_NODE_PROVISIONED}

			fi
		fi


	;;

	replica)
		if [ ! -f ${UCP_INFO} ]
		then
			echo "UCP manager not provisioned yet ..." && exit 0
		fi

		if [ ! -f ${UCP_NODE_PROVISIONED} ]
		then
			echo "---- UCP NODE INSTALL ----"

			#docker run --rm --name ucp \
			#-v /var/run/docker.sock:/var/run/docker.sock \
			#docker/ucp join --replica --admin-username ${ucpuser} --admin-password ${ucppasswd} \
			#--host-address ${nodeip} --san ${fqdn} --san 127.0.0.1 --san 0.0.0.0 --san localhost  --san ${ucpfqdn} \
			#--url $(head -1 ${UCP_INFO}) \
			#--fingerprint $(tail -1 ${UCP_INFO})

			#We will use old service standard
			#service docker restart

            docker swarm join ${ucpip}:2377 --advertise-addr ${nodeip}  --listen-addr ${nodeip} \
                --token $(grep "manager.token" ${UCP_INFO}|cut -d " " -f2)

			touch ${UCP_NODE_PROVISIONED}
		else
			echo "UCP replica ${nodename} already provioned ..." && exit 0
		fi


	;;



	node)
		if [ ! -f ${UCP_INFO} ]
		then
			echo "UCP manager not provisioned yet ..." && exit 0
		fi

		if [ ! -f ${UCP_NODE_PROVISIONED} ]
		then
			echo "---- UCP NODE INSTALL ----"

			#docker run --rm --name ucp \
	  	#-v /var/run/docker.sock:/var/run/docker.sock \
	  	#docker/ucp join --admin-username ${ucpuser} --admin-password ${ucppasswd} \
		#	--host-address ${nodeip} --san ${fqdn} --san 127.0.0.1 --san 0.0.0.0 --san localhost \
		#	--url $(head -1 ${UCP_INFO}) \
		#	--fingerprint $(tail -1 ${UCP_INFO})

			#We will use old service standard

            docker swarm join ${ucpip}:2377 --advertise-addr ${nodeip}  --listen-addr ${nodeip} \
                --token $(grep "worker.token" ${UCP_INFO}|cut -d " " -f2)

			touch ${UCP_NODE_PROVISIONED}
			#service docker restart

			touch ${UCP_NODE_PROVISIONED}
		else
			echo "UCP node ${nodename} already provioned ..." && exit 0
		fi


	;;

	client)
		echo "Client install"
		ucpurl=$(head -1 ${UCP_INFO})
		mkdir /home/vagrant/bundle

		docker run --rm --name simple-ucp-tools -v /home/vagrant/bundle:/OUTDIR frjaraur/simple-ucp-tools -n ${ucpurl} -u ${ucpuser}  -p ${ucppasswd}
        sudo chown -R vagrant:vagrant /home/vagrant

		sudo DEBIAN_FRONTEND=noninteractive apt-get install -qq lxde xinit firefox unzip zip gpm mlocate console-common chromium-browser
		sudo service gpm start
		sudo update-rc.d gpm enable
		sudo localectl set-x11-keymap es
		sudo localectl set-keymap es
		sudo setxkbmap -layout es
		#echo -e "XKBMODEL=\"pc105\"\nXKBLAYOUT=\"es\"" > /etc/default/keyboard
		echo -e "XKBLAYOUT=\"es\"\nXKBMODEL=\"pc105\"\nXKBVARIANT=\"\"\nXKBOPTIONS=\"lv3:ralt_switch,terminate:ctrl_alt_bksp\"" >/etc/default/keyboard
		echo '@setxkbmap -option lv3:ralt_switch,terminate:ctrl_alt_bksp "es"' | sudo tee -a /etc/xdg/lxsession/LXDE/autostart
		echo '@setxkbmap -layout "es"'|sudo tee -a /etc/xdg/lxsession/LXDE/autostart


    #################
    # We are using 10.0.100.10 as DTR because DNS isn't set and Certificate isn't valid for dtr.domainname
    #
    ###
    # Notary
    sudo curl -o /usr/local/bin/notary -sSL https://github.com/docker/notary/releases/download/v0.4.3/notary-Linux-amd64 && sudo chmod 755 /usr/local/bin/notary
    echo -e "alias notary=\"notary -s https://10.0.100.10:7443 -d ~/.docker/trust\"\n" > /home/vagrant/.bash_aliases

	;;

	*)
		echo "Undefined DDC UCP role" && exit 0
	;;

esac


###
# We are using 10.0.100.10 as DTR because DNS isn't set and Certificate isn't valid for dtr.domainname
# DTR CA for all nodes !!!
curl -o ${VAGRANT_PROVISION_DIR}/getca.sh -sSL https://bitbucket.org/frjaraur/tools/raw/2e1e84e5c787a0dc1f3deb017051010c6c30a02f/getca.sh && chmod 755 ${VAGRANT_PROVISION_DIR}/getca.sh
${VAGRANT_PROVISION_DIR}/getca.sh -d 10.0.100.10 -p 7443
