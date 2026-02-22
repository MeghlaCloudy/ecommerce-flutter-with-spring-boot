class AuthHelper {
  static bool isLoggedIn = false;
  static String? currentUser;

  static bool login(String username, String password) {
    // সিম্পল চেক (পরে SQLite বা secure storage-এ রাখো)
    if (username == "admin" && password == "1234") {
      isLoggedIn = true;
      currentUser = username;
      return true;
    }
    return false;
  }

  static void logout() {
    isLoggedIn = false;
    currentUser = null;
  }
}
