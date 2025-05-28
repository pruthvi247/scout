import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:scout/mocks/mock_activities.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scout/handlers/utils/phone_validator.dart';

enum ServiceType {
  treePlantation,
  foodDistribution,
  bloodDonation,
  education,
  other
}

const serviceTypeLabels = {
  ServiceType.treePlantation: 'Tree Plantation',
  ServiceType.foodDistribution: 'Food Distribution',
  ServiceType.bloodDonation: 'Blood Donation',
  ServiceType.education: 'Education',
  ServiceType.other: 'Other',
};

class AddActivityScreen extends StatefulWidget {
  const AddActivityScreen({super.key});

  @override
  State<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _reviewerController = TextEditingController();
  final TextEditingController _commentsController = TextEditingController();
  ServiceType? _selectedServiceType;
  DateTime _selectedDateTime = DateTime.now();
  List<File> _images = [];
  bool _useCurrentLocation = false;
  bool _isLoadingLocation = false;
  String? _locationError;

  Future<void> _pickImages() async {
    // Request permission for photos/camera
    final status = await Permission.photos.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Permission required to access gallery/photos.')),
      );
      return;
    }
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage();
    if (picked != null && picked.length <= 6) {
      setState(() {
        _images = picked.map((x) => File(x.path)).toList();
      });
    } else if (picked.length > 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can select up to 6 images.')),
      );
    }
  }

  Future<void> _getCurrentLocation() async {
    // Request location permission
    final status = await Permission.locationWhenInUse.request();
    if (!status.isGranted) {
      setState(() {
        _locationError = 'Location permission is required.';
        _isLoadingLocation = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Permission required to access location.')),
      );
      return;
    }
    setState(() {
      _isLoadingLocation = true;
      _locationError = null;
    });
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationError = 'Location services are disabled.';
          _isLoadingLocation = false;
        });
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationError = 'Location permissions are denied.';
            _isLoadingLocation = false;
          });
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationError = 'Location permissions are permanently denied.';
          _isLoadingLocation = false;
        });
        return;
      }
      final pos = await Geolocator.getCurrentPosition();
      setState(() {
        _addressController.text = 'Lat: ${pos.latitude}, Lng: ${pos.longitude}';
        _isLoadingLocation = false;
      });
    } catch (e) {
      setState(() {
        _locationError = 'Failed to get location.';
        _isLoadingLocation = false;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // Add to local mock list (in real app, call backend)
      mockActivities.insert(
        0,
        Activity(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _titleController.text,
          dateTime: _selectedDateTime,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Activity added!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Activity')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => v == null || v.isEmpty ? 'Enter title' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ServiceType>(
                value: _selectedServiceType,
                items: ServiceType.values
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(serviceTypeLabels[e]!),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => _selectedServiceType = val),
                decoration: const InputDecoration(labelText: 'Service Type'),
                validator: (v) => v == null ? 'Select service type' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                        'Date/Time: ${DateFormat('yyyy-MM-dd HH:mm').format(_selectedDateTime)}'),
                  ),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDateTime,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        final time = await showTimePicker(
                          context: context,
                          initialTime:
                              TimeOfDay.fromDateTime(_selectedDateTime),
                        );
                        if (time != null) {
                          setState(() {
                            _selectedDateTime = DateTime(
                              picked.year,
                              picked.month,
                              picked.day,
                              time.hour,
                              time.minute,
                            );
                          });
                        }
                      }
                    },
                    child: const Text('Edit'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Switch(
                    value: _useCurrentLocation,
                    onChanged: (val) async {
                      setState(() => _useCurrentLocation = val);
                      if (val) {
                        await _getCurrentLocation();
                      } else {
                        _addressController.clear();
                      }
                    },
                  ),
                  const Text('Use Current Location'),
                ],
              ),
              if (_isLoadingLocation) const LinearProgressIndicator(),
              if (_locationError != null)
                Text(_locationError!,
                    style: const TextStyle(color: Colors.red)),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                enabled: !_useCurrentLocation,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter address' : null,
              ),
              const SizedBox(height: 16),
              Text('Photos (4-6):'),
              Wrap(
                spacing: 8,
                children: [
                  ..._images.map((img) => Image.file(img,
                      width: 60, height: 60, fit: BoxFit.cover)),
                  if (_images.length < 6)
                    IconButton(
                      icon: const Icon(Icons.add_a_photo),
                      onPressed: _pickImages,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _reviewerController,
                decoration:
                    const InputDecoration(labelText: 'Reviewer Phone Number'),
                keyboardType: TextInputType.phone,
                maxLength: 10,
                validator: validateIndianPhone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _commentsController,
                decoration: const InputDecoration(labelText: 'Comments'),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
