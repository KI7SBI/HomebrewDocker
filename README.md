DMR Homebrew Server with IPSC Bridge
===============================


## Dockerfile
This Dockerfile packages up some great code the other people wrote:
- dmrlink by N0MJS, IPSC_Bridge branch, https://github.com/n0mjs710/DMRlink/tree/IPSC_Bridge
- hblink by N0MJS, HB_Brige branch, https://github.com/n0mjs710/HBlink/tree/HB_Bridge
- ipscbuild by Vance w6ss@dx40.com


Docker is best at running a single application. In this case, we wanted to run 2 applications.
Supervisord is employed to run HB_Bridge and IPSC_Bridge, Docker thinks we're just running Supervisor.





## Config
Before you begin, you must edit the configuration files.

### hblink.cfg
Defines parameters for homebrew.
Master means: open a port and wait for HB clients to connect. Your hotspot 
(Pi-Star or openSpot, etc) will connect here. The default port is 55555/udp.
Docker requires an additional layer of port mapping, so be sure to
connect to your exposed port.

### HB_Bridge.cfg
Defines AMBE ports for talking to IPSC_Bridge.
Also, defines the talkgroup deck.

### dmrlink.cfg
Defines parameters for IPSC master and peers.
If you have a cBridge, use it as an IPSC master.

### IPSC_Bridge.cfg
Settings paired (inverted) from HB_Bridge.cfg. HB_Bridge and IPSC_Bridge will use these 2 ports to communicate.

### Other Config
supervisord.conf



# Build

## Clone a copy of the Dockerfile
	git clone https://github.com/KI7SBI/HomebrewDocker.git

## Edit your config files
	cd HomebrewDocker
	nano ...

## Build the Dockerfile
When you run the following build command, config files are copied into the docker image.
Name:Tag can be set to any value you wish.
	sudo docker build -t HBIPSCDocker:config1


## Multiple copies or versions
Edit config files, and build again, using a different tag. For example,
	sudo docker build -t HBIPSCDocker:pnwdigital



#Run
Remember to map exposed ports.
	sudo docker run -d -p 50001:55555 HBIPSCDocker:config1
	sudo docker run -d -p 50002:55555 HBIPSCDocker:pnwdigital


# Connect your hotspot
Hotspots in MMDVM Server mode may connect to your port 50001 to use config1 bridge settings.
Or, connect to 50002 to use pnwdigital bridge settings.

# Manage Docker Instances
	docker ps
	docker images
	docker kill
	


#Why Docker?
Yes, docker has a learning curve. It may seem unnecessary for you, and perhaps it is in your case.
The goal in containerizing the HB+IPSC pair is primarily to simplify running multiple instances on a single server.
If you dont care to run multiple instances, then you may always just install these apps directly. 



