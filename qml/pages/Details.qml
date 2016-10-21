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
    allowedOrientations: Orientation.All

    property string word: "ERROR"

    property bool word_changed: false
    property string origin_word: ""
    property string new_word: ""

    onStatusChanged: {
        if(word_changed === true) {
            page.word = new_word
            word_text.text = new_word
            translation_text.text = simple_interface.getTranslationOfWord(new_word)
            priority.value = simple_interface.getPriorityOfWord(new_word)

            var last_page = pageStack.previousPage(page)
            last_page.word_changed = true
            last_page.origin_word = page.origin_word
            last_page.new_word = page.new_word

            word_changed = false
        }
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        VerticalScrollDecorator {}

        PullDownMenu {
            MenuItem {
                text: qsTr("Edit")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("Edit.qml"), { origin_word: page.word })
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
                IconButton {
                    id: word_icon
                    height: word.height
                    width: height
                    icon.source: "image://theme/icon-s-clipboard"
                    onClicked: Clipboard.text = page.word
                }

                Label {
                    id: word
                    text: qsTr("Word: ")
                    color: Theme.highlightColor
                }

                Text {
                    id: word_text
                    width: column.width - word.width - word_icon.width
                    color: Theme.primaryColor
                    wrapMode: Text.Wrap
                    text: page.word
                }
            }

            Row {
                IconButton {
                    id: translation_icon
                    height: translation.height
                    width: height
                    icon.source: "image://theme/icon-s-clipboard"
                    onClicked: Clipboard.text = translation_text.text
                }

                Label {
                    id: translation
                    text: qsTr("Translation: ")
                    color: Theme.highlightColor
                }

                Text {
                    id: translation_text
                    width: column.width - translation.width - translation_icon.width
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
