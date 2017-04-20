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

    property bool word_changed: false
    property int word_id: 0

    property string search_text: ""

    onStatusChanged: {
        if(word_changed === true) {
            var word = simple_interface.getWord(page.word_id)
            var translation = simple_interface.getTranslationOfWord(page.word_id)
            var priority = simple_interface.getPriorityOfWord(page.word_id)

            for(var i = 0; i < listModel.count; ++i) {
                if(listModel.get(i).id === page.word_id) {
                    listModel.remove(i)
                    listModel.insert(i, {"id": page.word_id, "word": word, "translation": translation, "priority": priority})
                    break
                }
            }

            for(i = 0; i < originModel.count; ++i) {
                if(originModel.get(i).id === page.word_id) {
                    originModel.remove(i)
                    originModel.insert(i, {"id": page.word_id, "word": word, "translation": translation, "priority": priority})
                    break
                }
            }
            word_changed = false
        }
    }

    RemorsePopup {
        id: remorse_popup
    }

    Item {
        id: functions

        function remove_word(word_id, item) {
            if(simple_interface.removeVocabulary(word_id)) {
                item.animateRemoval()

                for(var i = 0; i < originModel.count; ++i) {
                    if(originModel.get(i).id === word_id) {
                        originModel.remove(i)
                        break
                    }
                }

                for(i = 0; i < listModel.count; ++i) {
                    if(listModel.get(i).id === word_id) {
                        listModel.remove(i)
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
                var word = simple_interface.getWord(wordlist[i])
                var translation = simple_interface.getTranslationOfWord(wordlist[i])
                var priority = simple_interface.getPriorityOfWord(wordlist[i])
                originModel.append({"id": wordlist[i], "word": word, "translation": translation, "priority": priority})
                listModel.append({"id": wordlist[i], "word": word, "translation": translation, "priority": priority})
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

    Timer {
        id: search_timer
        repeat: false
        interval: 750
        onTriggered: {
            functions.filter_list(page.search_text)
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

        PullDownMenu {
            MenuItem {
                text: qsTr("Remove all vocabulary")
                onClicked: {
                    remorse_popup.execute(qsTr("Remove all vocabulary"), function() {if(!simple_interface.clearAllVocabulary()) { panel.show() } else { listModel.clear(); originModel.clear() } }, 10000)
                }
            }
        }

        header: Column {
            width: page.width
            spacing: Theme.paddingMedium

            PageHeader {
                width: parent.width
                title: qsTr("Vocabulary list") + " (" + listModel.count + ")"
            }

            SearchField {
                width: parent.width
                placeholderText: qsTr("Search vocabulary")
                EnterKey.onClicked: parent.focus = true
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                onTextChanged: {
                    page.search_text = text
                    search_timer.restart()
                }
            }
        }

        Component.onCompleted: {
            functions.load_list()
        }

        delegate: ListItem {
            id: listitem
            width: parent.width
            
            Rectangle {
                anchors {
                    bottom: parent.bottom
                    left: parent.left
                }

                height: parent.height * 0.2
                width: parent.width * priority / 100

                color: Theme.secondaryHighlightColor
                visible: priority > 1
                opacity: .5
            }

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
                        pageStack.push(Qt.resolvedUrl("Edit.qml"), { word_id: id } )
                    }
                }

                MenuItem {
                    text: "<img src=\"image://theme/icon-m-delete\" width=\"" + Theme.iconSizeSmall + "\" height=\"" + Theme.iconSizeSmall + "\" align=\"middle\" >" + qsTr("Remove vocabulary")
                    textFormat: Text.StyledText
                    onClicked: {
                        listitem.remorseAction(qsTr("Remove vocabulary"), function() { functions.remove_word(id, listitem) })
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
                pageStack.push(Qt.resolvedUrl("Details.qml"), { word_id: id })
            }
        }

        VerticalScrollDecorator {}
    }
}
