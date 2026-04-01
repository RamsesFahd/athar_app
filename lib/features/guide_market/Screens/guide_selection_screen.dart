import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/custom_stepper.dart';
import '../widgets/guide_card.dart';
import 'booking_summary_screen.dart';
import 'package:athar_app/core/models/user/user_model.dart';
import 'package:athar_app/features/guide_market/logic/booking_notifier.dart';
import 'package:athar_app/features/guide_market/logic/marketplace_repository.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';

class GuideSelectionScreen extends ConsumerWidget {
  final String tripTitle;
  final double tripPrice; // adult price
  final double childPrice;
  final String date;
  final String time;
  final int adults;
  final int children;
  final String imageUrl;

  const GuideSelectionScreen({
    super.key,
    required this.tripTitle,
    required this.date,
    required this.time,
    required this.adults,
    required this.children,
    required this.imageUrl,
    required this.tripPrice,
    this.childPrice = 0.0,
  });

  Map<String, dynamic> _tutorToMap(TutorModel tutor) => {
        'uId': tutor.uId,
        'name': tutor.fullName,
        'rating': 5.0,
        'exp': tutor.licenceNumber ?? 'Licensed',
        'company': tutor.companyName ??
            (tutor.tutorType == TutorType.company ? 'Company' : 'Individual'),
        'bio': tutor.bio ?? '',
        'languages': ['Arabic', 'English'],
        'availableDays': [],
        'skills': [],
      };

  void _showGuideDetails(BuildContext context, WidgetRef ref,
      Map<String, dynamic> guide, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(guide['name']),
            const SizedBox(height: 5),
            Row(
              children: List.generate(
                5,
                (index) => Icon(
                  index < (guide['rating'] as double).floor()
                      ? Icons.star
                      : Icons.star_border,
                  color: Colors.amber,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if ((guide['bio'] as String).isNotEmpty) ...[
                Text(guide['bio'],
                    style: TextStyle(color: Colors.grey[700])),
                const SizedBox(height: 15),
              ],
              Text(l10n.languages,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: (guide['languages'] as List)
                    .map((lang) => Chip(
                          backgroundColor: Theme.of(context)
                              .primaryColor
                              .withValues(alpha: 0.1),
                          label: Text(lang,
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold)),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              minimumSize: const Size(double.infinity, 50),
            ),
            onPressed: () {
              ref.read(bookingNotifierProvider.notifier).selectTutor(
                    guide['uId'] as String,
                    guide['name'] as String,
                  );
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookingSummaryScreen(
                    tripTitle: tripTitle,
                    guideName: guide['name'] as String,
                    date: date,
                    time: time,
                    adults: adults,
                    children: children,
                    adultPrice: tripPrice,
                    childPrice: childPrice,
                    totalPrice: (tripPrice * adults) + (childPrice * children),
                    imageUrl: imageUrl,
                  ),
                ),
              );
            },
            child: Text(l10n.select_this_guide,
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.choose_guide)),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: CustomStepper(currentStep: 3),
          ),
          Expanded(
            child: FutureBuilder<List<TutorModel>>(
              future:
                  ref.read(marketplaceRepositoryProvider).fetchAvailableTutors(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final tutors = snapshot.data ?? [];

                if (tutors.isEmpty) {
                  return const Center(child: Text('No guides available'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: tutors.length,
                  itemBuilder: (context, index) {
                    final guide = _tutorToMap(tutors[index]);
                    return GuideCard(
                      guide: guide,
                      onTap: () =>
                          _showGuideDetails(context, ref, guide, l10n),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
