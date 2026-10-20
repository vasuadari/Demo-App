# Students (iOS)

SwiftUI companion app for the Rails **Demo App** `students` resource.

## Requirements

- Xcode 15+
- iOS 17+
- Rails Demo App running locally (`rails server` on port 3000)

## Open & run

1. Open `Students.xcodeproj` in Xcode on a Mac.
2. Select an iPhone simulator.
3. Run (**⌘R**).

The app talks to `http://127.0.0.1:3000` by default (works in the Simulator against your Mac).

### Physical device

Set your Mac’s LAN IP, either by editing `APIConfiguration.swift` or by adding an environment variable in the Xcode scheme:

```
DEMO_APP_API_URL=http://192.168.x.x:3000
```

## Features

- List students from `GET /students.json`
- Create / update / delete via the Rails JSON API
- Pull to refresh

## Rails API notes

The Rails app exposes JSON for the students scaffold. This PR also:

- Fixes `StudentsController#create` so it uses request params (it previously forced empty values)
- Skips CSRF verification for JSON requests so the native client can POST/PUT/DELETE
