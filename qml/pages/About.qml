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

Page {
    id: page
    allowedOrientations: Orientation.All

    SilicaFlickable {

        VerticalScrollDecorator {}

        anchors.fill: parent

        contentHeight: column.height

        Column {
            id: column

            anchors {
                left: parent.left
                right: parent.right
                margins: Theme.paddingLarge
            }

            PageHeader {
                title: qsTr("About")
            }

            Label {
                font.bold: true
                text: "Vocabulary 1.9"
            }

            Label {

                anchors {
                    left: parent.left
                    right: parent.right
                }

                focus: true
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.Wrap

                text: qsTr("Vocabulary is a vocabulary trainer for SailfishOS designed to be used independent of the language you want to learn.")
            }

            PageHeader {
                title: qsTr("Main authors")
            }

            Label {

                anchors {
                    left: parent.left
                    right: parent.right
                }

                focus: true
                color: Theme.primaryColor
                wrapMode: Text.Wrap

                text: "Marcus Soll"
            }

            PageHeader {
                title: qsTr("Contributors")
            }

            Label {

                anchors {
                    left: parent.left
                    right: parent.right
                }

                focus: true
                color: Theme.primaryColor
                wrapMode: Text.Wrap

                text: "Ingvix
sfbg"
            }

            PageHeader {
                title: qsTr("License")
            }

            Label {

                anchors {
                    left: parent.left
                    right: parent.right
                }

                focus: true
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
                wrapMode: Text.Wrap
                text: "Copyright 2016,2017,2019 Marcus Soll

Licensed under the Apache License, Version 2.0 (the \"License\"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an \"AS IS\" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License."
            }
        }
    }
}
