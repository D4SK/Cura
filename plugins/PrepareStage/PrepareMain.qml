//Copyright (c) 2021 Ultimaker B.V.
//Cura is released under the terms of the LGPLv3 or higher.

import QtQuick 2.4

import UM 1.0 as UM
import Cura 1.0 as Cura

Item
{
    id: prepareMain

    Cura.ActionPanelWidget
    {
        id: actionPanelWidget
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: UM.Theme.getSize("main_window_header").height
        anchors.bottomMargin: UM.Theme.getSize("thick_margin").height
    }
}