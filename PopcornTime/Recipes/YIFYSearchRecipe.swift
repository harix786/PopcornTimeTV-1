//
//  SearchRecipe.swift
//  PopcornTime
//
//  Created by Yogi Bear on 3/19/16.
//  Copyright © 2016 PopcornTime. All rights reserved.
//

import TVMLKitchen
import PopcornKit

class YIFYSearchRecipe: SearchRecipe {

    override init(type: PresentationType = .Search) {
        super.init(type: type)
    }

    override func filterSearchText(text: String, callback: (String -> Void)) {
        NetworkManager.sharedManager().fetchMovies(limit: 50, page: 1, quality: "720p", minimumRating: 0, queryTerm: text, genre: nil, sortBy: "download_count", orderBy: "desc") { movies, error in
            if let movies = movies {
                let mapped: [String] = movies.map { movie in
                    return movie.lockUp
                }

                if let file = NSBundle.mainBundle().URLForResource("SearchRecipe", withExtension: "xml") {
                    do {
                        var xml = try String(contentsOfURL: file)

                        xml = xml.stringByReplacingOccurrencesOfString("{{TITLE}}", withString: "Found \(movies.count) \(movies.count == 1 ? "movie" : "movies") for \"\(text.cleaned)\"")
                        xml = xml.stringByReplacingOccurrencesOfString("{{RESULTS}}", withString: mapped.joinWithSeparator("\n"))

                        callback(xml)
                    } catch {
                        print("Could not open Catalog template")
                    }
                }
            }
        }

    }

}

class EZTVSearchRecipe: SearchRecipe {

    var recipe: String? {
        if let file = NSBundle.mainBundle().URLForResource("SearchRecipe", withExtension: "xml") {
            do {
                return try String(contentsOfURL: file)
            } catch {
                print("Could not open Catalog template")
            }
        }
        return nil
    }

    override init(type: PresentationType = .Search) {
        super.init(type: type)
    }

    override func filterSearchText(text: String, callback: (String -> Void)) {
        let manager = NetworkManager.sharedManager()
        manager.fetchShowPageNumbers { pageNumbers, error in
            if let pageNumbers = pageNumbers {
                manager.fetchShows(pageNumbers, searchTerm: text, genre: nil, sort: "trending") { shows, error in
                    if let shows = shows {
                        let mapped: [String] = shows.map { show in
                            return show.lockUp
                        }
                        if let recipe = self.recipe {
                            var xml = recipe
                            xml = xml.stringByReplacingOccurrencesOfString("{{TITLE}}", withString: "Found \(shows.count) \(shows.count == 1 ? "show" : "shows") for \"\(text.cleaned)\"")
                            xml = xml.stringByReplacingOccurrencesOfString("{{RESULTS}}", withString: mapped.joinWithSeparator("\n"))
                            callback(xml)
                        }
                    }
                }
            }
        }
    }
}
