PREFIX ?= /usr/local/rosenpass
install:
	echo "Installing to ${PREFIX}"
	mkdir -p ${PREFIX}
	cp *.sh ${PREFIX}/
	cp *.service ${PREFIX}/
	cp config.example ${PREFIX}/config.example
	cp config.example_cn ${PREFIX}/config.example_cn
	cp config.example ${PREFIX}/config
	sed -i "s?<INSTALL_DIR>?${PREFIX}?g" ${PREFIX}/*.service
	sed -i "s?<INSTALL_DIR>?${PREFIX}?g" ${PREFIX}/config
	sed -i "s?<INSTALL_DIR>?${PREFIX}?g" ${PREFIX}/config.example_cn
	chmod a+x ${PREFIX}/*.sh
	bash ${PREFIX}/makedirs.sh
install_service:
	cp ${PREFIX}/*.service /etc/systemd/system/
	systemctl daemon-reload
	systemctl enable rp_assignip --now
	systemctl enable rosenpass --now
