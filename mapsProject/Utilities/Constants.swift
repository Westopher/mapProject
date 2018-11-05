//
//  Constants.swift
//  mapsProject
//
//  Created by West Kraemer on 11/5/18.
//  Copyright © 2018 West Kraemer. All rights reserved.
//

import Foundation

//https://www.flickr.com/services/apps/create/noncommercial/?
let apiKey = "cc48b67dd9785676eb78f63870f4a025"

func flickrUrl(forApiKey key: String, withAnnotation annotation: DroppablePin, andNumberOfPhotos number: Int) -> String {
    let url = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.longitude)&radius=1&radius_units=mi&per_page=\(number)&format=json&nojsoncallback=1"
    print(url)
    return url
}

//
