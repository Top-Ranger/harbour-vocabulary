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

    property real correct_this_time: 0
    property real correct_overall: simple_interface.getOverallPercentageCorrect();
    property int most_wrong: -1

    SilicaFlickable {
        anchors.fill: parent

        VerticalScrollDecorator {}

        contentHeight: column.height

        Column {
            id: column
            spacing: Theme.paddingLarge

            anchors {
                left: parent.left
                right: parent.right
                margins: Theme.paddingLarge
            }

            PageHeader {
                title: qsTr("Training Results")
            }

            Row {
                Label {
                    id: this_time
                    text: qsTr("Correct this time: ")
                    color: Theme.highlightColor
                }

                Text {
                    id: this_time_label
                    width: column.width - this_time.width
                    color: Theme.primaryColor
                    wrapMode: Text.Wrap
                    text: "" + Math.round(100 * page.correct_this_time) + "%"
                }
            }

            Row {
                Label {
                    id: overall
                    text: qsTr("Overall percentage: ")
                    color: Theme.highlightColor
                }

                Text {
                    id: overall_label
                    width: column.width - overall.width
                    color: Theme.primaryColor
                    wrapMode: Text.Wrap
                    text: "" + Math.round(100 * page.correct_overall) + "%"
                }
            }
            
            Text {
                visible: most_wrong !== -1
                width: parent.width
                text: qsTr("Vocabulary with the most wrong answers:")
                font.underline: true
                font.bold: true
                color: Theme.highlightColor
                wrapMode: Text.Wrap
            }
            
            Row {
                visible: most_wrong !== -1
                Label {
                    id: most_wrong_word
                    text: qsTr("Vocabulary: ")
                    color: Theme.highlightColor
                }

                Text {
                    id: most_wrong_word_label
                    width: column.width - most_wrong_word.width
                    color: Theme.primaryColor
                    wrapMode: Text.Wrap
                    text: most_wrong !== -1 ? simple_interface.getWord(most_wrong) : ""
                }
            }
            
            Row {
                visible: most_wrong !== -1
                Label {
                    id: most_wrong_translation
                    text: qsTr("Translation: ")
                    color: Theme.highlightColor
                }

                Text {
                    id: most_wrong_translation_label
                    width: column.width - most_wrong_translation.width
                    color: Theme.primaryColor
                    wrapMode: Text.Wrap
                    text: most_wrong !== -1 ? simple_interface.getTranslationOfWord(most_wrong) : ""
                }
            }
            
            Button {
                visible: most_wrong !== -1
                anchors {
                    left: parent.left
                    right: parent.right
                }
                text: qsTr("Show on cover")
                onClicked: {
                    random_vocabulary.word = most_wrong_word_label.text
                    random_vocabulary.translation = most_wrong_translation_label.text
                }
            }
        }
    }
}
