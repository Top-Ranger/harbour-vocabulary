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
import harbour.vocabulary.CSVHandle 1.0

Page {
    id: page
    allowedOrientations: Orientation.All
    property string path: ""
    property bool started: false

    CSVHandle {
        id: handle
    }

    SilicaFlickable {
        anchors.fill: parent

        VerticalScrollDecorator {}

        contentHeight: column.height

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingMedium

            PageHeader {
                title: qsTr("Export CSV")
            }

            Label {
                text: qsTr("Settings:")
            }

            ComboBox {
                id: seperator_select
                width: parent.width
                label: qsTr("Seperator")

                menu: ContextMenu {
                    MenuItem { text: qsTr("Tab") }
                    MenuItem { text: qsTr("Space") }
                    MenuItem { text: qsTr("Comma") }
                    MenuItem { text: qsTr("Semicolon") }
                }
            }

            TextSwitch {
                checked: true
                id: header
                width: parent.width
                text: qsTr("Add header")
            }

            Button {
                width: parent.width
                enabled: !page.started
                text: qsTr("Export")
                onClicked: {
                    page.started = true
                    var seperator = CSVHandle.TAB

                    switch(seperator_select.currentIndex) {
                    case 0:
                        seperator = CSVHandle.TAB
                        break
                    case 1:
                        seperator = CSVHandle.SPACE
                        break
                    case 2:
                        seperator = CSVHandle.COMMA
                        break
                    case 3:
                        seperator = CSVHandle.SEMICOLON
                        break
                    }

                    var results = handle.saveCSV(page.path, seperator, header.checked)
                    if(results.length === 0) {
                        errors.text = qsTr("Successfully exported")
                    }
                    else {
                        var results_text = qsTr("Error while exporting! Data might not be complete.")
                        results_text += "\n\n"
                        for(var i = 0; i < results.length; ++i) {
                            results_text += results[i]
                            results_text += "\n"
                        }
                        errors.text = results_text
                    }
                }
            }

            Text {
                id: errors
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
                text: ""
            }
        }
    }
}
