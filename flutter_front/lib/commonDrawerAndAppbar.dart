 import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Common Bar Demo',
      home: const HomePage(),
    );
  }
}

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const CommonAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      centerTitle: true,
      backgroundColor: Colors.blue,
      actions: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.notifications)),
        IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
      ],
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class AppDrawer extends StatelessWidget {
  final BuildContext context;
  const AppDrawer({super.key, required this.context});

  void navigate(Widget page) {
    Navigator.pop(context);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            accountName: Text("Meghla"),
            accountEmail: Text("meghlaclo@gmail.com"),
            currentAccountPicture: CircleAvatar(
              // child: Icon(Icons.person, size: 49),
              // backgroundImage: NetworkImage("https://i.pravatar.cc/300") ,
              backgroundImage: AssetImage("assets/logo.png"),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Home"),
            onTap: () => navigate(const HomePage()),
          ),

          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Profile"),
            onTap: () => navigate(const ProfilePage()),
          ),

          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Contact"),
            onTap: () => navigate(const ContactPage()),
          ),

          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text("Notification"),
            onTap: () => navigate(const NotificationPage()),
          ),

          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("About"),
            onTap: () => navigate(const AboutPage()),
          ),
        ],
      ),
    );
  }
}

//=============HomePage=================
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: "Home"),
      drawer: AppDrawer(context: context),
      body: pageBody("Home Page", Icons.home),
    );
  }
}

//=============ProfilePage=================
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: "Profile"),
      drawer: AppDrawer(context: context),
      body: pageBody("Profile Page", Icons.person),
    );
  }
}

//=============AboutPage=================
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: "About"),
      drawer: AppDrawer(context: context),
      body: pageBody("About Page", Icons.info),
    );
  }
}

//=============ContactPage=================
class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: "Contact"),
      drawer: AppDrawer(context: context),
      body: pageBody("Contact Page", Icons.info),
    );
  }
}

//=============SettingPage=================
class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: "SettingP"),
      drawer: AppDrawer(context: context),
      body: pageBody("Setting Page", Icons.settings),
    );
  }
}

//=============NotificationPage=================
class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: "Notification"),
      drawer: AppDrawer(context: context),
      body: pageBody("Notification Page", Icons.notifications),
    );
  }
}

//===============COMMON PAGE BODY============
Widget pageBody(String title, IconData icon) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 80, color: Colors.blue),
        const SizedBox(height: 16),
        Text(
          title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}




