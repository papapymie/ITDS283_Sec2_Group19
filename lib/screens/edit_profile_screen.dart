import 'dart:convert';
import 'dart:io'; 
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart'; 
import 'package:firebase_storage/firebase_storage.dart'; 

class EditProfileScreen extends StatefulWidget {
  final Map<String, String> profileData;
  const EditProfileScreen({super.key, required this.profileData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>(); 
  late Map<String, TextEditingController> _controllers;
  
  File? _imageFile; // เก็บรูปที่เลือก
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _controllers = {
      'name':        TextEditingController(text: widget.profileData['name']),
      'phone':       TextEditingController(text: widget.profileData['phone']),
      'houseNo':     TextEditingController(text: widget.profileData['houseNo']),
      'moo':         TextEditingController(text: widget.profileData['moo']),
      'village':     TextEditingController(text: widget.profileData['village']),
      'room':        TextEditingController(text: widget.profileData['room']),
      'floor':       TextEditingController(text: widget.profileData['floor']),
      'soi':         TextEditingController(text: widget.profileData['soi']),
      'road':        TextEditingController(text: widget.profileData['road']),
      'province':    TextEditingController(text: widget.profileData['province']),
      'district':    TextEditingController(text: widget.profileData['district']),
      'subdistrict': TextEditingController(text: widget.profileData['subdistrict']),
      'postcode':    TextEditingController(text: widget.profileData['postcode']),
    };
  }

  @override
  void dispose() {
    _controllers.forEach((_, c) => c.dispose());
    super.dispose();
  }

  // ฟังก์ชันเลือกรูปภาพ
  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('เลือกจากแกลลอรี่'),
              onTap: () async {
                final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) setState(() => _imageFile = File(pickedFile.path));
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('ถ่ายรูปจากกล้อง'),
              onTap: () async {
                final pickedFile = await _picker.pickImage(source: ImageSource.camera);
                if (pickedFile != null) setState(() => _imageFile = File(pickedFile.path));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }


Future<void> _save() async {
  if (!_formKey.currentState!.validate()) return;

  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator()));

  try {
    String? base64Image;

    // ถ้ามีการเลือกรูปใหม่ ให้แปลงรูปเป็น Base64
    if (_imageFile != null) {
      List<int> imageBytes = await _imageFile!.readAsBytes();
      base64Image = base64Encode(imageBytes);
    }

    final updated = _controllers.map((k, c) => MapEntry(k, c.text.trim()));
    
    // ถ้ามีรูปใหม่ให้ใส่เข้าไป ถ้าไม่มีให้ใช้รูปเดิม 
    if (base64Image != null) {
      updated['profile_image'] = base64Image;
    } else {
      updated['profile_image'] = widget.profileData['profile_image'] ?? '';
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set(updated, SetOptions(merge: true));

    if (mounted) {
      Navigator.pop(context); // ปิด loading
      Navigator.pop(context, updated); // กลับหน้า Profile
    }
  } catch (e) {
    Navigator.pop(context);
    print("Error: $e");
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF7EC8A4), Color(0xFF5BB89A), Color(0xFF3A9E82)],
          ),
        ),
        child: SafeArea(
          child: Form( 
            key: _formKey,
            child: Column(
              children: [
                // Header / Back Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                          child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('PROFILE', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 2)),
                        const SizedBox(height: 16),

                        // Avatar Section - กดเพื่อเปลี่ยนรูป
                        Center(
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Stack(
                              children: [
                                Container(
                                  width: 100, height: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 3),
                                    image: _imageFile != null 
                                        ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover)
                                        : (widget.profileData['profile_image'] != null && widget.profileData['profile_image']!.isNotEmpty
                                            ? DecorationImage(image: NetworkImage(widget.profileData['profile_image']!), fit: BoxFit.cover)
                                            : null),
                                  ),
                                  child: _imageFile == null ? const Icon(Icons.person, size: 60, color: Colors.grey) : null,
                                ),
                                Positioned(
                                  bottom: 0, right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                    child: const Icon(Icons.camera_alt, size: 18, color: Colors.teal),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        _buildLabel('ชื่อ - นามสกุล'),
                        _buildEditField(_controllers['name']!),

                        _buildLabel('เบอร์โทรศัพท์'),
                        _buildEditField(_controllers['phone']!, keyboardType: TextInputType.phone),

                        Row(children: [
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            _buildLabel('บ้านเลขที่'),
                            _buildEditField(_controllers['houseNo']!),
                          ])),
                          const SizedBox(width: 10),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            _buildLabel('หมู่'),
                            _buildEditField(_controllers['moo']!),
                          ])),
                        ]),

                        Row(children: [
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            _buildLabel('หมู่บ้าน'),
                            _buildEditField(_controllers['village']!),
                          ])),
                          const SizedBox(width: 10),
                          SizedBox(width: 70, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            _buildLabel('ห้อง'),
                            _buildEditField(_controllers['room']!),
                          ])),
                          const SizedBox(width: 10),
                          SizedBox(width: 70, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            _buildLabel('ชั้น'),
                            _buildEditField(_controllers['floor']!),
                          ])),
                        ]),

                        Row(children: [
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            _buildLabel('ซอย'),
                            _buildEditField(_controllers['soi']!),
                          ])),
                          const SizedBox(width: 10),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            _buildLabel('ถนน'),
                            _buildEditField(_controllers['road']!),
                          ])),
                        ]),

                        Row(children: [
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            _buildLabel('จังหวัด'),
                            _buildEditField(_controllers['province']!),
                          ])),
                          const SizedBox(width: 10),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            _buildLabel('อำเภอ'),
                            _buildEditField(_controllers['district']!),
                          ])),
                        ]),

                        Row(children: [
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            _buildLabel('ตำบล'),
                            _buildEditField(_controllers['subdistrict']!),
                          ])),
                          const SizedBox(width: 10),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            _buildLabel('รหัสไปรษณีย์'),
                            _buildEditField(_controllers['postcode']!, keyboardType: TextInputType.number),
                          ])),
                        ]),

                        const SizedBox(height: 32),

                        // Buttons
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _save,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(255, 67, 188, 140),
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(double.infinity, 48),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: Colors.white)),
                                ),
                                child: const Text('SAVE', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.5)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.pink.shade100,
                                  foregroundColor: const Color(0xFF1A3A2E),
                                  minimumSize: const Size(double.infinity, 48),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: Colors.white)),
                                ),
                                child: const Text('CANCEL', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.5)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 4),
      child: Text(text, style: const TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w600)),
    );
  }

  // ปรับแก้ตรงนี้ให้เป็น TextFormField เพื่อใช้ Validator ได้
  Widget _buildEditField(TextEditingController controller, {TextInputType? keyboardType}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 13, color: Color(0xFF1A3A2E)),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          errorStyle: TextStyle(height: 0), // ซ่อนตัวอักษร Error เพื่อความสวยงาม (เพราะเราโชว์ SnackBar แล้ว)
        ),
        // ฟังก์ชันเช็คว่าห้ามว่าง
        validator: (value) {
          if (value == null || value.trim().isEmpty) return '';
          return null;
        },
      ),
    );
  }
}