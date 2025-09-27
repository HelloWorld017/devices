import Quickshell
import QtQuick
import QtQuick.Layouts

PanelWindow {
	color: "transparent"
	implicitWidth: 70
	implicitHeight: 30

	margins.top: 12
	margins.right: 12

	anchors {
		top: true
		right: true
	}

	Rectangle {
		anchors.fill: parent
		radius: 10
		color: "#a0000000"

		RowLayout {
			anchors.centerIn: parent
			spacing: 2

			Rectangle {
				color: "red"
				width: 12
				height: 12
				radius: 6
			}

			Text {
				text: "REC"
				font.family: "Pretendard JP"
				font.pixelSize: 15
				font.weight: 600
				color: "white"
			}
		}
	}
}
