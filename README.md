# MEng-BusyBuddy
### UCL MEng Computer Science Final Year Project

Pre-requisites: macOS 11.2 or later, Xcode 12.4 or later.

#### Directory Tree
```
+-- BusyBuddy/                                # contains all source code for main application
|    +-- Assets.xcassets/                     # colours, icons
|    |   +-- ...
|    +-- Base.lproj/  
|    +-- Core ML/                             # all Core ML models, BusyModel protocol, and BusyModel conformant classes
|    |   +-- ...
|    +-- Network/ 
|    |   +-- NetworkClient.swift
|    |   +-- TfLUnifiedAPIClient.swift
|    +-- Preview Content/
|    |   +-- ...
|    +-- Resources/
|    |   +-- ExampleJamCams.swift             # for testing
|    +-- Views/                               # all SwiftUI views and components
|    |   +-- ...
|    +-- ...
|    +-- BusyScore.swift
|    +-- ...
|    +-- JamCam.swift
|    +-- JamCamsCache.swift
|    +-- JamCamsManager.swift                 # responsible for maintaining JamCam and Bookmarks data structures, updating BusyScores
|    +-- ...
+-- BusyBuddyTests/                           # contains all code for unit tests
|    +-- ...
|    +-- MockObjects.swift                    # defines mock objects used during unit testing
|    +-- ...
+-- BusyWidgets/                              # contains Swift logic and SwiftUI code for the WidgetKit extension
|    +-- ...
+-- JamCamIntent/                             # for WidgetKit parameter definition
|    +-- ...
|
```
