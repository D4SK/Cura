
// Copyright (c) 2022 Ultimaker B.V.
// Cura is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 2.3

import UM 1.5 as UM
import Cura 1.0 as Cura

Item
{
    id: objectSelector
    width: UM.Theme.getSize("objects_menu_size").width

    // Eat up all the mouse events (we don't want the scene to react or have the scene context menu showing up)
    MouseArea
    {
        anchors.fill: parent
        acceptedButtons: Qt.AllButtons
    }

    Rectangle
    {
        id: contents
        width: parent.width
        height: listView.height + border.width * 2
        color: UM.Theme.getColor("main_background")
        border.width: UM.Theme.getSize("default_lining").width
        border.color: UM.Theme.getColor("lining")

        Behavior on height { NumberAnimation { duration: 100 } }

        anchors.bottom: parent.bottom

        property var extrudersModel: CuraApplication.getExtrudersModel()
        UM.SettingPropertyProvider
        {
            id: machineExtruderCount

            containerStack: Cura.MachineManager.activeMachine
            key: "machine_extruder_count"
            watchedProperties: [ "value" ]
            storeIndex: 0
        }

        ListView
        {
            id: listView
            anchors
            {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: UM.Theme.getSize("default_lining").width
            }
            property real maximumHeight: UM.Theme.getSize("objects_menu_size").height
            height: Math.min(contentHeight, maximumHeight)

            ScrollBar.vertical: UM.ScrollBar
            {
                id: scrollBar
            }
            clip: true

            model: Cura.ObjectsModel {}

            delegate: ObjectItemButton
            {
                id: modelButton
                Binding
                {
                    target: modelButton
                    property: "checked"
                    value: model.selected
                }
                text: model.name
                width: listView.width - scrollBar.width
                property bool outsideBuildArea: model.outside_build_area
                property int perObjectSettingsCount: model.per_object_settings_count
                property string meshType: model.mesh_type
                property int extruderNumber: model.extruder_number
                property string extruderColor:
                {
                    if (model.extruder_number == -1)
                    {
                        return "";
                    }
                    return contents.extrudersModel.getItem(model.extruder_number).color;
                }
                property bool showExtruderSwatches: machineExtruderCount.properties.value > 1
            }
        }
    }
}
