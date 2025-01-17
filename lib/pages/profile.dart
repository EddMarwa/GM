import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';
import 'package:shoppingapp/pages/onboarding.dart';
import 'package:shoppingapp/services/auth.dart';
import 'package:shoppingapp/services/shared_pref.dart';
import 'package:shoppingapp/widget/support_widget.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? image, name, email;
  final ImagePicker _picker = ImagePicker();
  File? selectedImage;

  getthesharedpref() async {
    image = await SharedPreferenceHelper().getUserImage();
    name = await SharedPreferenceHelper().getUserName();
    email = await SharedPreferenceHelper().getUserEmail();
    if (mounted) {
      setState(() {});  // Safely call setState after checking if widget is still mounted
    }
  }

  @override
  void initState() {
    super.initState();
    getthesharedpref();
  }

  Future getImage() async {
    var image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      selectedImage = File(image.path);
      uploadItem();
      if (mounted) {
        setState(() {});  // Safely call setState after checking if widget is still mounted
      }
    }
  }

  uploadItem() async {
    if (selectedImage != null) {
      String addId = randomAlphaNumeric(10);
      Reference firebaseStorageRef = FirebaseStorage.instance.ref().child("blogImage").child(addId);

      final UploadTask task = firebaseStorageRef.putFile(selectedImage!);
      var downloadUrl = await (await task).ref.getDownloadURL();
      await SharedPreferenceHelper().saveUserImage(downloadUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xfff2f2f2),
        title: Text("Profile", style: AppWidget.boldTextFeildStyle()),
      ),
      backgroundColor: const Color(0xfff2f2f2),
      body: name == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                selectedImage != null
                    ? GestureDetector(
                        onTap: getImage,
                        child: Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(60),
                            child: Image.file(
                              selectedImage!,
                              height: 150.0,
                              width: 150.0,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      )
                    : GestureDetector(
                        onTap: getImage,
                        child: Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(60),
                            child: Image.network(
                              image!,
                              height: 150.0,
                              width: 150.0,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                const SizedBox(height: 20.0),
                _buildProfileInfo("Name", name!),
                const SizedBox(height: 20.0),
                _buildProfileInfo("Email", email!),
                const SizedBox(height: 20.0),
                _buildLogOutOption(),
                const SizedBox(height: 20.0),
                _buildDeleteAccountOption(),
              ],
            ),
    );
  }

  Widget _buildProfileInfo(String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Material(
        elevation: 3.0,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: Row(
            children: [
              Icon(label == "Name" ? Icons.person_outline : Icons.mail_outline, size: 35.0),
              const SizedBox(width: 10.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppWidget.lightTextFeildStyle()),
                  Text(value, style: AppWidget.semiboldTextFeildStyle()),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogOutOption() {
    return GestureDetector(
      onTap: () async {
        await AuthMethods().signOut();
        if (mounted) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Onboarding()));
        }
      },
      child: _buildOptionItem(Icons.logout, "LogOut"),
    );
  }

  Widget _buildDeleteAccountOption() {
    return GestureDetector(
      onTap: () async {
        await AuthMethods().deleteuser();
        if (mounted) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Onboarding()));
        }
      },
      child: _buildOptionItem(Icons.delete_outline, "Delete Account"),
    );
  }

  Widget _buildOptionItem(IconData icon, String label) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Material(
        elevation: 3.0,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: Row(
            children: [
              Icon(icon, size: 35.0),
              const SizedBox(width: 10.0),
              Text(label, style: AppWidget.semiboldTextFeildStyle()),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios_outlined)
            ],
          ),
        ),
      ),
    );
  }
}
