// Copyright (c) 2018 Ultimaker B.V.
// Cura is released under the terms of the LGPLv3 or higher.

import QtQuick 2.7
import QtQuick.Controls 2.3

import UM 1.3 as UM
import Cura 1.0 as Cura

import "Recommended"
import "Custom"

Item
{
    id: content

    property int absoluteMinimumHeight: 200 * screenScaleFactor
    implicitWidth: UM.Theme.getSize("print_setup_widget").width
    implicitHeight: contents.height + buttonRow.height
    enum Mode
    {
        Recommended = 0,
        Custom = 1
    }

    // Catch all mouse events
    MouseArea
    {
        anchors.fill: parent
        hoverEnabled: true
    }

    // Set the current mode index to the value that is stored in the preferences or Recommended mode otherwise.
    property int currentModeIndex:
    {
        var index = Math.round(UM.Preferences.getValue("cura/active_mode"))

        if (index != null && !isNaN(index))
        {
            return index
        }
        return PrintSetupSelectorContents.Mode.Recommended
    }
    onCurrentModeIndexChanged: UM.Preferences.setValue("cura/active_mode", currentModeIndex)

    Item
    {
        id: contents
        // Use the visible property instead of checking the currentModeIndex. That creates a binding that
        // evaluates the new height every time the visible property changes.
        height: recommendedPrintSetup.visible ? recommendedPrintSetup.height : customPrintSetup.height

        anchors
        {
            top: parent.top
            left: parent.left
            right: parent.right
        }

        RecommendedPrintSetup
        {
            id: recommendedPrintSetup
            anchors
            {
                left: parent.left
                right: parent.right
                top: parent.top
            }
            visible: currentModeIndex == PrintSetupSelectorContents.Mode.Recommended
            height: base.height - parent.y - UM.Theme.getSize("default_margin").height*20;

            function onModeChanged()
            {
                currentModeIndex = PrintSetupSelectorContents.Mode.Custom;
            }
        }

        CustomPrintSetup
        {
            id: customPrintSetup
            anchors
            {
                left: parent.left
                right: parent.right
                top: parent.top
            }
            height: base.height - parent.y - UM.Theme.getSize("default_margin").height*20;
            visible: currentModeIndex == PrintSetupSelectorContents.Mode.Custom
        }
    }

    Item
    {
        id: buttonRow
        property real padding: UM.Theme.getSize("default_margin").width
        height:
        {
            const draggable_area_height = draggableArea.visible ? draggableArea.height : 0;
            if (currentModeIndex == PrintSetupSelectorContents.Mode.Custom)
            {
                return recommendedButton.height + 2 * padding + draggable_area_height;
            }
            return draggable_area_height;
        }

        anchors
        {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }

        Cura.SecondaryButton
        {
            id: recommendedButton
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.margins: parent.padding
            leftPadding: UM.Theme.getSize("default_margin").width
            rightPadding: UM.Theme.getSize("default_margin").width
            text: catalog.i18nc("@button", "Recommended")
            iconSource: UM.Theme.getIcon("ChevronSingleLeft")
            visible: currentModeIndex == PrintSetupSelectorContents.Mode.Custom
            onClicked: currentModeIndex = PrintSetupSelectorContents.Mode.Recommended
        }
    }
}
