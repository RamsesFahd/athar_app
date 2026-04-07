import 'package:flutter/material.dart';

class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Event Details"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("مهرجان القهوة السعودية", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 25),
            Row(
              children: [
                Icon(Icons.calendar_today, color: colorScheme.secondary),
                const SizedBox(width: 10),
                Text("التاريخ: 20 مايو 2026", style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Icon(Icons.location_on, color: colorScheme.secondary),
                const SizedBox(width: 10),
                Text("الموقع: مكة المكرمة", style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
            const SizedBox(height: 30),
            Text("عن الفعالية:", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            Text("فعالية ثقافية لاستعراض طرق تحضير القهوة السعودية والاحتفاء بالقيم الثقافية.", style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}