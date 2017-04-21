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
import harbour.vocabulary.SettingsProxy 1.0

ListItem {
	id: vocabularyListItem
	width: parent.width
	
	SettingsProxy {
        	id: settings
	}
	
	Rectangle {
		anchors {
			bottom: parent.bottom
			left: parent.left
		}

		height: parent.height * 0.2
		width: parent.width * priority / 100

		color: Theme.secondaryHighlightColor
		visible: (priority > 1) && settings.adaptiveTrainingEnabled
		opacity: .5
	}

	Row {
		width: parent.width - 2*Theme.paddingLarge
		anchors.centerIn: parent

		anchors {
			left: parent.left
			right: parent.right
			margins: Theme.paddingLarge
		}

		Label {
			id: word_label
			text: word
			color: Theme.primaryColor
		}
		Label {
			text: " "
			color: Theme.primaryColor
		}
		Label {
			width: parent.width - word_label.width
			text: translation
			color: Theme.secondaryColor
			horizontalAlignment: Text.AlignLeft
			truncationMode: TruncationMode.Elide
		}
	}

	menu: ContextMenu {
		MenuItem {
			text: "<img src=\"image://theme/icon-s-edit\" align=\"middle\" /> " + qsTr("Edit vocabulary")
			textFormat: Text.StyledText
			onClicked: {
				pageStack.push(Qt.resolvedUrl("Edit.qml"), { word_id: id } )
			}
		}

		MenuItem {
			text: "<img src=\"image://theme/icon-m-delete\" width=\"" + Theme.iconSizeSmall + "\" height=\"" + Theme.iconSizeSmall + "\" align=\"middle\" >" + qsTr("Remove vocabulary")
			textFormat: Text.StyledText
			onClicked: {
				vocabularyListItem.remorseAction(qsTr("Remove vocabulary"), function() { functions.remove_word(id, vocabularyListItem) })
			}
		}

		MenuItem {
			text: "<img src=\"image://theme/icon-s-clipboard\" align=\"middle\" /> "+ qsTr("Copy word to clipboard")
			textFormat: Text.StyledText
			onClicked: {
				Clipboard.text = word
			}
		}

		MenuItem {
			text: "<img src=\"image://theme/icon-s-clipboard\" align=\"middle\" /> " + qsTr("Copy translation to clipboard")
			textFormat: Text.StyledText
			onClicked: {
				Clipboard.text = translation
			}
		}
	}

	onClicked: {
		pageStack.push(Qt.resolvedUrl("Details.qml"), { word_id: id })
	}
}
