# grocer-app

## Overview
The purpose of Grocer is to help organize grocery lists for people who go to multiple grocery stores to shop. Users can add and check off ingredients in an overall grocery list, while also maintatining separate, more specific grocery lists for each of their favorite grocery stores.

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
   
## Work in progress features
* Recipes
   * Use recipes endpoint from Spoonacular API to find good recipes using current ingredients
   * Display recommended recipes in table view
   * Add save feature to save favorite recipes
   * Recipe detail page describing which ingredients are on the user's grocery list and which ingredients are missing
