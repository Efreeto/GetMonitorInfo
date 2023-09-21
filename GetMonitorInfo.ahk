err := DllCall("GetDisplayConfigBufferSizes", "UInt", 2, "UInt*", &pathCount:=0, "UInt*", &modeCount:=0) ; 2:QDC_ONLY_ACTIVE_PATHS
CheckError(err, A_LineNumber - 1)
paths := Buffer(72 * pathCount)   ; 72 for DISPLAYCONFIG_PATH_INFO
modes := Buffer(64 * modeCount)   ; 64 for DISPLAYCONFIG_MODE_INFO
err := DllCall("QueryDisplayConfig", "UInt", 2, "UInt*", &pathCount, "Ptr", paths, "UInt*", &modeCount, "Ptr", modes, "Ptr", 0) ; 2:QDC_ONLY_ACTIVE_PATHS
CheckError(err, A_LineNumber - 1)

offset := 0
Loop pathCount
{
    adapterId := NumGet(paths, offset, "UInt64")
    sourceId := NumGet(paths, offset + 8, "UInt")
    targetId := NumGet(paths, offset + 28, "UInt")
    ; MsgBox adapterID " and " sourceId " and " targetId

    deviceName := Buffer(420)                       ; 420 for DISPLAYCONFIG_TARGET_DEVICE_NAME
    NumPut("Int", 2, deviceName, 0)                 ; 2:DISPLAYCONFIG_DEVICE_INFO_GET_TARGET_NAME
    NumPut("UInt", deviceName.Size, deviceName, 4)  ; size
    NumPut("UInt64", adapterId, deviceName, 8)      ; adapterId
    NumPut("UInt", targetId, deviceName, 16)        ; id
    err := DllCall("DisplayConfigGetDeviceInfo", "Ptr", deviceName)
    CheckError(err, A_LineNumber - 1)
    monitorFriendlyDeviceName := StrGet(deviceName.Ptr + 36)
    ; monitorDevicePath := StrGet(deviceName.Ptr + 164)

    colorInfo := Buffer(32)                         ; 32 for DISPLAYCONFIG_GET_ADVANCED_COLOR_INFO
    NumPut("Int", 9, colorInfo, 0)                  ; 9:DISPLAYCONFIG_DEVICE_INFO_GET_ADVANCED_COLOR_INFO
    NumPut("UInt", colorInfo.Size, colorInfo, 4)    ; size
    NumPut("UInt64", adapterId, colorInfo, 8)       ; adapterId
    NumPut("UInt", targetId, colorInfo, 16)         ; id
    err := DllCall("DisplayConfigGetDeviceInfo", "Ptr", colorInfo)
    CheckError(err, A_LineNumber - 1)
    value := NumGet(colorInfo, 20, "Int")    ; get the `value` after 20 header
    advancedColorSupported := (value & 0x1) == 0x1
    advancedColorEnabled := (value & 0x2) == 0x2
    wideColorEnforced := (value & 0x4) == 0x4
    advancedColorForceDisabled := (value & 0x8) == 0x8
    MsgBox(
        "Monitor name: `"" monitorFriendlyDeviceName "`""
        "`n advancedColorSupported: " advancedColorSupported
        "`n advancedColorEnabled: " advancedColorEnabled
        "`n wideColorEnforced: " wideColorEnforced
        "`n advancedColorForceDisabled: " advancedColorForceDisabled)
    offset += 72
}

CheckError(error, lineNumber)
{
    If error
    {
        MsgBox "Error! code: " err " (ln:" lineNumber ")"
        ExitApp
    }
}