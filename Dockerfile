FROM jenkins

MAINTAINER jaltek <jaltek@mailbox.org>

USER root

RUN apt-key adv --keyserver keys.gnupg.net --recv-keys 14AA40EC0831756756D7F66C4F4EA0AAE5267A6C; \
        echo "deb http://ppa.launchpad.net/ondrej/php/ubuntu trusty main" >> /etc/apt/sources.list; \
        echo "deb-src http://ppa.launchpad.net/ondrej/php/ubuntu trusty main" >> /etc/apt/sources.list

RUN export DEBIAN_FRONTEND=noninteractive; \
        apt-get update; \
        apt-get -qq install php7.0 php7.0-cli php7.0-xsl php7.0-json php7.0-curl php7.0-sqlite php7.0-mysqlnd php7.0-xdebug php7.0-intl php7.0-mcrypt php-pear curl git ant sudo

RUN /usr/local/bin/install-plugins.sh checkstyle cloverphp crap4j dry htmlpublisher jdepend plot pmd violations warnings xunit git ansicolor

RUN sed -i 's|disable_functions.*=|;disable_functions=|' /etc/php/7.0/cli/php.ini; \
	echo "xdebug.max_nesting_level = 500" >> /etc/php/7.0/mods-available/xdebug.ini

RUN mkdir -p /usr/share/jenkins/ref/composerbin && chown -R jenkins:jenkins /usr/share/jenkins/ref/composerbin; \
	sudo -H -u jenkins bash -c ' \
		curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/share/jenkins/ref/composerbin --filename=composer;'; \
	ln -s /usr/share/jenkins/ref/composerbin/composer /usr/local/bin/; \
	sudo -H -u jenkins bash -c ' \
		export COMPOSER_BIN_DIR=/usr/share/jenkins/ref/composerbin; \
		export COMPOSER_HOME=/usr/share/jenkins/ref; \
		composer global require "phpunit/phpunit=*" --prefer-source --no-interaction; \
		composer global require "squizlabs/php_codesniffer=*" --prefer-source --no-interaction; \
		composer global require "phploc/phploc=*" --prefer-source --no-interaction; \
		composer global require "pdepend/pdepend=*" --prefer-source --no-interaction; \
		composer global require "phpmd/phpmd=*" --prefer-source --no-interaction; \
		composer global require "sebastian/phpcpd=*" --prefer-source --no-interaction; \
		composer global require "theseer/phpdox=*" --prefer-source --no-interaction; '; \
	ln -s /var/jenkins_home/composerbin/pdepend /usr/local/bin/; \
	ln -s /var/jenkins_home/composerbin/phpcpd /usr/local/bin/; \
	ln -s /var/jenkins_home/composerbin/phpcs /usr/local/bin/; \
	ln -s /var/jenkins_home/composerbin/phpdox /usr/local/bin/; \
	ln -s /var/jenkins_home/composerbin/phploc /usr/local/bin/; \
	ln -s /var/jenkins_home/composerbin/phpmd /usr/local/bin/; \
	ln -s /var/jenkins_home/composerbin/phpunit /usr/local/bin/

RUN mkdir -p /usr/share/jenkins/ref/jobs/php-template; \
	curl -o /usr/share/jenkins/ref/jobs/php-template/config.xml https://raw.githubusercontent.com/sebastianbergmann/php-jenkins-template/master/config.xml; \
	chown -R jenkins:jenkins /usr/share/jenkins/ref/jobs

USER jenkins

