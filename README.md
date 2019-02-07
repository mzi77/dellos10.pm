# dellos10.pm

Dell NOS10 module for  RANCID - Really Awesome New Cisco confIg Differ

## Using module

Before using this perl module you must put new device type lines to `/etc/rancid/rancid.types.conf` file

`dellos10;script;rancid -t dellos10`

`dellos10;login;clogin`

`dellos10;module;dellos10`

`dellos10;inloop;dellos10::inloop`

`dellos10;command;dellos10::GetSystem;show version`

`dellos10;command;dellos10::GetConf;show running-configuration`
