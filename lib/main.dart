import 'dart:convert';
import 'dart:typed_data'; // Julio Emanuel Alberto Carrillo Núñez 2021-0182
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Julio Emanuel Alberto Carrillo Núñez 2021-0182

void main() {
  runApp(ElectionApp());
}

class ElectionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Election App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: EventsPage(),
    );
  }
}

class EventsPage extends StatefulWidget {
  @override
  _EventsPageState createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  List<Event> events = [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Eventos'),
      ),
      body: ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(events[index].title),
            subtitle: Text(events[index].date.toString()),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventDetailsPage(event: events[index]),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEventPage(onEventAdded: _addEvent),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _addEvent(Event event) {
    setState(() {
      events.add(event);
      _saveEvents();
    });
  }

  Future<void> _loadEvents() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? eventsData = prefs.getStringList('events');

    if (eventsData != null) {
      setState(() {
        events = eventsData
            .map((eventJson) => Event.fromJson(jsonDecode(eventJson)))
            .toList();
      });
    }
  }

  Future<void> _saveEvents() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> eventsData =
        events.map((event) => jsonEncode(event.toJson())).toList();
    prefs.setStringList('events', eventsData);
  }
}

class EventDetailsPage extends StatelessWidget {
  final Event event;

  EventDetailsPage({required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles del Evento'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              event.title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              event.date.toString(),
              style: TextStyle(fontSize: 18),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              event.description,
              style: TextStyle(fontSize: 18),
            ),
          ),
          if (event.photo != null)
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Image.memory(
                event.photo!,
                fit: BoxFit.cover,
                height: 200,
              ),
            ),
          if (event.audio != null)
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextButton(
                onPressed: () {},
                child: Text('Reproducir Audio'),
              ),
            ),
        ],
      ),
    );
  }
}

class AddEventPage extends StatefulWidget {
  final Function(Event) onEventAdded;

  AddEventPage({required this.onEventAdded});

  @override
  _AddEventPageState createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar Evento'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Título'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Descripción'),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                _selectDate(context);
              },
              child: Text('Seleccionar Fecha'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                widget.onEventAdded(Event(
                  title: _titleController.text,
                  description: _descriptionController.text,
                  date: _selectedDate,
                ));
                Navigator.pop(context);
              },
              child: Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
      });
  }
}

class Event {
  final String title;
  final DateTime date;
  final String description;
  final Uint8List? photo;
  final Uint8List? audio;

  Event({
    required this.title,
    required this.date,
    required this.description,
    this.photo,
    this.audio,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'date': date.toIso8601String(),
      'description': description,
      'photo': photo != null ? base64Encode(photo!) : null,
      'audio': audio != null ? base64Encode(audio!) : null,
    };
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      title: json['title'],
      date: DateTime.parse(json['date']),
      description: json['description'],
      photo: json['photo'] != null ? base64Decode(json['photo']) : null,
      audio: json['audio'] != null ? base64Decode(json['audio']) : null,
    );
  }
}
