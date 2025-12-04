import 'package:flutter/material.dart';

class DrawerTiles extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget? destinationPage;
  final Color color;
  final void Function()? onTap;

  const DrawerTiles({
    required this.title,
    required this.icon,
    this.destinationPage,
    this.color = Colors.lightGreen,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(color: color, fontWeight: FontWeight.w500),
      ),
      onTap: () {
        Navigator.pop(context); 

        if (onTap != null) {
          onTap!(); 
        } else if (destinationPage != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => destinationPage!),
          );
        }
      },
    );
  }
}
