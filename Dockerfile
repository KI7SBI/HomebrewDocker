#	Dockerfile
#	HBServer

#WORKDIR


FROM	debian:jessy-slim
ADD	./provision-debian.sh /root/provision-debian.sh
RUN	/root/provision-debian.sh
