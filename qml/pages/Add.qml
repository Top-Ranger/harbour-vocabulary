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

    Item {
        id: functions

        function save_word() {
            if(simple_interface.addVocabulary(word.text, translation.text)) {
                pageStack.pop()
            }
            else {
                panel.show()
            }
        }
    }

    SilicaFlickable {
        anchors.fill: parent

        VerticalScrollDecorator {}

        PullDownMenu {
        }

        contentHeight: column.height

        Column {
            id: column
            width: page.width
            spacing: Theme.paddingMedium

            PageHeader {
                title: qsTr("Add vocabulary")
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

            Button {
                width: parent.width
                text: qsTr("Save vocabulary")
                onClicked: functions.save_word()
            }
        }
    }

    UpperPanel {
        id: panel
        text: qsTr("Can not save vocabulary")
    }
}

