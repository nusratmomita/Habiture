// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../providers/theme_provider.dart';

// class SettingsScreen extends StatelessWidget {
//   const SettingsScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final themeProvider = Provider.of<ThemeProvider>(context);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Settings"),
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           // Theme Switch
//           ListTile(
//             leading: const Icon(Icons.brightness_6),
//             title: const Text("Dark Mode"),
//             trailing: Switch(
//               value: themeProvider.isDarkMode,
//               onChanged: (value) {
//                 themeProvider.toggleTheme();
//               },
//             ),
//           ),
//           const Divider(),

//           // Account Section
//           const Padding(
//             padding: EdgeInsets.symmetric(vertical: 10),
//             child: Text(
//               "Account",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//           ),
//           ListTile(
//             leading: const Icon(Icons.person),
//             title: const Text("Edit Profile"),
//             onTap: () {
//               // Navigate to Profile Edit Screen
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.lock),
//             title: const Text("Change Password"),
//             onTap: () {
//               // Add navigation later
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.exit_to_app),
//             title: const Text("Logout"),
//             onTap: () {
//               // Implement logout
//             },
//           ),

//           const Divider(),

//           // About Section
//           const Padding(
//             padding: EdgeInsets.symmetric(vertical: 10),
//             child: Text(
//               "About",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//           ),
//           ListTile(
//             leading: const Icon(Icons.info),
//             title: const Text("App Version"),
//             subtitle: const Text("v1.0.0"),
//           ),
//         ],
//       ),
//     );
//   }
// }
