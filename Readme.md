DDC2 Deployment

licenses mut be included in "licenses" dir ....

.

├── config.yml

├── dtr_install.sh

├── ucp_install.sh

├── licenses

│   └── docker_subscription.lic

├── Readme.md

├── tmp_deploying_stage All install process runtime files will be located here ... be carefull, it should be empty or even don't exist on clean start (or after a vagrant destroy for example).

└── Vagrantfile



**** Always remove "tmp_deploying_stage" before a clean "vagrant up", for example if reseting environment with "vagrant destroy -f",
