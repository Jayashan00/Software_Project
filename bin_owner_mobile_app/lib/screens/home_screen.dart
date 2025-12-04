// import 'package:flutter/material.dart';

// class HomePage extends StatelessWidget {
//   const HomePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Scaffold(
//       // appBar: AppBar(
//       //   title: const Text('Smart Bin Dashboard'),
//       //   actions: [
//       //     IconButton(
//       //       icon: const Icon(Icons.account_circle),
//       //       onPressed: () {
//       //         // Navigate to profile/settings
//       //       },
//       //     ),
//       //   ],
//       // ),
//       drawer: Drawer(
//         // Your side drawer here
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Greeting
//             Text(
//               'Good Morning, Alex 👋',
//               style: theme.textTheme.headlineSmall?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 16),

//             // Bin status section
//             Text('Bin Status', style: theme.textTheme.titleMedium),
//             const SizedBox(height: 8),
//             SizedBox(
//               height: 140,
//               child: ListView(
//                 scrollDirection: Axis.horizontal,
//                 children: const [
//                   BinCard(
//                     binName: 'Organic Bin',
//                     fill: 0.8,
//                     color: Colors.green,
//                   ),
//                   BinCard(
//                     binName: 'Plastic Bin',
//                     fill: 0.5,
//                     color: Colors.orange,
//                   ),
//                   BinCard(
//                     binName: 'General Waste',
//                     fill: 0.95,
//                     color: Colors.red,
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 24),

//             // Next Collection
//             Card(
//               elevation: 3,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: ListTile(
//                 leading: const Icon(Icons.calendar_today, color: Colors.blue),
//                 title: const Text('Next Collection'),
//                 subtitle: const Text('Friday, May 26 at 8:00 AM'),
//               ),
//             ),

//             const SizedBox(height: 24),

//             // Notifications
//             Text('Recent Alerts', style: theme.textTheme.titleMedium),
//             const SizedBox(height: 8),
//             const AlertTile(
//               icon: Icons.warning,
//               message: 'Organic bin is full – Requested pickup',
//             ),
//             const AlertTile(
//               icon: Icons.sensor_door,
//               message: 'Plastic bin sensor offline',
//             ),

//             const SizedBox(height: 24),

//             // Quick Actions
//             Text('Quick Actions', style: theme.textTheme.titleMedium),
//             const SizedBox(height: 8),
//             GridView.count(
//               crossAxisCount: 2,
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               mainAxisSpacing: 8,
//               crossAxisSpacing: 8,
//               children: const [
//                 QuickAction(icon: Icons.delete_outline, label: 'View Bins'),
//                 QuickAction(icon: Icons.bug_report, label: 'Report Issue'),
//                 QuickAction(icon: Icons.settings, label: 'Settings'),
//                 QuickAction(icon: Icons.calendar_month, label: 'Calendar'),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class BinCard extends StatelessWidget {
//   final String binName;
//   final double fill;
//   final Color color;

//   const BinCard({
//     required this.binName,
//     required this.fill,
//     required this.color,
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 3,
//       margin: const EdgeInsets.only(right: 12),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Container(
//         width: 160,
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(binName, style: const TextStyle(fontWeight: FontWeight.bold)),
//             const Spacer(),
//             LinearProgressIndicator(value: fill, color: color),
//             const SizedBox(height: 4),
//             Text('${(fill * 100).toInt()}% Full'),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class AlertTile extends StatelessWidget {
//   final IconData icon;
//   final String message;

//   const AlertTile({required this.icon, required this.message, super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       leading: Icon(icon, color: Colors.redAccent),
//       title: Text(message),
//       dense: true,
//     );
//   }
// }

// class QuickAction extends StatelessWidget {
//   final IconData icon;
//   final String label;

//   const QuickAction({required this.icon, required this.label, super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton(
//       onPressed: () {},
//       style: ElevatedButton.styleFrom(
//         backgroundColor: Colors.grey[900],
//         foregroundColor: Colors.white,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         padding: const EdgeInsets.all(12),
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(icon, size: 32),
//           const SizedBox(height: 8),
//           Text(label),
//         ],
//       ),
//     );
//   }
// }
