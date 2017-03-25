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

    Item {
        id: functions

        function save_change() {
            if(simple_interface.editVocabulary(page.word_id, word.text, translation.text, priority.value)) {
                var last_page = pageStack.previousPage()
                last_page.word_changed = true
                last_page.word_id = page.word_id
                pageStack.pop()
            }
            else {
                panel.show()
            }
        }
    }

    Component.onCompleted: {
        word.text = simple_interface.getWord(page.word_id)
        translation.text = simple_interface.getTranslationOfWord(page.word_id)
        priority.value = simple_interface.getPriorityOfWord(page.word_id)
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
        }
    }

    UpperPanel {
        id: panel
        text: qsTr("Can not save change to vocabulary")
    }
}

