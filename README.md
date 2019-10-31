# TSplitter v0.1.0
A tool that adds some features to https://github.com/Toufool/Auto-Split used in conjuction with https://github.com/LiveSplit
You need AutoHotkey to use this program (Download from https://www.autohotkey.com/)


## Features
### Fake split
You can setup splits in AutoSplit that are not part of your LiveSplit splits.
This is particulary useful to have splits during **specific** fullscreen fadeouts by having a "fake" split right before the desired fadeout.

To convert a split into a fake split you just need to add the word "fake" to the split image used by AutoSplit.

### Delayed split
You can setup a time delay for the split to go from AutoSplit to LiveSplit.
This allows to setup an image in AutoSplit and have the split occur later in LiveSplit.
This is useful when its not possible to have a good image for the precise moment where the split is desired.

To have a delayed split you just need to add "delayXXXX"  to the split image name used by AutoSplit; where XXXX is the amount of milliseconds the split should be delayed.

## Usage
Simply open **TSplitter.ahk** to run the program.

You need to fill the keybinds used by both AutoSplit and LiveSplit. As well as setting the path to the folder containing the images used by AutoSplit.
Not that every time you change something you need to save for the changes to take effect. You can do so by using the **File > Save** menu, or by pressing **Ctrl + S**.

The main difference when using this tool is that **your AutoSplit and LiveSplit keybinds should be different**.
When doing runs, **you should only use your AutoSplit keybinds**. The program will automatically forward them to LiveSplit when applicable.

## Examples
In the Examples folder you can see two set of examples of split images configured for AutoSplit and also using the features of TSplitter.

## Known Issues
- Launch AutoSplit and LiveSplit before running the program
- Having the same keybinds in AutoSplit and LiveSplit might cause issues. This program expects the keybinds to be different (which conflicts with the "normal" usage of AutoSplit)
- For issues configuring images for AutoSplit please refer to https://github.com/Toufool/Auto-Split
