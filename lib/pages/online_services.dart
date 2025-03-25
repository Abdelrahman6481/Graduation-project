import 'package:flutter/material.dart';

class OnlineServicesPage extends StatelessWidget {
  const OnlineServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> services = [
      {"title": "Book an appointment", "page": const BookAppointmentPage()},
      {"title": "Registration Fees Payment", "page": const FeesPaymentPage()},
      {"title": "Requests", "page": const RequestsPage()},
      {"title": "My Requests Follow-up", "page": const FollowUpPage()},
      {"title": "Clinic", "page": const ClinicPage()},
      {"title": "Student Development Office (SDO)", "page": const SDOPage()},
      {"title": "Bus Reservation", "page": const BusReservationPage()},
      {"title": "Student Activities", "page": const ActivitiesPage()},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Online Services", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF8B0000), // لون أحمر ثابت
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: services.map((service) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => service["page"]),
                );
              },
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 6.0), // تقليل المسافات بين العناصر
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black26, width: 1), // تحديد حواف خفيفة
                ),
                child: Text(
                  service["title"],
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// صفحات الخدمات الفارغة (يتم ملؤها لاحقًا)
class BookAppointmentPage extends StatelessWidget {
  const BookAppointmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Book an Appointment")),
      body: const Center(child: Text("Book an appointment Page")),
    );
  }
}

class FeesPaymentPage extends StatelessWidget {
  const FeesPaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Fees Payment")),
      body: const Center(child: Text("Fees Payment Page")),
    );
  }
}

class RequestsPage extends StatelessWidget {
  const RequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Requests")),
      body: const Center(child: Text("Requests Page")),
    );
  }
}

class FollowUpPage extends StatelessWidget {
  const FollowUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Follow-up Requests")),
      body: const Center(child: Text("Follow-up Requests Page")),
    );
  }
}

class ClinicPage extends StatelessWidget {
  const ClinicPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Clinic")),
      body: const Center(child: Text("Clinic Page")),
    );
  }
}

class SDOPage extends StatelessWidget {
  const SDOPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Student Development Office")),
      body: const Center(child: Text("SDO Page")),
    );
  }
}

class BusReservationPage extends StatelessWidget {
  const BusReservationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bus Reservation")),
      body: const Center(child: Text("Bus Reservation Page")),
    );
  }
}

class ActivitiesPage extends StatelessWidget {
  const ActivitiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Student Activities")),
      body: const Center(child: Text("Student Activities Page")),
    );
  }
}
