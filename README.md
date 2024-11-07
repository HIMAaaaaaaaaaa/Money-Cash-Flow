# Personal Finance Management App

## Overview

The **Personal Finance Management App** is a mobile application designed to help users efficiently manage their personal finances. It allows users to track their income, manage their expenses, and analyze their spending habits. Each user has their own unique data stored securely in Firebase, ensuring privacy and separation between users' records.

### Key Features:
- **User Authentication**: Users can register, log in, and log out securely using Firebase Authentication. Each user's data is isolated based on their unique user ID.
  
- **Expense Tracking**: Users can record their daily, weekly, and monthly expenses, categorized by type (e.g., food, transport, shopping). Data is stored in Firebase under each user's sub-collection.

- **Income Management**: Users can track their monthly income, and new income entries can be added through the "Income Details" page. The data is continuously updated and stored in Firebase.

- **Dashboard**: A personalized dashboard displays an overview of the user's finances, including total expenses, income, and expense category analysis through a pie chart.

- **Data Persistence**: All user data is stored securely in Firebase. Users' data remains saved and isolated, so when they log out and log back in, their data is preserved.

- **Firebase Integration**: The app integrates with Firebase Firestore for real-time data storage and Firebase Authentication for secure login and user management.

## Features Breakdown

1. **User Authentication**:
   - Registration, Login, and Logout functionality.
   - Firebase Authentication ensures a secure and personalized user experience.

2. **Expenses Management**:
   - Add, view, and categorize expenses.
   - View daily, weekly, and monthly expense summaries.

3. **Income Tracking**:
   - Add and view monthly income.
   - Keep track of income over time.

4. **Dashboard Overview**:
   - Displays personalized financial summaries and charts based on the user's data.
   - Provides visual insights into the user's finances.

5. **Firebase Database Structure**:
   - **users (collection)**: Stores user data such as ID, name, email, etc.
   - **expenses (sub-collection)**: Stores user-specific expense records.
   - **incomes (sub-collection)**: Stores user-specific income records.

## Firebase Database Structure

- **users (collection)**:
  - **userID (document)**:
    - Name
    - Email
    - Phone Number
    - Username

- **expenses (sub-collection)**:
  - **expenseID (document)**:
    - Category
    - Amount
    - Date
    - Note

- **incomes (sub-collection)**:
  - **incomeID (document)**:
    - Amount
    - Monthly Income
    - Note

## Tech Stack

- **Frontend**: Flutter
- **Backend**: Firebase (Firestore for real-time database and Firebase Authentication for user management)
- **Charts**: Pie chart for expense category breakdown

## Getting Started

1. Clone this repository to your local machine.
2. Install dependencies by running `flutter pub get`.
3. Set up Firebase project and configure Firebase credentials for the app.
4. Run the app on an emulator or physical device.

For detailed setup instructions, refer to the [Installation Guide](./docs/INSTALLATION.md).

## Future Enhancements

- Adding a budget tracking feature.
- Implementing detailed expense reports with export options (e.g., PDF).
- Adding support for multiple currencies.
- Introducing dark mode for improved user experience.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

