import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/address_model.dart';

class AddressRepository {
  static const String _prefsKeyAddresses = 'delivery_addresses';

  AddressRepository({required SharedPreferences prefs}) : _prefs = prefs;

  final SharedPreferences _prefs;

  Future<List<DeliveryAddress>> getAddresses() async {
    final raw = _prefs.getString(_prefsKeyAddresses);
    if (raw == null || raw.isEmpty) return <DeliveryAddress>[];

    final decoded = jsonDecode(raw);
    if (decoded is! List) return <DeliveryAddress>[];

    return decoded
        .whereType<Map>()
        .map((e) => DeliveryAddress.fromJson(e.cast<String, dynamic>()))
        .toList();
  }

  Future<void> saveAddresses(List<DeliveryAddress> addresses) async {
    final encoded = jsonEncode(addresses.map((a) => a.toJson()).toList());
    await _prefs.setString(_prefsKeyAddresses, encoded);
  }
}
