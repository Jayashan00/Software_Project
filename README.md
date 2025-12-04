🚛 Smart Waste - Truck Driver App
A Flutter-based mobile application designed for waste collection drivers to manage logistics, visualize routes, and update collection status in real-time. This app serves as the logistical component of the Smart Waste Management System.

📱 Key Features
Secure Authentication: JWT-based login for authorized collectors.

Fleet Management: View available trucks and assign/handover vehicles for shifts.

Route Management: Receive assigned routes from the Admin Dashboard.

Interactive Maps: Visualizes bin stops and route paths using Google Maps.

Live Tracking: Transmits real-time GPS coordinates to the backend (visible to Bin Owners and Admins).

Collection Status: Mark specific bins as "Collected" to reset fill levels in the system.

🛠️ Tech Stack
Framework: Flutter (Dart)

State Management: Provider (UserProvider, RouteProvider)

Maps & Location: Google Maps Flutter, Geolocator, Location

Networking: HTTP, Flutter Secure Storage (JWT Management)

🚀 Getting Started
Prerequisites
Flutter SDK installed.

Android Studio / VS Code.

Active Google Maps API Key.

Smart Waste Backend running locally or on a server.

Installation
Clone the repository:

Bash

git clone https://github.com/yourusername/truck_driver_mobile_app.git
cd truck_driver_mobile_app
Install dependencies:

Bash

flutter pub get
Configuration:

Open lib/config.dart and update the baseUrl to point to your backend (e.g., http://localhost:8080/api).

Ensure your Google Maps API Key is added to android/app/src/main/AndroidManifest.xml.

Run the app:

Bash

# For testing GPS simulation in browser
flutter run -d chrome

# For Android Emulator
flutter run -d android
🔄 User Workflow
Login: Driver logs in with credentials.

Select Truck: Driver selects an AVAILABLE truck from the inventory.

Get Route: Driver loads the assigned route for the day.

Start: Driver clicks "Start Route" (Location tracking begins).

Collect: Driver navigates to stops and marks bins as "Collected".

Finish: Driver stops the route and hands over the truck.
