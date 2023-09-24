// Copyright (c) 2022 UltiMaker
// Cura is released under the terms of the LGPLv3 or higher.

import QtQuick 2.7
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.10

import UM 1.7 as UM
import Cura 1.7 as Cura


RecommendedSettingSection
{
    id: speedSection

    title: catalog.i18nc("@label", "Speed")
    icon: UM.Theme.getIcon("SpeedOMeter")
    enableSectionSwitchVisible: false
    enableSectionSwitchEnabled: false
    tooltipText: catalog.i18nc("@label", "The following settings define the print speed")

    contents: [
        RecommendedSettingItem
        {
            settingName: catalog.i18nc("@action:label", "Speed Preset")
            tooltipText: catalog.i18nc("@label",
            "Change the printing speed.\nPrinting slower can be better for small details and will create sharper corners.\nPush the printing speed to the max for production runs or quick prototypes.\nThis works best if the material is in good (dry) condition")

            settingControl: Cura.SingleSettingComboBox
            {
                width: parent.width
                settingName: "speed_mode"
                updateAllExtruders: true
            }
        }
    ]
}
