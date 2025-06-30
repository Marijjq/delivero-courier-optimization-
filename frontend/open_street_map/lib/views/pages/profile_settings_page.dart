import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:easy_localization/easy_localization.dart';

class ProfileSettingsPage extends StatefulWidget {
  final String baseUrl;
  final String token;

  const ProfileSettingsPage({
    required this.baseUrl,
    required this.token,
    super.key,
  });

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _vehicleController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _loading = true;
  File? _imageFile;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final res = await http.get(
        Uri.parse('${widget.baseUrl}/api/user'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (res.statusCode == 200) {
        final user = jsonDecode(res.body);
        setState(() {
          _nameController.text = user['name'] ?? '';
          _emailController.text = user['email'] ?? '';
          _phoneController.text = user['phone'] ?? '';
          _vehicleController.text = user['vehicle'] ?? '';
          _avatarUrl = user['avatar'] != null
              ? '${widget.baseUrl}/storage/${user['avatar']}'
              : null;
          _loading = false;
        });
      } else {
        throw Exception('Failed to load user');
      }
    } catch (e) {
      debugPrint('Error loading user: $e');
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
        _avatarUrl = null;
      });
    }
  }

  Future<void> _save() async {
    final uri = Uri.parse('${widget.baseUrl}/api/user');
    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer ${widget.token}';
    request.fields['_method'] = 'PUT';

    request.fields['name'] = _nameController.text;
    request.fields['email'] = _emailController.text;
    request.fields['phone'] = _phoneController.text;
    request.fields['vehicle'] = _vehicleController.text;

    if (_newPasswordController.text.isNotEmpty) {
      request.fields['password'] = _newPasswordController.text;
      request.fields['password_confirmation'] = _confirmPasswordController.text;
    }

    if (_imageFile != null) {
      final file = await http.MultipartFile.fromPath(
        'avatar',
        _imageFile!.path,
        contentType: MediaType('image', 'jpeg'),
      );
      request.files.add(file);
    }

    try {
      final response = await request.send();
      final resBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("settings.updated_success".tr())),
        );
        Navigator.pop(context, true);
      } else {
        debugPrint('Update failed: $resBody');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "settings.failed".tr(args: [jsonDecode(resBody)['message'] ?? ""]),
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Update error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text('settings.title'.tr())),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 55,
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!)
                          : (_avatarUrl != null
                              ? NetworkImage(_avatarUrl!)
                              : const AssetImage('assets/images/user.png'))
                              as ImageProvider,
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: CircleAvatar(
                          backgroundColor: theme.colorScheme.primary,
                          radius: 16,
                          child: const Icon(
                            Icons.edit,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildInput("profile.name".tr(), _nameController, Icons.person),
                  const SizedBox(height: 15),
                  _buildInput("profile.email".tr(), _emailController, Icons.email, TextInputType.emailAddress),
                  const SizedBox(height: 15),
                  _buildInput("profile.phone".tr(), _phoneController, Icons.phone, TextInputType.phone),
                  const SizedBox(height: 15),
                  _buildInput("profile.vehicle".tr(), _vehicleController, Icons.directions_bike),
                  const Divider(height: 40),
                  Text(
                    "settings.change_password".tr(),
                    style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.secondary),
                  ),
                  const SizedBox(height: 15),
                  _buildInput("settings.new_password".tr(), _newPasswordController, Icons.lock, TextInputType.visiblePassword, true),
                  const SizedBox(height: 15),
                  _buildInput("settings.confirm_password".tr(), _confirmPasswordController, Icons.lock, TextInputType.visiblePassword, true),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.save),
                    label: Text("settings.save".tr()),
                    style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInput(
    String label,
    TextEditingController controller,
    IconData icon, [
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  ]) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
    );
  }
}
