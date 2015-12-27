FROM sabayon/base-armhfp

MAINTAINER mudler <mudler@sabayonlinux.org>

# Set locales to en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ADD ./ext/qemu-arm-static /usr/bin/qemu-arm-binfmt

RUN rsync -av "rsync://rsync.at.gentoo.org/gentoo-portage/licenses/" "/usr/portage/licenses/" && \
	ls /usr/portage/licenses -1 | xargs -0 > /etc/entropy/packages/license.accept

# Adding repository url
ADD ./confs/entropy_arm /etc/entropy/repositories.conf.d/entropy_arm

RUN equo rescue spmsync &&  equo up && equo u && \
  equo i app-admin/sudo net-misc/openssh net-misc/networkmanager \
	app-misc/sabayon-live app-misc/sabayon-skel net-misc/ntp \
	sys-apps/keyboard-configuration-helpers \
	sys-apps/systemd app-misc/sabayon-version \
        sys-process/vixie-cron


# Cleaning accepted license2s
RUN rm -rf /etc/entropy/packages/license.accept

RUN echo -5 | equo conf update

# Perform post-upgrade tasks (mirror sorting, updating repository db)
#ADD ./scripts/setup.sh /setup.sh
#RUN /bin/bash /setup.sh  && rm -rf /setup.sh


# Set environment variables.
ENV HOME /root

# Define working directory.
WORKDIR /

# Define standard volumes
#VOLUME ["/usr/portage", "/usr/portage/distfiles", "/usr/portage/packages", "/var/lib/entropy/client/packages"]
