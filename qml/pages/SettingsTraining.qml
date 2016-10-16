/*
 * Copyright 2016 Marcus Soll
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.vocabulary.SettingsProxy 1.0

Dialog {
    id: page
    allowedOrientations: Orientation.All

    onAccepted: {
        settings.adaptiveTrainingCorrectPoints = correct.value
        settings.adaptiveTrainingWrongPoints = wrong.value
        settings.adaptiveTrainingEnabled = adaptive_enabled.checked
    }

    Component.onCompleted: {
        correct.value = settings.adaptiveTrainingCorrectPoints
        wrong.value = settings.adaptiveTrainingWrongPoints
        adaptive_enabled.checked = settings.adaptiveTrainingEnabled
    }

    SettingsProxy {
        id: settings
    }

    SilicaFlickable {

        VerticalScrollDecorator {}

        anchors.fill: parent

        contentHeight: column.height

        Column {
            id: column

            anchors {
                left: parent.left
                right: parent.right
                margins: Theme.paddingLarge
            }

            DialogHeader {
                title: qsTr("Adjust adaptive training")
                width: page.width
                acceptText: qsTr("Save")
                cancelText: qsTr("Abort")
            }

            Text {

                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.paddingSmall
                }

                focus: true
                color: Theme.primaryColor
                width: page.width
                font.pixelSize: Theme.fontSizeMedium
                wrapMode: Text.Wrap

                text: qsTr("The adaptive training mode is designed in a way that prefers new / unknown vocabulary over known vocabulary.

Each vocabulary gets a priority between 1 and 100 which starts at 100. Every time a vocabulary is remembered correctly the priority gets reduced, for every mistake the priority is increased. For every priority point the vocabulary gets an additional chance of getting drawn from the vocabulary pool.")
            }

            Slider {
                id: correct
                width: parent.width
                stepSize: 1
                minimumValue: 0
                maximumValue: 20
                label: qsTr("Priority lost on correct answers")
                valueText: "" + value
            }

            Slider {
                id: wrong
                width: parent.width
                stepSize: 1
                minimumValue: 0
                maximumValue: 20
                label: qsTr("Priority gained on wrong answers")
                valueText: "" + value
            }

            TextSwitch {
                id: adaptive_enabled
                width: parent.width
                text: qsTr("Enable adaptive training")
                description: qsTr("If the adaptive training mode is disabled, all vocabulary have the same chance of appearing. While disabled, the priority of vocabulary is not changed.")
            }
        }
    }
}
