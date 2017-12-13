Using Docker to Virtualize a MMDVM server and IPSC bridge
===============================

This Dockerfile packages up some great code that other people wrote. 
- IPSC_Bridge branch of dmrlink by N0MJS, https://github.com/n0mjs710/DMRlink
- HB_Bridge branch of hblink by N0MJS, https://github.com/n0mjs710/HBlink
- ipscbuild by Vance w6ss@dx40.com
- Debian Jessie-Slim, etc.

Please read more about IPSC_Bridge and HB_Bridge before attempting to use them. This documentation is just really barely enough to let a knowledgable user follow steps to get it running. Please see the respective softwares for their documentation.

N0MJS makes a particular note:
> The configuration file for dmrlink is in ".ini" format, and is self-documented. A warning not in the self-documentation: Don't enable features you do not undertand, it can break dmrlink or the target IPSC (nothing turning off dmrlink shouldn't fix). There are options avaialble because the IPSC protocol appears to make them available, but dmrlink doesn't yet understand them. For exmaple, dmrlink does not process XNL/XCMP. If you enable it, and other peers expect interaction with it, the results may be unpredictable. Chances are, you'll confuse applications like RDAC that require it. The advantage to dmrlink not processing XNL/XCMP is that it also cannot "brick" a repeater or subscriber, since all of these dangerous features use XNL/XCMP.



## Why Docker?
The goal in containerizing the HB+IPSC pair is to simplify running multiple instances on a single server. 

Docker has great documentation online. https://docs.docker.com 


## Required Config
You must edit these configurations, then build your Docker image. The build process defined in the Dockerfile will copy your edited files into the new image.

Anytime you edit these config files, you'll want to build a new image. Use a different tag every time you build. Docker keeps a cache of the build process. The first build will run slowly. But rebuilding just to copy the new config will run very quickly. You'll see Docker's output when you try it. Examples below. 


### Dockerfile
You probably do not need to edit this file, even if you want to run multiple instances. Nor do you need to edit this file to change the port clients use to connect to your MMDVM server.

`EXPOSE 22222/udp` in Dockerfile, must match the port where your HB_Bridge master is listening, inside the container.

### hblink.cfg
Settings for your MMDVM Server go in this file. 

To run a MMDVM server, specify a Master. Leave the port at 22222, clients will never see it. Remember port 22222 is inside the container. You can run multiple containers, where they all listen on 22222 inside their own containers.

You'll get to choose what port clients will connect to, later, with `docker run -p <OUTSIDE-PORT>:22222/udp`.

	[<YOURCALL>-MMDVMServer-1]
	MODE: MASTER
	ENABLED: True
	REPEAT: True
	EXPORT_AMBE: False
	IP:
	PORT: 22222
	PASSPHRASE: changeme
	GROUP_HANGTIME: 1


### HB_Bridge.cfg
Defines the talkgroup deck. NO7RF knows more about this.

Also, defines internal ports for talking to IPSC_Bridge. Must match the same (inverted) settings in IPSC_Bridge.cfg. Might as well leave the defaults alone. The ports are arbitrary, and entirely contained within the runtime container. You may run multiple instances of the same docker image without any port conflicts. 


### dmrlink.cfg
Defines parameters for IPSC master and peers.


### IPSC_Bridge.cfg
Don't bother editing this one. Settings paired (inverted) from HB_Bridge.cfg. HB_Bridge and IPSC_Bridge will use these ports to communicate.


### supervisord.conf
Supervisord is employed to run HB_Bridge and IPSC_Bridge, we tell Docker just to run Supervisor. No edits required here.


## Build and Run
We're going to run two copies. We want different talkgroup decks A and B on separate HB servers. This implies two, different IPSC connections to two different cBridge managers.

	git clone https://github.com/KI7SBI/HomebrewDocker.git MMDVM-A
	git clone https://github.com/KI7SBI/HomebrewDocker.git MMDVM-B

Now, go edit all your config files, in both directories.
Next step is to build a docker image. `docker build -t REPOSITORY:TAG`
Notice how Docker reuses cached build images to build your second version in no time at all.

And run the 2 images. `-d` daemonizes the host process, `-p` forwards an outside port to the MMDVM server running inside. The outside ports must be unique on the host system, in this example 50001 and 50002.

	cd MMDVM-A
	sudo docker build -t mmdvm:server-a . 
	cd ../MMDVM-B
	sudo docker build -t mmdvm:server-b . 
	sudo docker run -d -p 50001:55555/udp mmdvm:server-a
	sudo docker run -d -p 50002:55555/udp mmdvm:server-b


## Connect your hotspot
From the outside, clients can connect to MMDVM servers on 50001 or 50002.


## Accessing log files from hblink and dmrlink
Haven't built that in yet, but you can do it with Docker. One solution might be to mount a host folder from within the container, and write the log files there. Logs are in /tmp/hblink.log and /tmp/dmrlink.log. 
