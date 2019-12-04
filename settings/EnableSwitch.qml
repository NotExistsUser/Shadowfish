import QtQuick 2.1
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0
import Nemo.DBus 2.0
import Nemo.Notifications 1.0
import com.jolla.settings 1.0
import org.nemomobile.systemsettings 1.0

SettingsToggle {
    id: v2raySwitch

    property string entryPath
    property bool activeState
    readonly property string v2rayConfPath: "/home/nemo/.config/v2ray/config.json"
    readonly property string v2rayConfTemplatePath: "/home/nemo/.config/v2ray/config.json.template"
    checked: activeState
    name: "ShadowFish"
    icon.source: "image://theme/icon-m-v2ray"

    active: activeState

    menu: ContextMenu {
        SettingsMenuItem {
            onClicked: v2raySwitch.goToSettings("system_settings/connectivity/v2ray")
        }
    }

    onActiveStateChanged: {
        v2raySwitch.busy = false
    }

    ConfigurationGroup {
        id: v2rayConf
        path: "/apps/jolla-settings-v2ray"
        property string remark: ""
        property string serverIP: ""
        property string proxyType: "smart"

    }

    Timer {
        id: checkState
        interval: 1000
        repeat: true
        triggeredOnStart: false
        onTriggered: {
            console.log("start check systemd status");
            systemdServiceIface.updateProperties()
        }
    }


    DBusInterface {
        id: systemdServiceIface
        bus: DBus.SystemBus
        service: "org.freedesktop.systemd1"
        path: "/org/freedesktop/systemd1/unit/myv2ray_2eservice"
        iface: 'org.freedesktop.systemd1.Unit'

        signalsEnabled: true

        function updateProperties() {
            var activeProperty = systemdServiceIface.getProperty("ActiveState")
            if (activeProperty === "active") {
                activeState = true
                checkState.stop();
                v2raySwitch.busy = false;
            }
            else if (activeProperty === "inactive") {
                activeState = false
                checkState.stop();
                v2raySwitch.busy = false;
            }
            else if (activeProperty === "failed") {
                activeState = false
                checkState.stop();
                v2raySwitch.busy = false;
            }
            else {
                if(!checkState.running)checkState.start();
            }
        }

        onPropertiesChanged: updateProperties();
        Component.onCompleted: updateProperties();
    }

    DBusInterface {
        bus: DBus.SystemBus
        service: "org.freedesktop.systemd1"
        path: "/org/freedesktop/systemd1/unit/myv2ray_2eservice"
        iface: 'org.freedesktop.DBus.Properties'

        signalsEnabled: true
        onPropertiesChanged: systemdServiceIface.updateProperties()
        Component.onCompleted: systemdServiceIface.updateProperties()
    }

    DBusInterface {
        bus: DBus.SystemBus
        service: "org.freedesktop.systemd1"
        path: "/org/freedesktop/systemd1"
        iface: "org.freedesktop.systemd1.Manager"
        signalsEnabled: true

        signal unitNew(string name)
        onUnitNew: {
            if (name == "xyz.freedom.v2ray.service") {
                systemdServiceIface.updateProperties()
            }
        }
    }

    DBusInterface {
        id: proxyBus
        bus: DBus.SystemBus
        service: "xyz.freedom.v2ray"
        path: "/xyz/freedom/v2ray"
        iface: "xyz.freedom.v2ray"
        signalsEnabled: true
    }


    onToggled: {
        if (v2raySwitch.busy) {
            return
        }
        if(!v2rayConf.remark || !v2rayConf.serverIP ){
            // open settings page
            v2raySwitch.goToSettings("system_settings/connectivity/v2ray")
            return
        }
        v2raySwitch.busy = true;
        if (v2rayConf.proxyType == "smart" ||
            v2rayConf.proxyType == "global"
        ){
            callService(activeState, callProxy)
        }else{
            callService(activeState)
        }
    }


    function callService(tmpState, callback){
        var svcArgs = [
                    {'type': 's', 'value': tmpState?'stopSvc':'startSvc'}
                ];
        proxyBus.typedCall('doProxy', svcArgs,
                           function(result) {
                               if(!result){
                                    console.log("no result")
                               }else{
                                   if (v2rayConf.proxyType == "smart" ||
                                       v2rayConf.proxyType == "global"
                                   ){
                                       console.log("smart switch enabled!")
                                       if(callback)callback(tmpState);
                                   }
                               }
                           },
                           function(error) {
                               console.log("callService Error:" , error);
                           });
    }

    function callProxy(tmpState, callback){
        var args = [
                    {'type': 's', 'value': tmpState?'stopProxy':'startProxy'}
                ];
        proxyBus.typedCall('doProxy', args,
                           function(result) {
                               console.log("callProxy Debug:",result);
                               if(!result && !tmpState ){
                                   // callback
                                   activeState = false;
                               }else{
                                   systemdServiceIface.updateProperties();
                               }
                           },
                           function(error) {
                               console.log("callProxy Error:" , error);
                               activeState = false;
                               // stop svc
                               callService(true);
                           });
    }
}
