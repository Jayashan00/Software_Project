import 'package:flutter/material.dart';
import 'package:truck_driver_mobile_app/screens/navigation_drawer.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Controllers to get text from the TextFields
    final TextEditingController nameController = TextEditingController();
    final TextEditingController problemController = TextEditingController();

    // Method to display AlertDialog
    void showAlertDialog(BuildContext context, String title, String message) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: <Widget>[
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    // Method to handle submit logic
    void submitReport() {
      String name = nameController.text.trim();
      String problem = problemController.text.trim();

      if (name.isEmpty || problem.isEmpty) {
        // Show Alert Dialog for Error
        showAlertDialog(context, "Error", "All fields are required!");
        return; // Stop execution if validation fails
      }

      // Show Alert Dialog for Success
      showAlertDialog(context, "Success", "Report Submitted Successfully!");

      // Clear the text fields after submission
      nameController.clear();
      problemController.clear();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Report a Problem"),
      ),
      drawer: const MyNavigationDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name Label and Input Field
            const Text(
              "Name",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter your name',
              ),
            ),
            const SizedBox(height: 30),

            // Problem Description Label and Input Field
            const Text(
              "Problem Description",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: problemController,
              maxLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter the problem',
              ),
            ),
            const SizedBox(height: 50),

            // Submit Button
            Center(
              child: ElevatedButton(
                onPressed: submitReport,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                  backgroundColor: Colors.blue,
                  disabledBackgroundColor: Colors.blue[300],
                  elevation: 5,
                ),
                child: const Text(
                  "Send",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
