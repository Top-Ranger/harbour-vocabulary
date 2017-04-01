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

Page {
    id: page
    allowedOrientations: Orientation.All

    onStatusChanged: {
        if(status = PageStatus.Activating) {
            functions.load_languages()
        }
    }

    Item {
        id: functions

        function load_languages() {
            languageModel.clear()
            var languages = language_interface.getAllLanguages()
            for(var i = 0; i < languages.length; ++i) {
                languageModel.append({"lid": languages[i], "language": language_interface.getLanguageName(languages[i])})
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
        id: languageModel
    }

    SilicaListView {
        id: list
        model: languageModel
        anchors.fill: parent
        currentIndex: -1

        header: Column {
            width: page.width
            spacing: Theme.paddingMedium

            PageHeader {
                width: parent.width
                title: qsTr("Languages") + " (" + languageModel.count + ")"
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
                    width: parent.width / 1.3
                    id: language_label
                    text: language
                    color: Theme.primaryColor
                    horizontalAlignment: Text.AlignHCenter
                    truncationMode: TruncationMode.Fade
                }
                Label {
                    text: " "
                    color: Theme.primaryColor
                }
                Label {
                    width: parent.width - language_label.width
                    text: language_interface.countVocabularyWithLanguage(lid)
                    color: Theme.secondaryColor
                    horizontalAlignment: Text.AlignHCenter
                    truncationMode: TruncationMode.Fade
                }
            }

            onClicked: {
                pageStack.push(Qt.resolvedUrl("LanguageList.qml"), { language_id: lid } )
            }

            menu: ContextMenu {
            }
        }

        VerticalScrollDecorator {}
    }
}
