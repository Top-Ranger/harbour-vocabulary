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

        function remove_word(word) {
            if(simple_interface.removeVocabulary(word)) {
                for(var i = 0; i < listModel.count; ++i) {
                    if(listModel.get(i).word === word) {
                        listModel.remove(i)
                        return
                    }
                }
            }
            else {
                panel.show()
            }
        }
    }

    ListModel {
        id: listModel

        Component.onCompleted: {
            var wordlist = simple_interface.getAllWords()
            for(var i = 0; i < wordlist.length; ++i) {
                listModel.append({"word": wordlist[i]})
            }
        }
    }

    UpperPanel {
        id: panel
        text: qsTr("Can not remove vocabulary")
    }

    SilicaListView {
        id: list
        model: listModel
        anchors.fill: parent
        currentIndex: -1

        header: PageHeader {
            title: qsTr("Vocabulary list")
        }

        delegate: ListItem {
            width: parent.width

            Row {
                width: parent.width - 2*Theme.paddingLarge
                anchors.centerIn: parent

                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.paddingLarge
                }

                Label {
                    text: word
                    color: Theme.primaryColor
                }
                Label {
                    text: " "
                    color: Theme.primaryColor
                }
                Label {
                    text: simple_interface.getTranslationOfWord(word)
                    width: page.width / 3 * 2
                    color: Theme.secondaryColor
                    horizontalAlignment: Text.AlignLeft
                    truncationMode: TruncationMode.Elide
                }
            }

            menu: ContextMenu {
                MenuItem {
                    text: qsTr("Remove vocabulary")
                    onClicked: {
                        functions.remove_word(word)
                    }
                }
            }
        }

        VerticalScrollDecorator {}
    }
}

