import 'package:flutter/material.dart';
import 'package:athar_app/generated/l10n/app_localizations.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Name controller 
  final _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // Input decoration
    final inputDec = InputDecoration(
      filled: true,
      fillColor: theme.colorScheme.surface,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );

    return Scaffold(
      appBar: AppBar(
        // Page title
        title: Text(l10n.editProfileTitle, style: theme.textTheme.titleLarge),
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: Center(
        // Center content (so the page isn't empty)
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Profile image + change icon 
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 52,
                      backgroundColor: theme.colorScheme.primary.withOpacity(0.08),
                      child: Icon(Icons.person,
                          color: theme.colorScheme.primary.withOpacity(0.7),
                          size: 44),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: () {
                          // Bottom sheet just for UI
                          showModalBottomSheet(
                            context: context,
                            builder: (_) => SafeArea(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: const Icon(Icons.photo_library_outlined),
                                    title: Text(l10n.chooseFromGallery),
                                    onTap: () => Navigator.pop(context),
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.camera_alt_outlined),
                                    title: Text(l10n.takePhoto),
                                    onTap: () => Navigator.pop(context),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            // Camera button background
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.camera_alt_outlined,
                              color: theme.colorScheme.onPrimary, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                // Name label
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(l10n.fullNameLabel, style: theme.textTheme.bodyLarge),
                ),
                const SizedBox(height: 8),

                // Name field
                TextField(
                  controller: _name,
                  decoration: inputDec.copyWith(hintText: l10n.nameHint),
                ),

                const SizedBox(height: 18),

                // Save/Continue button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.continueButton),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}