import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WeatherCommunityScreen extends StatefulWidget {
  final String location;
  const WeatherCommunityScreen({Key? key, required this.location})
    : super(key: key);

  @override
  State<WeatherCommunityScreen> createState() => _WeatherCommunityScreenState();
}

class _WeatherCommunityScreenState extends State<WeatherCommunityScreen> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> reports = [];
  late String location;

  @override
  void initState() {
    super.initState();
    location = widget.location;
    _loadReports();
  }

  Future<void> _loadReports() async {
    final querySnapshot =
        await _firestore
            .collection('weatherReports')
            .orderBy('timestamp', descending: true)
            .get();

    setState(() {
      reports = querySnapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  Future<void> _submitReport() async {
    if (_controller.text.isEmpty) return;

    await _firestore.collection('weatherReports').add({
      'message': _controller.text,
      'timestamp': Timestamp.now(),
      'location': location,
    });

    _controller.clear();
    await _loadReports();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Report submitted')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Community Weather Reports')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: "What's the weather like?",
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _submitReport, child: const Text('Send')),
            const Divider(height: 30),
            Expanded(
              child: ListView.builder(
                itemCount: reports.length,
                itemBuilder: (context, index) {
                  final report = reports[index];
                  return ListTile(
                    title: Text(report['message'] ?? ''),
                    subtitle: Text(
                      '${report['location'] ?? 'Unknown Location'} - ${(report['timestamp'] as Timestamp).toDate().toString().split('.')[0]}',
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
