# Calorie Tracker App

Video overview and explanation: [YouTube Link](https://www.youtube.com/watch?v=M9tKhn7N6Ns)

A **Flutter-based Calorie Tracking App** developed as a final project for an Android App Development class. The app allows users to **search, log, and track daily food intake** using real nutritional data, helping users manage their calorie goals.

## Features

- **User Authentication:** Email/password sign-in and sign-up using Firebase Authentication.

- **Dynamic Calorie Tracking:** Logs calories for individual food items and compares total daily intake to a user-defined calorie limit.

- **Food Database Integration:** Search and retrieve nutritional information and images for food items from the OpenFoodFacts API.

- **Daily Log Management:** Users can log unlimited items in categories like breakfast, lunch, dinner, and snacks.

- **Data Persistence:** All user data (daily logs, calorie limits) stored in Firebase Firestore for access across sessions.

- **Detailed Item Info:** Logs include calories, serving amount and unit, time eaten, and food name.

- **Simple, Custom UI:** Designed for easy navigation and intuitive logging.

## Tech Stack

- **Frontend:** Flutter & Dart

- **Backend / Database:** Firebase Firestore, Firebase Authentication

- **API:** OpenFoodFacts

## Firebase Data Structure
- Users
  - user1
    - savedDays
      - 08-13-2024
        - foods
          - foodItemBarcodeID
          - foodItemBarcodeID2
          - ...
      - 08-14-2024
      - ...
    - userSettings
      - calorieLimit
  - user2
  - ...

## Notes
- Tested with 100+ food items across multiple users; no issues reported.
- Built solo as a full-stack Flutter project with Firebase integration.
