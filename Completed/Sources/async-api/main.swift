import Foundation

enum LocationError: Error {
	case unknown
}

func getWeatherReadings(for location: String) async throws -> [Double] {
	switch location {
	case "London":
		return (1...100).map { _ in Double.random(in: 6...26) }
	case "Rome":
		return (1...100).map { _ in Double.random(in: 10...32) }
	case "San Francisco":
		return (1...100).map { _ in Double.random(in: 12...20) }
	default:
		throw LocationError.unknown
	}
}

func fibonacci(of number: Int) -> Int {
	var first = 0
	var second = 1

	for _ in 0..<number {
		let previous = first
		first = second
		second = previous + first
	}

	return first
}

struct DoubleGenerator: AsyncSequence {
	typealias Element = Int

	struct AsyncIterator: AsyncIteratorProtocol {
		var current = 1

		mutating func next() async -> Int? {
			defer { current &*= 2 }
			await Task.sleep(500000000)
			if current < 0 {
				return nil
			} else {
				return current
			}
		}
	}

	func makeAsyncIterator() -> AsyncIterator {
		AsyncIterator()
	}
}
func printMessage() async throws {
	let doubles = DoubleGenerator()
	for await value in doubles {
		print(value)
	}
	let match = await doubles.contains(16777216)
	print(match)
}


@main
struct AsyncApp {
    
    static func main() async {
		do {
			try await printMessage()
		} catch {
			print("Caught an error: \(error.localizedDescription)")
		}
//        await fetchIPGeoCountryAPIs()
//        await fetchRevengeOfTheSithCharactersAPI()
    }
    
    static func fetchIPGeoCountryAPIs() async {
        do {
            // Get Current IP Address
            let ipifyResponse: IpifyResponse = try await fetchAPI(url: IpifyResponse.url)
            print("Resp: \(ipifyResponse)")
            
            // Get Geolocation data using the IP Address
            let freeGeoIpResponse: FreeGeoIPResponse = try await fetchAPI(url: FreeGeoIPResponse.url(ipAddress: ipifyResponse.ip))
            print("Resp: \(freeGeoIpResponse)")
            
            // Get Country Detail using the geolocation data country code
            let restCountriesResponse: RestCountriesResponse = try await fetchAPI(url: RestCountriesResponse.url(countryCode:  freeGeoIpResponse.countryCode))
            print("Resp: \(restCountriesResponse)")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    static func fetchRevengeOfTheSithCharactersAPI() async {
        do {
            // Fetch revenge of the sith movie data containing array of characters ulrs
            let revengeOfSith: SWAPIResponse<Film> = try await fetchAPI(url: Film.url(id: "6"))
            print("Resp: \(revengeOfSith.response)")
            
            // Get first 3 characters and fetch them using TaskGroup in parallel
            let urlsToFetch = Array(revengeOfSith.response.characterURLs.prefix(upTo: 3))
            let revengeOfSithCharacters: [SWAPIResponse<People>] = try await fetchAPIGroup(urls: urlsToFetch)
            print("Resp: \(revengeOfSithCharacters)")
        } catch {
            print(error.localizedDescription)
        }
    }
}
