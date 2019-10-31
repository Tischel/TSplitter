#SingleInstance force

Version := "0.2.0"
SetFormat, float, 0.0

; Split window variables
SplitImagePathTextfield :=
SplitNameTextfield :=
SplitProbabilityTextfield :=
SplitPauseTimeTextfield :=
SplitDelayTextfield :=
SplitMaskedCheck :=
SplitFakeCheck :=
Global SelectedSplitIndex := -1

; Main window
Gui, 1:New, -Resize, TSplitter Editor v%Version%
Gui, 1:Add, Button, w100 gAddSplit, Add split
Gui, 1:Add, Button, w100 gEditSplit, Edit selected
Gui, 1:Add, Button, w100 gRemoveSplit, Remove selected
Gui, 1:Add, Button, w100 gMoveUpSplit, Move up
Gui, 1:Add, Button, w100 gMoveDownSplit, Move down
Gui, 1:Add, ListView, x117 y7 r0 h400 w730 gSplitsListView -LV0x10 -Multi +ReadOnly +NoSort, #|Name|Probability|Pause time|Delay|Masked|Fake|Image

Menu, FileMenu, Add, &New`tCtrl+N, NewSplits
Menu, FileMenu, Add, &Open`tCtrl+O, OpenSplits
Menu, FileMenu, Add, &Save as...`tCtrl+S, SaveSplits
Menu, HelpMenu, Add, &About`tCtrl+A, ShowAbout
Menu, MyMenuBar, Add, &File, :FileMenu
Menu, MyMenuBar, Add, &Help, :HelpMenu
Gui, 1:Menu, MyMenuBar

Gui, 1:Show

LV_ModifyCol(1, 30)
LV_ModifyCol(2, 120)
LV_ModifyCol(3, 80)
LV_ModifyCol(4, 80)
LV_ModifyCol(5, 80)
LV_ModifyCol(6, 80)
LV_ModifyCol(7, 80)
LV_ModifyCol(8, 500)

Return

SplitsListView:
  if (A_GuiEvent = "DoubleClick")
  {
    SelectedSplitIndex := LV_GetNext()
    if (SelectedSplitIndex > 0) {
      ShowSplitWindow()
    }
  }
Return

NewSplits:
  MsgBox, 0x2131, New splits, All changes will be lost, continue anyway?
  IfMsgBox Ok
    ClearSplits()
Return

OpenSplits:
  rowCount := LV_GetCount()

  if (rowCount > 0) 
  {
    MsgBox, 0x2131, Open splits, All changes will be lost, continue anyway?
    IfMsgBox, Ok
      OpenSplits()
  }
  else
  {
    OpenSplits()
  }
Return

OpenSplits()
{
  FileSelectFolder, splitsFolder, , 0, Select split images folder

  IfExist, %splitsFolder%
  {
    splitFileNames := []

    Loop %splitsFolder%\*.*
    {
      IfInString, A_LoopFileName, .png 
      {
        splitFileNames.Push(A_LoopFileName)
      }
    }

    if (splitFileNames.MaxIndex() = 0) {
      MsgBox, 0x10, Error, No PNG images found in that folder!
      Return
    }

    ClearSplits()

    for i, splitFileName in splitFileNames
    {
      cleanFileName := StrReplace(splitFileName, ".png", "")
      components := StrSplit(cleanFileName, "_")

      splitName := split%i%
      if (components.MaxIndex() > 1) {
        splitName := components[2]
      }

      probabilty := 90
      pauseTime := 0
      delay := 0
      masked := "No"
      fake := "No"

      for j, component in components
      {
        ; probability
        IfInString, component, (
        {
          str := StrReplace(component, "(", "")
          str := StrReplace(str, ")", "")
          probability := str * 100.0
        }

        ; pause time
        IfInString, component, [
        {
          str := StrReplace(component, "[", "")
          str := StrReplace(str, "]", "")
          pauseTime := str
        }

        RegExMatch(splitFileName, "O)(.*)(_delay)(?<delay>\d+)", Match)
        if (Match["delay"]) {
          delay := Match["delay"]
        }

        IfInString, splitFileName, {m}
          masked := "Yes"

        IfInString, splitFileName, fake
          fake := "Yes"
      }

      path = %splitsFolder%\%splitFileName%
      LV_Add(, i, splitName, probability, pauseTime, delay, masked, fake, path)
    }
  }
}
Return

SaveSplits:
  rowCount := LV_GetCount()
  if (rowCount = 0)
  {
    Return
  }

  FileSelectFolder, splitsFolder, , 1, Select empty folder to save splits
  
  IfExist, %splitsFolder%
  {
    if (!IsDirectoryEmpty(splitsFolder)) 
    {
      MsgBox, 0x10, Error, Please select an empty folder!
      Return
    }

    Loop % LV_GetCount()
    {
      LV_GetText(name, A_index, 2)
      LV_GetText(probabillty, A_index, 3)
      LV_GetText(pauseTime, A_index, 4)
      LV_GetText(delay, A_index, 5)
      LV_GetText(masked, A_index, 6)
      LV_GetText(fake, A_index, 7)
      LV_GetText(imagePath, A_index, 8)

      finalName = %name%
      if (fake = "Yes") {
        finalName = %name%_fake
      }
      
      finalProbability = 
      if (probabillty != "0") {
        finalProbability = _(%probabillty%)
      }

      finalPauseTime = 
      if (pauseTime != "0") {
        finalPauseTime = _[%pauseTime%]
      }

      finalDelay = 
      if (delay != "0") {
        finalDelay = _delay%delay%
      }

      finalMasked =
      if (masked = "Yes") {
        finalMasked = _{m}
      }

      index = 000%A_index%
      if (A_index > 999) {
        index = %A_index%
      } else if (A_Index > 99) {
        index = 0%A_index%
      } else if (A_Index > 9) {
        index = 00%A_index%
      }

      fileName = %index%_%finalName%%finalProbability%%finalPauseTime%%finalDelay%%finalMasked%.png
      path = %splitsFolder%\%fileName%

      DllCall("CopyFile", "Str", imagePath, "Str", path, Int, 0)
    }
  }
Return

IsDirectoryEmpty(Dir)
{
   Loop %Dir%\*.*, 0, 1
      return 0
   return 1
}

AddSplit:
  SelectedSplitIndex := -1
  ShowSplitWindow()
Return

EditSplit:
  SelectedSplitIndex := LV_GetNext()
  if (SelectedSplitIndex > 0) {
    ShowSplitWindow()
  }
Return

RemoveSplit:
  SelectedSplitIndex := LV_GetNext()
  if (SelectedSplitIndex > 0) {
    LV_Delete(SelectedSplitIndex)
  }
Return

MoveUpSplit:
  SelectedSplitIndex := LV_GetNext()
  if (SelectedSplitIndex <= 1) {
    Return
  }

  Swap(SelectedSplitIndex, SelectedSplitIndex - 1)

  LV_Modify(SelectedSplitIndex - 1, "Select")
Return

MoveDownSplit:
  rowCount := LV_GetCount()
  SelectedSplitIndex := LV_GetNext()
  if (SelectedSplitIndex >= rowCount) {
    Return
  }

  Swap(SelectedSplitIndex, SelectedSplitIndex + 1)

  LV_Modify(SelectedSplitIndex + 1, "Select")
Return

Swap(index1, index2)
{
  LV_GetText(order1, index1, 1)
  LV_GetText(name1, index1, 2)
  LV_GetText(probabillty1, index1, 3)
  LV_GetText(pauseTime1, index1, 4)
  LV_GetText(delay1, index1, 5)
  LV_GetText(masked1, index1, 6)
  LV_GetText(fake1, index1, 7)
  LV_GetText(imagePath1, index1, 8)

  LV_GetText(order2, index2, 1)
  LV_GetText(name2, index2, 2)
  LV_GetText(probabillty2, index2, 3)
  LV_GetText(pauseTime2, index2, 4)
  LV_GetText(delay2, index2, 5)
  LV_GetText(masked2, index2, 6)
  LV_GetText(fake2, index2, 7)
  LV_GetText(imagePath2, index2, 8)

  LV_Modify(index1, , order1, name2, probabillty2, pauseTime2, delay2, masked2, fake2, imagePath2)
  LV_Modify(index2, , order2, name1, probabillty1, pauseTime1, delay1, masked1, fake1, imagePath1)
}

ShowSplitWindow()
{
  order := 
  imagePath := 
  name := 
  probabillty := "90"
  pauseTime := "0"
  delay := "0"
  masked := false
  fake := false

  if (SelectedSplitIndex > 0) 
  {
    LV_GetText(order, SelectedSplitIndex, 1)
    LV_GetText(name, SelectedSplitIndex, 2)
    LV_GetText(probabillty, SelectedSplitIndex, 3)
    LV_GetText(pauseTime, SelectedSplitIndex, 4)
    LV_GetText(delay, SelectedSplitIndex, 5)

    LV_GetText(maskedText, SelectedSplitIndex, 6)
    masked := (maskedText = "Yes" ? true : false)

    LV_GetText(fakeText, SelectedSplitIndex, 7)
    fake := (fakeText = "Yes" ? true : false)

    LV_GetText(imagePath, SelectedSplitIndex, 8)
  }

  title := (SelectedSplitIndex > 0 ? "Edit split #"order : "New Split")
  Gui, 2:New, +Owner -Resize, %title%
  Gui, 2:Add, Text, y20, Image path:
  Gui, 2:Add, Edit, x80 y5 w277 h40 vSplitImagePathTextfield, %imagePath%
  Gui, 2:Add, Button, x+-1 y4 w30 h42 gSelectImage, ...

  Gui, 2:Add, Text, x10 y54, Split name:
  Gui, 2:Add, Edit, x80 y50 w305 vSplitNameTextfield, %name%

  Gui, 2:Add, Text, x10 y85, Probability:
  Gui, 2:Add, Edit, x70 y81 w50 vSplitProbabilityTextfield Limit3 Number, %probabillty%
  Gui, 2:Add, UpDown, 0x80 Range1-100, %probabillty%

  Gui, 2:Add, Text, x140 y85, Pause time:
  Gui, 2:Add, Edit, x205 y81 w60 vSplitPauseTimeTextfield Limit4 Number, %pauseTime%
  Gui, 2:Add, UpDown, 0x80 Range0-9999, %pauseTime%

  Gui, 2:Add, Text, x285 y85, Delay:
  Gui, 2:Add, Edit, x325 y81 w60 vSplitDelayTextfield Limit5 Number, %delay%
  Gui, 2:Add, UpDown, 0x80 Range0-99999, %delay%

  Gui, 2:Add, CheckBox, x100 y115 vSplitMaskedCheck Checked%masked%, Masked image
  Gui, 2:Add, CheckBox, x220 y115 vSplitFakeCheck Checked%fake%, Fake split
  
  Gui, 2:Add, Button, x10 y150 w377 h30 gSaveEditedSplit, Save

  Gui, 2:Show
}

ClearSplits()
{
  Loop % LV_GetCount()
  {
    LV_Delete(1)
  }
}

SelectImage:
  GuiControlGet, imagePath, , SplitImagePathTextfield
  FileSelectFile, imagePath, ,%imagePath%, Select splt image, PNG Images (*.png)
  GuiControl, , SplitImagePathTextfield, %imagePath%
Return

SaveEditedSplit:
; validate name
GuiControlGet, name, , SplitNameTextfield
if (!name or name = "") {
  MsgBox, Invalid split name!
  Return
}

; validate path
GuiControlGet, imagePath, , SplitImagePathTextfield
IfNotExist, %imagePath%
{
  MsgBox, Couldn't find an image at "%imagePath%"!
  Return
}

IfNotInString, imagePath, .png
{
  MsgBox, Only PNG images accepted!
  Return
}

; get values
GuiControlGet, probabillty, , SplitProbabilityTextfield
GuiControlGet, pauseTime, , SplitPauseTimeTextfield
GuiControlGet, delay, , SplitDelayTextfield
GuiControlGet, masked, , SplitMaskedCheck
maskedText := (masked = 1 ? "Yes" : "No")
GuiControlGet, fake, , SplitFakeCheck
fakeText := (fake = 1 ? "Yes" : "No")

Gui, 2:Destroy
Gui, 1:Default

; save
if (SelectedSplitIndex = -1)
{
  rowCount := LV_GetCount() + 1
  LV_Add(, rowCount, name, probabillty, pauseTime, delay, maskedText, fakeText, imagePath)
}
else
{
  LV_Modify(SelectedSplitIndex, , SelectedSplitIndex, name, probabillty, pauseTime, delay, maskedText, fakeText, imagePath)
}

Return

ShowAbout:
  Gui, About:New, +Owner -Resize, About
  Gui, About:Font, bold
  Gui, About:Add, Text,, TSplitter Editor v%Version%
  Gui, About:Font, norm
  Gui, About:Add, Link,, Check latest releases and documentation at`n<a href="https://github.com/Tischel/TSplitter">https://github.com/Tischel/TSplitter</a>
  Gui, About:Show
Return

GuiClose:
ExitApp