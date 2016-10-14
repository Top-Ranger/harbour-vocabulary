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

    property string word: "ERROR"

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        VerticalScrollDecorator {}

        PullDownMenu {
            MenuItem {
                text: qsTr("Edit")
                onClicked: {
                    pageStack.replace(Qt.resolvedUrl("Edit.qml"), { origin_word: page.word })
                }
            }
        }

        Column {
            id: column
            width: page.width
            spacing: Theme.paddingLarge

            anchors {
                left: parent.left
                right: parent.right
                margins: Theme.paddingLarge
            }

            PageHeader {
                title: qsTr("Details")
            }

            Row {
                Label {
                    id: word
                    text: qsTr("Word: ")
                    color: Theme.highlightColor
                }

                Text {
                    width: column.width - word.width
                    color: Theme.primaryColor
                    wrapMode: Text.Wrap
                    text: page.word
                }
            }

            Row {
                Label {
                    id: translation
                    text: qsTr("Translation: ")
                    color: Theme.highlightColor
                }

                Text {
                    width: column.width - translation.width
                    color: Theme.primaryColor
                    wrapMode: Text.Wrap
                    text: simple_interface.getTranslationOfWord(page.word)
                }
            }

            Slider {
                id: priority
                width: column.width
                enabled: false
                handleVisible: false
                minimumValue: 1
                maximumValue: 100
                label: qsTr("Priority")
                valueText: "" + value
                value: simple_interface.getPriorityOfWord(page.word)
            }
        }
    }
}
