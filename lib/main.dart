import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryHomePage extends StatefulWidget {
  InventoryHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _InventoryHomePageState createState() => _InventoryHomePageState();
}

class _InventoryHomePageState extends State<InventoryHomePage> {
  late FirebaseFirestore _firestore;

  @override
  void initState() {
    super.initState();
    _firestore = FirebaseFirestore.instance;
  }

  // Fetch inventory data
  Stream<QuerySnapshot> _getInventoryStream() {
    return _firestore.collection('inventory').snapshots();
  }

  // Delete an inventory item
  Future<void> _deleteItem(String itemId) async {
    await _firestore.collection('inventory').doc(itemId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getInventoryStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          var inventoryItems = snapshot.data!.docs;
          return ListView.builder(
            itemCount: inventoryItems.length,
            itemBuilder: (context, index) {
              var item = inventoryItems[index];
              return ListTile(
                title: Text(item['name']),
                subtitle: Text(
                  'Quantity: ${item['quantity']} | Price: \$${item['price']}',
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _deleteItem(item.id),
                ),
                onTap: () {
                  // Navigate to update page (to be implemented)
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to Add Item screen (to be implemented)
        },
        tooltip: 'Add Item',
        child: Icon(Icons.add),
      ),
    );
  }
}

// Add Inventory Item
class AddInventoryPage extends StatefulWidget {
  const AddInventoryPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddInventoryPageState createState() => _AddInventoryPageState();
}

class _AddInventoryPageState extends State<AddInventoryPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a new item to Firestore
  Future<void> _addItem() async {
    await _firestore.collection('inventory').add({
      'name': _nameController.text,
      'quantity': int.parse(_quantityController.text),
      'price': double.parse(_priceController.text),
    });
    Navigator.pop(context); // Go back after adding item
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Inventory Item')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Item Name'),
            ),
            TextField(
              controller: _quantityController,
              decoration: InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _priceController,
              decoration: InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _addItem, child: Text('Add Item')),
          ],
        ),
      ),
    );
  }
}
