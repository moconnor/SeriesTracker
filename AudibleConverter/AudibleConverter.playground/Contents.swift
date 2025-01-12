import Cocoa


func indexOfDictionary(withKey key: String, matchingValue value: Any, in array: [[String: Any]]) -> Int? {
    return array.firstIndex { dictionary in
        dictionary[key] as? AnyHashable == value as? AnyHashable
    }
}

var greeting = "Hello, let's convert some JSON"


let fileName = "LibationLibrary2025-01-07.json"
let downloadPath = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Desktop")
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
var authorCount = 0
var seriesSet: Set<String> = []
var seriesDictionaryArray: [[String: Any]] = []
var authorsUUIDDictionary: [String:String] = [:]
let variousAuthorDictionary = ["name": "Various", "id": UUID().uuidString]

for dictionary in dictionaryArray {
    
    var authorsName = "Unknown"
    var authorUUIDString = ""
    if let _ = dictionary["AuthorNames"] as? String {
        authorsName = dictionary["AuthorNames"] as! String
    }
    
    if authorsUUIDDictionary[authorsName] == nil {
        authorsUUIDDictionary[authorsName] = UUID().uuidString
        authorCount += 1
    }
    authorUUIDString = authorsUUIDDictionary[authorsName]!
    
    
    let authorDictionary = ["name": authorsName, "id": authorUUIDString]
    
    var seriesOrder = 0
    let seriesOrderString = dictionary["SeriesOrder"] as! String//   "SeriesOrder": "6 : Laundry Files",
    if seriesOrderString != "" {
        if seriesOrderString.contains(" : ") {
            let seriesOrderArray = seriesOrderString.split(separator: " : ")
            seriesOrder = Int(seriesOrderArray[0]) ?? 0
        }
    }
    
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
    
    if let seriesNameString = dictionary["SeriesNames"] as? String {//}, seriesName != "" {
//        print("\(count) - Series: \(seriesName) - Title: \(dictionary["Title"] as! String)")
        var seriesName = seriesNameString
        var seriesStatus: String = "Undetermined"
        var seriesAuthorDictionary = authorDictionary
        if seriesNameString == "" {
            seriesName = "Individual Books - 894847592"
            seriesStatus = "Not a series"
            seriesAuthorDictionary = variousAuthorDictionary
        } else {
            seriesName = seriesNameString
        }
        if seriesSet.contains(seriesName) == false {
            
            var seriesDictionary = ["name": seriesName,
                                    "id": UUID().uuidString,
                                    "status":seriesStatus,
                                    "author": seriesAuthorDictionary,
                                    ] as [String : Any]

            seriesDictionary["books"] = [bookDictionary]
            seriesCount += 1
            seriesSet.insert(seriesName)
            seriesDictionaryArray.append(seriesDictionary)
        } else {
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

print("Author Count: \(authorCount)")

for authorKey in authorsUUIDDictionary.keys {
    if let authorUUID = authorsUUIDDictionary[authorKey] {
        print("\(authorKey): (\(authorUUID))")
    } else {
        print("\(authorKey): Missing UUID?!?")
    }
}

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
