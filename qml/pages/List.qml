/*
 * Copyright 2016,2017,2019 Marcus Soll
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

    property int language_id: -1 // If this is -1 no language will be filtered, else this list will be specifically for that language
    property string language_name: "ERROR"

    property bool word_changed: false
    property int word_id: 0

    property int sort_criterium: SimpleInterface.ALPHABETICAL_WORD
    property string search_text: ""

    property bool priority_visible: settings.adaptiveTrainingEnabled
    property bool translation_visible: settings.listShowTranslation

    onSort_criteriumChanged: {
        settings.listSortCriterium = page.sort_criterium
        search_timer.stop()
        functions.load_list()
        functions.filter_list(page.search_text)
    }

    SettingsProxy {
        id: settings
    }

    Component.onCompleted: {
        if(page.language_id !== -1) {
            page.language_name = simple_interface.getLanguageName(page.language_id)
        }
    }

    onStatusChanged: {
        if(word_changed === true) {
            var word = simple_interface.getWord(page.word_id)
            var translation = simple_interface.getTranslationOfWord(page.word_id)
            var priority = simple_interface.getPriorityOfWord(page.word_id)
            var new_language_id = simple_interface.getLanguageId(page.word_id)

            for(var i = 0; i < listModel.count; ++i) {
                if(listModel.get(i).id === page.word_id) {
                    listModel.remove(i)
                    if(page.language_id === -1 || new_language_id === page.language_id) {
                        listModel.insert(i, {"id": page.word_id, "word": word, "translation": translation, "priority": priority })
                    }
                    break
                }
            }

            for(i = 0; i < originModel.count; ++i) {
                if(originModel.get(i).id === page.word_id) {
                    originModel.remove(i)
                    if(page.language_id === -1 || new_language_id === page.language_id) {
                        originModel.insert(i, {"id": page.word_id, "word": word, "translation": translation, "priority": priority })
                    }
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
            var wordlist = []
            if(page.language_id === -1) {
                wordlist = simple_interface.getAllWords(page.sort_criterium)
            }
            else {
                wordlist = simple_interface.getVocabularyByLanguage(page.language_id, page.sort_criterium)
            }

            var words = simple_interface.getBatchWord(wordlist)
            var translations = simple_interface.getBatchTranslationOfWord(wordlist)
            var priorities = simple_interface.getBatchPriorityOfWord(wordlist)
            for(var i = 0; i < wordlist.length; ++i) {
                originModel.append({"id": wordlist[i], "word": words[i], "translation": translations[i], "priority": priorities[i] })
                listModel.append({"id": wordlist[i], "word": words[i], "translation": translations[i], "priority": priorities[i] })
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

        function remove_all_in_this_language() {
            var array = []
            for(var i = 0; i < originModel.count; ++i) {
                array.push(originModel.get(i).id)
            }
            if(simple_interface.removeBatchVocabulary(array)) {
                originModel.clear()
                listModel.clear()
            }
            else {
                panel.show()
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
                visible: page.language_id === -1
                onClicked: {
                    remorse_popup.execute(qsTr("Remove all vocabulary"), function() {if(!simple_interface.clearAllVocabulary()) { panel.show() } else { listModel.clear(); originModel.clear() } }, 10000)
                }
            }

            MenuItem {
                text: qsTr("Remove all vocabulary in language")
                visible: page.language_id !== -1
                onClicked: {
                    remorse_popup.execute(qsTr("Remove all vocabulary"), function() { functions.remove_all_in_this_language() }, 10000)
                }
            }

            MenuItem {
                text: page.translation_visible ? qsTr("Hide translation") : qsTr("Show translation")
                onClicked: {
                    settings.listShowTranslation = !page.translation_visible
                }
            }

            MenuItem {
                text: qsTr("Select sort criterium")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("SortSelection.qml"), {
                                       names: [ qsTr("Alphabetically (word)"), qsTr("Alphabetically (translation)"), qsTr("Priority (highest)"), qsTr("Priority (lowest)"), qsTr("Creation date (newest)"), qsTr("Creation date (oldest)"), qsTr("Modification date (newest)"), qsTr("Modification date (oldest)"), qsTr("Number asked (highest)"), qsTr("Number asked (lowest)"), qsTr("Number correct (highest)"), qsTr("Number correct (lowest)"), qsTr("Percentage correct (highest)"), qsTr("Percentage correct (lowest)"), ],
                                       values: [ SimpleInterface.ALPHABETICAL_WORD, SimpleInterface.ALPHABETICAL_TRANSLATION, SimpleInterface.PRIORITY_HIGHEST, SimpleInterface.PRIORITY_LOWEST, SimpleInterface.CREATION_NEWEST, SimpleInterface.CREATION_OLDEST, SimpleInterface.MODIFICATION_NEWEST, SimpleInterface.MODIFICATION_OLDEST, SimpleInterface.NUMBER_ASKED_HIGHEST, SimpleInterface.NUMBER_ASKED_LOWEST, SimpleInterface.NUMBER_CORRECT_HIGHEST, SimpleInterface.NUMBER_CORRECT_LOWEST, SimpleInterface.PERCENT_CORRECT_HIGHEST, SimpleInterface.PERCENT_CORRECT_LOWEST, ],
                                       current_sorting: page.sort_criterium
                                   })
                }
            }
        }

        header: Column {
            width: page.width
            spacing: Theme.paddingMedium

            PageHeader {
                width: parent.width
                title: page.language_id === -1 ? qsTr("Vocabulary list") + " (" + listModel.count + ")" : page.language_name + " (" + listModel.count + ")"
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

        delegate: ListItem {
            id: vocabularyListItem
            anchors {
                right: parent.right
                left: parent.left
            }

            Rectangle {
                anchors {
                    bottom: parent.bottom
                    left: parent.left
                }

                height: parent.height * 0.2
                width: parent.width * priority / 100

                color: Theme.secondaryHighlightColor
                visible: page.priority_visible && (priority > 1)
                opacity: .5
            }

            Row {
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.paddingLarge
                    top: parent.top
                    bottom: parent.bottom
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
                    visible: page.translation_visible
                    horizontalAlignment: Text.AlignLeft
                    truncationMode: TruncationMode.Elide
                }
            }

            menu: ContextMenu {
                MenuItem {
                    text: qsTr("Edit vocabulary")
                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("Edit.qml"), { word_id: id } )
                    }
                }

                MenuItem {
                    text: qsTr("Remove vocabulary")
                    onClicked: {
                        vocabularyListItem.remorseAction(qsTr("Remove vocabulary"), function() { functions.remove_word(id, vocabularyListItem) })
                    }
                }

                MenuItem {
                    text: qsTr("Copy word to clipboard")
                    onClicked: {
                        Clipboard.text = word
                    }
                }

                MenuItem {
                    text: qsTr("Copy translation to clipboard")
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
