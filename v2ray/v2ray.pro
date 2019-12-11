TEMPLATE = aux

#v2ray config json
v2conf.files = config.json.template
v2conf.path = /home/nemo/.config/v2ray/
INSTALLS += v2conf

#sh script
sh.files = shadowfish.sh
sh.path = /usr/bin/
INSTALLS += sh