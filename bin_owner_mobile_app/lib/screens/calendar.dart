import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:bin_owner_mobile_app/theme/colors.dart';
import 'package:bin_owner_mobile_app/services/notification_service.dart';
import 'package:intl/intl.dart';

class CollectionEvent {
  final String type;
  final String time;
  final List<String> bins;

  CollectionEvent({required this.type, required this.time, required this.bins});
}

class CollectionCalendarScreen extends StatefulWidget {
  const CollectionCalendarScreen({super.key});

  @override
  State<CollectionCalendarScreen> createState() => _CollectionCalendarScreenState();
}

class _CollectionCalendarScreenState extends State<CollectionCalendarScreen> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late CalendarFormat _calendarFormat;

  // Events map: Date -> List of Events
  Map<DateTime, List<CollectionEvent>> _events = {};
  bool _isLoading = true;
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = _focusedDay;
    _calendarFormat = CalendarFormat.month;
    _loadRealEvents();
  }

  // ✅ FETCH REAL DATA FROM BACKEND
  Future<void> _loadRealEvents() async {
    setState(() => _isLoading = true);

    try {
      // 1. Fetch all notifications from backend
      final rawNotifications = await _notificationService.fetchNotifications();

      Map<DateTime, List<CollectionEvent>> loadedEvents = {};

      for (var notif in rawNotifications) {
        // 2. Filter only for 'COLLECTION_DATE' types
        if (notif['type'] == 'COLLECTION_DATE') {

          // 3. Extract Date from Metadata or CreatedAt
          // Backend saves it in metadata: { "collection_date": "2025-12-05" }
          String? dateStr = notif['metadata']?['collection_date'];

          DateTime eventDate;
          if (dateStr != null) {
            eventDate = DateTime.parse(dateStr);
          } else {
            // Fallback: use the notification creation time
            eventDate = DateTime.parse(notif['createdAt']);
          }

          // Normalize date (remove time part) for the Calendar key
          DateTime normalizedDate = DateTime.utc(eventDate.year, eventDate.month, eventDate.day);

          // 4. Create Event Object
          final event = CollectionEvent(
            type: notif['title'] ?? 'Collection',
            time: DateFormat('hh:mm a').format(eventDate), // Format time nicely
            bins: [notif['binId'] ?? 'Bin'],
          );

          if (loadedEvents[normalizedDate] == null) {
            loadedEvents[normalizedDate] = [];
          }
          loadedEvents[normalizedDate]!.add(event);
        }
      }

      if (mounted) {
        setState(() {
          _events = loadedEvents;
          _isLoading = false;
        });
      }

    } catch (e) {
      print("Error loading calendar events: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<CollectionEvent> _getEventsForDay(DateTime day) {
    // Normalize day to UTC to match keys
    final normalizedDay = DateTime.utc(day.year, day.month, day.day);
    return _events[normalizedDay] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Collection Calendar', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadRealEvents,
          ),
        ],
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
        : Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: _calendarFormat,

            // ✅ Connect Data Here
            eventLoader: _getEventsForDay,

            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() => _calendarFormat = format);
            },
            onPageChanged: (focusedDay) => _focusedDay = focusedDay,

            // Styles
            calendarStyle: CalendarStyle(
              defaultTextStyle: const TextStyle(color: Colors.white),
              weekendTextStyle: const TextStyle(color: Colors.white70),
              selectedDecoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Colors.grey[800],
                shape: BoxShape.circle,
              ),
              markerDecoration: const BoxDecoration(
                color: AppColors.secondary, // Dot color
                shape: BoxShape.circle,
              ),
              outsideDaysVisible: false,
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              leftChevronIcon: const Icon(Icons.chevron_left, color: Colors.white),
              rightChevronIcon: const Icon(Icons.chevron_right, color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.grey),
          Expanded(child: _buildEventList()),
        ],
      ),
    );
  }

  Widget _buildEventList() {
    final events = _getEventsForDay(_selectedDay);

    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 50, color: Colors.grey[700]),
            const SizedBox(height: 10),
            Text(
              'No collections scheduled for this day',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: const Color(0xFF2C2C2C),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _getEventColor(event.type).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(_getEventIcon(event.type), color: _getEventColor(event.type)),
            ),
            title: Text(
              event.type,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(event.time, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.delete_outline, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('Bins: ${event.bins.join(', ')}', style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getEventColor(String type) {
    if (type.contains('Recyclables')) return Colors.blueAccent;
    if (type.contains('Organic')) return Colors.greenAccent;
    return AppColors.primary;
  }

  IconData _getEventIcon(String type) {
    if (type.contains('Recyclables')) return Icons.recycling;
    if (type.contains('Organic')) return Icons.eco;
    return Icons.local_shipping;
  }
}