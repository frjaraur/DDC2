DDC2 Deployment

**license file must be included in 'licenses' dir**

.

├── config.yml

├── dtr_install.sh

├── ucp_install.sh

├── licenses

│   └── docker_subscription.lic

├── Readme.md

├── tmp_deploying_stage All install process runtime files will be located here ... be carefull, it should be empty or even don't exist on clean start (or after a vagrant destroy for example).

└── Vagrantfile


Usage is quite simple.... use ucp-client (X client) to connect to your deployed UCP on https://10.0.100.10:8443 (default configuration specifiec on config.yml)

make create 

make destroy
