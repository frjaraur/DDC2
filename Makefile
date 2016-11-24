create:
	vagrant up
destroy:
	vagrant destroy -f 
	rm -rf ./tmp_deploying_stage

recreate:
	make destroy create

stop:
	vboxmanage controlvm ucp-node1 poweroff
	vboxmanage controlvm ucp-node2 poweroff
	vboxmanage controlvm ucp-replica1 poweroff
	vboxmanage controlvm ucp-replica2 poweroff
	vboxmanage controlvm ucp-manager poweroff

start:
	vboxmanage startvm ucp-manager --type headless
	sleep 60
	vboxmanage startvm ucp-replica1 --type headless
	vboxmanage startvm ucp-replica2 --type headless
	sleep 120
	vboxmanage startvm ucp-node1 --type headless
	vboxmanage startvm ucp-node2 --type headless

status:
	vagrant status	
