//@ pragma UseQApplication
import QtQuick
import Quickshell
import "./modules/bar/"
import "./modules/sidePanel/"
import "./modules/notification/"
import "./modules/lockscreen/"
import "./modules/test/"
import "./services"

ShellRoot {
    id: root

    //Test {}
    Bar {}
    LockScreen {}
    SidePanel {}
    Popup{}
}
