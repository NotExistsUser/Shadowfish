TEMPLATE = aux

# DBus service
dbusService.files = xyz.freedom.v2ray.service
dbusService.path = /usr/share/dbus-1/system-services/
INSTALLS += dbusService

# DBus interface
dbusInterface.files = xyz.freedom.v2ray.xml
dbusInterface.path = /usr/share/dbus-1/interfaces/
INSTALLS += dbusInterface

# DBus config
dbusConf.files = xyz.freedom.v2ray.conf
dbusConf.path = /etc/dbus-1/system.d/
INSTALLS += dbusConf

# DBus service 2
dbusService2.files = projectv.v2ray.service \
                    myv2ray.service
dbusService2.path = /usr/lib/systemd/system/
INSTALLS += dbusService2
