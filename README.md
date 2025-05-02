# geofencing-class-attendance-app

GeoAttendanceApp is a mobile application designed to streamline class attendance tracking by leveraging geofencing technology. The app ensures that students can only mark their attendance when physically present within a predefined geographic boundary, such as a classroom or campus.

## 🚀 Features

- **Geofencing-Based Attendance**: Restricts attendance marking to specific geographic areas to prevent proxy attendance.
- **Real-Time Location Verification**: Utilizes GPS to verify user location in real-time.
- **User Authentication**: Secure login system to ensure only authorized users can access the app.
- **Attendance History**: Allows users to view their past attendance records.
- **Cross-Platform Support**: Built with Flutter for both Android and iOS platforms.

## 🛠️ Technologies Used

- **Flutter**: For cross-platform mobile app development.
- **Firebase**: Backend services including Authentication and Firestore for real-time database.
- **Google Maps API**: For geolocation and geofencing functionalities.

## 📱 Screenshots

![authscreen](https://github.com/user-attachments/assets/0be22dd6-40f9-462c-9369-08e011ae9704)
![adminauthscreen](https://github.com/user-attachments/assets/c1574e45-b840-48ee-92c4-22b0aa5cdb83)
![studentdashboard](https://github.com/user-attachments/assets/af706475-15de-46c2-8b19-9251dbaa63a8)
![admindashboard](https://github.com/user-attachments/assets/21e13afb-622a-48e9-bfa0-089a4268f2aa)
![image](https://github.com/user-attachments/assets/50846477-3690-4eb2-805b-ad752e4f4545)
![image](https://github.com/user-attachments/assets/f9be23ee-4ce5-47e6-b276-dc69eb1beb69)
![image](https://github.com/user-attachments/assets/0038ed66-5807-473d-a490-0ae8cc958b03)
![image](https://github.com/user-attachments/assets/3203bb76-f98d-49ba-96e9-23810639a21c)


## 🧑‍💻 Getting Started

### Prerequisites

- Flutter SDK installed on your machine.
- A Firebase project set up with Authentication and Firestore.
- Google Maps API key.

### Installation
1. Clone the Repository:
git clone https://github.com/m1-ah/geofencing-class-attendance-app.git
Navigate to the Project Directory:

## 2. Install dependencies:
flutter pub get

## 3.Configure Firebase:
Add your google-services.json (for Android) and 
GoogleService-Info.plist (for iOS) files to the respective directories.

## 4. Add Google Maps API Key:
For Android: Add your API key in android/app/src/main/AndroidManifest.xml.
For iOS: Add your API key in ios/Runner/AppDelegate.swift.

## 5. Run the app:
flutter run

## 🤝 Contributing
Contributions are welcome! Please fork the repository and submit a pull request for any enhancements or bug fixes.

## 📄 License
This project is licensed under the MIT License - see the LICENSE file for details.

## 📫 Contact
For any inquiries or feedback, please contact devmaina01@gmail.com
