//
//  SpoonacularAPIModel.swift
//  Grocer
//
//  Created by Arjun Viswanathan on 5/5/20.
//  Copyright © 2020 Arjun Viswanathan. All rights reserved.
//

import Foundation

class SpoonacularAPIModel {
    let API_KEY = "5c3418351b4a4d90b913b7a17a39abe5"
    let BASE_URL = "https://api.spoonacular.com"
    var ingredients = [IngredientCodable]()
    
    static let shared = SpoonacularAPIModel()
    
    func getAutocompleteIngredients(query: String, onSuccess: @escaping ([IngredientCodable]) -> Void) {
        let numberOfResults = 5
        if let url = URL(string: "\(BASE_URL)/food/ingredients/autocomplete?apiKey=\(API_KEY)&query=\(query)&number=\(numberOfResults)") {
            let urlRequest = URLRequest(url: url)
            URLSession.shared.dataTask(with: urlRequest, completionHandler: {(data, response, error) in
                if let data = data {
                    do {
                        self.ingredients = try JSONDecoder().decode([IngredientCodable].self, from: data)
                        onSuccess(self.ingredients)
                    } catch {
                        print(error)
                        exit(1)
                    }
                }
            }).resume()
        }
    }
}
