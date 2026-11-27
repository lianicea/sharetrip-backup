import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/sharetrip_local_store.dart';
import 'driver_portal_page.dart';

class DriverRegistrationPage extends StatefulWidget {
  const DriverRegistrationPage({super.key});
  @override
  State<DriverRegistrationPage> createState() => _DriverRegistrationPageState();
}

class _DriverRegistrationPageState extends State<DriverRegistrationPage> {
  final _key = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _vehicleModel = TextEditingController();
  final _plate = TextEditingController();
  String _vehicleType = 'Shuttle';
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [_name, _email, _phone, _password, _vehicleModel, _plate]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _register() async {
    if (!_key.currentState!.validate()) return;
    setState(() => _saving = true);
    await ShareTripLocalStore.saveDriverProfile({
      'name': _name.text.trim(),
      'email': _email.text.trim(),
      'phone': _phone.text.trim(),
      'vehicleType': _vehicleType,
      'vehicleModel': _vehicleModel.text.trim(),
      'plate': _plate.text.trim(),
    });
    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.pushAndRemoveUntil(context,
      MaterialPageRoute(builder: (_) => const DriverPortalPage()), (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Driver Registration')),
    body: Center(child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: Form(key: _key, child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(Icons.drive_eta_outlined, size: 48, color: AppColors.primary),
          const SizedBox(height: 10),
          const Text('Create your driver profile', textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          const Text('Enter your details and vehicle information.',
            textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 22),
          _input('Full name', _name, validator: _required),
          _input('School email', _email, keyboard: TextInputType.emailAddress,
            validator: (v) => (v == null || !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())) ? 'Enter a valid email.' : null),
          _input('Contact number', _phone, keyboard: TextInputType.phone, validator: _required),
          _input('Password', _password, obscure: true,
            validator: (v) => (v == null || v.length < 8) ? 'Use at least 8 characters.' : null),
          const SizedBox(height: 8),
          const Text('Vehicle type', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: _vehicleType,
            items: const [
              DropdownMenuItem(value: 'Shuttle', child: Text('Shuttle')),
              DropdownMenuItem(value: 'Motorcycle', child: Text('Motorcycle')),
              DropdownMenuItem(value: 'Tricycle', child: Text('Tricycle')),
            ],
            onChanged: (v) => setState(() => _vehicleType = v ?? 'Shuttle'),
          ),
          _input('Vehicle model / description', _vehicleModel, validator: _required),
          _input('Plate number', _plate, validator: _required),
          const SizedBox(height: 16),
          SizedBox(height: 48, child: ElevatedButton(
            onPressed: _saving ? null : _register,
            child: Text(_saving ? 'Saving...' : 'Register as Driver'),
          )),
          const SizedBox(height: 8),
          const Text('Demo note: this saves the driver profile on this device. School identity and driver documents still need server-side verification.',
            textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ],
      )),
    )),
  );

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'This field is required.' : null;

  Widget _input(String label, TextEditingController controller, {
    TextInputType? keyboard, bool obscure = false, String? Function(String?)? validator,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 13),
    child: TextFormField(
      controller: controller, keyboardType: keyboard, obscureText: obscure,
      validator: validator ?? _required,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
    ),
  );
}
