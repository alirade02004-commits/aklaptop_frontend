import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DashboardPage extends StatefulWidget {
  final int userId;
  final String username;
  const DashboardPage({Key? key, required this.userId, required this.username}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final itemCont = TextEditingController();
  final String apiUrl = "https://campus-backend-1-jxul.onrender.com";

  Future<void> placeOrder() async {
    if (itemCont.text.isEmpty) return;
    await http.post(
      Uri.parse("$apiUrl/add-order"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userId": widget.userId,
        "item_name": itemCont.text,
        "quantity": 1
      }),
    );
    itemCont.clear();
    setState(() {}); // Refresh list
  }

  Future<List<dynamic>> getOrders() async {
    final res = await http.get(Uri.parse("$apiUrl/orders/${widget.userId}"));
    return json.decode(res.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dashboard: ${widget.username}"), actions: [
        IconButton(icon: const Icon(Icons.exit_to_app), onPressed: () => Navigator.pop(context))
      ]),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(child: TextField(controller: itemCont, decoration: const InputDecoration(hintText: "Enter item to order..."))),
                IconButton(icon: const Icon(Icons.shopping_cart), onPressed: placeOrder)
              ],
            ),
          ),
          const Text("Your Orders Table", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: getOrders(),
              builder: (context, snap) {
                if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                if (snap.data!.isEmpty) return const Center(child: Text("No orders yet."));
                return ListView.builder(
                  itemCount: snap.data!.length,
                  itemBuilder: (context, i) => ListTile(
                    leading: const Icon(Icons.check_circle, color: Colors.green),
                    title: Text(snap.data![i]['item_name']),
                    subtitle: Text("Date: ${snap.data![i]['order_date']}"),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
