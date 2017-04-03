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
import harbour.vocabulary.Trainer 1.0

Page {
    id: page
    allowedOrientations: Orientation.All

    property int language_id: -1
    property int number_vocabulary: 0

    property var filter_type: []
    property var filter_argv: []

    Item {
        id: functions

        function load_languages() {
            languageModel.clear()
            var languages = language_interface.getAllLanguages()
            languageModel.append({"lid": -1, "language": qsTr("All languages")})
            for(var i = 0; i < languages.length; ++i) {
                languageModel.append({"lid": languages[i], "language": language_interface.getLanguageName(languages[i])})
            }
        }

        function update_filters() {
            var filter_type = []
            var filter_argv = []
            if(language_id !== -1) {
                filter_type.push(Trainer.LANGUAGE)
                filter_argv.push(page.language_id)
            }
            page.number_vocabulary = trainer.count_vocabulary(filter_type, filter_argv)
            page.filter_type = filter_type
            page.filter_argv = filter_argv
        }
    }

    Trainer {
        id: trainer
    }

    Component.onCompleted: {
        functions.load_languages()
    }

    ListModel {
        id: languageModel
    }

    SilicaFlickable {
        anchors.fill: parent

        VerticalScrollDecorator {}

        contentHeight: column.height

        Column {
            id: column
            width: page.width
            spacing: Theme.paddingMedium

            PageHeader {
                title: qsTr("Select training options")
            }

            Row {
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.paddingLarge
                }

                Label {
                    text: qsTr("Number vocabulary:")
                }
                Label {
                    text: " "
                }
                Label {
                    text: "" + page.number_vocabulary
                    color: Theme.secondaryColor
                }
            }

            Button {
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.horizontalPageMargin
                }

                width: parent.width
                text: qsTr("Start training")
                enabled: page.number_vocabulary !== 0
                onClicked: pageStack.push(Qt.resolvedUrl("Training.qml"), { filter_type: page.filter_type, filter_argv: page.filter_argv, replace: true } )
            }

            Label {
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.paddingLarge
                }

                text: qsTr("Language:")
            }

            Repeater {
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.horizontalPageMargin
                }

                model: languageModel

                delegate: ListItem {
                    width: parent.width
                    Label {
                        anchors.centerIn: parent
                        width: parent.width - 2*Theme.horizontalPageMargin
                        text: language
                        color: page.language_id === lid ? Theme.primaryColor : Theme.secondaryColor
                        font.bold: page.language_id === lid
                        horizontalAlignment: Text.AlignHCenter
                        truncationMode: TruncationMode.Fade
                    }

                    onClicked: {
                        page.language_id = lid
                        functions.update_filters()
                    }
                }
            }
        }
    }

    UpperPanel {
        id: panel
        text: qsTr("Can not save change to vocabulary")
    }
}

