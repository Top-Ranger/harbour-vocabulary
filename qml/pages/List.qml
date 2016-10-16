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

    property bool word_changed: false
    property string origin_word: ""
    property string new_word: ""

    onStatusChanged: {
        if(word_changed === true) {
            for(var i = 0; i < listModel.count; ++i) {
                if(listModel.get(i).word === origin_word) {
                    listModel.remove(i)
                    listModel.insert(i, {"word": new_word})
                    word_changed = false
                    return
                }
            }
        }
    }

    Item {
        id: functions

        function remove_word(word, item) {
            if(simple_interface.removeVocabulary(word)) {
                item.animateRemoval()
            }
            else {
                panel.show()
            }
        }

        function load_list() {
            listModel.clear()
            var wordlist = simple_interface.getAllWords()
            for(var i = 0; i < wordlist.length; ++i) {
                listModel.append({"word": wordlist[i]})
            }
        }
    }

    ListModel {
        id: listModel
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

        Component.onCompleted: {
            functions.load_list()
        }

        delegate: ListItem {
            id: listitem
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
                    id: translation_label
                    text: simple_interface.getTranslationOfWord(word)
                    width: page.width / 3 * 2
                    color: Theme.secondaryColor
                    horizontalAlignment: Text.AlignLeft
                    truncationMode: TruncationMode.Elide
                }
            }

            menu: ContextMenu {
                MenuItem {
                    text: qsTr("Edit vocabulary")
                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("Edit.qml"), { origin_word: word } )
                    }
                }

                MenuItem {
                    text: qsTr("Remove vocabulary")
                    onClicked: {
                        listitem.remorseAction(qsTr("Remove vocabulary"), function() { functions.remove_word(word, listitem) })
                    }
                }
            }

            onClicked: {
                pageStack.push(Qt.resolvedUrl("Details.qml"), { word: word })
            }
        }

        VerticalScrollDecorator {}
    }
}

