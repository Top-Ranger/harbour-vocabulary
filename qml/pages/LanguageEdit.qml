/*
 * Copyright 2017 Marcus Soll
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

    property int language_id: -1

    Component.onCompleted: {
        language.text = language_interface.getLanguageName(page.language_id)
    }

    Item {
        id: functions

        function save_change() {
            if(language_interface.renameLanguage(page.language_id, language.text)) {
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

        contentHeight: column.height

        Column {
            id: column
            width: page.width
            spacing: Theme.paddingMedium

            PageHeader {
                title: qsTr("Edit language") + " " + language_interface.getLanguageName(page.language_id)
            }

            Button {
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.horizontalPageMargin
                }

                width: parent.width
                text: qsTr("Save change")
                enabled: language.text !== ""
                onClicked: functions.save_change()
            }

            TextArea {
                id: language
                width: parent.width
                height: implicitHeight
                EnterKey.onClicked: { text = text.replace("\n", ""); parent.focus = true }
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                placeholderText: qsTr("Input language name")
                label: qsTr("Language name")
            }
        }
    }

    UpperPanel {
        id: panel
        text: qsTr("Can not save change to language")
    }
}

