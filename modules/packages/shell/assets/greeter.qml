import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Services.Greetd

ShellRoot {
  id: root

  property string username: settings.adapter.user
  property bool authenticating: false
  property bool responseRequired: false
  property bool echoResponse: false
  property string pendingPassword: ""
  property bool hasPendingPassword: false
  property string prompt: ""
  property string message: ""
  property bool failed: false
  property bool editingUser: false
  property string wallpaperSource: ""
  signal clearInput()

  FileView {
    id: settings
    path: Quickshell.env("GREETER_CONFIG")
    blockLoading: true
    JsonAdapter {
      property string user: ""
      property string wallpaperFile: ""
      property list<string> session: []
    }
  }

  FileView {
    path: settings.adapter.wallpaperFile
    watchChanges: true
    onFileChanged: reload()
    onLoaded: root.wallpaperSource = text().trim()
  }

  SystemClock { id: clock; precision: SystemClock.Seconds }

  function reset() {
    authenticating = false;
    responseRequired = false;
    pendingPassword = "";
    hasPendingPassword = false;
    prompt = "";
    message = "";
    failed = false;
    clearInput();
  }

  function cancel() {
    if (Greetd.available && authenticating) Greetd.cancelSession();
    reset();
  }

  function submit(text) {
    if (editingUser) {
      if (text.trim().length > 0) {
        username = text.trim();
      }

      editingUser = false;
      clearInput();
    } else if (Greetd.available && username.length > 0) {
      failed = false;
      message = "";

      if (responseRequired) {
        responseRequired = false;
        clearInput();
        Greetd.respond(text);
      } else if (!authenticating) {
        pendingPassword = text;
        hasPendingPassword = true;
        authenticating = true;
        clearInput();
        Greetd.createSession(username);
      }
    }
  }

  Connections {
    target: Greetd
    function onAuthMessage(message, error, responseRequired, echoResponse) {
      root.responseRequired = responseRequired;
      root.echoResponse = echoResponse;
      root.failed = error;

      if (responseRequired) {
        root.prompt = message;

        if (!echoResponse && root.hasPendingPassword) {
          const password = root.pendingPassword;
          root.pendingPassword = "";
          root.hasPendingPassword = false;
          root.responseRequired = false;
          Greetd.respond(password);
        } else {
          root.pendingPassword = "";
          root.hasPendingPassword = false;
        }
      } else {
        root.message = message;
      }
    }

    function onAuthFailure(message) {
      root.reset();
      root.failed = true;
      root.message = message || "Authentication failed. Try again.";
    }

    function onError(error) {
      root.reset();
      root.failed = true;
      root.message = error;
    }

    function onReadyToLaunch() {
      root.pendingPassword = "";
      root.hasPendingPassword = false;
      root.clearInput();
      Greetd.launch(settings.adapter.session);
    }
  }

  FloatingWindow {
    id: window
    title: "Login"
    color: "#101018"

    readonly property real layoutScale: 1 / Screen.devicePixelRatio

    Shortcut {
      sequence: "Escape"
      onActivated: root.cancel()
    }

    Item {
      anchors.fill: parent
      layer.enabled: true
      layer.effect: MultiEffect {
        blurEnabled: true
        blurMax: 64
        blur: 1
        contrast: -0.1084
      }

      Image {
        anchors.fill: parent
        source: root.wallpaperSource
        fillMode: Image.PreserveAspectCrop
        horizontalAlignment: Image.AlignHCenter
        verticalAlignment: Image.AlignVCenter
        autoTransform: true
      }
    }

    Rectangle {
      anchors.fill: parent
      color: "black"
      opacity: 1 - 0.7172
    }

    Item {
      x: 300 * window.layoutScale
      y: 300 * window.layoutScale
      width: time.implicitWidth
      height: 290 * window.layoutScale
      layer.enabled: true
      layer.effect: MultiEffect {
        shadowEnabled: true
        shadowColor: "black"
        shadowBlur: 0.3
        shadowVerticalOffset: 2
        shadowOpacity: 1
      }

      Text {
        id: time
        text: Qt.formatDateTime(clock.date, "HH:mm")
        color: "white"
        font.family: "Aquatico"
        font.pixelSize: 150 * (96 / 72) * window.layoutScale
      }

      Text {
        x: 10 * window.layoutScale
        y: 260 * window.layoutScale
        text: Qt.locale("ja_JP").toString(clock.date, "MMM dd日 dddd")
        color: "#b3ffffff"
        font.family: "Pretendard JP"
        font.pixelSize: 24 * (96 / 72) * window.layoutScale
      }
    }

    Rectangle {
      id: field
      anchors.horizontalCenter: parent.horizontalCenter
      y: parent.height / 2 + 470 * window.layoutScale - height / 2
      width: 375 * window.layoutScale
      height: 90 * window.layoutScale
      radius: height / 2
      border.width: 1
      border.color: "#0dffffff"
      color: root.failed ? "#1acc2222" : root.authenticating ? "#1affffff" : "transparent"

      TextInput {
        id: input
        anchors.fill: parent
        anchors.margins: 12 * window.layoutScale
        horizontalAlignment: TextInput.AlignHCenter
        verticalAlignment: TextInput.AlignVCenter
        color: "#c8c8c8"
        font.family: "Pretendard JP"
        font.pixelSize: 32 * (96 / 72) * window.layoutScale
        echoMode: root.editingUser || (root.responseRequired && root.echoResponse)
                  ? TextInput.Normal : TextInput.Password
        passwordCharacter: "•"
        passwordMaskDelay: 0
        selectByMouse: root.editingUser || root.echoResponse
        activeFocusOnTab: true
        focus: true
        enabled: root.editingUser || !root.authenticating || root.responseRequired
        clip: true
        onAccepted: root.submit(text)
        onEnabledChanged: if (enabled) forceActiveFocus()
        Keys.onEscapePressed: root.cancel()

        Text {
          anchors.centerIn: parent
          visible: input.text.length === 0
          text: root.editingUser ? "Username" : root.authenticating && !root.responseRequired
                ? "Authenticating…" : root.responseRequired && root.echoResponse
                ? root.prompt : root.username
          color: "#cdd6f4"
          font: input.font
          width: parent.width
          horizontalAlignment: Text.AlignHCenter
          elide: Text.ElideRight
        }
      }

      Connections {
        target: root
        function onClearInput() { input.text = ""; input.forceActiveFocus(); }
      }

      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.top
        anchors.bottomMargin: 16 * window.layoutScale
        width: Math.min(window.width - 40, 600 * window.layoutScale)
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        text: !Greetd.available ? "Greeter preview — greetd is not connected"
              : root.message || (root.responseRequired ? root.prompt : "")
        color: root.failed ? "#ef9a9a" : "#b3ffffff"
        font.family: "Pretendard JP"
        font.pixelSize: 14 * window.layoutScale
      }

      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.bottom
        anchors.topMargin: 14 * window.layoutScale
        text: root.editingUser ? "Cancel" : "Switch user"
        color: userMouse.containsMouse ? "#cdd6f4" : "#80ffffff"
        font.family: "Pretendard JP"
        font.pixelSize: 13 * window.layoutScale
        activeFocusOnTab: true
        function activate() {
          root.cancel();
          root.editingUser = !root.editingUser;
          input.forceActiveFocus();
        }
        Keys.onReturnPressed: activate()
        Keys.onSpacePressed: activate()
        MouseArea {
          id: userMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: parent.activate()
        }
      }
    }
  }
}
