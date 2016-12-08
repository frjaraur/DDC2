create:
	@vagrant up
destroy:
	@vagrant destroy -f 
	@rm -rf ./tmp_deploying_stage

recreate:
	make destroy create

stop:
	@vboxmanage controlvm ucp-client poweroff 2>/dev/null || true
	@vboxmanage controlvm ucp-node1 poweroff 2>/dev/null || true
	@vboxmanage controlvm ucp-node2 poweroff 2>/dev/null || true
	@vboxmanage controlvm ucp-replica1 poweroff 2>/dev/null || true
	@vboxmanage controlvm ucp-replica2 poweroff 2>/dev/null || true
	@vboxmanage controlvm ucp-manager poweroff 2>/dev/null || true

start:
	@vboxmanage startvm ucp-manager --type headless 2>/dev/null || true
	@sleep 60
	@vboxmanage startvm ucp-replica1 --type headless 2>/dev/null || true
	@vboxmanage startvm ucp-replica2 --type headless 2>/dev/null || true
	@sleep 120
	@vboxmanage startvm ucp-node1 --type headless 2>/dev/null || true
	@vboxmanage startvm ucp-node2 --type headless 2>/dev/null || true
	@vboxmanage startvm ucp-client 2>/dev/null || true

status:
	@vagrant status	
