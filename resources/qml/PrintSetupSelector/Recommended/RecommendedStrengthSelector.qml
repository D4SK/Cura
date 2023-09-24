// Copyright (c) 2022 UltiMaker
// Cura is released under the terms of the LGPLv3 or higher.

import QtQuick 2.7
import QtQuick.Controls 2.15
import QtQuick.Layouts 2.10

import UM 1.7 as UM
import Cura 1.7 as Cura


RecommendedSettingSection
{
    id: strengthSection

    title: catalog.i18nc("@label", "Strength")
    icon: UM.Theme.getIcon("Hammer")
    enableSectionSwitchVisible: false
    enableSectionSwitchEnabled: false
    tooltipText: catalog.i18nc("@label", "The following settings define the strength of your part.")

    UM.SettingPropertyProvider
    {
        id: infillSteps
        containerStackId: Cura.MachineManager.activeStackId
        key: "gradual_infill_steps"
        watchedProperties: ["value", "enabled"]
        storeIndex: 0
    }

    contents: [
        RecommendedSettingItem
        {
            settingName: catalog.i18nc("infill_sparse_density description", "Infill Density")
            tooltipText: catalog.i18nc("@label", "Adjusts the density of infill of the print.")
            settingControl: Cura.SingleSettingSlider
            {
                height: UM.Theme.getSize("combobox").height
                width: parent.width
                settingName: "infill_sparse_density"
                updateAllExtruders: true
                // disable slider when gradual support is enabled
                enabled: parseInt(infillSteps.properties.value) === 0

                function updateSetting(value)
                {
                    Cura.MachineManager.setSettingForAllExtruders("infill_sparse_density", "value", value)
                    Cura.MachineManager.resetSettingForAllExtruders("infill_line_distance")
                }
            }
        },
        RecommendedSettingItem
        {
            settingName: catalog.i18nc("@action:label", "Walls")
            tooltipText: catalog.i18nc("@label", "Defines the thickness of your part side walls.")
            settingControl: Cura.SingleSettingTextField
            {
                width: parent.width
                settingName: "wall_line_count"
                updateAllExtruders: true
                validator: UM.IntValidator {}
            }
        },
        RecommendedSettingItem
        {
            settingName: catalog.i18nc("@action:label", "Top Layers")
            tooltipText: catalog.i18nc("@label", "Defines the thickness of your parts roof.")
            settingControl: Cura.SingleSettingTextField
            {
                width: parent.width
                settingName: "top_layers"
                updateAllExtruders: true
                validator: UM.IntValidator {}
            }
        },
        RecommendedSettingItem
        {
            settingName: catalog.i18nc("@action:label", "Bottom Layers")
            tooltipText: catalog.i18nc("@label", "Defines the thickness of your parts floor")
            settingControl: Cura.SingleSettingTextField
            {
                width: parent.width
                settingName: "bottom_layers"
                updateAllExtruders: true
                validator: UM.IntValidator {}
            }
        }
    ]
}
