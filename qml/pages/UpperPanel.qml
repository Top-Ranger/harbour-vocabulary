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

Item {
    id: dockedPanel
    width: Screen.width
    height: Screen.height / 8

    property color color: "black"
    property int time: 2000
    property string text: ""

    signal triggered()

    function show() {
        if(panel.open)
        {
            timer.stop()
            panel.hide()
        }
        timer.start()
        panel.show()
    }

    DockedPanel {
        id: panel
        width: parent.width
        height: Theme.itemSizeLarge
        dock: Dock.Top

        Rectangle {
            width: parent.width
            height: parent.height
            color: dockedPanel.color

            Label {
                text: dockedPanel.text
                font.pixelSize: Theme.fontSizeLarge
                color: Theme.primaryColor
                anchors.centerIn: parent
            }
        }

        Timer {
            id: timer
            interval: dockedPanel.time
            onTriggered: {
                panel.hide()
                dockedPanel.triggered()
            }
        }
    }
}
