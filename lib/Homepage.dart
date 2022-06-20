// main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // text fields' controllers
  final TextEditingController _nameController = TextEditingController();

  final CollectionReference _users =
  FirebaseFirestore.instance.collection('users');

  // This function is triggered when the floatting button or one of the edit buttons is pressed
  // Adding a product if no documentSnapshot is passed
  // If documentSnapshot != null then update an existing product
  Future<void> _createOrUpdate([DocumentSnapshot? documentSnapshot]) async {
    String action = 'create';
    if (documentSnapshot != null) {
      action = 'update';
      _nameController.text = documentSnapshot['name'];
      // _priceController.text = documentSnapshot['price'].toString();
    }

    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.only(
                top: 10,
                left: 10,
                right: 10,
                // prevent the soft keyboard from covering text fields
                bottom: MediaQuery
                    .of(ctx)
                    .viewInsets
                    .bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),

                const SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  child: Text(action == 'create' ? 'Create' : 'Update'),
                  onPressed: () async {
                    final String? name = _nameController.text;


                    if (name != null ) {
                      if (action == 'create') {
                        // Persist a new product to Firestore
                        await _users.add({"name": name});
                      }

                      if (action == 'update') {
                        // Update the product
                        await _users
                            .doc(documentSnapshot!.id)
                            .update({"name": name});
                      }

                      // Clear the text fields
                      _nameController.text = '';

                      // Hide the bottom sheet
                      Navigator.of(context).pop();
                    }
                  },
                )
              ],
            ),
          );
        });
  }

  // Deleteing a product by id
  Future<void> _deleteProduct(String productId) async {
    await _users.doc(productId).delete();
    print("inside");

    // Show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('You have successfully deleted a text')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('my project'),

        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _createOrUpdate(),


          ),
        ],
        shape: ContinuousRectangleBorder(),

      ),
      // Using StreamBuilder to display all products from Firestore in real-time
      body: StreamBuilder(
        stream: _users.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return ListView.builder(
              itemCount: streamSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot =
                streamSnapshot.data!.docs[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(documentSnapshot['name']),
                    // subtitle: Text(documentSnapshot['price'].toString()),
                    trailing: SizedBox(
                      width: 180,
                      child: Row(
                        children: [
                          // Press this button to edit a single product
                          RaisedButton(

                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              child:Text(
                                  "Update"),
                              textColor: Colors.red,
                              onPressed: ()  =>
                                  _createOrUpdate(documentSnapshot)),
                          RaisedButton(

                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              child:Text(
                                  "Delete"),
                              textColor: Colors.red,
                              onPressed: () async{
                                print("Working");
                                await _deleteProduct(documentSnapshot.id);
                              }

                            // IconButton(
                            //     icon: const Icon(Icons.edit),
                            //     onPressed: () =>
                            //         _createOrUpdate(documentSnapshot)),
                            // This icon button is used to delete a single product
                            // IconButton(
                            //     icon: const Icon(Icons.delete),
                            //     onPressed: () =>
                            //         _deleteProduct(documentSnapshot.id)),
                          )],
                      ),
                    ),
                  ),
                );
              },
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      // Add new product

    );
  }
}

