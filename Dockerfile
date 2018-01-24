FROM alpine:latest

ARG	MINEMELD_CORE_VERSION=0.9.44.post1
ARG	MINEMELD_UI_VERSION=0.9.44

RUN clear &&\
	echo -e "\n PaloAlto" &&\
	echo -e "\e[1;33m    /|    //||     _                    /|    //||              //      //\e[0m" &&\
	echo -e "\e[1;33m   //|   // ||    (_)   __     ___     //|   // ||     ___     //  ___ //\e[0m" &&\
	echo -e "\e[1;33m  // |  //  ||   / / //   )) //___)   // |  //  ||   //___)   // //   //\e[0m" &&\
	echo -e "\e[1;33m //  | //   ||  / / //   // //       //  | //   ||  //       // //   //\e[0m" &&\
	echo -e "\e[1;33m//   |//    || / / //   // ((____   //   |//    || ((____   // ((___//\e[0m" &&\
	echo -e "\n\n" &&\
	echo -e "CORE VERSION: $MINEMELD_CORE_VERSION\nUI VERSION: $MINEMELD_UI_VERSION" &&\
	echo -e "------------------------------------------------------------------------------" &&\
	echo -e "\e[0;32mINSTALL MINEMELD ENGINE\e[0m" &&\
	echo -n -e "\e[0;32m# Create minemeld user\e[0m" &&\
    adduser minemeld -s /bin/false -D &&\
	echo -e "\e[1;32m  ✔\e[0m" &&\
    echo -n -e "\e[0;32m# Create minemeld directories\e[0m" &&\
    mkdir -p -m 0775 /opt/minemeld/engine /opt/minemeld/local /opt/minemeld/log /opt/minemeld/prototypes /opt/minemeld/supervisor /opt/minemeld/www /opt/minemeld/local/certs /opt/minemeld/local/config /opt/minemeld/local/data /opt/minemeld/local/library /opt/minemeld/local/prototypes /opt/minemeld/local/config/traced /opt/minemeld/local/config/api /opt/minemeld/local/trace /opt/minemeld/supervisor/config/conf.d &&\
	echo -e "\e[1;32m  ✔\e[0m" &&\
    echo -n -e "\e[0;32m# Install MineMeld dependencies & Infrastructure\e[0m" &&\
	echo '@edge http://dl-cdn.alpinelinux.org/alpine/edge/main' >> /etc/apk/repositories &&\
	echo '@edge http://dl-cdn.alpinelinux.org/alpine/edge/community' >> /etc/apk/repositories &&\
	echo 'http://dl-cdn.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories &&\
	apk -U -q add apk-tools@edge &&\
	apk -q --progress add c-ares ca-certificates curl openssl collectd collectd-rrdtool collectd-utils cython erlang-asn1 erlang-public-key git file leveldb libffi librrd libssl1.0 libxml2 libxslt p7zip rabbitmq-server redis snappy su-exec supervisor tzdata &&\
	echo -e "\e[1;32m  ✔\e[0m" &&\
    echo -n -e "\e[0;32m# Install MineMeld python dependencies\e[0m" &&\
	apk -q --progress add python2 py2-virtualenv py-libxml2 py2-certifi py2-click py2-crypto py2-cryptography py2-dateutil py2-dicttoxml py2-flask py2-flask-oauthlib py2-flask-wtf py2-gevent py2-greenlet py2-gunicorn py2-lxml py2-lz4 py2-mock py2-netaddr py2-netaddr py2-openssl py2-pip py2-psutil py2-redis py2-sphinx py2-sphinx_rtd_theme py2-sphinxcontrib-websupport py2-tz py2-urllib3 py2-virtualenv py2-yaml &&\
	echo -e "\e[1;32m  ✔\e[0m" &&\
	echo -e "\e[0;32m# Get Minemeld prototypes...\e[0m" &&\
	cd /tmp &&\
	echo "Working directory: $(pwd)" &&\
	git clone https://github.com/PaloAltoNetworks/minemeld-node-prototypes.git &&\
	mkdir -p /opt/minemeld/prototypes/"$MINEMELD_CORE_VERSION" &&\
	mv minemeld-node-prototypes/prototypes/* /opt/minemeld/prototypes/"$MINEMELD_CORE_VERSION" &&\
    ln -sn /opt/minemeld/prototypes/"$MINEMELD_CORE_VERSION" /opt/minemeld/prototypes/current &&\
	echo -e "\e[1;32m  ✔\e[0m" &&\
	echo -n -e "\e[0;32m# Get Minemeld-Core\e[0m" &&\
	curl -sSL "https://github.com/PaloAltoNetworks/minemeld-core/archive/${MINEMELD_CORE_VERSION}.tar.gz" | tar xzf - -C /opt/minemeld/engine/ &&\
	cd /opt/minemeld/engine &&\
	mv "minemeld-core-$MINEMELD_CORE_VERSION"/ core &&\
	echo -e "\e[1;32m  ✔\e[0m" &&\
	echo -n -e "\e[0;32m# Install dev packages\e[0m" &&\
	apk -q --progress add -t DEV c-ares-dev cython cython-dev g++ gcc gdnsd-dev leveldb-dev libffi-dev libxml2-dev libxslt-dev musl-dev openssl-dev snappy-dev rrdtool-dev linux-headers python-dev &&\
	echo -e "\e[1;32m  ✔\e[0m" &&\
	echo -e "\e[0;32m# Create virtualenv...\e[0m" &&\
	echo "Working directory: $(pwd)" &&\
	virtualenv --system-site-packages /opt/minemeld/engine/"$MINEMELD_CORE_VERSION" &&\
	chown -R minemeld:minemeld /opt/minemeld/engine/"$MINEMELD_CORE_VERSION" &&\
	chmod -R 0775 /opt/minemeld/engine/"$MINEMELD_CORE_VERSION" &&\
	source /opt/minemeld/engine/"$MINEMELD_CORE_VERSION"/bin/activate &&\
	echo -e "\e[1;32m  ✔\e[0m" &&\
	sed -i 's/==.*//g' /opt/minemeld/engine/core/requirements* &&\
	echo -n -e "\e[0;32m# Install engine requirements\e[0m" &&\
	pip install -q -r /opt/minemeld/engine/core/requirements.txt &&\
	echo -e "\e[1;32m  ✔\e[0m" &&\
	echo -n -e "\e[0;32m# Install web requirements\e[0m" &&\
	pip install -q -r /opt/minemeld/engine/core/requirements-web.txt &&\
	echo -e "\e[1;32m  ✔\e[0m" &&\
	echo -n -e "\e[0;32m# Install dev requirements\e[0m" &&\
	pip install -q -r /opt/minemeld/engine/core/requirements-dev.txt &&\
	deactivate &&\
	echo -e "\e[1;32m  ✔\e[0m" &&\
	echo -e "\e[0;32m# Install engine...\e[0m" &&\
	/opt/minemeld/engine/"$MINEMELD_CORE_VERSION"/bin/pip install -e /opt/minemeld/engine/core &&\
    ln -sn /opt/minemeld/engine/"$MINEMELD_CORE_VERSION" /opt/minemeld/engine/current &&\
	echo -e "\e[1;32m  ✔\e[0m" &&\
# Cleanup
	rm -rf /tmp/* /var/cache/apk/* &&\
	apk -q del --purge DEV
RUN	export PATH=$PATH:/opt/minemeld/engine/current/bin &&\
	source /opt/minemeld/engine/"$MINEMELD_CORE_VERSION"/bin/activate &&\
# This doesn't work. For some reason it doesn't see the system packages even though they are in the PYTHONPATH and can be imported by python
	#echo -e -n "\e[0;32m# Create extensions frigidaire\e[0m" &&\
	#mm-extensions-freeze /opt/minemeld/local/library /opt/minemeld/local/library/freeze.txt &&\
	#echo -e "\e[1;32m  ✔\e[0m" &&\
	echo -n -e "\e[0;32m# Create constraints file\e[0m" &&\
	cd /opt/minemeld/engine/"$MINEMELD_CORE_VERSION" &&\
	/opt/minemeld/engine/"$MINEMELD_CORE_VERSION"/bin/pip freeze /opt/minemeld/engine/core 2>/dev/null | grep -v minemeld-core > /tmp/constraints-venv.txt &&\
	deactivate &&\
	pip freeze /opt/minemeld/engine/core 2>/dev/null | grep -v minemeld-core > /tmp/constraints-system.txt &&\
	cat /tmp/constraints-venv.txt /tmp/constraints-system.txt | sort | uniq > /opt/minemeld/local/library/constraints.txt &&\
	echo -e "\e[1;32m  ✔\e[0m" &&\
	echo -n -e "\e[0;32m# Create CA config file\e[0m" &&\
	echo "# no_merge_certifi: true" >/opt/minemeld/local/certs/cacert-merge-config.yml &&\
	echo -e "\e[1;32m  ✔\e[0m" &&\
	#echo -n -e "\e[0;32m# Create CA bundle\e[0m" &&\
	#mm-cacert-merge --config /opt/minemeld/local/certs/cacert-merge-config.yml --dst /opt/minemeld/local/certs/bundle.crt /opt/minemeld/local/certs/site/ &&\
	#echo -e "\e[1;32m  ✔\e[0m" &&\
	echo -e "------------------------------------------------------------------------------"
#########################################################################################
# MISCELLANEOUS FILES
#########################################################################################
RUN	echo -e "\e[0;32m# Get minemeld-ansible git repo...\e[0m" &&\
	cd /tmp &&\
	git clone https://github.com/PaloAltoNetworks/minemeld-ansible.git &&\
	echo -e "\e[1;32m  ✔\e[0m" &&\
	echo -n -e "\e[0;32m# Interpolating templates\e[0m" &&\
	cd minemeld-ansible/roles/minemeld/templates &&\
# Config CollectD to output logs to emit warnings to STDOUT
	sed 's/"\/var\/log\/collectd.log"/STDOUT/' collectd.centos7.conf.j2 | sed 's/info/notice/' | sed 's/Timestamp true/Timestamp false/' >/etc/collectd/collectd.conf &&\
# Unholy template replacement to remain close to PaloAlto Ansible repo
# General
	sed -i 's/{{ *main_directory *}}/\/opt\/minemeld/g' * &&\
	sed -i 's/{{supervisor_directory}}/\/opt\/minemeld\/supervisor/g' * &&\
	sed -i 's/{{venv_directory}}/\/opt\/minemeld\/engine\/current/g' * &&\
	sed -i 's/{{engine_directory}}/\/opt\/minemeld\/engine/g' * &&\
	sed -i 's/{{trace_directory}}/\/opt\/minemeld\/local\/trace/g' * &&\
	sed -i 's/{{traced_config_directory}}/\/opt\/minemeld\/local\/config\/traced/g' * &&\
	sed -i 's/{{data_directory}}/\/opt\/minemeld\/local\/data/g' * &&\
	sed -i 's/{{prototypes_local_directory}}/\/opt\/minemeld\/local\/prototypes/g' * &&\
	sed -i 's/{{prototypes_repo_directory}}/\/opt\/minemeld\/prototypes/g' * &&\
	sed -i 's/{{certs_directory}}/\/opt\/minemeld\/local\/certs/g' * &&\
	sed -i 's/{{config_directory}}/\/opt\/minemeld\/local\/config/g' * &&\
#  Listener
	sed '2ienvironment=HOME=/home/minemeld' minemeld-supervisord-listener.supervisord.j2 | sed '3ipriority=10' >/opt/minemeld/supervisor/config/conf.d/supervisord-listener.conf &&\
#  Traced
	sed '3ipriority=100' minemeld-traced.supervisord.j2 | sed '4istartsecs=20' >/opt/minemeld/supervisor/config/conf.d/traced.conf &&\
#  Engine
#	sed '3ipriority=900' minemeld-engine.supervisord.j2 | sed 's/\(environment=.*\)/\1,PYTHONPATH=$PYTHONPATH:/opt/minemeld/engine/' >/opt/minemeld/supervisor/config/conf.d/engine.conf &&\
	sed '3ipriority=900' minemeld-engine.supervisord.j2 >/opt/minemeld/supervisor/config/conf.d/engine.conf &&\
#  Web
	sed '4istartsecs=20' minemeld-web.supervisord.j2 >/opt/minemeld/supervisor/config/conf.d/web.conf &&\
# NGINX config file
	sed 's/{{www_directory}}/\/opt\/minemeld\/www/g' minemeld-web.nginx.j2 >/opt/minemeld/www/minemeld-web.nginx.conf &&\
# API Defaults
	sed 's/{{local_directory}}/\/opt\/minemeld\/local/' 10-defaults.yml.j2 | sed 's/{{library_directory}}/\/opt\/minemeld\/local\/library/' >/opt/minemeld/local/config/api/10-defaults.yml &&\
	echo -e "\e[1;32m  ✔\e[0m" &&\
	echo -n -e "\e[0;32m# Copy configuration files and sample certificates" &&\
	cd /tmp &&\
# Various configuration files
	mv minemeld-ansible/roles/minemeld/templates/minemeld_types.db.j2 /usr/share/minemeld_types.db &&\
	mv minemeld-ansible/roles/minemeld/files/traced.yml /opt/minemeld/local/config/traced/ &&\
	mv minemeld-ansible/roles/minemeld/files/wsgi.htpasswd /opt/minemeld/local/config/api/ &&\
	mv minemeld-ansible/roles/minemeld/files/committed-config.yml /opt/minemeld/local/config/ &&\
	mv minemeld-ansible/roles/minemeld/templates/supervisord.conf.j2 /opt/minemeld/supervisor/config/supervisord.conf &&\
# Certificates
	mv minemeld-ansible/roles/minemeld/files/minemeld.cer /opt/minemeld/local/certs/ &&\
	mv minemeld-ansible/roles/minemeld/files/minemeld.pem /opt/minemeld/local/certs/ &&\
# Cleanup
#	sed -i 's/command=\/opt\/minemeld\/engine\/current\/bin\/command=//' /opt/minemeld/supervisor/config/conf.d/*.conf &&\
	sed -i 's/"//g' /opt/minemeld/supervisor/config/conf.d/*.conf &&\
	rm -rf /tmp/* &&\
	echo -e "\e[1;32m  ✔\e[0m" &&\
	echo -e "------------------------------------------------------------------------------"
##########################################################################################
# WEB UI
##########################################################################################
RUN	echo -e "\e[0;32mINSTALL WEB UI\e[0m" &&\
	echo -e "\e[0;32m# Install npm packages...\e[0m" &&\
	apk -q --progress add --no-cache -t DEV_WEBUI nodejs nodejs-npm g++ libsass libsass-dev make &&\
#    npm install -g npm@latest &&\
#    apk add --no-cache -t DEV_WEBUI nodejs-current &&\
    mkdir -p /var/www/webui &&\
    curl -sSL https://github.com/PaloAltoNetworks/minemeld-webui/archive/${MINEMELD_UI_VERSION}.tar.gz | tar xzf - -C /opt/minemeld/www &&\
    cd  /opt/minemeld/www/minemeld-webui-${MINEMELD_UI_VERSION} &&\
    npm --quiet install &&\
	echo -e "\e[1;32m  ✔\e[0m" &&\
	echo -e "\e[0;32m# Install Bower components...\e[0m" &&\
	export PATH="$PATH:/opt/minemeld/www/minemeld-webui-${MINEMELD_UI_VERSION}/node_modules/.bin/" &&\
    bower install --allow-root &&\
	echo -e "\e[1;32m  ✔\e[0m" &&\
	echo -n -e "\e[0;32m# Installing typings...\e[0m" &&\
    typings install &&\
	echo -e "\e[1;32m  ✔\e[0m" &&\
    echo -e "\e[0;32m# Checking for vulnerabilitiess...\e[0m" &&\
    nsp check &&\
	echo -e "\e[1;32m  ✔\e[0m" &&\
	echo -e "\e[0;32m# Gulp build...\e[0m" &&\
    gulp build &&\
	echo -e "\e[1;32m  ✔\e[0m" &&\
	ln -s "/opt/minemeld/www/minemeld-webui-${MINEMELD_UI_VERSION}/dist" /opt/minemeld/www/current &&\
# Cleanup
    rm -rf /tmp/* &&\
	apk -q --no-cache del --purge DEV_WEBUI &&\
	echo -e "------------------------------------------------------------------------------"

RUN	echo -e "\e[0;32mINSTALL WEB SERVER INFRASTRUCTURE\e[0m" &&\
	echo -n -e "\e[0;32m# Install webapp webserver dependencies\e[0m" &&\
	apk --no-cache -q --progress add py2-gunicorn py2-passlib py2-flask py-flask-passlib py2-flask-login py-rrd &&\
	echo -e "\e[1;32m  ✔\e[0m" &&\
	echo -n -e "\e[0;32m# Install web server\e[0m" &&\
	apk -q --no-cache --progress add nginx &&\
	mkdir -p /var/run/nginx &&\
	cp /opt/minemeld/local/certs/minemeld.cer /etc/nginx &&\
	cp /opt/minemeld/local/certs/minemeld.pem /etc/nginx &&\
	mv /opt/minemeld/www/minemeld-web.nginx.conf /etc/nginx/conf.d/default.conf &&\
	echo -e "\e[1;32m  ✔\e[0m" &&\
	echo ' * Disable global ssl session cache'  &&\
	sed -i 's/ssl_session_cache.*//' /etc/nginx/nginx.conf &&\
#	touch /opt/minemeld/local/config/api/feeds.htpasswd &&\
	echo -e "\e[1;32m  ✔\e[0m" &&\
	echo -e "------------------------------------------------------------------------------"

# Add CA bundle
COPY bundle.crt /opt/minemeld/local/certs/

# Apply correct ownership
RUN	echo -n -e "\e[0;32m# Fixing permissions\e[0m" &&\
	mkdir -m 0755 -p /var/run/minemeld/ &&\
	chown -R minemeld: /opt/minemeld /var/run/minemeld &&\
	chown -R rabbitmq: /var/lib/rabbitmq /var/log/rabbitmq /usr/lib/rabbitmq &&\
	chmod 0644 /etc/collectd/collectd.conf &&\
#	chmod 0600 /opt/minemeld/local/certs/*.pem &&\
	echo -e "\e[1;32m  ✔\e[0m" &&\
	echo -e "------------------------------------------------------------------------------"

ARG	CONTAINERPILOT_VERSION=3.6.2
RUN	echo -n -e "\e[0;32m# Installing Containerpilot\e[0m" &&\
	curl -sSL "https://github.com/joyent/containerpilot/releases/download/${CONTAINERPILOT_VERSION}/containerpilot-${CONTAINERPILOT_VERSION}.tar.gz" | tar xzf - -C /usr/local/bin &&\
# Create healthcheck scripts for Containerpilot
	echo -e "#!/bin/sh\nredis-cli ping >/dev/null 2>&1" >/usr/local/bin/redis-healthcheck &&\
	echo -e "#!/bin/sh\nrabbitmqctl node_health_check >/dev/null 2>&1" >/usr/local/bin/rabbitmq-healthcheck &&\
	echo -e "#!/bin/sh\ncollectdctl -s \$(awk '/SocketFile/{ print substr(\$2,2,length(\$2)-2) }' /etc/collectd/collectd.conf) listval >/dev/null 2>&1" >/usr/local/bin/collectd-healthcheck &&\
# Create prestart script to fix GRSEC errors
	echo -e "#!/bin/sh\nsetfattr -n user.pax.flags -v E $(which python) /usr/lib/libffi.so.6.0.4 >/dev/null" >/usr/local/bin/prestart.sh &&\
	chmod +x /usr/local/bin/* &&\
	apk -q --no-cache add attr &&\
	echo -e "\e[1;32m  ✔\e[0m" &&\
	echo -e "------------------------------------------------------------------------------"

# Add Redis configuration files
COPY redis.conf /etc/
# Add Containerpilot config file
COPY minemeld.json5 /etc/

#ENTRYPOINT ["containerpilot", "-config", "/etc/minemeld.json5"]
