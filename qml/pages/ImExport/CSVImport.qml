/*
 * Copyright 2016,2017 Marcus Soll
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
    property int language_id: -1

    Component.onCompleted: {
        functions.load_languages()
    }

    Item {
        id: functions

        function load_languages() {
            languageModel.clear()
            var languages = language_interface.getAllLanguages()
            for(var i = 0; i < languages.length; ++i) {
                languageModel.append({"lid": languages[i], "language": language_interface.getLanguageName(languages[i])})
            }
        }
    }

    ListModel {
        id: languageModel
    }

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
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.horizontalPageMargin
                }

                text: qsTr("Import settings:")
                font.bold: true
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

            Label {
                text: qsTr("Import language:")
            }

            Repeater {
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.horizontalPageMargin
                }

                model: languageModel

                delegate: ListItem {
                    width: parent.width
                    Label {
                        anchors.centerIn: parent
                        width: parent.width - 2*Theme.horizontalPageMargin
                        text: language
                        color: page.language_id == lid ? Theme.primaryColor : Theme.secondaryColor
                        horizontalAlignment: Text.AlignHCenter
                        truncationMode: TruncationMode.Fade
                    }

                    onClicked: {
                        new_language_input.text = ""
                        page.language_id = lid
                    }
                }
            }

            TextArea {
                id: new_language_input
                width: parent.width
                EnterKey.onClicked: { text = text.replace("\n", ""); parent.focus = true }
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                placeholderText: qsTr("Input new language")
                label: qsTr("New language")
                onTextChanged: page.language_id = -1
            }

            Button {
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.horizontalPageMargin
                }

                enabled: !page.started && (page.language_id !== -1 || new_language_input.text !== "")
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

                    var id = page.language_id

                    if(page.language_id === -1) {
                        id = language_interface.addLanguage(new_language_input.text)
                        if(id === -1) {
                            errors.text = qsTr("Can not add new language")
                            return
                        }
                    }

                    var results = handle.loadCSV(page.path, seperator, header.checked, word_column.currentIndex, translation_column.currentIndex, priority_column.currentIndex, priority.checked, id)
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
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.horizontalPageMargin
                }

                id: errors
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
