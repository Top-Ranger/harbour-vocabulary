/*
 * Copyright 2016,2020 Marcus Soll
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

Page {
    id: page
    allowedOrientations: Orientation.All

    property bool word_added: false // Added for compatibility with Add.qml

    SettingsProxy {
        id: settings_proxy
    }

    SilicaFlickable {
        anchors.fill: parent

        VerticalScrollDecorator {}

        PullDownMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.push(Qt.resolvedUrl("About.qml"))
            }

            MenuItem {
                text: qsTr("Adjust adaptive training")
                onClicked: pageStack.push(Qt.resolvedUrl("SettingsTraining.qml"))
            }

            MenuItem {
                text: qsTr("Import / Export")
                onClicked: pageStack.push(Qt.resolvedUrl("ImExport.qml"))
            }
        }

        contentHeight: column.height

        Column {
            id: column
            width: page.width
            spacing: Theme.paddingMedium

            PageHeader {
                title: qsTr("Vocabulary Trainer")
            }

            BackgroundItem {
                width: parent.width
                enabled: simple_interface.count > 0
                Label {
                    text: qsTr("Start training")
                    anchors.centerIn: parent
                    color: simple_interface.count === 0 ? Theme.secondaryColor : Theme.primaryColor
                }

                onClicked: {
                    if(settings_proxy.trainingDirectStart) {
                        pageStack.push(Qt.resolvedUrl("Training.qml"))
                    }
                    else {
                        pageStack.push(Qt.resolvedUrl("FiltersTraining.qml"))
                    }
                }
            }

            BackgroundItem {
                width: parent.width
                Label {
                    text: qsTr("Show all vocabulary")
                    anchors.centerIn: parent
                }

                onClicked: pageStack.push(Qt.resolvedUrl("List.qml"))
            }

            BackgroundItem {
                width: parent.width
                Label {
                    text: qsTr("Add vocabulary")
                    anchors.centerIn: parent
                }

                onClicked: pageStack.push(Qt.resolvedUrl("Add.qml"))
            }

            BackgroundItem {
                width: parent.width
                Label {
                    text: qsTr("Manage languages")
                    anchors.centerIn: parent
                }

                onClicked: pageStack.push(Qt.resolvedUrl("Languages.qml"))
            }
        }
    }
}
