#SingleInstance Force
#InstallKeybdHook
#InstallMouseHook
SendMode Input
SetWorkingDir %A_ScriptDir%
CoordMode, Mouse, Screen

; BeMousless numpad mouse controller.
; Numpad0 + Right toggles the controller on and off.

mouseMode := false
movementTimer := 0
orbitTimer := 0
movementStarted := 0
movementSpeed := 0.0
orbitAngle := 0.0
orbitCenterX := 0
orbitCenterY := 0
orbitRadius := 80
leftButtonHeld := false
dragLocked := false
scrollDirection := 0

; Toggle the controller. The prefix key is also used for right click below.
Numpad0 & Right::ToggleMouseMode()

; Exit the script completely. It can also be stopped from the tray icon.
^!q::ExitApp
^!r::Reload

; Ctrl + movement selects and keeps holding the item until Numpad5 drops it.
#If mouseMode
^LShift::DisableMouseMode()
^RShift::DisableMouseMode()
Numpad5::ClickOrDrop()
^Numpad5::ClickOrDrop()
~*Ctrl Up::ReleaseTransientDrag()
Numpad0::Click, Right
NumpadAdd::StartScroll(-1)
NumpadAdd Up::StopScroll()
NumpadSub::StartScroll(1)
NumpadSub Up::StopScroll()

; Hold these keys for fluid, accelerated movement.
*Numpad7::StartMovement()
*Numpad8::StartMovement()
*Numpad9::StartMovement()
*Numpad4::StartMovement()
*Numpad6::StartMovement()
*Numpad1::StartMovement()
*Numpad2::StartMovement()
*Numpad3::StartMovement()
*Numpad7 Up::EndMovement()
*Numpad8 Up::EndMovement()
*Numpad9 Up::EndMovement()
*Numpad4 Up::EndMovement()
*Numpad6 Up::EndMovement()
*Numpad1 Up::EndMovement()
*Numpad2 Up::EndMovement()
*Numpad3 Up::EndMovement()

; Precision mode: hold Numpad . while moving for a slower cursor.
*NumpadDot::TogglePrecision()

; 0 + . starts/stops a smooth circular cursor path around the current point.
Numpad0 & NumpadDot::ToggleOrbit()
#If

ToggleMouseMode() {
    global mouseMode
    if mouseMode
        DisableMouseMode()
    else
        EnableMouseMode()
}

EnableMouseMode() {
    global mouseMode
    mouseMode := true
    ToolTip, MOUSE MODE ON`n7 8 9 / 4 6 / 1 2 3: move`n5: left click/drop   0: right click`n- / +: scroll up/down`nCtrl + move: select and hold   5: collect/drop`n0 + . : orbit   Ctrl+Shift: disable`nCtrl+Alt+R: reload   Ctrl+Alt+Q: exit
    SetTimer, HideModeTip, -1800
}

DisableMouseMode() {
    global mouseMode, movementTimer, orbitTimer, movementSpeed, movementStarted, leftButtonHeld, dragLocked, scrollDirection
    mouseMode := false
    if movementTimer
        SetTimer, MoveCursor, Off
    if orbitTimer
        SetTimer, OrbitCursor, Off
    SetTimer, ScrollCursor, Off
    movementTimer := 0
    orbitTimer := 0
    movementSpeed := 0.0
    movementStarted := 0
    if leftButtonHeld {
        Click, Up
        leftButtonHeld := false
    }
    dragLocked := false
    scrollDirection := 0
    ToolTip
}

HideModeTip() {
    ToolTip
}

BeginLeftButton() {
    global leftButtonHeld
    if !leftButtonHeld {
        Click, Down
        leftButtonHeld := true
    }
}

EndLeftButton() {
    global leftButtonHeld
    if leftButtonHeld {
        Click, Up
        leftButtonHeld := false
    }
}

ClickOrDrop() {
    global leftButtonHeld, dragLocked
    if leftButtonHeld {
        EndLeftButton()
        dragLocked := false
    } else {
        Click, Left
    }
}

ReleaseTransientDrag() {
    ; A Ctrl drag is intentionally preserved after Ctrl is released so the
    ; selected item can be moved and dropped at a later destination.
}

StartScroll(direction) {
    global scrollDirection
    scrollDirection := direction
    ScrollCursor()
    SetTimer, ScrollCursor, 55
}

StopScroll() {
    global scrollDirection
    scrollDirection := 0
    SetTimer, ScrollCursor, Off
}

ScrollCursor() {
    global scrollDirection
    if scrollDirection > 0
        MouseClick, WheelUp, , , 1, 0
    else if scrollDirection < 0
        MouseClick, WheelDown, , , 1, 0
}

EndMovement() {
    global movementStarted, dragLocked
    if AnyDirectionHeld()
        return
    movementStarted := 0
    SetTimer, MoveCursor, Off
    if !dragLocked
        EndLeftButton()
}

StartMovement() {
    global movementTimer, movementStarted, leftButtonHeld, dragLocked
    if GetKeyState("Ctrl", "P") {
        if !leftButtonHeld
            BeginLeftButton()
        dragLocked := true
    }
    if !movementStarted {
        movementStarted := A_TickCount
        SetTimer, MoveCursor, 10
    }
}

MoveCursor() {
    global mouseMode, movementStarted, movementSpeed, dragLocked
    if !mouseMode || !AnyDirectionHeld() {
        movementStarted := 0
        movementSpeed := 0.0
        if !dragLocked
            EndLeftButton()
        SetTimer, MoveCursor, Off
        return
    }

    heldFor := A_TickCount - movementStarted
    movementSpeed := 2.5 + (heldFor / 1000.0 * 18.0)
    if movementSpeed > 22.0
        movementSpeed := 22.0
    if GetKeyState("NumpadDot", "P")
        movementSpeed := movementSpeed * 0.22
    if movementSpeed < 1.0
        movementSpeed := 1.0

    horizontal := GetKeyState("Numpad6", "P") - GetKeyState("Numpad4", "P")
    vertical := GetKeyState("Numpad2", "P") - GetKeyState("Numpad8", "P")
    diagonalX := GetKeyState("Numpad9", "P") + GetKeyState("Numpad3", "P") - GetKeyState("Numpad7", "P") - GetKeyState("Numpad1", "P")
    diagonalY := GetKeyState("Numpad1", "P") + GetKeyState("Numpad3", "P") - GetKeyState("Numpad7", "P") - GetKeyState("Numpad9", "P")

    x := horizontal + diagonalX
    y := vertical + diagonalY
    length := Sqrt(x * x + y * y)
    if length {
        ; Normalize diagonals so diagonal travel is not faster than straight travel.
        moveX := Round(x / length * movementSpeed)
        moveY := Round(y / length * movementSpeed)
        MouseMove, %moveX%, %moveY%, 0, R
    }
}

AnyDirectionHeld() {
    return GetKeyState("Numpad1", "P") || GetKeyState("Numpad2", "P") || GetKeyState("Numpad3", "P")
        || GetKeyState("Numpad4", "P") || GetKeyState("Numpad6", "P")
        || GetKeyState("Numpad7", "P") || GetKeyState("Numpad8", "P") || GetKeyState("Numpad9", "P")
}

TogglePrecision() {
    ; The actual precision state is read directly while NumpadDot is held.
}

ToggleOrbit() {
    global orbitTimer, orbitCenterX, orbitCenterY, orbitAngle
    if orbitTimer {
        SetTimer OrbitCursor, 0
        orbitTimer := 0
        return
    }
    MouseGetPos, orbitCenterX, orbitCenterY
    orbitAngle := 0.0
    orbitTimer := 1
    SetTimer, OrbitCursor, 12
}

OrbitCursor() {
    global mouseMode, orbitTimer, orbitCenterX, orbitCenterY, orbitAngle, orbitRadius
    if !mouseMode || !GetKeyState("NumpadDot", "P") {
        SetTimer, OrbitCursor, Off
        orbitTimer := 0
        return
    }
    orbitAngle += 0.10
    moveX := Round(Cos(orbitAngle) * orbitRadius)
    moveY := Round(Sin(orbitAngle) * orbitRadius)
    MouseMove, %moveX%, %moveY%, 0, R
}