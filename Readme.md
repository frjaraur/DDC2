
Still in Aplha, a lot of possible errors must be verified and try to avoid them... but UCP provision works ;)

DEFAULTS to "admin" user with "orca" password...

licenses mut be included in "licenses" dir ....

.
├── ddc_install.sh
├── licenses
│   └── docker_subscription.lic
├── Readme.md
├── tmp_deploying_stage All install process runtime files will be located here ... be carefull, it should be empty or even don't exist on clean start (or after a vagrant destroy for example).
└── Vagrantfile



**** Always remove "tmp_deploying_stage" before a clean "vagrant up", for example if reseting environment with "vagrant destroy -f",
