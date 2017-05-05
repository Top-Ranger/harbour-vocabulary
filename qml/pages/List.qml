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
import harbour.vocabulary.SettingsProxy 1.0
import harbour.vocabulary.SimpleInterface 1.0

Page {
    id: page
    allowedOrientations: Orientation.All

    property bool word_changed: false
    property int word_id: 0

    property int sort_criterium: SimpleInterface.ALPHABETICAL_WORD
    property string search_text: ""

    onSort_criteriumChanged: {
        settings.listSortCriterium = page.sort_criterium
        search_timer.stop()
        functions.load_list()
        functions.filter_list(page.search_text)
    }

    SettingsProxy {
        id: settings
    }

    onStatusChanged: {
        if(word_changed === true) {
            var word = simple_interface.getWord(page.word_id)
            var translation = simple_interface.getTranslationOfWord(page.word_id)
            var priority = simple_interface.getPriorityOfWord(page.word_id)
            var priority_visible = settings.adaptiveTrainingEnabled

            for(var i = 0; i < listModel.count; ++i) {
                if(listModel.get(i).id === page.word_id) {
                    listModel.remove(i)
                    listModel.insert(i, {"id": page.word_id, "word": word, "translation": translation, "priority": priority, "priority_visible": priority_visible})
                    break
                }
            }

            for(i = 0; i < originModel.count; ++i) {
                if(originModel.get(i).id === page.word_id) {
                    originModel.remove(i)
                    originModel.insert(i, {"id": page.word_id, "word": word, "translation": translation, "priority": priority, "priority_visible": priority_visible})
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
            originModel.clear()
            var wordlist = simple_interface.getAllWords(page.sort_criterium)
            var words = simple_interface.getBatchWord(wordlist)
            var translations = simple_interface.getBatchTranslationOfWord(wordlist)
            var priorities = simple_interface.getBatchPriorityOfWord(wordlist)
            var priority_visible = settings.adaptiveTrainingEnabled
            for(var i = 0; i < wordlist.length; ++i) {
                originModel.append({"id": wordlist[i], "word": words[i], "translation": translations[i], "priority": priorities[i], "priority_visible": priority_visible})
                listModel.append({"id": wordlist[i], "word": words[i], "translation": translations[i], "priority": priorities[i], "priority_visible": priority_visible})
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

            MenuItem {
                text: qsTr("Select sort criterium")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("SortSelection.qml"), {
                                       names: [ qsTr("Alphabetically (word)"), qsTr("Alphabetically (translation)"), qsTr("Priority (highest)"), qsTr("Priority (lowest)"), qsTr("Creation date (newest)"), qsTr("Creation date (oldest)"), qsTr("Modification date (newest)"), qsTr("Modification date (oldest)"), ],
                                       values: [ SimpleInterface.ALPHABETICAL_WORD, SimpleInterface.ALPHABETICAL_TRANSLATION, SimpleInterface.PRIORITY_HIGHEST, SimpleInterface.PRIORITY_LOWEST, SimpleInterface.CREATION_NEWEST, SimpleInterface.CREATION_OLDEST, SimpleInterface.MODIFICATION_NEWEST, SimpleInterface.MODIFICATION_OLDEST, ]
                                   })
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
            page.sort_criterium = settings.listSortCriterium
            if(listModel.count === 0) {
                functions.load_list()
            }
        }

        delegate: VocabularyListItem {}

        VerticalScrollDecorator {}
    }
}
