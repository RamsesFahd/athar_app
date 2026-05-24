import 'package:flutter/material.dart';
import 'package:athar_app/features/bookings/logic/rating_repository.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';

/// Shown on a completed booking for the tourist.
/// Checks whether a rating already exists for [bookingId] and either renders
/// the submitted value (read-only) or an interactive 5-star submission form.
class RatingStarsWidget extends StatefulWidget {
  final String bookingId;
  final String touristId;
  final String tutorId;
  final String tripId;

  const RatingStarsWidget({
    super.key,
    required this.bookingId,
    required this.touristId,
    required this.tutorId,
    required this.tripId,
  });

  @override
  State<RatingStarsWidget> createState() => _RatingStarsWidgetState();
}

class _RatingStarsWidgetState extends State<RatingStarsWidget> {
  final RatingRepository _repo = RatingRepository();

  // null = loading, -1 = not rated yet, 1–5 = already rated / just submitted
  int? _existingStars;
  int _selected = 0;
  bool _submitting = false;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _checkExisting();
  }

  Future<void> _checkExisting() async {
    // Use a lightweight query first; if rated, we only know it exists (not
    // the star value). For simplicity we store the submitted value locally.
    final rated = await _repo.hasRated(widget.bookingId);
    if (mounted) setState(() => _existingStars = rated ? 0 : -1);
  }

  Future<void> _submit() async {
    if (_selected == 0 || _submitting) return;
    setState(() => _submitting = true);
    try {
      await _repo.submitRating(
        bookingId: widget.bookingId,
        touristId: widget.touristId,
        tutorId: widget.tutorId,
        tripId: widget.tripId,
        stars: _selected,
      );
      if (mounted) setState(() => _submitted = true);
    } catch (_) {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    // Loading
    if (_existingStars == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // Already rated (either before this session or just submitted)
    if (_existingStars == 0 || _submitted) {
      return _buildConfirmation(theme, isAr, l10n);
    }

    // Interactive form
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            l10n.rateYourGuide,
            style: theme.textTheme.bodyLarge
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final star = i + 1;
              return GestureDetector(
                onTap: () => setState(() => _selected = star),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    star <= _selected ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: theme.colorScheme.primary,
                    size: 38,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selected > 0 && !_submitting ? _submit : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(isAr ? 'إرسال التقييم' : 'Submit Rating'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmation(ThemeData theme, bool isAr, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: Colors.green.shade600, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isAr ? 'تم إرسال تقييمك، شكرًا!' : 'Rating submitted, thank you!',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600, color: Colors.green.shade700),
            ),
          ),
        ],
      ),
    );
  }
}
