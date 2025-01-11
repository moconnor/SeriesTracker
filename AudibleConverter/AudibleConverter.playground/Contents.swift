import Cocoa


func indexOfDictionary(withKey key: String, matchingValue value: Any, in array: [[String: Any]]) -> Int? {
    return array.firstIndex { dictionary in
        dictionary[key] as? AnyHashable == value as? AnyHashable
    }
}

var greeting = "Hello, let's convert some JSON"


let fileName = "LibationLibrary2025-01-07.json"
let downloadPath = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Development/AudibleConverter")
let filePath = downloadPath.appendingPathComponent(fileName)


var jsonString = ""
do {
    // Read the content of the file
    jsonString = try String(contentsOf: filePath, encoding: .utf8)
    print("File Contents READ!")
} catch {
    print("Failed to read file: \(error.localizedDescription)")
}

var dictionaryArray: [[String: Any]] = []
do {
    dictionaryArray = try JSONSerialization.jsonObject(with: jsonString.data(using: .utf8)!) as! [[String: Any]]
    print("JSON converted to dictionary!:\n\(dictionaryArray.count)")
} catch {
    print("Failed to convert JSON: \(error.localizedDescription)")
}

var count = 1
var seriesCount = 0
var seriesSet: Set<String> = []
var seriesDictionaryArray: [[String: Any]] = []
for dictionary in dictionaryArray {
    
    if let seriesName = dictionary["SeriesNames"] as? String, seriesName != "" {
//        print("\(count) - Series: \(seriesName) - Title: \(dictionary["Title"] as! String)")
        if seriesSet.contains(seriesName) == false {
            
            let authorDictionary = ["name": dictionary["AuthorNames"] as! String, "id": UUID().uuidString]

            var seriesDictionary = ["name": seriesName,
                                    "id": UUID().uuidString,
                                    "status":"In Progress",
                                    ] as [String : Any]
            
            
            let seriesOrderString = dictionary["SeriesOrder"] as! String//   "SeriesOrder": "6 : Laundry Files",
            let seriesOrderArray = seriesOrderString.split(separator: " : ")
            let seriesOrder = Int(seriesOrderArray[0])
            
            var bookDateString = dictionary["DateAdded"] as! String
            if bookDateString.contains(".") {
                let bookDateArray = bookDateString.split(separator: ".")
                bookDateString = "\(bookDateArray[0])"
            }
            
            let bookDate = "\(bookDateString)Z"
            let bookDictionary = ["title": dictionary["Title"] as! String,
                                  "author": authorDictionary,
                                  "seriesOrder": seriesOrder as Any,
                                  "readStatus":"Completed",
                                  "id": UUID().uuidString,
                                  "startDate": bookDate,
                                  "endDate": bookDate,
                                ] as [String : Any]

            seriesDictionary["books"] = [bookDictionary]
            seriesCount += 1
            seriesSet.insert(seriesName)
            seriesDictionaryArray.append(seriesDictionary)
        } else {
            let authorDictionary = ["name": dictionary["AuthorNames"] as! String, "id": UUID().uuidString]
            
            let seriesOrderString = dictionary["SeriesOrder"] as! String//   "SeriesOrder": "6 : Laundry Files",
            let seriesOrderArray = seriesOrderString.split(separator: " : ")
            let seriesOrder = Int(seriesOrderArray[0])
            
            var bookDateString = dictionary["DateAdded"] as! String
            if bookDateString.contains(".") {
                let bookDateArray = bookDateString.split(separator: ".")
                bookDateString = "\(bookDateArray[0])"
            }
            
            let bookDate = "\(bookDateString)Z"
            let bookDictionary = ["title": dictionary["Title"] as! String,
                                  "author": authorDictionary,
                                  "seriesOrder": seriesOrder as Any,
                                  "readStatus":"Completed",
                                  "id": UUID().uuidString,
                                  "startDate": bookDate,
                                  "endDate": bookDate,
            ] as [String : Any]
                
            if let parentIndex = seriesDictionaryArray.firstIndex(where: { $0["name"] as? String == seriesName }) {
                // Extract the embedded array of dictionaries as mutable
                var books = seriesDictionaryArray[parentIndex]["books"] as? [[String: Any]] ?? []
                books.append(bookDictionary)
                // Reassign the modified array back to the parent dictionary
                seriesDictionaryArray[parentIndex]["books"] = books
                print("Series '\(seriesName)' contains (\(books.count) books")
            }
        }
    }
    count += 1
}



print("Series Count: \(seriesCount)")

do {
    let seriesJSONData = try JSONSerialization.data(withJSONObject: seriesDictionaryArray, options: [.prettyPrinted])
    if let jsonString = String(data: seriesJSONData, encoding: .utf8) {
        print("Series JSON String:\n\(jsonString)")
    } else {
        print("Series serialization failed")
    }
} catch {
    print("Failed to convert JSON: \(error.localizedDescription)")
}
