import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:navysync/models/event.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Event> events = [
    Event(
      id: "1",
      title: "Meeting with team",
      description: "Discuss project updates and next steps",
      date: DateTime.now(),
      location: "Conference Room A",
      creatorId: "12345",
    ),
    Event(
      id: "1",
      title: "Meeting with team",
      description: "Discuss project updates and next steps",
      date: DateTime.now(),
      location: "Conference Room A",
      creatorId: "12345",
    ),
    Event(
      id: "1",
      title: "Meeting with team",
      description: "Discuss project updates and next steps",
      date: DateTime.now(),
      location: "Conference Room A",
      creatorId: "12345",
    ),
    Event(
      id: "1",
      title: "Meeting with team",
      description: "Discuss project updates and next steps",
      date: DateTime.now(),
      location: "Conference Room A",
      creatorId: "12345",
    ),
  ];

  Widget _buildEventCard(Event event) {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        children: [
          Text(event.title),
          Text(event.description),
          Text(event.date.toString()),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text("Dashboard"),
            actions: [
              IconButton(
                icon: const Icon(Icons.calendar_month),
                onPressed: () {},
              ),
              IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
            ],
          ),

          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              return _buildEventCard(events[index]);
            }, childCount: events.length),
          ),
        ],
      ),
    );
  }
}
