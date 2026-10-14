// lib/service/contact_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/contact.dart';



class ContactService {
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com/users';

  Future<List<Contact>> getContacts() async {
    final response = await http.get(Uri.parse(_baseUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Contact.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load contacts: ${response.statusCode}');
    }
  }

  Future<Contact> addContact(Contact contact) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(contact.toJson()),
    );

    if (response.statusCode == 201) {
      return Contact.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to add contact: ${response.statusCode}');
    }
  }
}