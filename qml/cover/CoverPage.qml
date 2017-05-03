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

CoverBackground {
    
    Image {
        source: 'vocabulary-cover.png'
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        height: sourceSize.height * width / sourceSize.width
    } 
    
    Column {
        anchors {
            fill: parent
            margins: Theme.horizontalPageMargin
        }

        spacing: Theme.paddingMedium

        Label {
            color: Theme.primaryColor
            width: parent.width
            wrapMode: Text.Wrap
            text: random_vocabulary.word
        }

        Label {
            color: Theme.secondaryColor
            width: parent.width
            wrapMode: Text.Wrap
            text: random_vocabulary.translation
        }
    }

    CoverActionList {
        CoverAction {
            iconSource: "image://theme/icon-cover-next"
            onTriggered: random_vocabulary.newRandom()
        }
    }
}


