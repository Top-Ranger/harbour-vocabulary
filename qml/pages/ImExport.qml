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

Page {
    id: page
    allowedOrientations: Orientation.All
    property bool is_import: true
    property bool path_exists: false

    SilicaFlickable {
        anchors.fill: parent

        VerticalScrollDecorator {}

        contentHeight: column.height

        Column {
            id: column
            width: page.width
            spacing: Theme.paddingMedium

            PageHeader {
                title: qsTr("Import / Export")
            }

            ComboBox {
                id: select_operation
                width: parent.width
                label: qsTr("Operation")

                onCurrentItemChanged: {
                    switch(currentIndex) {
                    case 0:
                        page.is_import = true
                        targetPath.text = file_utils.getFilePath(".csv")
                        break
                    case 1:
                        page.is_import = false
                        targetPath.text = file_utils.getFilePath(".csv")
                        break
                    }
                }

                menu: ContextMenu {
                    MenuItem { text: qsTr("Import CSV") }
                    MenuItem { text: qsTr("Export CSV") }
                }
            }

            TextField {
                id: targetPath
                label: qsTr("Target path")
                placeholderText: qsTr("Target path")
                onTextChanged: {
                    page.path_exists = file_utils.checkFileExists(text)
                }
            }

            Label {
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.horizontalPageMargin
                }

                text: qsTr("WARNING: Overwriting file")
                font.pixelSize: Theme.fontSizeLarge
                font.italic: true
                visible: !page.is_import && page.path_exists
            }

            Button {
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Theme.horizontalPageMargin
                }

                id: start
                enabled: (page.is_import && page.path_exists) || !page.is_import
                text: qsTr("Start import / export")


                onClicked: {
                    var target = "ImExport/CSVExport.qml"
                    switch(select_operation.currentIndex) {
                    case 0:
                        target = "ImExport/CSVImport.qml"
                        break
                    case 1:
                        target = "ImExport/CSVExport.qml"
                        break;
                    }

                    pageStack.replace(Qt.resolvedUrl(target), { path: targetPath.text })
                }
            }
        }
    }
}
