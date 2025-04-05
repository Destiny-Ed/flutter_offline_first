
# OfflineFirst Flutter Package

## Overview

The `OfflineFirst` package for Flutter helps implement an **Offline First** approach for fetching, saving, and watching data with local caching using **Hive** as the local database. It supports various fetching strategies and integrates with network requests seamlessly to ensure your application works efficiently offline and online.

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
  offline_first: latest
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

TODO: Include short and useful examples for package users. Add longer examples
to `/example` folder.

```dart
const like = 'sample';
```

## Additional information

TODO: Tell users more about the package: where to find more information, how to
contribute to the package, how to file issues, what response they can expect
from the package authors, and more.
