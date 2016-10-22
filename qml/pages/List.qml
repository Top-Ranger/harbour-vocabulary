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
            var translation = simple_interface.getTranslationOfWord(new_word)

            for(var i = 0; i < listModel.count; ++i) {
                if(listModel.get(i).word === origin_word) {
                    listModel.remove(i)
                    listModel.insert(i, {"word": new_word, "translation": translation})
                    word_changed = false
                    break
                }
            }

            for(i = 0; i < originModel.count; ++i) {
                if(originModel.get(i).word === origin_word) {
                    originModel.remove(i)
                    originModel.insert(i, {"word": new_word, "translation": translation})
                    word_changed = false
                    break
                }
            }
        }
    }

    Item {
        id: functions

        function remove_word(word, item) {
            if(simple_interface.removeVocabulary(word)) {
                item.animateRemoval()

                for(var i = 0; i < originModel.count; ++i) {
                    if(originModel.get(i).word === word) {
                        originModel.remove(i)
                        break
                    }
                }
            }
            else {
                panel.show()
            }
        }

        function load_list() {
            listModel.clear()
            var wordlist = simple_interface.getAllWords()
            for(var i = 0; i < wordlist.length; ++i) {
                var translation = simple_interface.getTranslationOfWord(wordlist[i])
                originModel.append({"word": wordlist[i], "translation": translation})
                listModel.append({"word": wordlist[i], "translation": translation})
            }
        }

        function filter_list(filter) {
            listModel.clear()
            filter = filter.toLowerCase()
            for(var i = 0; i < originModel.count; ++i) {
                var item = originModel.get(i)
                if(item.word.toLowerCase().indexOf(filter) !== -1 || item.translation.toLowerCase().indexOf(filter) !== -1) {
                    listModel.append(item)
                }
            }
        }
    }

    ListModel {
        id: listModel
    }

    ListModel {
        id: originModel
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

        header: Column {
            width: page.width
            spacing: Theme.paddingMedium

            PageHeader {
                width: parent.width
                title: qsTr("Vocabulary list")
            }

            SearchField {
                width: parent.width
                placeholderText: qsTr("Search vocabulary")
                onTextChanged: {
                    functions.filter_list(text)
                }
            }
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
                    id: word_label
                    text: word
                    color: Theme.primaryColor
                }
                Label {
                    text: " "
                    color: Theme.primaryColor
                }
                Label {
                    width: parent.width - word_label.width
                    text: translation
                    color: Theme.secondaryColor
                    horizontalAlignment: Text.AlignLeft
                    truncationMode: TruncationMode.Elide
                }
            }

            menu: ContextMenu {
                MenuItem {
                    text: "<img src=\"image://theme/icon-s-edit\" align=\"middle\" /> " + qsTr("Edit vocabulary")
                    textFormat: Text.StyledText
                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("Edit.qml"), { origin_word: word } )
                    }
                }

                MenuItem {
                    text: "<img src=\"image://theme/icon-m-delete\" width=\"" + Theme.iconSizeSmall + "\" height=\"" + Theme.iconSizeSmall + "\" align=\"middle\" >" + qsTr("Remove vocabulary")
                    textFormat: Text.StyledText
                    onClicked: {
                        listitem.remorseAction(qsTr("Remove vocabulary"), function() { functions.remove_word(word, listitem) })
                    }
                }

                MenuItem {
                    text: "<img src=\"image://theme/icon-s-clipboard\" align=\"middle\" /> "+ qsTr("Copy word to clipboard")
                    textFormat: Text.StyledText
                    onClicked: {
                        Clipboard.text = word
                    }
                }

                MenuItem {
                    text: "<img src=\"image://theme/icon-s-clipboard\" align=\"middle\" /> " + qsTr("Copy translation to clipboard")
                    textFormat: Text.StyledText
                    onClicked: {
                        Clipboard.text = translation
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
