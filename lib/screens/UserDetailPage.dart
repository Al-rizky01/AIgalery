import 'dart:io';
import 'package:aigalery1/widgets/app_bbn.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class UserDetailPage extends StatefulWidget {
  final String userId;

  const UserDetailPage({Key? key, required this.userId}) : super(key: key);

  @override
  _UserDetailPageState createState() => _UserDetailPageState();
}



class _UserDetailPageState extends State<UserDetailPage> {
  Map<String, dynamic>? userData;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();
  XFile? _newImage;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();
      if (doc.exists) {
        setState(() {
          userData = doc.data();
        });
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    }
  }

  Future<void> _changeProfilePicture() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() {
      _isLoading = true;
      _newImage = pickedFile;
    });

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_pictures/${widget.userId}.jpg');
      await storageRef.putFile(File(_newImage!.path));
      final downloadUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update({'profilePicture': downloadUrl});

      setState(() {
        _isLoading = false;
        userData?['profilePicture'] = downloadUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile picture updated successfully')),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile picture: $e')),
      );
    }
  }

  Future<void> _changeUsername() async {
    final TextEditingController usernameController = TextEditingController(
      text: userData?['username'],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Username'),
          content: TextFormField(
            controller: usernameController,
            decoration: const InputDecoration(
              labelText: 'New Username',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (usernameController.text.isNotEmpty) {
                  try {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(widget.userId)
                        .update({'username': usernameController.text});

                    setState(() {
                      userData?['username'] = usernameController.text;
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Username updated successfully')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to update username: $e')),
                    );
                  }
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _changeBirthdate() async {
    DateTime? selectedDate = userData?['birthdate'] is Timestamp
        ? (userData?['birthdate'] as Timestamp).toDate()
        : DateTime.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .update({'birthdate': pickedDate});

        setState(() {
          userData?['birthdate'] = pickedDate;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Birthdate updated successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update birthdate: $e')),
        );
      }
    }
  }

Future<void> _changeDescription() async {
  final TextEditingController descriptionController = TextEditingController(
    text: userData?['description'] ?? '',
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Change Description'),
        content: TextFormField(
          controller: descriptionController,
          decoration: const InputDecoration(
            labelText: 'New Description',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (descriptionController.text.isNotEmpty) {
                try {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(widget.userId)
                      .update({'description': descriptionController.text});

                  setState(() {
                    userData?['description'] = descriptionController.text;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Description updated successfully')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update description: $e')),
                  );
                }
                Navigator.of(context).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}


  void _showChangeProfilePictureDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Profile Picture'),
          content: const Text('Do you want to change your profile picture?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _changeProfilePicture();
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  String _formatBirthdate(dynamic birthdate) {
    if (birthdate is Timestamp) {
      return DateFormat('yyyy-MM-dd').format(birthdate.toDate());
    } else if (birthdate is String) {
      try {
        final parsedDate = DateTime.parse(birthdate);
        return DateFormat('yyyy-MM-dd').format(parsedDate);
      } catch (e) {
        return birthdate;
      }
    } else {
      return 'N/A';
    }
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('User Detail'),
    ),
    body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : userData == null
            ? const Center(child: Text('User data not available'))
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: _showChangeProfilePictureDialog,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: userData!['profilePicture'] != null
                              ? NetworkImage(userData!['profilePicture'])
                              : null,
                          child: userData!['profilePicture'] == null
                              ? const Icon(Icons.person, size: 50)
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      userData!['username'] ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8.0),
                    // Tampilkan description jika ada
                    if (userData!['description'] != null &&
                        userData!['description'].isNotEmpty)
                      Text(
                        userData!['description'],
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Birthdate: ${userData!['birthdate'] != null ? _formatBirthdate(userData!['birthdate']) : 'N/A'}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Email: ${userData!['email'] ?? 'N/A'}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16.0),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'changeProfilePicture':
                            _showChangeProfilePictureDialog();
                            break;
                          case 'changeUsername':
                            _changeUsername();
                            break;
                          case 'changeBirthdate':
                            _changeBirthdate();
                            break;
                          case 'changeDescription':
                            _changeDescription();
                            break;
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        const PopupMenuItem(
                          value: 'changeProfilePicture',
                          child: Text('Change Profile Picture'),
                        ),
                        const PopupMenuItem(
                          value: 'changeUsername',
                          child: Text('Change Username'),
                        ),
                        const PopupMenuItem(
                          value: 'changeBirthdate',
                          child: Text('Change Birthdate'),
                        ),
                        const PopupMenuItem(
                          value: 'changeDescription',
                          child: Text('Change Description'),
                        ),
                      ],
                      icon: const Icon(Icons.more_horiz),
                    ),
                  ],
                ),
              ),
              
  );
}

}
