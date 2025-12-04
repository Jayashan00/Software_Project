♻️ Smart Waste Management System
A comprehensive, IoT-enabled ecosystem designed to optimize municipal waste collection. This full-stack solution integrates real-time bin monitoring, dynamic route planning, and live fleet tracking to connect Bin Owners, Truck Drivers, and Administrators.

🏗️ System Architecture
The system consists of four main interconnected components:

Backend API: The core logic, database, and IoT processor.

Admin Dashboard: A web portal for logistics management and analytics.

Bin Owner App: A mobile app for users to monitor bins and track trucks.

Truck Driver App: A mobile app for drivers to execute routes and share location.

🚀 Component Overview
1. 🖥️ Smart Waste Backend
The central brain of the system, built with Spring Boot. It handles data persistence, authentication, and real-time communication between hardware sensors and user applications.

Tech Stack: Java 17, Spring Boot 3.5, MongoDB, MQTT (HiveMQ), WebSocket, JWT Security.

Key Features:

Role-Based Security: Secure API access for Admins, Collectors, and Owners.

IoT Integration: Processes real-time fill levels via MQTT from smart bins.

Route Algorithm: Manages route creation and assignment logic.

Live Tracking Engine: Processes GPS updates from drivers and pushes them to owners.

2. 📊 Admin Dashboard
A responsive web application built with React for municipal administrators to manage the entire operation.

Tech Stack: React.js, Vite, Google Maps API, Chart.js, Lucide React.

Key Features:

Fleet Management: Add trucks and assign drivers.

Route Optimization: Create collection routes visually on a map.

Analytics: View bin fill trends, truck availability, and maintenance stats.

User Management: Manage collector and bin owner profiles.

3. 🗑️ Bin Owner Mobile App
A cross-platform mobile application built with Flutter for residents or businesses who own smart bins.

Tech Stack: Flutter, Provider, Google Maps Flutter, HTTP.

Key Features:

Bin Status: View real-time fill levels (Plastic, Paper, Glass).

Live Tracking: Watch the assigned collection truck move on the map in real-time.

Smart Calendar: See scheduled collection dates.

Issue Reporting: Report broken lids or sensor malfunctions directly to admins.

4. 🚛 Truck Driver Mobile App
A dedicated Flutter application for waste collectors to streamline their daily routes.

Tech Stack: Flutter, Geolocator, Location Services, Google Maps.

Key Features:

Route Navigation: View the assigned route and list of stops.

Location Sharing: Transmits real-time GPS coordinates to the backend when a route is active.

Collection Verification: Mark bins as "Collected" to reset their status in the system.

Shift Management: Start/Stop routes and handover trucks.

🛠️ Installation & Setup
Prerequisites
Java JDK 17+

Node.js & npm

Flutter SDK

MongoDB (Local or Atlas)

Active Google Maps API Key

1. Backend Setup
Bash

cd smart_waste_backend
# Update application.properties with your MongoDB URI and MQTT credentials
./mvnw spring-boot:run
2. Admin Dashboard Setup
Bash

cd dashboard
npm install
# Create a .env file with your VITE_MAPS_API_KEY
npm run dev
3. Mobile Apps Setup (Owner & Driver)
Bash

cd bin_owner_mobile_app  # OR cd truck_driver_mobile_app
flutter pub get
# Update lib/config.dart with your Backend IP address
flutter run
🔄 How It Works (The Logistics Loop)
Bin Sensor sends fill level data to Backend via MQTT.

Backend detects a full bin (90%+) and alerts the Admin Dashboard.

Admin creates a Route including the full bin and assigns a Truck/Driver.

Driver logs into the Driver App, sees the route, and clicks "Start".

Driver App begins transmitting live GPS coordinates.

Bin Owner opens the Owner App, clicks "Track", and sees the truck approaching their location on the map.

Driver arrives, empties the bin, and marks it "Collected".

System resets the bin level to 0% and marks the job complete.

🔒 Security
Authentication: All API requests are secured via JWT (JSON Web Tokens).

Validation: Backend sanitizes all incoming sensor and user data.

Authorization: Strict role checks (e.g., only Admins can delete users; only Drivers can update truck location).

📄 License
This project is licensed under the MIT License - see the LICENSE file for details.
