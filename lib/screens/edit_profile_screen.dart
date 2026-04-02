import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, String> profileData;
  const EditProfileScreen({super.key, required this.profileData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late Map<String, TextEditingController> _controllers;

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

  void _save() {
    final updated = _controllers.map((k, c) => MapEntry(k, c.text.trim()));
    Navigator.pop(context, updated);
  }

  void _cancel() => Navigator.pop(context);

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
          child: Column(
            children: [
              // AppBar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _cancel,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
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
                      const Text(
                        'PROFILE',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Avatar
                      Center(
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: const Icon(Icons.person, size: 50, color: Colors.grey),
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

                      const SizedBox(height: 28),

                      // Save / Cancel buttons
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: _save,
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 67, 188, 140),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.white, width: 1.5),
                                ),
                                alignment: Alignment.center,
                                child: const Text(
                                  'SAVE',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: _cancel,
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.pink.shade100,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.white, width: 1.5),
                                ),
                                alignment: Alignment.center,
                                child: const Text(
                                  'CANCEL',
                                  style: TextStyle(
                                    color: Color(0xFF1A3A2E),
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 4),
      child: Text(
        text,
        style: const TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildEditField(TextEditingController controller,
      {TextInputType? keyboardType}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 13, color: Color(0xFF1A3A2E)),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }
}
