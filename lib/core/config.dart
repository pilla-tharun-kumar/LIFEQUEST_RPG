class RpgConfig {
  // --- Firebase Configuration ---
  // If true, the app will try to initialize live Firebase Authentication.
  // Requires standard 'google-services.json' (Android) and 'GoogleService-Info.plist' (iOS).
  static bool isFirebaseEnabled = true;

  // --- MongoDB Atlas Configuration ---
  // If true, changes will be pushed in the background to your MongoDB Atlas Cluster.
  static bool isMongoSyncEnabled = true;

  // Past your MongoDB Atlas connection string URI here.
  // Note: we target the 'lifequest_rpg' database by default.
  static String mongoUri = "mongodb+srv://tharunkumarpilla_db_user:tharun123@rpggame.vohmrsw.mongodb.net/lifequest_rpg?retryWrites=true&w=majority";
}
