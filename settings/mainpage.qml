import QtQuick 2.1
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0
import Nemo.DBus 2.0
import Nemo.Notifications 1.0
import com.jolla.settings 1.0
import org.nemomobile.systemsettings 1.0
import "./database.js" as DB
import "./fileutil.js" as FileUtil

Page {
    id: page
    property bool activeState: false
    readonly property string v2rayConfPath: "/home/nemo/.config/v2ray/config.json"
    readonly property string v2rayConfTemplatePath: "/home/nemo/.config/v2ray/config.json.template"
    property string configStr;
    property string usedConfig;


    function updateProxyType() {
        if (v2rayConf.proxyType == "smart") {
            return 0;
        } else if (v2rayConf.proxyType == "global") {
            return 1;
        } else if (v2rayConf.proxyType == "direct") {
            return 2;
        }
    }

    ListModel{
        id: allConfigsModel
    }

    QtObject{
        id: signalCenter
        signal error;
        signal updateSuccess;
        signal addSuccess;
        signal notify(var str);

        onError: {
            notification.show(qsTr("Error occured"))
        }

        onUpdateSuccess: {
            notification.show(qsTr("Update successful"));
            DB.queryall(allConfigsModel)
        }
        onAddSuccess: {
            notification.show(qsTr("Add successful"));
            DB.queryall(allConfigsModel)
        }

        onNotify: {
            notification.show(str);
        }

    }

    onActiveStateChanged: {
        enableSwitch.busy = false;
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

    Notification{
        id: notification
        function show(message, icn) {
            replacesId = 0
            previewSummary = ""
            previewBody = message
            icon = icn ? icn : ""
            publish()
        }

        function showPopup(title, message, icn) {
            replacesId = 0
            previewSummary = title
            previewBody = message
            icon = icn
            publish()
        }

        expireTimeout: 3000
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
                enableSwitch.busy = false;
            }
            else if (activeProperty === "inactive") {
                activeState = false
                checkState.stop();
                enableSwitch.busy = false;
            }
            else if (activeProperty === "failed") {
                activeState = false
                checkState.stop();
                enableSwitch.busy = false;
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

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        PullDownMenu{
            MenuItem{
                text:qsTr("About")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("aboutpage.qml"));
                }
            }

            MenuItem{
                text:qsTr("Log")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("viewpage.qml"));
                }
            }

            MenuItem{
                text:qsTr("Add Server Node")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("addconfigpage.qml"),{
                                       "thisconfig": {},
                                       "signalCenter": signalCenter
                                   });
                }
            }
        }

        Column {
            id: column
            width: page.width

            PageHeader {
                title: qsTr("ShadowFish")
            }


            

            ListItem {
                id: enableItem

                contentHeight: enableSwitch.height
                _backgroundColor: "transparent"

                highlighted: enableSwitch.down || menuOpen

                TextSwitch {
                    id: enableSwitch

                    property string entryPath: "system_settings/connectivity/freedom/shadowfish_active"

                    automaticCheck: false
                    checked: activeState
                    enabled: allConfigsModel.count > 0 && v2rayConf.remark && !busy
                    text: qsTr("ShadowFish service state")

                    onClicked: {
                        if (enableSwitch.busy) {
                            return
                        }
                        enableSwitch.busy = true;
                        for(var i = 0; i < allConfigsModel.count; i++){
                            if(v2rayConf.remark === allConfigsModel.get(i).remark){
                                usedConfig = allConfigsModel.get(i).config;
                            }
                        }
                        
                        if(checked){
                            callService(activeState, callProxy)
                        }else{
                            var saved = saveFile();
                            if(saved){
                                callService(activeState, callProxy)
                            }else{
                                notification.show(qsTr("Save to config file failed"));
                                enableSwitch.busy = false;
                            }
                        }

                    }
                }
            }


            ComboBox{
                id: proxyTypeField
                width: parent.width
                label: qsTr("Proxy Type")
                description: qsTr("Proxy type, global, direct, or smart proxy")
                currentIndex: updateProxyType()
                enabled: !enableSwitch.checked
                menu: ContextMenu {
                    MenuItem {
                        text: qsTr("SmartProxy")
                    }
                    MenuItem {
                        text: qsTr("GlobalProxy")
                    }
                    MenuItem{
                        text: qsTr("Direct")
                    }
                }
                function getVal(){
                    var newValue;
                    switch (currentIndex) {
                    case 0:
                        newValue = "smart"
                        break
                    case 1:
                        newValue = "global"
                        break
                    case 2:
                        newValue = "direct"
                        break
                    }
                    return newValue;
                }
                onCurrentIndexChanged: {
                    v2rayConf.proxyType = getVal()
                    if(configsView.count > 0){
                        saveFile()
                    }
                }
            }


            SectionHeader{
                text: qsTr("Nodes")
            }

            SilicaListView{
                id: configsView
                width: parent.width
                height: Screen.height / 3
                contentHeight: Theme.itemSizeMedium
                model: allConfigsModel
                spacing: Theme.paddingSmall
                clip: true
                delegate: ListItem{
                    id: listItem
                    width: parent.width
                    ListView.onRemove: animateRemoval(listItem)
                    contentHeight: nodeSwitch.height
                                   + ( menuOpen? contextMenu.height : 0)
                                   + Theme.paddingSmall
                    menu: contextMenu
                    function remove() {
                        remorseAction(qsTr("Deleting"), function() {
                            DB.delconfig(remark);
                            view.model.remove(index);
                        })
                    }
                    TextSwitch {
                        id: nodeSwitch
                        automaticCheck: false
                        enabled: !enableSwitch.checked
                        checked: v2rayConf.remark == remark
                        width: parent.width
                        text: remark
                        description: vtype + " " + JSON.parse(config).server
                        onClicked: {
                            v2rayConf.serverIP = JSON.parse(config).server;
                            v2rayConf.remark = remark;
                            usedConfig = config;
                        }
                        onPressAndHold: listItem.openMenu()
                    }
                    Component {
                        id: contextMenu
                        ContextMenu {
                            MenuItem {
                                text: qsTr("Edit")
                                enabled: !enableSwitch.checked
                                onClicked: {
                                    pageStack.push(Qt.resolvedUrl("addconfigpage.qml"),{
                                                       "thisconfig": JSON.parse(config),
                                                       "signalCenter": signalCenter
                                                   })
                                }
                            }
                            MenuItem {
                                text: qsTr("Remove")
                                enabled: !nodeSwitch.checked
                                onClicked: remove();
                            }

                        }
                    }
                }

                ViewPlaceholder{
                    anchors.fill: parent
                    enabled: configsView.count == 0
                    text: qsTr("No nodes yet")
                    hintText: qsTr("Pull down to add new nodes")
                }
            }


        }
    }



    function getFromConfFile(){
        FileUtil.doesFileExist(v2rayConfTemplatePath, function(o){
            if(!o.responseText){
                // pass
            }else{
                FileUtil.getFile(v2rayConfTemplatePath, function(o){
                    try{
                        configStr = o.responseText;
                    }catch(e){
                        // pass
                    }
                });
            }

        });
    }

    

    function saveFile() {
        if(!configStr){
            enableSwitch.busy = false;
            return false;
        }
        var text = configStr;
        // console.log("usedConfig: ", usedConfig);
        var configJson = JSON.parse(usedConfig);
        text = text.replace("PROTOCOL_TYPE", configJson.vtype.toLowerCase());

        if ( configJson.vtype == "VMess" ){
            text = text.replace("MUX_ENABLE", true);
            text = text.replace("NETWORK", '"' + configJson.network + '"');
            text = text.replace("SERVERS_CONFIG", "null");
            text = text.replace("VNEXT_CONFIG",'[{' +
                                '"address": "' + configJson.server + '",' +
                                '  "port": ' + configJson.port + ', '+
                                '  "users": [ '+
                                '    { '+
                                '      "id": "'+ configJson.uuid +'", '+
                                '      "alterId": '+ configJson.alterid +', '+
                                '      "security": "'+ configJson.security +'" '+
                                '    } '+
                                '  ] '+
                                '}]');

            switch(configJson.network){
            case "tcp":
                text = text.replace("TCP_SETTINGS",'{'+
                                    '"header": { '+
                                    '  "type": "'+ configJson.type + '"' +
                                    '}'+
                                    '}');
                break;
            case "http":
                text = text.replace("HTTP_SETTINGS",'{'+
                                    '"host": ["'+ configJson.host +'"],'+
                                    '"path": "' + configJson.path + '"'+
                                    '}');
                text = text.replace("TLS_SETTINGS",'{'+
                                    '"allowInsecure": ' + configJson.insecure +','+
                                    '"serverName": null'+
                                    '}');
                text = text.replace("MYTLS", '"'+ configJson.tls + '"');
                break;
            case "ws":
                text = text.replace("WS_SETTINGS",'{'+
                                    '"path": "' + configJson.path + '",'+
                                    '"connectionReuse": true,'+
                                    '"headers": {'+
                                    '  "Host": "' + configJson.host + '"'+
                                    '}'+
                                    '}');
                text = text.replace("TLS_SETTINGS",'{'+
                                    '"allowInsecure": ' + configJson.insecure +','+
                                    '"serverName": null'+
                                    '}');
                text = text.replace("MYTLS", '"'+ configJson.tls + '"');
                break;
            case "kcp":
                text = text.replace("KCP_SETTINGS",'{'+
                                    '"header": {'+
                                    '"type": "' + configJson.type + '"'+
                                    '}'+
                                    '}');
                break;
            default:
                console.log("Do nothing");

            }

        }else{
            text = text.replace("MUX_ENABLE", false);
            text = text.replace("VNEXT_CONFIG", "null");
            text = text.replace("SERVERS_CONFIG",'[{' +
                                '"address": "' + configJson.server + '",' +
                                '"port": ' + configJson.port + ', '+
                                '"method": "' + configJson.security + '",' +
                                '"password": "' + configJson.uuid + '",' +
                                '"ota": false ,'+
                                '"level": 1'+
                                '}]');
            text = text.replace("NETWORK", "null");
        }

        // smart or global
        if (proxyTypeField.getVal() == "global"){
            text = text.replace(/OUTBOUND_DIRECT/g, "proxy");
        }else{
            text = text.replace(/OUTBOUND_DIRECT/g, "direct");
        }


        // clean marcs
        text = text.replace(/\:.*?_SETTINGS/g, ": null");
        text = text.replace("MYTLS", "null");

        var request = new XMLHttpRequest();
        request.open("PUT", v2rayConfPath, false);
        request.send(text);
        var status = request.status;
        return status == 0;
    }


    function callService(tmpState, callback){
        console.log("call service")
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
                                    ) {
                                       console.log("smart switch enabled!")
                                       if(callback)callback(tmpState);
                                   }
                               }
                           },
                           function(error) {
                               console.log("callService Error:" , error);
                               notification.show(qsTr("Start service error"));
                           });
    }

    function callProxy(tmpState, callback){
        console.log("call proxy")
        var args = [
                    {'type': 's', 'value': tmpState?'stopProxy':'startProxy'}
                ];
        proxyBus.typedCall('doProxy', args,
                           function(result) {
                               console.log("callProxy Debug:",result);
                               if(!result && !tmpState ){
                                   // callback
                                   activeState = false;
                                   notification.show(qsTr("Start smart proxy error"));
                               }else{
                                   systemdServiceIface.updateProperties();
                               }
                           },
                           function(error) {
                               console.log("callProxy Error:" , error);
                               activeState = false;
                               // stop svc
                               callService(true);
                               notification.show(qsTr("Start smart proxy error"));
                           });
    }

    Component.onCompleted: {
        DB.initialize();
        DB.signcenter = signalCenter;
        getFromConfFile();
        DB.queryall(allConfigsModel);
    }
}
