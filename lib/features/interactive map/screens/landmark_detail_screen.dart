import 'package:flutter/material.dart';

class LandmarkDetailScreen extends StatelessWidget {
  const LandmarkDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Landmark Details"), centerTitle: true),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 250, width: double.infinity,
              color: Theme.of(context).colorScheme.tertiary.withOpacity(0.2),
              child: const Icon(Icons.museum_outlined, size: 60),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("قصر شبرا التاريخي", style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 15),
                  Text(
                    "هذا القصر يعكس التراث المعماري الأصيل لمدينة الطائف، حيث يجمع بين التصميم التقليدي والجمال الفني.",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}