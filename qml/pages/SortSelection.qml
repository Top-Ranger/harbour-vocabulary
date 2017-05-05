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

    property var names: []
    property var values: []

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
            var len = Math.min(page.names.length, page.values.length)
            if(page.names.length !== page.values.length) {
                console.error("Names and values are not the same length - items may be missing")
            }

            for(var i = 0; i < len; ++i) {
                listModel.append({"name": page.names[i], "value": page.values[i]})
            }
        }
    }

    ListModel {
        id: listModel
    }

    SilicaListView {
        id: list
        model: listModel
        anchors.fill: parent

        header: Column {
            width: page.width
            spacing: Theme.paddingMedium

            PageHeader {
                width: parent.width
                title: qsTr("Sorting criterium")
            }
        }

        Component.onCompleted: {
            functions.load_list()
        }

        delegate: ListItem {
            anchors {
                right: parent.right
                left: parent.left
            }

            Label {
                anchors {
                    right: parent.right
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                    margins: Theme.paddingLarge
                }

                text: name
                horizontalAlignment: Text.AlignLeft
                truncationMode: TruncationMode.Elide
            }

            onClicked: {
                var last_page = pageStack.previousPage()
                last_page.sort_criterium = value
                pageStack.pop()
            }
        }

        VerticalScrollDecorator {}
    }
}
