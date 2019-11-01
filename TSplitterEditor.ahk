#SingleInstance force

Version := "0.2.1"
SetFormat, float, 0.0

; Split window variables
SplitImagePicture :=
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
Gui, 1:Add, Button, w100 gEditSplit, Edit
Gui, 1:Add, Button, w100 gDuplicateSplit, Duplicate
Gui, 1:Add, Button, w100 gRemoveSplit, Remove
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
      asd := components.MaxIndex()


      splitName = split%i%
      if (components.MaxIndex() > 1) {
        splitName := components[2]
      }

      probability := 90
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

          if (probability > 100) {
            probability := 100
          }
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
      
      finalProbability = _(0.90)
      if (probabillty != "0") {
        if (probability = 100) {
          finalProbability = _(1)
        } else {
          finalProbability = _(0.%probabillty%)
        }
      }

      finalPauseTime = _[0]
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

DuplicateSplit:
  SelectedSplitIndex := LV_GetNext()
  if (SelectedSplitIndex > 0) {
    CloneSplit(SelectedSplitIndex)
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

CloneSplit(index)
{
  order := LV_GetCount() + 1
  LV_GetText(name, index, 2)
  name = %name% Copy

  LV_GetText(probability, index, 3)
  LV_GetText(pauseTime, index, 4)
  LV_GetText(delay, index, 5)
  LV_GetText(masked, index, 6)
  LV_GetText(fake, index, 7)
  LV_GetText(imagePath, index, 8)

  LV_Add(, order, name, probability, pauseTime, delay, masked, fake, imagePath)
}

Swap(index1, index2)
{
  LV_GetText(order1, index1, 1)
  LV_GetText(name1, index1, 2)
  LV_GetText(probability1, index1, 3)
  LV_GetText(pauseTime1, index1, 4)
  LV_GetText(delay1, index1, 5)
  LV_GetText(masked1, index1, 6)
  LV_GetText(fake1, index1, 7)
  LV_GetText(imagePath1, index1, 8)

  LV_GetText(order2, index2, 1)
  LV_GetText(name2, index2, 2)
  LV_GetText(probability2, index2, 3)
  LV_GetText(pauseTime2, index2, 4)
  LV_GetText(delay2, index2, 5)
  LV_GetText(masked2, index2, 6)
  LV_GetText(fake2, index2, 7)
  LV_GetText(imagePath2, index2, 8)

  LV_Modify(index1, , order1, name2, probability2, pauseTime2, delay2, masked2, fake2, imagePath2)
  LV_Modify(index2, , order2, name1, probability1, pauseTime1, delay1, masked1, fake1, imagePath1)
}

ShowSplitWindow()
{
  Gui, 2:Destroy
  Gui, 1:Default

  order := 
  imagePath := 
  name := 
  probabillty := "90"
  pauseTime := "0"
  delay := "0"
  masked := false
  fake := false

  rowCount := LV_GetCount()

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
  Gui, 2:New, +Owner +Resize, %title%

  if (imagePath) {
    Gui, 2:Add, Picture, x50 y10 w300 h-1 vSplitImagePicture, %imagePath%
  }
  Gui, 2:Add, Text, x10 y+20, Image path:
  Gui, 2:Add, Edit, x80 y+-25 w277 h40 vSplitImagePathTextfield, %imagePath%
  Gui, 2:Add, Button, x+-1 y+-41 w30 h42 gSelectImage, ...

  Gui, 2:Add, Text, x10 y+10, Split name:
  Gui, 2:Add, Edit, x80 y+-14 w305 vSplitNameTextfield, %name%

  Gui, 2:Add, Text, x10 y+20, Probability:
  Gui, 2:Add, Edit, x70 y+-15 w50 vSplitProbabilityTextfield Limit3 Number, %probabillty%
  Gui, 2:Add, UpDown, 0x80 Range1-100, %probabillty%

  Gui, 2:Add, Text, x140 y+-19, Pause time:
  Gui, 2:Add, Edit, x205 y+-15 w60 vSplitPauseTimeTextfield Limit4 Number, %pauseTime%
  Gui, 2:Add, UpDown, 0x80 Range0-9999, %pauseTime%

  Gui, 2:Add, Text, x285 y+-19, Delay:
  Gui, 2:Add, Edit, x325 y+-15 w60 vSplitDelayTextfield Limit5 Number, %delay%
  Gui, 2:Add, UpDown, 0x80 Range0-99999, %delay%

  Gui, 2:Add, CheckBox, x100 y+20 vSplitMaskedCheck Checked%masked%, Masked image
  Gui, 2:Add, CheckBox, x220 y+-12 vSplitFakeCheck Checked%fake%, Fake split
  
  Gui, 2:Add, Button, x100 y+30 w200 h30 gSaveEditedSplit, Save

  if (SelectedSplitIndex > 1)
  {
    Gui, 2:Add, Button, x10 y+-30 w30 h30 gEditPreviousSplit, <
  }

  if (SelectedSplitIndex > 0 and SelectedSplitIndex < rowCount)
  {
    Gui, 2:Add, Button, x355 y+-30 w30 h30 gEditNextSplit, >
  }

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
  GuiControl, , SplitImagePicture, %imagePath%
Return

EditPreviousSplit:
  SaveSplit()
  SelectedSplitIndex := SelectedSplitIndex - 1
  ShowSplitWindow()
Return

EditNextSplit:
  SaveSplit()
  SelectedSplitIndex := SelectedSplitIndex + 1
  ShowSplitWindow()
Return

SaveEditedSplit:
  SaveSplit()
Return

SaveSplit()
{
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
}

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