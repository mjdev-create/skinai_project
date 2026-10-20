import 'package:flutter/material.dart';
import '../widgets/app_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                children: [
                  // ----- Top bar -----
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Row(
                      children: [
                        Icon(Icons.celebration, color: cs.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Skinai',
                          style: text.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(context, '/login'),
                          child: const Text('Log in'),
                        ),
                        const SizedBox(width: 8),
                        FilledButton.tonal(
                          onPressed: () => Navigator.pushNamed(context, '/register'),
                          child: const Text('Register'),
                        ),
                      ],
                    ),
                  ),

                  // ----- Hero -----
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 56),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [cs.primaryContainer, cs.tertiaryContainer],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.event_available, size: 64, color: cs.primary),
                        const SizedBox(height: 16),
                        Text(
                          'Plan unforgettable events,\nwithout the stress.',
                          textAlign: TextAlign.center,
                          style: text.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: cs.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Reserve venues, track your guest list and manage every booking in one place.',
                          textAlign: TextAlign.center,
                          style: text.titleMedium?.copyWith(color: cs.onPrimaryContainer),
                        ),
                        const SizedBox(height: 28),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          alignment: WrapAlignment.center,
                          children: [
                            AppButton(
                              label: 'Create account',
                              onPressed: () => Navigator.pushNamed(context, '/register'),
                            ),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(160, 48),
                              ),
                              onPressed: () => Navigator.pushNamed(context, '/login'),
                              child: const Text('Log in'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ----- Features -----
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      alignment: WrapAlignment.center,
                      children: const [
                        _Feature(
                          icon: Icons.place_outlined,
                          title: 'Choose a venue',
                          text: 'Pick the place, date and type of event that fits your plan.',
                        ),
                        _Feature(
                          icon: Icons.groups_outlined,
                          title: 'Track your guests',
                          text: 'Set the number of guests and add special requests.',
                        ),
                        _Feature(
                          icon: Icons.fact_check_outlined,
                          title: 'Manage reservations',
                          text: 'See all your bookings from one simple dashboard.',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ----- Call to action -----
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Text(
                              'Ready to plan your event?',
                              style: text.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            // Activity 9: shared AppButton opens the reservation form
                            AppButton(
                              label: 'Reserve an Event',
                              onPressed: () => Navigator.pushNamed(context, '/report'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text('© 2026 Skinai Event Reservation', style: text.bodySmall),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;
  const _Feature({required this.icon, required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: 290,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: cs.secondaryContainer,
                child: Icon(icon, color: cs.onSecondaryContainer),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(text),
            ],
          ),
        ),
      ),
    );
  }
}