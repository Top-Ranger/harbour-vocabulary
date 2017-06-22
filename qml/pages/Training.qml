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
import harbour.vocabulary.Trainer 1.0

Page {
    id: page
    allowedOrientations: Orientation.All

    property var filter_type: []
    property var filter_argv: []
    property bool loading_success: false
    property int selected_modus: Trainer.TEST_BOTH

    property int end_after: 0

    Component.onCompleted: {
        if(trainer.load_vocabulary(filter_type, filter_argv, selected_modus)) {
            loading_success = true
            master.new_question()
        }
    }

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
            property int questions_asked: 0
            property int questions_correct: 0
            
            property var keys_question_wrong: []
            property var values_question_wrong: []
            
            function add_wrong_id(id) {
                if(end_after === 0){
                    return
                }
                
                // Search for key
                for(var i = 0; i < keys_question_wrong.length; ++i) {
                    if(keys_question_wrong[i] === id) {
                        values_question_wrong[i] = values_question_wrong[i] + 1
                        return
                    }
                }
                
                // Key not known - add it
                keys_question_wrong.push(id)
                values_question_wrong.push(1)
            }

            function new_question() {
                questions_asked += 1

                if(page.end_after !== 0 && questions_asked > page.end_after) {
                    // Find most wrong vocabulary
                    var most_wrong_id = -1
                    var most_wrong_count = 0
                    
                    for(var i = 0; i < keys_question_wrong.length; ++i) {
                        if(values_question_wrong[i] > most_wrong_count) {
                            console.log(keys_question_wrong[i])
                            most_wrong_count = values_question_wrong[i]
                            most_wrong_id = keys_question_wrong[i]
                        }
                    }
                    
                    // Show result page
                    pageStack.replace(Qt.resolvedUrl("TrainingResult.qml"), { correct_this_time: questions_correct / (questions_asked-1), most_wrong: most_wrong_id } )
                    return
                }

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

            Label {
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.horizontalPageMargin
                }

                visible: !page.loading_success
                text: qsTr("Can not load vocabulary!")
                font.bold: true
                font.italic: true
                font.pixelSize: Theme.fontSizeLarge
                color: Theme.primaryColor
            }

            Row {
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.horizontalPageMargin
                }

                Label {
                    id: word_label
                    text: qsTr("Word: ")
                    color: Theme.primaryColor
                }

                Label {
                    width: parent.width - word_label.width
                    text: (master.trainings_mode === Trainer.GUESS_TRANSLATION || master.current_status === master.status_reveal_answer) ? trainer.word : ""
                    color: Theme.secondaryColor
                    wrapMode: Text.Wrap
                }
            }

            TextArea {
                id: word
                visible: master.trainings_mode === Trainer.GUESS_WORD
                readOnly: master.current_status !== 0
                width: parent.width
                height: implicitHeight
                inputMethodHints: Qt.ImhNoPredictiveText
                EnterKey.onClicked: { text = text.replace("\n", ""); parent.focus = true }
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                placeholderText: qsTr("Input answer")
                label: qsTr("Answer")
            }

            Row {
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.horizontalPageMargin
                }

                Label {
                    id: translation_label
                    text: qsTr("Translation: ")
                    color: Theme.primaryColor
                }

                Label {
                    width: parent.width - translation_label.width
                    text: (master.trainings_mode === Trainer.GUESS_WORD || master.current_status === master.status_reveal_answer) ? trainer.translation : ""
                    color: Theme.secondaryColor
                    wrapMode: Text.Wrap
                }
            }

            TextArea {
                id: translation
                visible: master.trainings_mode === Trainer.GUESS_TRANSLATION
                readOnly: master.current_status !== 0
                width: parent.width
                height: implicitHeight
                inputMethodHints: Qt.ImhNoPredictiveText
                EnterKey.onClicked: { text = text.replace("\n", ""); parent.focus = true }
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                placeholderText: qsTr("Input answer")
                label: qsTr("Answer")
            }

            Row {
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.horizontalPageMargin
                }

                Label {
                    id: language_label
                    text: qsTr("Language: ")
                    color: Theme.primaryColor
                }

                Label {
                    width: parent.width - language_label.width
                    text: trainer.language !== -1 ? simple_interface.getLanguageName(trainer.language) : ""
                    color: Theme.secondaryColor
                    wrapMode: Text.Wrap
                }
            }

            Row {
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.horizontalPageMargin
                }

                Label {
                    id: correct_label
                    text: qsTr("Correct: ")
                    color: Theme.primaryColor
                }

                Label {
                    width: parent.width - correct_label.width
                    text: trainer.numberAsked === 0 ? "" : "" + Math.round(100.0*trainer.numberCorrect / trainer.numberAsked) + "%"
                    color: Theme.secondaryColor
                    wrapMode: Text.Wrap
                }
            }

            Button {
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.horizontalPageMargin
                }

                width: parent.width
                text: qsTr("Reveal answer")
                enabled: master.current_status === master.status_ask_question && page.loading_success
                onClicked: {
                    master.current_status = master.status_reveal_answer
                }
            }

            Row {
                spacing: Theme.paddingSmall
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.horizontalPageMargin
                }

                Button {
                    width: parent.width/2 - Theme.paddingSmall/2
                    enabled: master.current_status === master.status_reveal_answer && page.loading_success
                    text: qsTr("Correct")
                    onClicked: {
                        trainer.correct()
                        master.questions_correct += 1
                        master.new_question()
                    }
                }

                Button {
                    width: parent.width/2 - Theme.paddingSmall/2
                    enabled: master.current_status === master.status_reveal_answer && page.loading_success
                    text: qsTr("False")
                    onClicked: {
                        trainer.wrong()
                        master.add_wrong_id(trainer.id)
                        master.new_question()
                    }
                }
            }
        }
    }
}
