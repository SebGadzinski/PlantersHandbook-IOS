# PlantersHandbook-IOS
Comp 4905 - Honours Project

Application for tree planters all around the world to help manage their earnings.

## Apple Store Link
Link: https://apps.apple.com/ca/app/planters-handbook/id1558354786

## Use Cases:

### Filling Digital Handbook "Work Day"
A user can add days to seasons which contain information on the blocks, sub-blocks, and caches the user has planted on. Once the user select a cache that the user is planting at, the user get a digital tally sheet for that cache to fill out tree types, and bag up inputs. Totals are auto calculated at the bottom of the screen for the user to know what amount they are at at all times.

![alt text][fillDay]

[fillDay]: https://github.com/SebGadzinski/PlantersHandbook-IOS/blob/main/Backend/planters-handbook/ReadMeGifs/final_handbook.gif
 
### GPS Tree Tracking
In Tally Sheet, a user can click the blue bar button at the top right of the navigation bar to see the "GPS Tree Tracking" view of that cache. Once they select "Start Planting" the app tracks their planting path and records there distance and time. If the user gives a "trees per plot" input, the user can see how many trees should be in the ground with the distance they travelled based off the trees per plot.

![alt text][treeTracking]

[treeTracking]: https://github.com/SebGadzinski/PlantersHandbook-IOS/blob/main/Backend/planters-handbook/ReadMeGifs/final_gps.gif
 
### Printing & Sharing
The reason why this application is so benificial towards tree planters is because users can completely get rid of the paper handbook and send a pdf copy of a tally sheet that contains ALL information that a normal tally sheet has + WAY MORE BENIFICIAL INFORMATION. A user can print the "Day" they worked on and share it with their foreman via bluetooth if they also contain a IOS device, or share it via any messenger.

![alt text][printAndShare]

[printAndShare]: https://github.com/SebGadzinski/PlantersHandbook-IOS/blob/main/Backend/planters-handbook/ReadMeGifs/final_print.gif

## Statistics
User can view statistics on there data.

Days

 - Average day & Best day
   
 - Line charts
       
   - Cash
       
   - Distance
       
   - Steps (Why I asked for step distance after login)
       
   - Time
       
   - Trees

Seasons
 
 - Average & Best season
    
 - Horizontal bar chart
 
   - Distance travelled
        
 - Pie charts
       
   - Cash vs Trees

 - Time spent planting

       
![alt text][stats]

[stats]: https://github.com/SebGadzinski/PlantersHandbook-IOS/blob/main/Backend/planters-handbook/ReadMeGifs/final_stats.gif

## Database
MongoDB Realm Offline First Database.

## API's
Google maps API

## CocoaPods
pod 'RealmSwift'

pod 'UnderLineTextField'

pod 'SwiftSpinner'

pod 'JDropDownAlert'

pod 'EmailValidator'

pod 'Navajo-Swift'

pod 'GoogleMaps'

pod 'GooglePlaces'

pod 'Charts'

pod 'M13Checkbox'

pod 'SwiftyGif'

## Architecture Pattern
Model View Controller.

## Storyboard-Navigation, Component, Complete UML, and Entity UML Diagrams
Storyboard-Navigation - Because this application is all programic does not using storyboard, I have this diagram displaying the what view controlleres lead to others. Instead of seuges from view controller to view controller there is just a main navigation controller with SplashViewController as its root controller and from there push's and pops of view controllers are taken place.

Link to diagrams: https://drive.google.com/file/d/1f_KAla1V4i5HOA7P_KZ4LDVyfmvk4shc/view?usp=sharing

## Improvements For Future
### Adding Foreman View
I would like to add a foreman view of this application where the planters foreman can add them to a season, and a foreman can put out days where planters can add there contribution to their day (what the planters day is currently). This would require for internet to be on the camp always when the planters come back. That is why i did not start with creation of the foreman view before planters because currently there is not a 100% chance a that the camp has internet connection. This can progress to a checkers, supervisors, millcheckers, and supervisor views.

### More Statistic Cards.
With feedback from reviews, I would like to see progression in the statistics aspect of the application. Also would like to create a CardViewController class that
can be used to abstract some of the code inside of StatisticsViewController.

## Running Project

### Prerequisite
Ensure CocoaPods is installed

https://cocoapods.org/

Install Xcode (Must have a mac or Virtual Machine)

### Generate pods required for the workspace

Ensure Folder location is : PlantersHandbook-IOS/PlantersHandbook

Open Terminal 

Type Command : pod install

### Run On Xcode

1. Open Xcode
2. Open folder dirProjectIn/PlantersHandbook-IOS/PlantersHandbook
3. PlantersHandbook.xcworkspace
4. Wait for Xcode to load
6. Select a simulator
7. Press run button on the top left
8. Wait for simulator to finish loading and build to finish
9. App should be running

## Personal Info
Creator: Sebastian Gadzinski

Supervisor: Olga Baysal

University: Carleton University
