import QtQuick 2.0
import Sailfish.Silica 1.0
import "./fileutil.js" as FileUtil

Page {
    id: page
    allowedOrientations: Orientation.Portrait
    property string errorlog_path: "/var/log/v2ray/error.log"

    SilicaFlickable {
        id: flickable
        anchors.fill: parent
        contentHeight: column.height
        VerticalScrollDecorator { flickable: flickable }

        Column {
            id: column
            x: Theme.horizontalPageMargin
            width: parent.width - 2*x

            PageHeader {
                title: qsTr("Log")
            }

            Label {
                id: portraitText
                textFormat: Text.PlainText
                width: parent.width
                wrapMode: Text.WrapAnywhere
                font.pixelSize: Theme.fontSizeTiny
                font.family: "Monospace"
                color: Theme.secondaryColor
                visible: page.orientation === Orientation.Portrait ||
                         page.orientation === Orientation.PortraitInverted
            }
            Item {
                width: parent.width
                height: 2*Theme.paddingLarge
                visible: message.text !== ""
            }
            Label {
                id: message
                width: parent.width
                wrapMode: Text.Wrap
                // show medium size if there is no portrait (or landscape text)
                // in that case, this message becomes main message
                font.pixelSize: portraitText.text === "" ? Theme.fontSizeMedium : Theme.fontSizeTiny
                color: portraitText.text === "" ? Theme.highlightColor : Theme.secondaryColor
                horizontalAlignment: Text.AlignHCenter
                visible: message.text !== ""
            }
            Item {
                width: parent.width
                height: 2*Theme.paddingLarge
                visible: message.text !== ""
            }
        }
    }

    function getFromConfFile(){
        FileUtil.doesFileExist(errorlog_path, function(o){
            if(!o.responseText){
                message.text = qsTr("log file not exist")
            }else{
                FileUtil.getFile(errorlog_path, function(o){
                    try{
                        portraitText.text = o.responseText;
                    }catch(e){
                        message.text = e.toString();
                    }
                });
            }

        });
    }

    onStatusChanged: {
        if (status === PageStatus.Activating) {
            getFromConfFile();
        }
    }
}
