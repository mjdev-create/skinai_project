import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';

// The five UI states from the lecture (slide 25).
enum ReportUiState { idle, loading, success, empty, error }

const List<String> _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String _formatDate(DateTime d) => '${_months[d.month - 1]} ${d.day}, ${d.year}';

// A simple in-memory reservation (stands in for a future models/ class).
class _Reservation {
  final String ref;
  final String eventName;
  final String eventType;
  final String venue;
  final String dateLabel;
  final int guests;

  const _Reservation({
    required this.ref,
    required this.eventName,
    required this.eventType,
    required this.venue,
    required this.dateLabel,
    required this.guests,
  });
}

// StatefulWidget: the form must remember input, validation and async state.
class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({super.key});

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen>
    with SingleTickerProviderStateMixin {
  // Created once in State, not in build() (lecture slide 16).
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _venueCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  final _guestsCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  late final TabController _tabs;

  static const _eventTypes = [
    'Wedding',
    'Birthday',
    'Corporate Meeting',
    'Seminar / Workshop',
    'Reunion',
  ];

  String? _eventType;
  bool _simulateFailure = false; // demo switch to trigger the Error state

  ReportUiState _uiState = ReportUiState.idle; // state of the submit form
  ReportUiState _listState = ReportUiState.loading; // state of the list tab

  final List<_Reservation> _reservations = [];
  _Reservation? _last;
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _loadReservations(); // simulated fetch: Loading, then Empty on first open
  }

  @override
  void dispose() {
    _tabs.dispose();
    _nameCtrl.dispose();
    _venueCtrl.dispose();
    _dateCtrl.dispose();
    _guestsCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------
  // Async actions (simulated)
  // ---------------------------------------------------------------

  Future<void> _submit() async {
    if (_uiState == ReportUiState.loading) return; // block duplicate taps
    if (!(_formKey.currentState?.validate() ?? false)) return; // field errors

    setState(() => _uiState = ReportUiState.loading);
    try {
      await Future<void>.delayed(const Duration(seconds: 3)); // SIMULATED
      if (_simulateFailure) throw Exception('Simulated failure');
      if (!mounted) return;

      _counter++;
      final reservation = _Reservation(
        ref: 'EVT-${1000 + _counter}',
        eventName: _nameCtrl.text.trim(),
        eventType: _eventType ?? '',
        venue: _venueCtrl.text.trim(),
        dateLabel: _dateCtrl.text,
        guests: int.parse(_guestsCtrl.text.trim()),
      );
      setState(() {
        _reservations.insert(0, reservation);
        _last = reservation;
        _listState = ReportUiState.success;
        _uiState = ReportUiState.success;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _uiState = ReportUiState.error);
    }
  }

  Future<void> _loadReservations() async {
    setState(() => _listState = ReportUiState.loading);
    try {
      await Future<void>.delayed(const Duration(milliseconds: 1500)); // SIMULATED
      if (_simulateFailure) throw Exception('Simulated failure');
      if (!mounted) return;
      setState(() {
        _listState = _reservations.isEmpty
            ? ReportUiState.empty
            : ReportUiState.success;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _listState = ReportUiState.error);
    }
  }

  void _clearAll() {
    setState(() {
      _reservations.clear();
      _last = null;
      _listState = ReportUiState.empty;
      if (_uiState == ReportUiState.success) _uiState = ReportUiState.idle;
    });
  }

  void _resetForm() {
    _nameCtrl.clear();
    _venueCtrl.clear();
    _dateCtrl.clear();
    _guestsCtrl.clear();
    _notesCtrl.clear();
    setState(() {
      _eventType = null;
      _uiState = ReportUiState.idle;
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 730)),
    );
    if (picked == null || !mounted) return;
    setState(() => _dateCtrl.text = _formatDate(picked));
  }

  // ---------------------------------------------------------------
  // Validators (return a message when invalid, null when valid)
  // ---------------------------------------------------------------

  String? _validateName(String? v) {
    if (v == null || v.trim().isEmpty) return 'Please enter the event name';
    if (v.trim().length < 3) return 'Event name must be at least 3 characters';
    return null;
  }

  String? _validateVenue(String? v) {
    if (v == null || v.trim().isEmpty) return 'Please enter the venue or location';
    return null;
  }

  String? _validateGuests(String? v) {
    if (v == null || v.trim().isEmpty) return 'Please enter the number of guests';
    final n = int.tryParse(v.trim());
    if (n == null || n < 1 || n > 500) return 'Guests must be a number from 1 to 500';
    return null;
  }

  // ---------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Reservation'),
        bottom: TabBar(
          controller: _tabs,
          tabs: [
            const Tab(icon: Icon(Icons.edit_calendar), text: 'New Reservation'),
            Tab(
              icon: const Icon(Icons.list_alt),
              text: 'My Reservations (${_reservations.length})',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _centered(_buildFormTab()),
          _centered(_buildListTab()),
        ],
      ),
    );
  }

  // Keeps content readable on wide Chrome windows.
  Widget _centered(Widget child) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }

  // ----- Tab 1: the form -----

  Widget _buildFormTab() {
    if (_uiState == ReportUiState.success && _last != null) {
      return _buildSuccessPanel(_last!);
    }
    final loading = _uiState == ReportUiState.loading;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Reserve an Event', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 4),
        const Text('Fields marked * are required.'),
        const SizedBox(height: 16),
        if (loading)
          Card(
            color: theme.colorScheme.secondaryContainer,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text('Submitting your reservation… please wait (simulated).'),
                  ),
                ],
              ),
            ),
          ),
        if (_uiState == ReportUiState.error) _buildErrorBanner(),
        // While loading, the form is dimmed and cannot be edited or re-submitted.
        IgnorePointer(
          ignoring: loading,
          child: Opacity(opacity: loading ? 0.6 : 1, child: _buildForm()),
        ),
        const SizedBox(height: 16),
        AppButton(
          label: loading ? 'Submitting…' : 'Submit Reservation',
          onPressed: loading ? null : _submit,
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 560; // responsive layout

          final typeField = DropdownButtonFormField<String>(
            // ignore: deprecated_member_use
            value: _eventType,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Event type *',
              border: OutlineInputBorder(),
            ),
            items: [
              for (final t in _eventTypes)
                DropdownMenuItem(value: t, child: Text(t)),
            ],
            onChanged: (v) => setState(() => _eventType = v),
            validator: (v) => v == null ? 'Please select an event type' : null,
          );

          final dateField = TextFormField(
            controller: _dateCtrl,
            readOnly: true,
            onTap: _pickDate,
            decoration: const InputDecoration(
              labelText: 'Event date *',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.calendar_today),
            ),
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Please choose an event date' : null,
          );

          return Column(
            children: [
              // Shared widget #1: AppTextField (reused from Activity 8)
              AppTextField(
                controller: _nameCtrl,
                label: 'Event name *',
                validator: _validateName,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _venueCtrl,
                label: 'Venue / location *',
                validator: _validateVenue,
              ),
              const SizedBox(height: 16),
              _pair(typeField, dateField, wide),
              const SizedBox(height: 16),
              TextFormField(
                controller: _guestsCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Number of guests *',
                  border: OutlineInputBorder(),
                ),
                validator: _validateGuests,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Special requests (optional)',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Simulate server failure (demo only)'),
                subtitle: const Text('Turn on to show the Error state, off to succeed.'),
                value: _simulateFailure,
                onChanged: (v) => setState(() => _simulateFailure = v),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _pair(Widget a, Widget b, bool wide) {
    if (wide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: a),
          const SizedBox(width: 16),
          Expanded(child: b),
        ],
      );
    }
    return Column(children: [a, const SizedBox(height: 16), b]);
  }

  // ----- ERROR banner with Retry / correction -----

  Widget _buildErrorBanner() {
    final cs = Theme.of(context).colorScheme;
    return Card(
      color: cs.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.error_outline, color: cs.error),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Reservation failed',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'We could not submit your reservation (simulated server failure). '
              'Your details were kept. Tap Retry, or turn off '
              '"Simulate server failure" below and retry.',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                FilledButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => setState(() => _uiState = ReportUiState.idle),
                  child: const Text('Edit details'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ----- SUCCESS panel with next actions -----

  Widget _buildSuccessPanel(_Reservation r) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        const Icon(Icons.check_circle, size: 72, color: Colors.green),
        const SizedBox(height: 12),
        Text(
          'Reservation submitted!',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 4),
        Text(
          'Reference ${r.ref} (simulated, not saved to a database)',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.event_available),
            title: Text(r.eventName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
              '${r.eventType} • ${r.dateLabel}\n${r.venue} • ${r.guests} guests',
            ),
            isThreeLine: true,
          ),
        ),
        const SizedBox(height: 16),
        // Shared widget #1 again: AppButton as the next action
        AppButton(
          label: 'View my reservations',
          onPressed: () {
            _resetForm();
            _tabs.animateTo(1);
          },
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: _resetForm,
          child: const Text('Reserve another event'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(), // back to Home
          child: const Text('Back to Home'),
        ),
      ],
    );
  }

  // ----- Tab 2: reservation list (Loading / Empty / Error / Success) -----

  Widget _buildListTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'My Reservations',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            TextButton.icon(
              onPressed: _listState == ReportUiState.loading ? null : _loadReservations,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
            TextButton.icon(
              onPressed: _reservations.isEmpty ? null : _clearAll,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Clear all'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildListBody(),
      ],
    );
  }

  Widget _buildListBody() {
    switch (_listState) {
      case ReportUiState.loading:
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 48),
          child: Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading your reservations… (simulated)'),
            ],
          ),
        );
      case ReportUiState.error:
        return _stateMessage(
          icon: Icons.cloud_off,
          title: 'Could not load reservations',
          message: 'The request failed (simulated). Please try again.',
          actionLabel: 'Retry',
          onAction: _loadReservations,
        );
      case ReportUiState.empty:
        return _stateMessage(
          icon: Icons.event_busy,
          title: 'No reservations yet',
          message: 'You have not reserved an event. Create your first reservation and it will appear here.',
          actionLabel: 'Reserve an event',
          onAction: () => _tabs.animateTo(0),
        );
      default:
        return Column(
          children: [for (final r in _reservations) _reservationCard(r)],
        );
    }
  }

  Widget _stateMessage({
    required IconData icon,
    required String title,
    required String message,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(icon, size: 64, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          // Shared widget used again, in another context
          AppButton(label: actionLabel, onPressed: onAction),
        ],
      ),
    );
  }

  Widget _reservationCard(_Reservation r) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.event)),
        title: Text(r.eventName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          '${r.eventType} • ${r.dateLabel}\n${r.venue} • ${r.guests} guests',
        ),
        isThreeLine: true,
        trailing: Text(r.ref, style: Theme.of(context).textTheme.labelSmall),
      ),
    );
  }
}