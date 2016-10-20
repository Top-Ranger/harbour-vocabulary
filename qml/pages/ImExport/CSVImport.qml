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
                title: qsTr("Import CSV")
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
                text: qsTr("CSV has header")
                description: qsTr("If this is enabled, it is assumed that the CSV file has a header and the first line will be ignored.")
            }

            ComboBox {
                id: word_column
                width: parent.width
                label: qsTr("Word column")
                currentIndex: 0

                menu: ContextMenu {
                    MenuItem { text: qsTr("1") }
                    MenuItem { text: qsTr("2") }
                    MenuItem { text: qsTr("3") }
                    MenuItem { text: qsTr("4") }
                    MenuItem { text: qsTr("5") }
                    MenuItem { text: qsTr("6") }
                    MenuItem { text: qsTr("7") }
                    MenuItem { text: qsTr("8") }
                    MenuItem { text: qsTr("9") }
                    MenuItem { text: qsTr("10") }
                }
            }

            ComboBox {
                id: translation_column
                width: parent.width
                label: qsTr("Translation column")
                currentIndex: 1

                menu: ContextMenu {
                    MenuItem { text: qsTr("1") }
                    MenuItem { text: qsTr("2") }
                    MenuItem { text: qsTr("3") }
                    MenuItem { text: qsTr("4") }
                    MenuItem { text: qsTr("5") }
                    MenuItem { text: qsTr("6") }
                    MenuItem { text: qsTr("7") }
                    MenuItem { text: qsTr("8") }
                    MenuItem { text: qsTr("9") }
                    MenuItem { text: qsTr("10") }
                }
            }

            TextSwitch {
                checked: true
                id: priority
                width: parent.width
                text: qsTr("Import priorities")
            }

            ComboBox {
                id: priority_column
                enabled: priority.checked
                width: parent.width
                label: qsTr("Priority column")
                currentIndex: 2

                menu: ContextMenu {
                    MenuItem { text: qsTr("1") }
                    MenuItem { text: qsTr("2") }
                    MenuItem { text: qsTr("3") }
                    MenuItem { text: qsTr("4") }
                    MenuItem { text: qsTr("5") }
                    MenuItem { text: qsTr("6") }
                    MenuItem { text: qsTr("7") }
                    MenuItem { text: qsTr("8") }
                    MenuItem { text: qsTr("9") }
                    MenuItem { text: qsTr("10") }
                }
            }

            Button {
                width: parent.width
                enabled: !page.started
                text: qsTr("Import")
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

                    var results = handle.loadCSV(page.path, seperator, header.checked, word_column.currentIndex, translation_column.currentIndex, priority_column.currentIndex, priority.checked)
                    if(results.length === 0) {
                        errors.text = qsTr("Successfully imported")
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
                    simple_interface.recount()
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
