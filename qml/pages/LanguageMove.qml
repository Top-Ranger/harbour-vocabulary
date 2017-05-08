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
import harbour.vocabulary.SimpleInterface 1.0

Page {
    id: page
    allowedOrientations: Orientation.All

    property int language_id: -1
    property string language_name: "ERROR"

    property int sort_criterium: SimpleInterface.ALPHABETICAL_WORD
    property string search_text: ""

    Item {
        id: functions

        function change_original_selected(id, target) {
            for(var i = 0; i < originModel.count; ++i) {
                if(originModel.get(i).id === id) {
                    originModel.get(i).selected = target
                    break
                }
            }

            for(var i = 0; i < listModel.count; ++i) {
                if(listModel.get(i).id === id) {
                    listModel.get(i).selected = target
                    break
                }
            }
        }

        function load_list() {
            listModel.clear()
            originModel.clear()
            var wordlist = simple_interface.getAllWords(page.sort_criterium)
            for(var i = 0; i < wordlist.length; ++i) {
                var word = simple_interface.getWord(wordlist[i])
                var translation = simple_interface.getTranslationOfWord(wordlist[i])
                originModel.append({"id": wordlist[i], "word": word, "translation": translation, "selected": false})
                listModel.append({"id": wordlist[i], "word": word, "translation": translation, "selected": false})
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

        function move_now() {
            var array = []
            for(var i = 0; i < originModel.count; ++i) {
                var item = originModel.get(i)
                if(item.selected) {
                    array.push(item.id)
                }
            }

            return simple_interface.moveToLanguage(page.language_id, array)
        }
    }

    Component.onCompleted: {
        page.language_name = simple_interface.getLanguageName(page.language_id)
        functions.load_list()
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
        text: qsTr("Can not move vocabulary")
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
                title: qsTr("Move vocabulary to") + " " + page.language_name
            }

            Button {
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.horizontalPageMargin
                }

                text: qsTr("Move selected vocabulary")
                onClicked: {
                    if(functions.move_now()) {
                        pageStack.pop()
                    }
                    else {
                        panel.show()
                    }
                }
            }

            ComboBox {
                width: parent.width
                label: qsTr("Sort")

                menu: ContextMenu {
                    MenuItem {
                        text: qsTr("alphabetically (word)")
                        onClicked: {
                            page.sort_criterium = SimpleInterface.ALPHABETICAL_WORD
                            search_timer.stop()
                            functions.load_list()
                            functions.filter_list(page.search_text)
                        }
                    }

                    MenuItem {
                        text: qsTr("alphabetically (translation)")
                        onClicked: {
                            page.sort_criterium = SimpleInterface.ALPHABETICAL_TRANSLATION
                            search_timer.stop()
                            functions.load_list()
                            functions.filter_list(page.search_text)
                        }
                    }

                    MenuItem {
                        text: qsTr("by priority (highest)")
                        onClicked: {
                            page.sort_criterium = SimpleInterface.PRIORITY_HIGHEST
                            search_timer.stop()
                            functions.load_list()
                            functions.filter_list(page.search_text)
                        }
                    }

                    MenuItem {
                        text: qsTr("by priority (lowest)")
                        onClicked: {
                            page.sort_criterium = SimpleInterface.PRIORITY_LOWEST
                            search_timer.stop()
                            functions.load_list()
                            functions.filter_list(page.search_text)
                        }
                    }

                    MenuItem {
                        text: qsTr("creation date (newest)")
                        onClicked: {
                            page.sort_criterium = SimpleInterface.CREATION_NEWEST
                            search_timer.stop()
                            functions.load_list()
                            functions.filter_list(page.search_text)
                        }
                    }

                    MenuItem {
                        text: qsTr("creation date (oldest)")
                        onClicked: {
                            page.sort_criterium = SimpleInterface.CREATION_OLDEST
                            search_timer.stop()
                            functions.load_list()
                            functions.filter_list(page.search_text)
                        }
                    }

                    MenuItem {
                        text: qsTr("modification date (newest)")
                        onClicked: {
                            page.sort_criterium = SimpleInterface.MODIFICATION_NEWEST
                            search_timer.stop()
                            functions.load_list()
                            functions.filter_list(page.search_text)
                        }
                    }

                    MenuItem {
                        text: qsTr("modification date (oldest)")
                        onClicked: {
                            page.sort_criterium = SimpleInterface.MODIFICATION_OLDEST
                            search_timer.stop()
                            functions.load_list()
                            functions.filter_list(page.search_text)
                        }
                    }
                }
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
                    color: selected ? Theme.primaryColor : Theme.secondaryColor
                    font.bold: selected
                }
                Label {
                    text: " "
                    color: selected ? Theme.primaryColor : Theme.secondaryColor
                    font.bold: selected
                }
                Label {
                    width: parent.width - word_label.width
                    text: translation
                    color: selected ? Theme.primaryColor : Theme.secondaryColor
                    font.bold: selected
                    horizontalAlignment: Text.AlignLeft
                    truncationMode: TruncationMode.Elide
                }
            }

            onClicked: {
                functions.change_original_selected(id, !selected)
            }
        }

        VerticalScrollDecorator {}
    }
}
