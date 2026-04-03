import Foundation

// Loads the albums from the Albums.json file.
func loadAlbums() -> [Album] {
    guard let url = Bundle.main.url(forResource: "Albums", withExtension: "json") else {
        print("File not found in bundle")
        return []
    }

    do {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let albums = try decoder.decode([Album].self, from: data)
        return albums
    } catch {
        print("Failed to decode JSON: \(error)")
        return []
    }
}