#!/bin/bash
cp -a /root/.ssh /target/root/
mkdir -p /target/etc/confluent/ssh/sshd_config.d/
chmod 700 /target/etc/confluent
cp /custom-installation/confluent/* /target/etc/confluent/
cp -a /custom-installation/tls /target/etc/confluent/
chmod go-rwx /etc/confluent/*
for i in /custom-installation/ssh/*.ca; do
    echo '@cert-authority *' $(cat $i) >> /target/etc/ssh/ssh_known_hosts
done

cp -a /etc/ssh/ssh_host* /target/etc/confluent/ssh/
cp -a /etc/ssh/sshd_config.d/confluent.conf /target/etc/confluent/ssh/sshd_config.d/
sshconf=/target/etc/ssh/ssh_config
if [ -d /target/etc/ssh/ssh_config.d/ ]; then
    sshconf=/target/etc/ssh/ssh_config.d/01-confluent.conf
fi
echo 'Host *' >> $sshconf
echo '    HostbasedAuthentication yes' >> $sshconf
echo '    EnableSSHKeysign yes' >> $sshconf
echo '    HostbasedKeyTypes *ed25519*' >> $sshconf

curl -f https://$mgr/confluent-public/os/$profile/scripts/firstboot.sh > /target/etc/confluent/firstboot.sh
chmod +x /target/etc/confluent/firstboot.sh
cp /tmp/allnodes /target/root/.shosts
cp /tmp/allnodes /target/etc/ssh/shosts.equiv
textcons=$(grep ^textconsole: /etc/confluent/confluent.deploycfg |awk '{print $2}')
if [ "$textcons" = "true" ] && ! grep console= /proc/cmdline > /dev/null; then
    cons=""
    if [ -f /custom-installation/autocons.info ]; then
        cons=$(cat /custom-installation/autocons.info)
    fi
    if [ ! -z "$cons" ]; then
        sed -e 's/GRUB_CMDLINE_LINUX="\([^"]*\)"/GRUB_CMDLINE_LINUX="\1 console='${cons#/dev/}'"/' /target/etc/default/grub
	chroot /target update-grub
    fi
fi

