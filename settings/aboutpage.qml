import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
id: aboutPage
    allowedOrientations: Orientation.Landscape | Orientation.Portrait | Orientation.LandscapeInverted

    SilicaFlickable {
        id: about
        anchors.fill: parent
        contentHeight: aboutRectangle.height

        VerticalScrollDecorator { flickable: about }

        Column {
            id: aboutRectangle
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            spacing: Theme.paddingSmall

            PageHeader {
                title: qsTr("About")
            }

            Image {
                source: "./v2ray.png"
                sourceSize.width: parent.width/4
                sourceSize.height: parent.width/4
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Label {
                text: "ShadowFish"
                horizontalAlignment: Text.Center
                width: parent.width - Theme.paddingLarge * 2
                anchors.horizontalCenter: parent.horizontalCenter
            }

            SectionHeader {
                text: qsTr("How to use")
            }

            Label {
                textFormat: Text.RichText;
                text: '<style>a:link { color: ' + Theme.highlightColor + '; }</style>' +
                      qsTr('This app is based on ') + ' <a href="https://www.v2ray.com/">v2ray-core</a>, ' +
                      qsTr('before start, take a look at how to use v2ray.' +
                      'Recommend server side config is %1 , the '+
                      'default by v2ray is OK too.').arg("<a href='https://paste.ubuntu.com/p/DqpB54MrRG/'>https://paste.ubuntu.com/p/DqpB54MrRG</a> ") +
                      qsTr('The template file is ') + '/home/nemo/.config/v2ray/config.json.template, ' +
                      qsTr('Default socks port is 1080, and a dokodemo-door port 12345') + '<br/><br/>' +
                      qsTr('About <b>Filled from Clipboard</b> feature, use CodeReader and scan qrcode from %1').arg(
                      '<a href="https://github.com/2dust/v2rayN">v2rayN</a>') + '<br/><br/>' +
                       'icon: <a href="https://www.iconfont.cn/user/detail?spm=a313x.7781069.0.d214f71f6&uid=58295">i3yc from iconfont.cn</a>'
                      ;
                width: parent.width - Theme.paddingLarge * 2
                anchors.horizontalCenter: parent.horizontalCenter
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.fontSizeSmall

                onLinkActivated: {
                    Qt.openUrlExternally(link);
                }
            }

            SectionHeader {
                text: qsTr("Donate")
            }

            TextArea{
                text: "Bitcoin: 1BPVYkr4rGxeDidWPGR48Apgn2NvfdRFKc "+
                      "ETH: 0x7434586e839d9cce25930C2D3369951894bEc34B "
                focusOnClick: true
                horizontalAlignment: TextInput.AlignLeft
                wrapMode: Text.WordWrap
                width: parent.width - Theme.paddingLarge
                EnterKey.onClicked: parent.focus = true
                font.pixelSize: Theme.fontSizeSmall
                Component.onCompleted: {
                    readOnly = true;
                }
            }
        }
    }
}
