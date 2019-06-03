import QtQuick 2.0
import Sailfish.Silica 1.0
import "./database.js" as DB

Page {

    property variant thisconfig
    property QtObject signalCenter
    property bool isVmess: vtypeField.value == "VMess"
    readonly property var uuidValidator: RegExpValidator { regExp: /[0-9a-z]{8}-[0-9a-z]{4}-[0-9a-z]{4}-[0-9a-z]{4}-[0-9a-z]{12}/ }
    readonly property var pwdValidator: RegExpValidator { regExp: /[0-9a-zA-Z_\-!\@\#\%\|\?\^\&\*\(\)\.\;\'\$]{1,}/ }

    backNavigation: remarkField.text ? false : true

    // reset combox currentIndex
    onIsVmessChanged: {
        securitytField.currentIndex = 0 ;
    }

    Connections{
        target: signalCenter
        onAddSuccess: {
            pageStack.pop(PageStackAction.Animated);
        }
        onUpdateSuccess: {
            pageStack.pop(PageStackAction.Animated);
        }
    }


    function getCurrentIndex(combox, value){
        for (var i=0; i<combox.menu._contentColumn.children.length; i++) {
            var child = combox.menu._contentColumn.children[i];
            if (child && child.visible && child.hasOwnProperty("__silica_menuitem")) {
                if (child.text === value) {
                    return i;
                }
            }
        }
        return 0;
    }

    RemorsePopup{
        id: remorse
    }

    SilicaFlickable {
        anchors.fill: parent
        width: parent.width
        contentHeight: column.height

        PullDownMenu{
            MenuItem{
                text: qsTr("Discard")
                onClicked: {
                    remorse.execute(qsTr("Discarding"), function(){
                        pageStack.pop();
                    }, 2500);
                }
            }

            MenuItem{
                text:qsTr("Save")
                enabled: remarkField.text &&
                         vtypeField.value &&
                         serverField.text &&
                         portField.text &&
                         uuidField.text &&
                         alterField.text;


                onClicked: {
                    var config = {
                        "remark": remarkField.text,
                        "vtype": vtypeField.value,
                        "server": serverField.text,
                        "port": portField.text,
                        "uuid": uuidField.text,
                        "alterid": alterField.text,
                        "security": securitytField.value,
                        "network": networkField.value,
                        "type": typeField.value,
                        "host": hostField.text,
                        "path": pathField.text,
                        "tls": tlsField.value,
                        "insecure": allowInsecureField.value
                    };
                    var configJson = JSON.stringify(config);
                    console.log("config json:", configJson);
                    DB.addconfig(remarkField.text, vtypeField.value, configJson);
                }
            }
        }
        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingSmall

            PageHeader {
                title: qsTr("Add Server Node")
            }


            ComboBox{
                id: vtypeField
                width: parent.width
                label: qsTr("Vtype")
                enabled: !thisconfig.remark
                description: qsTr("The proxy server type")
                currentIndex: getCurrentIndex(vtypeField,thisconfig.vtype)
                menu: ContextMenu {
                    MenuItem {
                        text: "VMess"
                    }
                    MenuItem {
                        text: "ShadowSocks"
                    }
                }
            }

            Item{
                width: parent.width
                height: Theme.itemSizeSmall
            }

            

            TextField{
                id: remarkField
                placeholderText: qsTr("Enter your description of this node")
                label: qsTr("Remark")
                width: parent.width
                enabled: !thisconfig.remark
                opacity: thisconfig.remark ? 0.6: 1
                inputMethodHints: Qt.ImhNoAutoUppercase
                EnterKey.enabled: text || inputMethodComposing
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: serverField.focus = true
                text: thisconfig.remark || ""

            }

            TextField{
                id: serverField
                placeholderText: qsTr("Enter your server IP or domain")
                label: qsTr("Server")
                width: parent.width
                inputMethodHints: Qt.ImhUrlCharactersOnly
                EnterKey.enabled: text || inputMethodComposing
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: portField.focus = true
                text: thisconfig.server || ""

            }

            TextField{
                id: portField
                width: parent.width
                placeholderText: qsTr("Enter your server port")
                label: qsTr("Port")
                inputMethodHints: Qt.ImhDigitsOnly
                EnterKey.enabled: text || inputMethodComposing
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: uuidField.focus = true
                text: thisconfig.port || ""
            }

            TextField{
                id: uuidField
                width: parent.width
                placeholderText:  isVmess ? qsTr("Enter your uuid") : qsTr("Enter your password")
                label: isVmess ? qsTr("UUID") : qsTr("Password")
                EnterKey.enabled: text || inputMethodComposing
                inputMethodHints: Qt.ImhUrlCharactersOnly
                validator: isVmess ? uuidValidator : pwdValidator
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: alterField.focus = true
                text: thisconfig.uuid || ""
            }

            ComboBox{
                id: securitytField
                label: qsTr("Security")
                description: isVmess ? qsTr("Use auto if you are not sure") : ""
                width: parent.width
                currentIndex: getCurrentIndex(securitytField,thisconfig.security)
                menu: ContextMenu {
                        Repeater {
                            model: isVmess ? vmessTypeModel : ssTypeModel
                            MenuItem {
                                text: label
                            }
                        }
                    }
            }



            Column{
                visible: isVmess
                width: parent.width
                spacing: Theme.paddingSmall
                TextField{
                    id: alterField
                    width: parent.width
                    placeholderText: qsTr("Enter your alter id")
                    label: qsTr("AlterID")
                    inputMethodHints: Qt.ImhDigitsOnly
                    EnterKey.enabled: text || inputMethodComposing
                    EnterKey.iconSource: "image://theme/icon-m-enter-close"
                    EnterKey.onClicked: {
                        alterField.focus = false
                    }
                    text: thisconfig.alterid || 64
                }

                ComboBox{
                    id: networkField
                    label: qsTr("NetworkType")
                    description: qsTr("Default is tcp")
                    width: parent.width
                    currentIndex: getCurrentIndex(networkField,thisconfig.network)
                    menu: ContextMenu {
                        MenuItem {
                            text: "tcp"
                        }
                        MenuItem {
                            text: "kcp"
                        }
                        MenuItem {
                            text: "ws"
                        }
                        MenuItem {
                            text: "h2"
                        }
                    }
                }

                SectionHeader{
                    text: qsTr("Use default if you are not sure below")
                }

                ComboBox{
                    id: typeField
                    label: qsTr("Camouflage type")
                    description: qsTr("tcp or kcp camouflage type, default is none")
                    width: parent.width
                    currentIndex: getCurrentIndex(typeField,thisconfig.type)
                    menu: ContextMenu {
                        MenuItem {
                            text: "none"
                        }
                        MenuItem {
                            text: "http"
                        }
                    }
                }

                TextField {
                    id: hostField
                    label: qsTr("Camouflage host")
                    inputMethodHints: Qt.ImhUrlCharactersOnly
                    placeholderText: "http host, ws host " + qsTr("or") +" h2 host"
                    width: parent.width - Theme.horizontalPageMargin
                    font.pixelSize: Theme.fontSizeSmall
                    text: thisconfig.host || ""
                    EnterKey.iconSource: "image://theme/icon-m-enter-next"
                    EnterKey.onClicked: pathField.focus = true
                }

                TextField {
                    id: pathField
                    label: qsTr("Path")
                    placeholderText: "ws path " + qsTr("or") + " h2 path"
                    width: parent.width
                    EnterKey.iconSource: "image://theme/icon-m-enter-next"
                    EnterKey.onClicked: tlsField.focus = true
                    font.pixelSize: Theme.fontSizeSmall
                    inputMethodHints: Qt.ImhUrlCharactersOnly
                    text: thisconfig.path || ""
                }

                ComboBox{
                    id: tlsField
                    label: qsTr("TLS Settings")
                    width: parent.width
                    currentIndex: getCurrentIndex(tlsField,thisconfig.tls)
                    menu: ContextMenu {
                        MenuItem {
                            text: "none"
                        }
                        MenuItem {
                            text: "tls"
                        }
                    }
                }

                ComboBox{
                    id: allowInsecureField
                    label: qsTr("Allow insecure")
                    description: qsTr("Default is true")
                    visible: tlsField.value === "tls"
                    currentIndex: getCurrentIndex(allowInsecureField,thisconfig.insecure)
                    width: parent.width
                    menu: ContextMenu {
                        MenuItem {
                            text: "true"
                        }
                        MenuItem {
                            text: "false"
                        }
                    }
                }

            }
            Item{
                width: parent.width
                height: Theme.itemSizeMedium
            }

        }
    }


    ListModel {
        id: vmessTypeModel
        ListElement {
            label: "auto"
        }
        ListElement {
            label: "none"
        }
        ListElement {
            label: "aes-128-gcm"
        }
        ListElement {
            label: "chacha20-poly1305"
        }
        ListElement {
            label: "chacha20-ietf-poly1305"
        }
    }
    
    ListModel {
        id: ssTypeModel
        ListElement {
            label: "aes-256-cfb"
        }
        ListElement {
            label: "aes-128-cfb"
        }
        ListElement {
            label: "chacha20"
        }
        ListElement {
            label: "chacha20-ietf"
        }
        ListElement {
            label: "aes-256-gcm"
        }
        ListElement {
            label: "aes-128-gcm"
        }
        ListElement {
            label: "chacha20-poly1305"
        }
        ListElement {
            label: "chacha20-ietf-poly1305"
        }
    }

    Component.onCompleted: {
        
    }
}
