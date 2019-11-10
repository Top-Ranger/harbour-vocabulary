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

Dialog {
    id: page
    allowedOrientations: Orientation.All

    property int language_id: -1
    canAccept: word.text != "" && translation.text != "" && (page.language_id !== -1 || new_language_input.text !== "")
    onAccepted: functions.save_word()

    Component.onCompleted: {
        page.language_id = settings_proxy.addVocabularyLanguage

        functions.load_list()
        functions.load_languages()
        functions.filter_list("")
    }

    SettingsProxy {
        id: settings_proxy
    }

    Item {
        id: functions

        function save_word() {
            var new_id = -1
            if(language_id === -1) {
                new_id = simple_interface.addLanguage(new_language_input.text)
                if(new_id === -1) {
                    panel.show()
                    return
                }
            }

            var id = page.language_id === -1 ? new_id : page.language_id

            if(simple_interface.addVocabulary(word.text, translation.text, id)) {
                settings_proxy.addVocabularyLanguage = id
            }
            else {
                panel.show()
            }
        }

        function load_list() {
            listModel.clear()
            var wordlist = simple_interface.getAllWords(SimpleInterface.NO_SORT)
            for(var i = 0; i < wordlist.length; ++i) {
                var word = simple_interface.getWord(wordlist[i])
                var language = simple_interface.getLanguageId(wordlist[i])
                originModel.append({"id": wordlist[i], "word": word, "language": language})
            }
        }

        function filter_list(filter) {
            listModel.clear()
            listModel.showItemNo = 0
            filter = filter.toLowerCase()
            for(var i = 0; i < originModel.count; ++i) {
                var item = originModel.get(i)
                if((page.language_id === -1 || page.language_id === item.language) && item.word.toLowerCase().indexOf(filter) !== -1) {
                    listModel.append(item)
                }
            }
            listModel.showItemNo = Math.floor(Math.random()*listModel.count)
        }

        function load_languages() {
            languageModel.clear()
            var language_id_correct = false
            var languages = simple_interface.getAllLanguages()
            var language_id_index  = 0
            for(var i = 0; i < languages.length; ++i) {
                languageModel.append({"lid": languages[i], "language": simple_interface.getLanguageName(languages[i])})
                if(languages[i] === page.language_id) {
                    language_id_correct = true
                    language_id_index = i + 1
                }
            }

            if(!language_id_correct) {
                page.language_id = -1
            }

            language_menu_timer.target_index = language_id_index
            language_menu_timer.start()
        }
    }

    ListModel {
        id: listModel

        property int showItemNo: 0
    }

    ListModel {
        id: originModel
    }

    ListModel {
        id: languageModel
    }

    Timer {
        id: search_timer
        repeat: false
        interval: 750

        property string lastWord: ""
        property int last_lid: -1

        onTriggered: {
            var newWord = word.text.trim()
            if(newWord !== lastWord || page.language_id !== last_lid) {
                lastWord = newWord
                last_lid = page.language_id
                functions.filter_list(newWord)
            }
        }
    }

    Timer {
        property int target_index: 0
        id: language_menu_timer
        repeat: false
        interval: 20
        onTriggered: languageComboBox.currentIndex = target_index
    }   // Could't find a better solution as everything else updated the index too soon.

    SilicaFlickable {
        id: silicaFlickable
        anchors.fill: parent

        DialogHeader {
            id: header
            //% Save new vocabulary
            title: qsTr("Add vocabulary")
            acceptText: qsTr("Save vocabulary")
        }

        VerticalScrollDecorator {}

        contentHeight: column.height

        PullDownMenu {
            MenuItem {
                text: qsTr("Reset priority of match")
                enabled: best_match_result_label.text !== ""
                onClicked: {
                    var word = listModel.get(listModel.showItemNo).word
                    var id = listModel.get(listModel.showItemNo).id
                    remorse.execute(qsTr("Resetting priority of ") + word, function(){ if(!simple_interface.setPriority(id,100)){ panel_priority.show() }})
                }
            }
        }

        Column {
            id: column
            width: page.width
            spacing: Theme.paddingMedium

            ComboBox {
                id: languageComboBox
                label: qsTr("Language")

                menu: ContextMenu {
                    MenuItem {
                        text: qsTr("Add new language")
                        onClicked: {
                            new_language_input.focus = true
                            page.language_id = -1
                            search_timer.stop()
                            functions.filter_list(word.text.trim())
                        }
                    }

                    Repeater {
                        id: languageRepeater
                        model: languageModel

                        delegate: MenuItem {
                            text: language
                            truncationMode: TruncationMode.Fade
                            onClicked: {
                                new_language_input.text = ""
                                page.language_id = lid
                                search_timer.stop()
                                functions.filter_list(word.text.trim())
                            }
                        }
                    }
                }
            }

            TextArea {
                id: new_language_input
                visible: languageComboBox.currentIndex === 0
                width: page.width
                EnterKey.onClicked: { text = text.replace("\n", ""); word.focus = true }
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                placeholderText: qsTr("Input new language")
                label: qsTr("New language")
            }

            Row {
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.horizontalPageMargin
                }
                Label {
                    id: number_similar_label
                    text: qsTr("Number similar: ")
                    color: Theme.primaryColor
                }
                Label {
                    width: parent.width - number_similar_label.width
                    text: "" + listModel.count
                    color: Theme.secondaryColor
                    horizontalAlignment: Text.AlignLeft
                    truncationMode: TruncationMode.Elide
                }
            }

            Row {
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.horizontalPageMargin
                }
                Label {
                    id: best_match_label
                    text: qsTr("Possible match: ")
                    color: Theme.primaryColor
                }
                Label {
                    id: best_match_result_label
                    width: parent.width - best_match_label.width - best_match_reset_icon.width
                    text: listModel.count === 0 ? "" : listModel.get(listModel.showItemNo).word
                    color: Theme.secondaryColor
                    horizontalAlignment: Text.AlignLeft
                    truncationMode: TruncationMode.Elide
                }
                IconButton {
                    id: best_match_reset_icon
                    height: best_match_label.height
                    icon.source: "image://theme/icon-m-forward"
                    visible: best_match_result_label.text != ""
                    enabled: listModel.count !== 1 && listModel.count !== 0
                    onClicked: {
                        listModel.showItemNo = (listModel.showItemNo + 1) % listModel.count
                    }
                }
            }

            TextArea {
                id: word
                width: parent.width
                height: implicitHeight
                EnterKey.onClicked: { text = text.replace("\n", ""); translation.focus = true }
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                placeholderText: qsTr("Input word or phrase here")
                label: qsTr("Word / phrase")
                onTextChanged: search_timer.restart()
            }

            TextArea {
                id: translation
                width: parent.width
                height: implicitHeight
                EnterKey.onClicked: { text = text.replace("\n", ""); parent.focus = true; silicaFlickable.scrollToTop() }
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                placeholderText: qsTr("Input translation here")
                label: qsTr("Translation")
            }
        }
    }

    RemorsePopup {
        id: remorse
    }

    UpperPanel {
        id: panel
        text: qsTr("Can not save vocabulary")
    }

    UpperPanel {
        id: panel_priority
        text: qsTr("Can not set priority")
    }
}
