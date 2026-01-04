import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'register_page.dart'; // Import the new pages
import 'dashboard_page.dart';

void main() {
  runApp(const MaterialApp(
    home: LoginPage(),
    debugShowCheckedModeBanner: false,
    title: "Campus Order System",
  ));
}

// YOUR ACTUAL RENDER URL
const String apiUrl = "https://campus-backend-1-jxul.onrender.com";

// --- ACTIVITY 1: LOGIN & REGISTRATION ---
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController userCont = TextEditingController();
  final TextEditingController passCont = TextEditingController();

  Future<void> performAuth(String endpoint) async {
    if (userCont.text.isEmpty || passCont.text.isEmpty) {
      showMsg("Please fill all fields");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("$apiUrl/$endpoint"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": userCont.text, "password": passCont.text}),
      );

      if (response.statusCode == 200) {
        if (endpoint == "login") {
          var data = json.decode(response.body);
          int userId = data['userId'];
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => OrderDashboard(userId: userId, username: userCont.text)),
          );
        } else {
          showMsg("Account Created! You can now Login.");
        }
      } else {
        showMsg("Authentication Failed: ${response.body}");
      }
    } catch (e) {
      showMsg("Connection Error: Make sure your Render backend is awake.");
    }
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: const Text("Campus Login"), centerTitle: true),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Icon(Icons.school, size: 80, color: Colors.blue),
              const SizedBox(height: 20),
              TextField(controller: userCont, decoration: const InputDecoration(labelText: "Username", border: OutlineInputBorder())),
              const SizedBox(height: 15),
              TextField(controller: passCont, decoration: const InputDecoration(labelText: "Password", border: OutlineInputBorder()), obscureText: true),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(onPressed: () => performAuth("login"), child: const Text("LOGIN")),
              ),
              TextButton(onPressed: () => performAuth("register"), child: const Text("Don't have an account? Register Here")),
            ],
          ),
        ),
      ),
    );
  }
}

// --- ACTIVITY 2: ORDER DASHBOARD ---
class OrderDashboard extends StatefulWidget {
  final int userId;
  final String username;
  const OrderDashboard({Key? key, required this.userId, required this.username}) : super(key: key);

  @override
  _OrderDashboardState createState() => _OrderDashboardState();
}

class _OrderDashboardState extends State<OrderDashboard> {
  final TextEditingController itemCont = TextEditingController();

  Future<void> placeOrder() async {
    if (itemCont.text.isEmpty) return;
    await http.post(
      Uri.parse("$apiUrl/add-order"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"userId": widget.userId, "item_name": itemCont.text, "quantity": 1}),
    );
    itemCont.clear();
    setState(() {}); // Refresh the list
  }

  Future<List<dynamic>> fetchOrders() async {
    final res = await http.get(Uri.parse("$apiUrl/orders/${widget.userId}"));
    if (res.statusCode == 200) {
      return json.decode(res.body);
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Welcome, ${widget.username}"), actions: [
        IconButton(icon: const Icon(Icons.logout), onPressed: () => Navigator.pop(context))
      ]),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(child: TextField(controller: itemCont, decoration: const InputDecoration(hintText: "What would you like to order?"))),
                const SizedBox(width: 10),
                ElevatedButton(onPressed: placeOrder, child: const Text("Order")),
              ],
            ),
          ),
          const Divider(),
          const Text("Your Order History", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: fetchOrders(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("No orders found."));

                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    var order = snapshot.data![index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      child: ListTile(
                        leading: const Icon(Icons.shopping_bag, color: Colors.green),
                        title: Text(order['item_name']),
                        subtitle: Text("Date: ${order['order_date']}"),
                        trailing: Text("Qty: ${order['quantity']}"),
                      ),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
