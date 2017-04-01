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

Page {
    id: page
    allowedOrientations: Orientation.All

    property int word_id: 0
    property int language_id: -1

    Item {
        id: functions

        function save_change() {
            var new_id = -1
            if(language_id === -1) {
                new_id = language_interface.addLanguage(new_language_input.text)
                if(new_id === -1) {
                    panel.show()
                    return
                }
            }

            var id = page.language_id === -1 ? new_id : page.language_id

            if(simple_interface.editVocabulary(page.word_id, word.text, translation.text, priority.value, id)) {
                var last_page = pageStack.previousPage()
                last_page.word_changed = true
                last_page.word_id = page.word_id
                pageStack.pop()
            }
            else {
                panel.show()
            }
        }

        function load_languages() {
            languageModel.clear()
            var languages = language_interface.getAllLanguages()
            for(var i = 0; i < languages.length; ++i) {
                languageModel.append({"lid": languages[i], "language": language_interface.getLanguageName(languages[i])})
            }
        }
    }

    Component.onCompleted: {
        functions.load_languages()
        word.text = simple_interface.getWord(page.word_id)
        translation.text = simple_interface.getTranslationOfWord(page.word_id)
        priority.value = simple_interface.getPriorityOfWord(page.word_id)
        page.language_id = simple_interface.getLanguageId(page.word_id)
    }

    ListModel {
        id: languageModel
    }

    SilicaFlickable {
        anchors.fill: parent

        VerticalScrollDecorator {}

        contentHeight: column.height

        Column {
            id: column
            width: page.width
            spacing: Theme.paddingMedium

            PageHeader {
                title: qsTr("Edit vocabulary") + " " + simple_interface.getWord(page.word_id)
            }

            Button {
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.horizontalPageMargin
                }

                width: parent.width
                text: qsTr("Save change")
                onClicked: functions.save_change()
            }

            TextArea {
                id: word
                width: parent.width
                height: implicitHeight
                EnterKey.onClicked: { text = text.replace("\n", ""); parent.focus = true }
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                placeholderText: qsTr("Input word or phrase here")
                label: qsTr("Word / phrase")
            }

            TextArea {
                id: translation
                width: parent.width
                height: implicitHeight
                EnterKey.onClicked: { text = text.replace("\n", ""); parent.focus = true }
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                placeholderText: qsTr("Input translation here")
                label: qsTr("Translation")
            }

            Slider {
                id: priority
                width: parent.width
                stepSize: 1
                minimumValue: 1
                maximumValue: 100
                label: qsTr("Priority")
                valueText: "" + value
            }

            Label {
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.horizontalPageMargin
                }

                text: qsTr("Languages:")
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
        }
    }

    UpperPanel {
        id: panel
        text: qsTr("Can not save change to vocabulary")
    }
}

