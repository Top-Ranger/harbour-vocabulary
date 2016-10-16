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
import harbour.vocabulary.Trainer 1.0

Page {
    id: page
    allowedOrientations: Orientation.All

    SilicaFlickable {
        anchors.fill: parent

        Trainer {
            id: trainer
        }

        Item {
            id: master
            property int status_ask_question: 0
            property int status_reveal_answer: 1
            property int current_status: status_ask_question
            property int trainings_mode: trainer.modus

            function new_question() {
                translation.text = ""
                word.text = ""
                trainer.next()
                master.current_status = master.status_ask_question
            }
        }

        VerticalScrollDecorator {}

        contentHeight: column.height

        Column {
            id: column
            width: page.width
            spacing: Theme.paddingLarge

            PageHeader {
                title: qsTr("Training")
            }

            Row {
                width: parent.width
                Label {
                    text: qsTr("Word: ")
                    color: Theme.primaryColor
                }

                Label {
                    text: (master.trainings_mode === Trainer.GUESS_TRANSLATION || master.current_status === master.status_reveal_answer) ? trainer.word : ""
                    color: Theme.secondaryColor
                }
            }

            TextArea {
                id: word
                visible: master.trainings_mode === Trainer.GUESS_WORD
                readOnly: master.current_status !== 0
                width: parent.width
                height: implicitHeight
                focus: true
                placeholderText: qsTr("Input answer")
                label: qsTr("Answer")
            }

            Row {
                width: parent.width
                Label {
                    text: qsTr("Translation: ")
                    color: Theme.primaryColor
                }

                Label {
                    text: (master.trainings_mode === Trainer.GUESS_WORD || master.current_status === master.status_reveal_answer) ? trainer.translation : ""
                    color: Theme.secondaryColor
                }
            }

            TextArea {
                id: translation
                visible: master.trainings_mode === Trainer.GUESS_TRANSLATION
                readOnly: master.current_status !== 0
                width: parent.width
                height: implicitHeight
                focus: true
                placeholderText: qsTr("Input answer")
                label: qsTr("Answer")
            }

            Button {
                width: parent.width
                text: qsTr("Reveal answer")
                enabled: master.current_status === master.status_ask_question
                onClicked: {
                    master.current_status = master.status_reveal_answer
                }
            }

            Row {
                width: parent.width

                Button {
                    width: parent.width/2
                    enabled: master.current_status === master.status_reveal_answer
                    text: qsTr("Correct")
                    onClicked: {
                        trainer.correct()
                        master.new_question()
                    }
                }

                Button {
                    width: parent.width/2
                    enabled: master.current_status === master.status_reveal_answer
                    text: qsTr("False")
                    onClicked: {
                        trainer.wrong()
                        master.new_question()
                    }
                }
            }
        }
    }
}
