import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import QtQuick.Controls.Material 2.2
import QtQuick.Dialogs 1.3

import Company.ServiceContactList 1.0
import Company.ServiceDeleteContact 1.0


import "../Componnet/Button" as MyButtonComponnent

Item {
    Component.onCompleted: { busyIndicator.visible = true; serviceContactList.requestContactList(); opacityAnimation.start() }

    property bool    refreshBusy: false
    property string  selectItems: ""

    NumberAnimation { id: opacityAnimation;  target: itemsListview; properties: "opacity"; from: 0.0; to: 1.0; duration: 700 }

    ServiceDeleteContact{
        id: serviceDeleteContact

        onSignalDeleteContactSuccess: {
            selectItems = "";
            busyIndicator.visible = true
            serviceContactList.requestContactList();
        }

        onSignalFaile: {
            busyIndicator.visible = false
            messageDialog.title = titleMsg
            messageDialog.text  = textMsg
            messageDialog.open()
        }
    }

    ServiceContactList{
        id: serviceContactList

        onSignalFaile: {
            busyIndicator.visible = false
            messageDialog.title = titleMsg
            messageDialog.text  = textMsg
            messageDialog.open()
        }
    }

    MessageDialog   {
        id: messageDialog

        onYes: {
            if(!selectItems)
            {
                messageDialog.title = "Warning"
                messageDialog.text  = "Please Select Item List"
                messageDialog.standardButtons = StandardButton.Ok
                messageDialog.open()
            }
            else
            {
                busyIndicator.visible = true
                serviceDeleteContact.requestDeleteContactList(selectItems.substring(0, selectItems.length-1))
            }
        }
    }

    ListView {
        id: itemsListview
        model: serviceContactList.modelContactList.listProperty
        delegate: delegateContent
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: btnDelete.top
        anchors.margins: 10
        spacing: 5
        cacheBuffer: 2000
        displayMarginBeginning: 400
        displayMarginEnd: 400
        ScrollIndicator.vertical: ScrollIndicator { }
        // highlight: highlight
        // highlightFollowsCurrentItem: false
        // highlight: Rectangle { color: "lightsteelblue"; radius: 5 }
        focus: true
        opacity: 0
        clip: true

        onFlickStarted:{
            if (atYBeginning)
                if (contentY < -50 ){
                    refreshBusy = true
                    serviceContactList.requestContactList();
                }
        }

        header: BusyIndicator {
            id: busyIndicatorRefresh; width: 40
            height:  refreshBusy ? 40 : 0
            visible: refreshBusy
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    MyButtonComponnent.CustomeButton {
        id: btnDelete
        buttonText: "Delete Contact"
        enabled: true
        buttonFontSize: 14
        buttonBackColor: Material.color(Material.Red)
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        width: controlWidth
        buttonHeight: 35
        onClicked: {
            messageDialog.title = "Question"
            messageDialog.text  = "Do you want delete contact?"
            messageDialog.standardButtons = StandardButton.Yes | StandardButton.No
            messageDialog.open()
        }
    }

    Component {
        id: highlight

        Rectangle {
            width: itemsListview.width; height: 40
            color: "lightsteelblue"; radius: 5
            y: itemsListview.currentItem.y

            Behavior on y { SpringAnimation { spring: 3; damping: 0.2 } }
        }
    }

    Timer{
        id: timer
        interval: 2000
        running: false
        onTriggered: { refreshBusy = false; running = false }
    }

    Component {
        id :delegateContent

        RowLayout{
            spacing: 10
            width: itemsListview.width
            Component.onCompleted: { busyIndicator.visible = false; refreshBusy = false; timer.running = true }

            Image {
                width: 130; height: 100
                fillMode: Image.PreserveAspectFit
                source: "/Image/profile/user-"+ lbPhoneNumber.text.substring(11,10) +".svg"
                sourceSize: "30x30"
            }

            CheckBox {
                id: checkBox
                Layout.preferredWidth: 20;
                Layout.alignment: Qt.AlignLeft
                onCheckStateChanged: checkBox.checked ? selectItems += "'"+ lbPhoneNumber.text + "'," : selectItems = selectItems.replace("'"+ lbPhoneNumber.text + "',", "")
            }

            Label {
                id: lbName
                Layout.alignment: Qt.AlignLeft
                text: family + " " + name
                Layout.preferredWidth: parent.width - 180
                elide: Text.ElideRight
                font { family: myStyle.iranSanceFontL; pixelSize: 12 }
            }

            Label {
                id: lbPhoneNumber
                Layout.alignment: Qt.AlignRight
                text: phoneNumber
                Layout.preferredWidth: 100
                font { family: myStyle.iranSanceFontL; pixelSize: 12 }
            }

            MouseArea{
                anchors.fill: parent
                onClicked: checkBox.checked = !checkBox.checked
            }
        }
    }
}
