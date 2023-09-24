import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(useMaterial3: true, primarySwatch: Colors.blue),
      home: const MyHomePage(),
      routes: {"/new-contact": (context) => const NewContactView()},
    );
  }
}

class Contact {
  final String name;
  final String id;

  Contact({
    required this.name,
  }) : id = const Uuid().v4();
}

class ContactBook extends ValueNotifier<List<Contact>> {
  // singleton starts
  ContactBook._sharedInstance() : super([]);
  static final ContactBook _shared = ContactBook._sharedInstance();
  factory ContactBook() => _shared;
  // singleton ends

  // value

  int get length => value.length;

  void add({required Contact contact}) {
    final contacts = value;
    contacts.add(contact);
    notifyListeners();
    // or
    // value.add(contact)
    //notifyListeners()
  }

  void remove({required Contact contact}) {
    final contacts = value;
    if (contacts.contains(contact)) {
      contacts.remove(contact);
      notifyListeners();
    }
  }

  Contact? contact({required int atIndex}) =>
      value.length > atIndex ? value[atIndex] : null;
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Home Page'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            // await Navigator.pushNamed(context, "/new-contact");
            Navigator.of(context).pushNamed("/new-contact");
          },
          child: const Icon(Icons.add),
        ),
        body: ValueListenableBuilder(
          valueListenable: ContactBook(),
          builder: (contact, value, child) {
            final contacts = value;
            return ListView.builder(
                itemCount: contacts.length,
                itemBuilder: (context, index) {
                  final contact = contacts[index];
                  return Dismissible(
                    onDismissed: (direction) {
                      ContactBook().remove(contact: contact);
                    },
                    key: ValueKey(contact.id),
                    child: Material(
                      color: Colors.white,
                      elevation: 6.0,
                      child: ListTile(
                        title: Text(contact.name),
                      ),
                    ),
                  );
                });
          },
        ));
  }
}

class NewContactView extends StatefulWidget {
  const NewContactView({super.key});

  @override
  State<NewContactView> createState() => _NewContactViewState();
}

class _NewContactViewState extends State<NewContactView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Contact'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
                hintText: 'Enter a new contact name here....'),
          ),
          TextButton(
              onPressed: () {
                final contact = Contact(name: _controller.text);
                ContactBook().add(contact: contact);
                Navigator.of(context).pop();
              },
              child: const Text('Add Contact'))
        ],
      ),
    );
  }
}
