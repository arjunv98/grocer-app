# ITP 342 FINAL PROJECT: ***GROCER***

## Overview
The purpose of Grocer is to help organize grocery lists for people who go to multiple grocery stores to shop. Users can add and check off ingredients in an overall grocery list, while also maintatining separate, more specific grocery lists for each of their favorite grocery stores.

## Requirements Met
### 3rd Party APIs
* Spoonacular API
   * Used to autocomplete ingredient search, as well as download images of ingredients
* Realm
   * Used for persistant storage and class management
   * Saves ingredients, stores, and grocery lists for each store in a Realm
   * **BUG**: as of iOS 13.3, realm fails to run on physical devices, so has not been tested on phone
### Apple Frameworks
* MapKit and Core Location
   * Used to determine user's current location
   * Used to search for food markets in local area
   * Displays map and annotates map with custom pins indicating store locations
* EventKit
   * Used to set a reminder to go grocery shopping
   * Automatically populates event and calls view controller to edit and create event
### Delegates
* CLLocationManagerDelagate
   * Used for methods involving the location manager and receiving current location
* UIAdaptivePresentationDelegate
   * Used to determine segue from presenting view controller
* UITableViewDelegate
   * Used to implement UITableView features in a UIViewController with embedded UITableView
* MKMapViewDelegate
   * Used to receive and implement map updates
### MVC
* Project follows Model-View-Controller format
* Project organized into separate groups for each
### Singleton
* Uses singleton object to manage API requests to Spoonacular API

## Current features:
### Ingredients
* Listed ingredients view
   * General ingredient checklist
   * Sortable by name and checked status
   * Pictures load asynchronously
* Add ingredients view
   * Fills in autocomplete search information from Spoonacular
   * Pictures load asynchronously
### Stores
* Store list view
   * Lists nearby grocery stores from map search
   * Sorted by distance from current location
   * Filterable by nearby stores or saved stores
* Store map view
   * Same data source as list view
   * Annotates map with nearby and saved stores
   * Items on map color-coded by save state
* Store detail view
   * Accessible from both map and list views
   * Lists store name, address, and distance
   * Displays specific grocery list for store
   * Can add calendar event to go grocery shopping
      * Calendar populates with store and grocery list information
* Store grocery list view
   * Used to edit specific store grocery list
   * Lists all ingredients added to general list (Listed ingredients view)
   * Check off ingredients to add to grocery list
