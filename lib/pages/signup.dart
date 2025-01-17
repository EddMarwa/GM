import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';
import 'package:shoppingapp/pages/bottomnav.dart';
import 'package:shoppingapp/pages/login.dart';
import 'package:shoppingapp/services/database.dart';
import 'package:shoppingapp/services/shared_pref.dart';
import 'package:shoppingapp/widget/support_widget.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  String? name, email, password;
  TextEditingController namecontroller = TextEditingController();
  TextEditingController mailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();

  final _formkey = GlobalKey<FormState>();

  registration() async {
    if (password != null && name != null && email != null) {
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
                email: email!, password: password!);

        if (userCredential.user != null) {
          // Ensure widget is still mounted before showing Snackbar
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.green,
            content: Text("Registered Successfully", style: TextStyle(fontSize: 20.0)),
          ));

          // Generate a random ID for the user
          String Id = randomAlphaNumeric(10);

          // Save user details to SharedPreferences
          await SharedPreferenceHelper().saveUserEmail(mailcontroller.text);
          await SharedPreferenceHelper().saveUserId(Id);
          await SharedPreferenceHelper().saveUserName(namecontroller.text);
          await SharedPreferenceHelper().saveUserImage(
              "https://firebasestorage.googleapis.com/v0/b/barberapp-ebcc1.appspot.com/o/icon1.png?alt=media&token=0fad24a5-a01b-4d67-b4a0-676fbc75b34a");

          // Add user data to Firestore
          Map<String, dynamic> userInfoMap = {
            "Name": namecontroller.text,
            "Email": mailcontroller.text,
            "Id": Id,
            "Image":
                "https://firebasestorage.googleapis.com/v0/b/barberapp-ebcc1.appspot.com/o/icon1.png?alt=media&token=0fad24a5-a01b-4d67-b4a0-676fbc75b34a"
          };

          await DatabaseMethods().addUserDetails(userInfoMap, Id);

          // Navigate to bottom navigation page (home screen) if still mounted
          if (!mounted) return;
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => BottomNav()));
        }
      } on FirebaseException catch (e) {
        if (!mounted) return; // Check if mounted before showing Snackbar

        if (e.code == 'weak-password') {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text("Password Provided is too Weak", style: TextStyle(fontSize: 20.0)),
          ));
        } else if (e.code == "email-already-in-use") {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text("Account Already exists", style: TextStyle(fontSize: 20.0)),
          ));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(top: 40.0, left: 20.0, right: 20.0, bottom: 40.0),
          child: Form(
            key: _formkey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset("images/login.png"),
                Center(
                  child: Text(
                    "Sign Up",
                    style: AppWidget.semiboldTextFeildStyle(),
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Text(
                  "Please enter the details below to\n                      continue.",
                  style: AppWidget.lightTextFeildStyle(),
                ),
                SizedBox(
                  height: 40.0,
                ),
                Text(
                  "Name",
                  style: AppWidget.semiboldTextFeildStyle(),
                ),
                SizedBox(height: 20.0),
                Container(
                  padding: EdgeInsets.only(left: 20.0),
                  decoration: BoxDecoration(color: Color(0xFFF4F5F9), borderRadius: BorderRadius.circular(10)),
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please Enter your Name';
                      }
                      return null;
                    },
                    controller: namecontroller,
                    decoration: InputDecoration(border: InputBorder.none, hintText: "Name"),
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Text(
                  "Email",
                  style: AppWidget.semiboldTextFeildStyle(),
                ),
                SizedBox(height: 20.0),
                Container(
                  padding: EdgeInsets.only(left: 20.0),
                  decoration: BoxDecoration(color: Color(0xFFF4F5F9), borderRadius: BorderRadius.circular(10)),
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please Enter your Email';
                      }
                      return null;
                    },
                    controller: mailcontroller,
                    decoration: InputDecoration(border: InputBorder.none, hintText: "Email"),
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Text(
                  "Password",
                  style: AppWidget.semiboldTextFeildStyle(),
                ),
                SizedBox(height: 20.0),
                Container(
                  padding: EdgeInsets.only(left: 20.0),
                  decoration: BoxDecoration(color: Color(0xFFF4F5F9), borderRadius: BorderRadius.circular(10)),
                  child: TextFormField(
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please Enter your Password';
                      }
                      return null;
                    },
                    controller: passwordcontroller,
                    decoration: InputDecoration(border: InputBorder.none, hintText: "Password"),
                  ),
                ),
                SizedBox(height: 30.0),
                GestureDetector(
                  onTap: () {
                    if (_formkey.currentState!.validate()) {
                      // Proceed with registration
                      name = namecontroller.text;
                      email = mailcontroller.text;
                      password = passwordcontroller.text;
                      registration();
                    }
                  },
                  child: Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width / 2,
                      padding: EdgeInsets.all(18),
                      decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(10)),
                      child: Center(child: Text("SIGN UP", style: TextStyle(color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.bold))),
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have an account? ", style: AppWidget.lightTextFeildStyle()),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => LogIn()));
                      },
                      child: Text("Sign In", style: TextStyle(color: Colors.green, fontSize: 18.0, fontWeight: FontWeight.w500)),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
