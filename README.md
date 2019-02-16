# Mememory: GIPHY Memory Game
Uses the GIPHY API 

## Getting Started
### Prerequisites
- Xcode 10.1
- iOS 12
- Swift 4.2

### Installing
The project uses Carthage for dependency management. To install Carthage:

```
$ brew update
$ brew install carthage
```

For further information on how to use Carthage you may go [here](https://github.com/Carthage/Carthage#installing-carthage)

After installing Carthage, go to `MemoryGame` folder where you can see the `Cartfile` and run the following command:

```
$ carthage update --platform iOS --no-use-binaries
```

Now, to run the app, you may now open `Mememory.xcodeproj` found in the directory `Mememory > Main`

Make sure to use your own GIPHY API key. Search for the "INSTALL_YOUR_API_KEY_HERE" in the project and change it to your own API key.

### Running the tests

Run tests using `CMD + U`

### Libraries used

##### RxSwift
- Allows for easier management of states in the app
##### RxDatasources 
- Reactive way of binding data to UICollectionViews / UITableViews
##### Moya
- Abstraction over Alamofire which makes implementing network calls much more straightforward
##### SnapKit 
- DSL for auto layout when creating programmatic views
##### Kingfisher
- Already handles all the image caching and downloading tasks for me
