// lib/screens/contacts_screen.dart
import 'package:flutter/material.dart';
import '../models/contact.dart';
import '../services/contact_service.dart';


class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final ContactService _service = ContactService();
  late Future<List<Contact>> _contactsFuture;
  List<Contact> _contacts = [];

  @override
  void initState() {
    super.initState();
    _contactsFuture = _loadContacts();
  }

  Future<List<Contact>> _loadContacts() async {
    try {
      _contacts = await _service.getContacts();
      return _contacts;
    } catch (e) {
      throw Exception('تعذر تحميل جهات الاتصال: $e');
    }
  }

  Future<void> _showAddDialog() async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();

    final shouldAdd = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة جهة اتصال'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'الاسم'),
            ),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'الإيميل'),
            ),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'الجوال'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('إضافة'),
          ),
        ],
      ),
    );

    if (shouldAdd != true) return;

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();

    if (name.isEmpty || email.isEmpty || phone.isEmpty) {
      _showMessage('الرجاء تعبئة جميع الحقول');
      return;
    }

    try {
      final newContact = await _service.addContact(
        Contact(name: name, email: email, phone: phone),
      );
      if (!mounted) return;
      setState(() => _contacts.add(newContact));
      _showMessage('تمت إضافة جهة الاتصال');
    } catch (e) {
      if (!mounted) return;
      _showMessage('فشلت الإضافة: $e');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('دفتر جهات الاتصال')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Contact>>(
        future: _contactsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          if (_contacts.isEmpty) {
            return const Center(child: Text('لا يوجد جهات اتصال'));
          }
          return ListView.builder(
            itemCount: _contacts.length,
            itemBuilder: (context, index) {
              final contact = _contacts[index];
              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(contact.name),
                subtitle: Text('${contact.email}\n${contact.phone}'),
                isThreeLine: true,
              );
            },
          );
        },
      ),
    );
  }
}