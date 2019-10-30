#SingleInstance force

Version := "0.1.0"

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

; GUI
Gui, New, +Resize +MinSize300x200 -MaximizeBox -MinimizeBox, TSplitter v%Version%

Gui, Font, bold
Gui, Add, Text,, AutoSplit Keybinds

Gui, Font, norm
Gui, Add, Text,, Split/Start
Gui, Add, Text,, Reset
Gui, Add, Text,, Undo
Gui, Add, Text,, Skip
Gui, Add, Hotkey, x70 y30 w70 vAutosplitSplitHotkey, %AutosplitSplit%
Gui, Add, Hotkey, w70 vAutosplitResetHotkey, %AutosplitReset%
Gui, Add, Hotkey, w70 vAutosplitUndoHotkey, %AutosplitUndo%
Gui, Add, Hotkey, w70 vAutosplitSkipHotkey, %AutosplitSkip%

Gui, Font, bold
Gui, Add, Text, x150 y6, LiveSplit Keybinds

Gui, Font, norm
Gui, Add, Text,, Split/Start
Gui, Add, Text,, Reset
Gui, Add, Text,, Undo
Gui, Add, Text,, Skip
Gui, Add, Hotkey, x220 y30 w70 vLivesplitSplitHotkey, %LivesplitSplit%
Gui, Add, Hotkey, w70 vLivesplitResetHotkey, %LivesplitReset%
Gui, Add, Hotkey, w70 vLivesplitUndoHotkey, %LivesplitUndo%
Gui, Add, Hotkey, w70 vLivesplitSkipHotkey, %LivesplitSkip%

Gui, Font, bold
Gui, Add, Text, x10, AutoSplit images folder

Gui, Font, norm
Gui, Add, Edit, w280 vAutosplitFolderTextfield, %AutosplitFolder%

Gui, Add, Button, Default x10 y+10 w280 h30 gReloadScript, Reload
Gui, Show

ControlFocus, Reload, TSplitter v%Version%

; Set keybinds
if AutosplitSplit {
  Hotkey, %AutosplitSplit%, Split
}
if AutosplitReset {
  Hotkey, %AutosplitReset%, Reset
}
if AutosplitUndo {
  Hotkey, %AutosplitUndo%, Undo
}
if AutosplitSkip {
  Hotkey, %AutosplitSkip%, Skip
}

; Parse splits
splitIndex := 1

splitFlags := []
splitFlags.Push(1)

splitDelays := []
splitDelays.Push(0)

IfExist, %AutosplitFolder%
  Loop %AutosplitFolder%\*.*
  {
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

SC029::
  Send {%AutosplitReset%}
return

Split:
  delay := splitDelays[splitIndex]
  Sleep, %delay%

  if (splitFlags[splitIndex] = 1) {
    Send {%LivesplitSplit%}
  }

  splitIndex := splitIndex + 1 
return

Reset:
  Send {%LivesplitReset%}
  splitIndex := 1
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
return

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

ReloadScript:
  SaveKeybinds()
  Reload
  Return

GuiClose:
  SaveKeybinds()
  ExitApp