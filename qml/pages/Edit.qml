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

Page {
    id: page
    property string origin_word: "ERROR"

    Item {
        id: functions

        function save_change() {
            if(simple_interface.editVocabulary(page.origin_word, word.text, translation.text, priority.value)) {
                pageStack.pop()
            }
            else {
                panel.show()
            }
        }
    }

    Component.onCompleted: {
        word.text = page.origin_word
        translation.text = simple_interface.getTranslationOfWord(page.origin_word)
        priority.value = simple_interface.getPriorityOfWord(page.origin_word)
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
                title: qsTr("Edit vocabulary") + " " + page.origin_word
            }

            TextArea {
                id: word
                width: parent.width
                height: implicitHeight
                focus: true
                placeholderText: qsTr("Input word or phrase here")
                label: qsTr("Word / phrase")
            }

            TextArea {
                id: translation
                width: parent.width
                height: implicitHeight
                focus: true
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

            Button {
                width: parent.width
                text: qsTr("Save change")
                onClicked: functions.save_change()
            }
        }
    }

    UpperPanel {
        id: panel
        text: qsTr("Can not save change to vocabulary")
    }
}

