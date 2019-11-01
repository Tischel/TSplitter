#SingleInstance force

Version := "0.2.2"

; Read saved key binds
IniRead, AutosplitSplit, TSplitter.ini, AutoSplit, Split
IniRead, AutosplitReset, TSplitter.ini, AutoSplit, Reset
IniRead, AutosplitUndo, TSplitter.ini, AutoSplit, Undo
IniRead, AutosplitSkip, TSplitter.ini, AutoSplit, Skip
IniRead, AutosplitFolder, TSplitter.ini, AutoSplit, Folder

IniRead, LivesplitSplit, TSplitter.ini, LiveSplit, Split
IniRead, LivesplitReset, TSplitter.ini, LiveSplit, Reset
IniRead, LivesplitUndo, TSplitter.ini, LiveSplit, Undo
IniRead, LivesplitSkip, TSplitter.ini, LiveSplit, Skip

if (AutosplitFolder = "ERROR") {
  AutosplitFolder = 
}

; GUI
Gui, 1:New, -Resize -MaximizeBox -MinimizeBox, TSplitter v%Version%

Gui, 1:Font, bold
Gui, 1:Add, GroupBox, x10 y5 w150 h130, AutoSplit Keybinds

Gui, 1:Font, norm
Gui, 1:Add, Text, x20 y29, Split/Start
Gui, 1:Add, Text, , Reset
Gui, 1:Add, Text, , Undo
Gui, 1:Add, Text, , Skip
Gui, 1:Add, Hotkey, x80 y25 w70 vAutosplitSplitHotkey gOnChange, %AutosplitSplit%
Gui, 1:Add, Hotkey, w70 vAutosplitResetHotkey gOnChange, %AutosplitReset%
Gui, 1:Add, Hotkey, w70 vAutosplitUndoHotkey gOnChange, %AutosplitUndo%
Gui, 1:Add, Hotkey, w70 vAutosplitSkipHotkey gOnChange, %AutosplitSkip%

Gui, 1:Font, bold
Gui, 1:Add, GroupBox, x165 y5 w150 h130, LiveSplit Keybinds

Gui, 1:Font, norm
Gui, 1:Add, Text, x175 y29, Split/Start
Gui, 1:Add, Text, , Reset
Gui, 1:Add, Text, , Undo
Gui, 1:Add, Text, , Skip
Gui, 1:Add, Hotkey, x235 y25 w70 vLivesplitSplitHotkey gOnChange, %LivesplitSplit%
Gui, 1:Add, Hotkey, w70 vLivesplitResetHotkey gOnChange, %LivesplitReset%
Gui, 1:Add, Hotkey, w70 vLivesplitUndoHotkey gOnChange, %LivesplitUndo%
Gui, 1:Add, Hotkey, w70 vLivesplitSkipHotkey gOnChange, %LivesplitSkip%

Gui, 1:Font, bold
Gui, 1:Add, GroupBox, x10 y140 w305 h50, AutoSplit images folder

Gui, 1:Font, norm
Gui, 1:Add, Edit, x20 y160 w261 vAutosplitFolderTextfield gOnChange, %AutosplitFolder%
Gui, 1:Add, Button, x+-1 y159 w30 h23 gSelectFolder, ...

Gui, 1:Font, bold
Gui, 1:Add, GroupBox, x10 y195 w305 h50, Current split

Gui, 1:Font, norm
Gui, 1:Add, Text, x20 y220 w290 vRunStatusLabel, Run not started...

Menu, FileMenu, Add, &Save`tCtrl+S, ReloadScript
Menu, HelpMenu, Add, &About`tCtrl+A, ShowAbout
Menu, MyMenuBar, Add, &File, :FileMenu
Menu, MyMenuBar, Add, &Help, :HelpMenu
Gui, 1:Menu, MyMenuBar

Gui, 1:Show

saveButtonAdded := false
ControlFocus, ..., TSplitter v%Version%
OnMessage(0x201, "WM_LBUTTONDOWN")

; Set keybinds
if (AutosplitSplit != "ERROR" and AutosplitSplit != "") {
  Hotkey, %AutosplitSplit%, Split
}
if (AutosplitReset != "ERROR" and AutosplitReset != "") {
  Hotkey, %AutosplitReset%, Reset
}
if (AutosplitUndo != "ERROR" and AutosplitUndo != "") {
  Hotkey, %AutosplitUndo%, Undo
}
if (AutosplitSkip != "ERROR" and AutosplitSkip != "") {
  Hotkey, %AutosplitSkip%, Skip
}

; Parse splits
splitIndex := 1

splitFlags := []
splitFlags.Push(1)

splitDelays := []
splitDelays.Push(0)

splitNames := []
splitNames.Push("Dummy")

IfExist, %AutosplitFolder%
  Loop %AutosplitFolder%\*.*
  {
    splitNames.Push(A_LoopFileName)

    IfInString, A_LoopFileName, fake
    {
      splitFlags.Push(0)
    }
    else
    {
      splitFlags.Push(1)
    }

    IfInString, A_LoopFileName, _delay
    {
      RegExMatch(A_LoopFileName, "O)(.*)(_delay)(?<delay>\d+)", Match)
      splitDelays.Push(Match["delay"])
    }
    else
    {
      splitDelays.Push(0)
    }
  }
Return

OnChange:
  if (saveButtonAdded = false) {
    Gui, 1:Add, Button, x10 y195 w305 h50 gReloadScript, Save
  }
Return

Split:
  delay := splitDelays[splitIndex]
  Sleep, %delay%

  if (splitFlags[splitIndex] = 1) {
    Send {%LivesplitSplit%}
  }

  splitIndex := splitIndex + 1

  if (splitIndex > splitFlags.MaxIndex()) {
    splitIndex := 1
  }

  UpdateRunStatus(splitIndex, splitNames)
return

Reset:
  Send {%LivesplitReset%}
  splitIndex := 1

  UpdateRunStatus(splitIndex, splitNames)
return

Undo:
  splitIndex := splitIndex - 1
  if (splitIndex > 2 and splitFlags[splitIndex - 1] = 0) {
    Send {%AutosplitUndo%}
    return
  }

  if (splitIndex < 2) {
    splitIndex := 2
  }

  Send {%LivesplitUndo%}

  UpdateRunStatus(splitIndex, splitNames)
return

Skip:
  splitIndex := splitIndex + 1
  if (splitIndex <= splitFlags.MaxIndex() and splitFlags[splitIndex - 1] = 0) {
    Send {%AutosplitSkip%}
    return
  }

  if (splitIndex > splitFlags.MaxIndex()) {
    splitIndex := splitFlags.MaxIndex()
  }

  Send {%LivesplitSkip%}

  UpdateRunStatus(splitIndex, splitNames)
return

UpdateRunStatus(index, names) {
  if (index = 1)
  {
    GuiControl, 1:, RunStatusLabel, Run not started...
  }
  else
  {
    splitName := names[index]
    GuiControl, 1:, RunStatusLabel, %splitName%
  }
}

SaveKeybinds() {
  GuiControlGet, AutosplitSplitHotkey
  IniWrite, %AutosplitSplitHotkey%, TSplitter.ini, AutoSplit, Split

  GuiControlGet, AutosplitResetHotkey
  IniWrite, %AutosplitResetHotkey%, TSplitter.ini, AutoSplit, Reset

  GuiControlGet, AutosplitUndoHotkey
  IniWrite, %AutosplitUndoHotkey%, TSplitter.ini, AutoSplit, Undo

  GuiControlGet, AutosplitSkipHotkey
  IniWrite, %AutosplitSkipHotkey%, TSplitter.ini, AutoSplit, Skip

  GuiControlGet, AutosplitFolderTextfield
  IniWrite, %AutosplitFolderTextfield%, TSplitter.ini, AutoSplit, Folder

  GuiControlGet, LivesplitSplitHotkey
  IniWrite, %LivesplitSplitHotkey%, TSplitter.ini, LiveSplit, Split

  GuiControlGet, LivesplitResetHotkey
  IniWrite, %LiveSplitResetHotkey%, TSplitter.ini, LiveSplit, Reset

  GuiControlGet, LivesplitUndoHotkey
  IniWrite, %LiveSplitUndoHotkey%, TSplitter.ini, LiveSplit, Undo

  GuiControlGet, LivesplitSkipHotkey
  IniWrite, %LiveSplitSkipHotkey%, TSplitter.ini, LiveSplit, Skip
}

SelectFolder:
  FileSelectFolder, AutosplitFolder, *%AutosplitFolder%, 0, Select AutoSplit images folder
  GuiControl, , AutosplitFolderTextfield, %AutosplitFolder%
  Return

ReloadScript:
  SaveKeybinds()
  Reload
  Return

ShowAbout:
  Gui, About:New, +Owner -Resize, About
  Gui, About:Font, bold
  Gui, About:Add, Text,, TSplitter v%Version%
  Gui, About:Font, norm
  Gui, About:Add, Link,, Check latest releases and documentation at`n<a href="https://github.com/Tischel/TSplitter">https://github.com/Tischel/TSplitter</a>
  Gui, About:Show
  Return

GuiClose:
  SaveKeybinds()
  ExitApp

WM_LBUTTONDOWN() {
  DllCall("SetFocus", "Ptr", 0)
}
