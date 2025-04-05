
# Flutter Offline First Package

## Overview

The `Flutter_Offline_First` package for Flutter helps implement an **Offline First** approach for fetching, saving, and watching data with local caching using **Hive** as the local database. It supports various fetching strategies and integrates with network requests seamlessly to ensure your application works efficiently offline and online.

This package provides the following features:

- Fetch data from network or cache using specified fetch policies.
- Save data locally for offline access.
- Watch for data updates with streams.
- Simple and easy-to-use API to manage data persistence.

---

## Installation

Add the following dependency to your `pubspec.yaml` file:

```yaml
dependencies:
  flutter_offline_first: latest
```

Run the command to fetch dependencies:

```bash
flutter pub get
```

## Initialization

Before using the OfflineFirst package, you need to initialize it in the main() method of your application:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await OfflineFirst.init();  // Initialize Offline First
  runApp(MyApp());
}
```
Once it has been initialized, you can start using the OfflineFirst class to fetch, save, and watch data.


## Usage

# Fetching Data

Use the fetchData() method to fetch data from the network or local cache. You can specify the fetching policy using the OfflineFirstFetchPolicy enum.

**Fetch Policies:**

- `networkOnly`: Only fetch data from the network.

- `cacheOnly`: Only fetch data from the cache.

- `cacheThenNetwork`: Fetch data from cache first, and then from the network if cache is empty.

**Example**

```dart
final result = await offlineFirst.fetchData(
  urlPath: newsApiUrl,
  fetchPolicy: OfflineFirstFetchPolicy.cacheOnly,
  debugMode: true,
);

if (result.status) {
  return NewsDataModel.fromJson(json.decode(result.data));
} else {
  throw Exception("❌ Error: ${result.message}");
}
```

# Saving Data

You can store data locally in the cache using the saveData() method. This will save the data under the specified key.

**Example**

```dart
await offlineFirst.saveData(
  key: 'key', 
  content: json.encode(content),
);
```

# Watching Data

To monitor changes in data in real-time, use the watchData() method with a StreamBuilder. This allows you to listen to changes in your cached data and automatically refresh the UI when the data updates.

**Example**

```dart
StreamBuilder<FetchFirstResponse>(
  stream: offlineFirst.watchData(
    urlPath: 'https://api.example.com/news',
    fetchPolicy: OfflineFirstFetchPolicy.cacheThenNetwork,
  ),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator();
    }

    if (!snapshot.hasData || !snapshot.data!.status) {
      return Text('Error: ${snapshot.data?.message ?? "No data"}');
    }

    final newsData = snapshot.data!.data;
    return Text('News: ${newsData.toString()}');
  },
)
```

# FetchFirstResponse

The `FetchFirstResponse` class represents the result of a fetch operation and contains the following fields:

```dart
class FetchFirstResponse {
  final bool status;
  final String? message;
  final dynamic data;

  FetchFirstResponse({
    required this.status,
    this.message,
    this.data,
  });
}
```

- `status`: `true` if the operation was successful, `false` if there was an error.

- `message`: Optional error message if status is `false`.

- `data`: The actual data returned (either from cache or network).



## Debug Mode

Enable debug mode to see logs related to the fetch and save operations. Simply pass debugMode: `true` when calling `fetchData()`.


## Contributing

Contributions are welcome!

Feel free to open issues and pull requests for bug fixes or new features. 

You can also send an email[talk2destinyed@gmail.com]


