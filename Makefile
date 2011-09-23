RELEASE=1.8

PACKAGE=ksm-control-daemon
PKGVER=1.0
PKGREL=6

KSM_DEB=${PACKAGE}_${PKGVER}-${PKGREL}_all.deb

all: ${KSM_DEB}

${KSM_DEB} ksm: ksm-control-scripts.org/ksm.init
	rm -rf ksm-control-scripts
	rsync -a --exclude .git ksm-control-scripts.org/ ksm-control-scripts
	cp -a debian ksm-control-scripts
	cd ksm-control-scripts; dpkg-buildpackage -rfakeroot -us -uc
	lintian ${KSM_DEB} || true

ksm-control-scripts.org/ksm.init:
	git clone git://gitorious.org/ksm-control-scripts/ksm-control-scripts.git ksm-control-scripts.org
	touch $@


.PHONY: upload
upload: ${KSM_DEB}
	umount /pve/${RELEASE}; mount /pve/${RELEASE} -o rw 
	mkdir -p /pve/${RELEASE}/extra
	rm -rf /pve/${RELEASE}/extra/Packages*
	rm -rf /pve/${RELEASE}/extra/${PACKAGE}_*.deb
	cp ${KSM_DEB} /pve/${RELEASE}/extra
	cd /pve/${RELEASE}/extra; dpkg-scanpackages . /dev/null | gzip -9c > Packages.gz
	umount /pve/${RELEASE}; mount /pve/${RELEASE} -o ro

.PHONY: distclean
distclean: clean
	rm -rf ksm-control-scripts.org

.PHONY: clean
clean:
	rm -rf *~ ksm-control-scripts ${PACKAGE}_*