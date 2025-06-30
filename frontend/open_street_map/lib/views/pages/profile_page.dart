import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:easy_localization/easy_localization.dart';

import 'profile_settings_page.dart';
import '/services/auth_service.dart';
import '/services/profile_service.dart';
import 'login.dart';

class ProfilePage extends StatefulWidget {
  final String token;
  final String baseUrl;

  const ProfilePage({required this.token, required this.baseUrl, super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _imageFile;
  Uint8List? _webImage;
  String? _imageUrl;

  String _name = '';
  String _email = '';
  String _phone = '';
  String _vehicle = '';
  bool _isOnline = false;
  bool _statusLoading = false;

  Timer? _locationTimer;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse('${widget.baseUrl}/api/user'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final user = jsonDecode(response.body);
        setState(() {
          _name = user['name'] ?? '';
          _email = user['email'] ?? '';
          _phone = user['phone'] ?? '';
          _vehicle = user['vehicle'] ?? '';
          _isOnline = user['is_online'] ?? false;
          _imageUrl = user['avatar'];
          _nameController.text = _name;
          _emailController.text = _email;
        });

        if (_isOnline) {
          _startLocationUpdates();
        }
      }
    } catch (_) {}
  }

  Future<void> _toggleOnlineStatus(bool value) async {
    setState(() => _statusLoading = true);

    final service = ProfileService(
      baseUrl: widget.baseUrl,
      token: widget.token,
    );

    final success = await service.updateOnlineStatus(value);

    setState(() {
      _statusLoading = false;
      if (success) _isOnline = value;
    });

    if (success && value) {
      await _requestAndSendLocation();
      _startLocationUpdates();
    } else if (success && !value) {
      _locationTimer?.cancel();
      _locationTimer = null;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? (value ? "profile.now_online".tr() : "profile.now_offline".tr())
              : "profile.status_update_failed".tr(),
        ),
      ),
    );
  }

  Future<void> _requestAndSendLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location permission denied')),
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final service = ProfileService(
        baseUrl: widget.baseUrl,
        token: widget.token,
      );

      await service.updateLocation(position.latitude, position.longitude);
    } catch (_) {}
  }

  void _startLocationUpdates() {
    _locationTimer?.cancel();
    _locationTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _requestAndSendLocation();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _locationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageProvider = kIsWeb && _webImage != null
        ? MemoryImage(_webImage!)
        : _imageFile != null
            ? FileImage(_imageFile!)
            : _imageUrl != null
                ? NetworkImage(_imageUrl!)
                : const AssetImage("assets/images/user.png") as ImageProvider;

    return Scaffold(
      appBar: AppBar(title: Text("profile.title".tr())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 36, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: CircleAvatar(radius: 60, backgroundImage: imageProvider),
            ),
            const SizedBox(height: 24),
            Text(_name, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
            Text(_email, style: TextStyle(fontSize: 16, color: theme.colorScheme.onSurface.withOpacity(0.6))),
            const SizedBox(height: 32),
            _buildInfoCard("profile.phone".tr(), _phone, theme),
            const SizedBox(height: 12),
            _buildInfoCard("profile.vehicle".tr(), _vehicle, theme),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("profile.online_status".tr(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                _statusLoading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                    : Switch(
                        value: _isOnline,
                        onChanged: _toggleOnlineStatus,
                        activeColor: Colors.green,
                        inactiveThumbColor: theme.colorScheme.error,
                      ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                final updated = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileSettingsPage(
                      baseUrl: widget.baseUrl,
                      token: widget.token,
                    ),
                  ),
                );
                if (updated == true) _loadUserProfile();
              },
              icon: const Icon(Icons.settings),
              label: Text("profile.edit".tr()),
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                await AuthService.logout(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('profile.logged_out'.tr())),
                );
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.logout),
              label: Text("profile.logout".tr()),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value.isNotEmpty ? value : "-", style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
