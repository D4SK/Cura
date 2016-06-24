// Copyright (c) 2015 Ultimaker B.V.
// Cura is released under the terms of the AGPLv3 or higher.

import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1

import UM 1.2 as UM
import Cura 1.0 as Cura

Rectangle
{
    id: base;

    property int currentModeIndex;
    property bool monitoringPrint: false

    // Is there an output device for this printer?
    property bool printerConnected: Cura.MachineManager.printerOutputDevices.length != 0
    onPrinterConnectedChanged: populatePrintMonitorModel()

    color: UM.Theme.getColor("sidebar");
    UM.I18nCatalog { id: catalog; name:"cura"}


    function showTooltip(item, position, text)
    {
        tooltip.text = text;
        position = item.mapToItem(base, position.x, position.y);
        tooltip.show(position);
    }

    function hideTooltip()
    {
        tooltip.hide();
    }

    function strPadLeft(string, pad, length) {
        return (new Array(length + 1).join(pad) + string).slice(-length);
    }

    function getPrettyTime(time)
    {
        var hours = Math.floor(time / 3600)
        time -= hours * 3600
        var minutes = Math.floor(time / 60);
        time -= minutes * 60
        var seconds = Math.floor(time);

        var finalTime = strPadLeft(hours, "0", 2) + ':' + strPadLeft(minutes,'0',2)+ ':' + strPadLeft(seconds,'0',2);
        return finalTime;
    }

    MouseArea
    {
        anchors.fill: parent
        acceptedButtons: Qt.AllButtons;

        onWheel:
        {
            wheel.accepted = true;
        }
    }

    // Mode selection buttons for changing between Setting & Monitor print mode
    Rectangle
    {
        id: sidebarHeaderBar
        anchors.left: parent.left
        anchors.right: parent.right
        height: childrenRect.height
        color: UM.Theme.getColor("sidebar_header_bar")

        Row
        {
            anchors.left: parent.left
            anchors.leftMargin: UM.Theme.getSize("default_margin").width;
            anchors.right: parent.right
            Button
            {
                width: (parent.width - UM.Theme.getSize("default_margin").width) / 2
                height: UM.Theme.getSize("sidebar_header").height
                onClicked: monitoringPrint = false
                iconSource: UM.Theme.getIcon("tab_settings");
                checkable: true
                checked: true
                exclusiveGroup: sidebarHeaderBarGroup

                style:  UM.Theme.styles.sidebar_header_tab
            }
            Button
            {
                width: (parent.width - UM.Theme.getSize("default_margin").width) / 2
                height: UM.Theme.getSize("sidebar_header").height
                onClicked: monitoringPrint = true
                iconSource: {
                    if(!printerConnected)
                    {
                        return UM.Theme.getIcon("tab_monitor")
                    } else if(Cura.MachineManager.printerOutputDevices[0].jobState == "paused")
                    {
                        return UM.Theme.getIcon("tab_monitor_paused")
                    } else if (Cura.MachineManager.printerOutputDevices[0].jobState != "error")
                    {
                        return UM.Theme.getIcon("tab_monitor_connected")
                    }
                }
                checkable: true
                exclusiveGroup: sidebarHeaderBarGroup

                style:  UM.Theme.styles.sidebar_header_tab
            }
            ExclusiveGroup { id: sidebarHeaderBarGroup }
        }
    }

    SidebarHeader {
        id: header
        width: parent.width
        height: totalHeightHeader

        anchors.top: sidebarHeaderBar.bottom
        anchors.topMargin: UM.Theme.getSize("default_margin").height

        onShowTooltip: base.showTooltip(item, location, text)
        onHideTooltip: base.hideTooltip()
    }

    Rectangle {
        id: headerSeparator
        width: parent.width
        height: UM.Theme.getSize("sidebar_lining").height
        color: UM.Theme.getColor("sidebar_lining")
        anchors.top: header.bottom
        anchors.topMargin: UM.Theme.getSize("default_margin").height
    }

    currentModeIndex:
    {
        var index = parseInt(UM.Preferences.getValue("cura/active_mode"))
        if(index)
        {
            return index;
        }
        return 0;
    }
    onCurrentModeIndexChanged:
    {
        UM.Preferences.setValue("cura/active_mode", currentModeIndex);
        if(modesListModel.count > base.currentModeIndex)
        {
            sidebarContents.push({ "item": modesListModel.get(base.currentModeIndex).item, "replace": true });
        }
    }

    Label {
        id: settingsModeLabel
        text: catalog.i18nc("@label:listbox","Print Setup");
        anchors.left: parent.left
        anchors.leftMargin: UM.Theme.getSize("default_margin").width;
        anchors.top: headerSeparator.bottom
        anchors.topMargin: UM.Theme.getSize("default_margin").height
        width: parent.width/100*45
        font: UM.Theme.getFont("large")
        color: UM.Theme.getColor("text")
        visible: !monitoringPrint
    }

    Rectangle {
        id: settingsModeSelection
        width: parent.width/100*55
        height: UM.Theme.getSize("sidebar_header_mode_toggle").height
        anchors.right: parent.right
        anchors.rightMargin: UM.Theme.getSize("default_margin").width
        anchors.top: headerSeparator.bottom
        anchors.topMargin: UM.Theme.getSize("default_margin").height
        visible: !monitoringPrint
        Component{
            id: wizardDelegate
            Button {
                height: settingsModeSelection.height
                anchors.left: parent.left
                anchors.leftMargin: model.index * (settingsModeSelection.width / 2)
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width / 2
                text: model.text
                exclusiveGroup: modeMenuGroup;
                checkable: true;
                checked: base.currentModeIndex == index
                onClicked: base.currentModeIndex = index

                style: ButtonStyle {
                    background: Rectangle {
                        border.width: UM.Theme.getSize("default_lining").width
                        border.color: control.checked ? UM.Theme.getColor("toggle_checked_border") :
                                          control.pressed ? UM.Theme.getColor("toggle_active_border") :
                                          control.hovered ? UM.Theme.getColor("toggle_hovered_border") : UM.Theme.getColor("toggle_unchecked_border")
                        color: control.checked ? UM.Theme.getColor("toggle_checked") :
                                   control.pressed ? UM.Theme.getColor("toggle_active") :
                                   control.hovered ? UM.Theme.getColor("toggle_hovered") : UM.Theme.getColor("toggle_unchecked")
                        Behavior on color { ColorAnimation { duration: 50; } }
                        Label {
                            anchors.centerIn: parent
                            color: control.checked ? UM.Theme.getColor("toggle_checked_text") :
                                       control.pressed ? UM.Theme.getColor("toggle_active_text") :
                                       control.hovered ? UM.Theme.getColor("toggle_hovered_text") : UM.Theme.getColor("toggle_unchecked_text")
                            font: UM.Theme.getFont("default")
                            text: control.text;
                        }
                    }
                    label: Item { }
                }
            }
        }
        ExclusiveGroup { id: modeMenuGroup; }
        ListView{
            id: modesList
            property var index: 0
            model: modesListModel
            delegate: wizardDelegate
            anchors.top: parent.top
            anchors.left: parent.left
            width: parent.width
        }
    }

    Label {
        id: monitorLabel
        text: catalog.i18nc("@label","Printer Monitor");
        anchors.left: parent.left
        anchors.leftMargin: UM.Theme.getSize("default_margin").width;
        anchors.top: headerSeparator.bottom
        anchors.topMargin: UM.Theme.getSize("default_margin").height
        width: parent.width/100*45
        font: UM.Theme.getFont("large")
        color: UM.Theme.getColor("text")
        visible: monitoringPrint
    }

    StackView
    {
        id: sidebarContents

        anchors.bottom: footerSeparator.top
        anchors.top: settingsModeSelection.bottom
        anchors.topMargin: UM.Theme.getSize("default_margin").height
        anchors.left: base.left
        anchors.right: base.right
        visible: !monitoringPrint

        delegate: StackViewDelegate
        {
            function transitionFinished(properties)
            {
                properties.exitItem.opacity = 1
            }

            pushTransition: StackViewTransition
            {
                PropertyAnimation
                {
                    target: enterItem
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: 100
                }
                PropertyAnimation
                {
                    target: exitItem
                    property: "opacity"
                    from: 1
                    to: 0
                    duration: 100
                }
            }
        }
    }

    // Item that shows the print monitor properties
    Column
    {
        id: printMonitor

        anchors.bottom: footerSeparator.top
        anchors.top: monitorLabel.bottom
        anchors.topMargin: UM.Theme.getSize("default_margin").height
        anchors.left: base.left
        anchors.leftMargin: UM.Theme.getSize("default_margin").width
        anchors.right: base.right
        visible: monitoringPrint

        Loader
        {
            sourceComponent: monitorSection
            property string label: catalog.i18nc("@label", "Temperatures")
        }
        Repeater
        {
            model: machineExtruderCount.properties.value
            delegate: Loader
            {
                sourceComponent: monitorItem
                property string label: machineExtruderCount.properties.value > 1 ? catalog.i18nc("@label", "Hotend Temperature %1").arg(index + 1) : catalog.i18nc("@label", "Hotend Temperature")
                property string value: printerConnected ? Math.round(Cura.MachineManager.printerOutputDevices[0].hotendTemperatures[index]) + "°C" : ""
            }
        }
        Repeater
        {
            model: machineHeatedBed.properties.value == "True" ? 1 : 0
            delegate: Loader
            {
                sourceComponent: monitorItem
                property string label: catalog.i18nc("@label", "Bed Temperature")
                property string value: printerConnected ? Math.round(Cura.MachineManager.printerOutputDevices[0].bedTemperature) + "°C" : ""
            }
        }

        Loader
        {
            sourceComponent: monitorSection
            property string label: catalog.i18nc("@label", "Active print")
        }
        Loader
        {
            sourceComponent: monitorItem
            property string label: catalog.i18nc("@label", "Job Name")
            property string value: printerConnected ? Cura.MachineManager.printerOutputDevices[0].jobName : ""
        }
        Loader
        {
            sourceComponent: monitorItem
            property string label: catalog.i18nc("@label", "Printing Time")
            property string value: printerConnected ? getPrettyTime(Cura.MachineManager.printerOutputDevices[0].timeTotal) : ""
        }
        Loader
        {
            sourceComponent: monitorItem
            property string label: catalog.i18nc("@label", "Estimated time left")
            property string value: printerConnected ? getPrettyTime(Cura.MachineManager.printerOutputDevices[0].timeTotal - Cura.MachineManager.printerOutputDevices[0].timeElapsed) : ""
        }
        Loader
        {
            sourceComponent: monitorItem
            property string label: catalog.i18nc("@label", "Current Layer")
            property string value: printerConnected ? "0" : ""
        }

        Component
        {
            id: monitorItem

            Row
            {
                Label
                {
                    text: label
                    color: UM.Theme.getColor("setting_control_text");
                    font: UM.Theme.getFont("default");
                    width: base.width * 0.4
                    elide: Text.ElideRight;
                }
                Label
                {
                    text: value
                    color: UM.Theme.getColor("setting_control_text");
                    font: UM.Theme.getFont("default");
                }
            }
        }
        Component
        {
            id: monitorSection

            Rectangle
            {
                color: UM.Theme.getColor("setting_category")
                width: base.width - 2 * UM.Theme.getSize("default_margin").width
                height: UM.Theme.getSize("section").height

                Label
                {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: UM.Theme.getSize("default_margin").width
                    text: label
                    font: UM.Theme.getFont("setting_category")
                    color: UM.Theme.getColor("setting_category_text")
                }
            }
        }
    }

    Rectangle
    {
        id: footerSeparator
        width: parent.width
        height: UM.Theme.getSize("sidebar_lining").height
        color: UM.Theme.getColor("sidebar_lining")
        anchors.bottom: saveButton.top
        anchors.bottomMargin: UM.Theme.getSize("default_margin").height
    }

    SaveButton
    {
        id: saveButton
        implicitWidth: base.width
        implicitHeight: totalHeight
        anchors.bottom: parent.bottom
        visible: !monitoringPrint
    }

    MonitorButton
    {
        id: monitorButton
        implicitWidth: base.width
        implicitHeight: totalHeight
        anchors.bottom: parent.bottom
        visible: monitoringPrint
    }


    SidebarTooltip
    {
        id: tooltip;
    }

    ListModel
    {
        id: modesListModel;
    }

    SidebarSimple
    {
        id: sidebarSimple;
        visible: false;

        onShowTooltip: base.showTooltip(item, location, text)
        onHideTooltip: base.hideTooltip()
    }

    SidebarAdvanced
    {
        id: sidebarAdvanced;
        visible: false;

        onShowTooltip: base.showTooltip(item, location, text)
        onHideTooltip: base.hideTooltip()
    }

    Component.onCompleted:
    {
        modesListModel.append({ text: catalog.i18nc("@title:tab", "Simple"), item: sidebarSimple })
        modesListModel.append({ text: catalog.i18nc("@title:tab", "Advanced"), item: sidebarAdvanced })
        sidebarContents.push({ "item": modesListModel.get(base.currentModeIndex).item, "immediate": true });
    }

    UM.SettingPropertyProvider
    {
        id: machineExtruderCount

        containerStackId: Cura.MachineManager.activeMachineId
        key: "machine_extruder_count"
        watchedProperties: [ "value" ]
        storeIndex: 0
    }

    UM.SettingPropertyProvider
    {
        id: machineHeatedBed

        containerStackId: Cura.MachineManager.activeMachineId
        key: "machine_heated_bed"
        watchedProperties: [ "value" ]
        storeIndex: 0
    }
}