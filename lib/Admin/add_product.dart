import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';
import 'package:shoppingapp/services/database.dart';
import 'package:shoppingapp/widget/support_widget.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final ImagePicker _picker = ImagePicker();
  File? selectedImage;
  TextEditingController namecontroller = TextEditingController();
  TextEditingController pricecontroller = TextEditingController();
  TextEditingController detailcontroller = TextEditingController();

  String? categoryValue;
  final List<String> categoryItems = ['Watch', 'Laptop', 'TV', 'Headphones'];

  // Image picker function
  Future<void> getImage() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null && mounted) { // Check if the widget is still mounted
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  // Function to upload item
  Future<void> uploadItem() async {
    if (selectedImage != null && namecontroller.text.isNotEmpty) {
      final addId = randomAlphaNumeric(10);
      final firebaseStorageRef = FirebaseStorage.instance
          .ref()
          .child("productImages")
          .child(addId);

      final task = firebaseStorageRef.putFile(selectedImage!);
      final dowloadUrl = await (await task).ref.getDownloadURL();

      final firstLetter = namecontroller.text.substring(0, 1).toUpperCase();

      Map<String, dynamic> addProduct = {
        "Name": namecontroller.text,
        "Image": dowloadUrl,
        "SearchKey": firstLetter,
        "UpdatedName": namecontroller.text.toUpperCase(),
        "Price": pricecontroller.text,
        "Detail": detailcontroller.text,
        "Category": categoryValue ?? "",
      };

      // Save product to database
      await DatabaseMethods().addProduct(addProduct, addId);
      await DatabaseMethods().addAllProducts(addProduct);

      // Reset fields after upload, guard against context after dispose
      if (mounted) {
        setState(() {
          selectedImage = null;
          namecontroller.clear();
          pricecontroller.clear();
          detailcontroller.clear();
          categoryValue = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              "Product uploaded successfully!",
              style: TextStyle(fontSize: 20.0),
            ),
          ),
        );
      }
    } else {
      // Show error if the product details are not filled
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(
              "Please fill all fields and select an image.",
              style: TextStyle(fontSize: 20.0),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back_ios_new_outlined),
        ),
        title: Text(
          "Add Product",
          style: AppWidget.semiboldTextFeildStyle(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Upload Image Section
              Text(
                "Upload the Product Image",
                style: AppWidget.lightTextFeildStyle(),
              ),
              SizedBox(height: 20.0),
              selectedImage == null
                  ? GestureDetector(
                      onTap: getImage,
                      child: Center(
                        child: Container(
                          height: 150,
                          width: 150,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 1.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(Icons.camera_alt_outlined),
                        ),
                      ),
                    )
                  : Center(
                      child: Material(
                        elevation: 4.0,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          height: 150,
                          width: 150,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 1.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.file(
                              selectedImage!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
              SizedBox(height: 20.0),

              // Product Name Section
              Text("Product Name", style: AppWidget.lightTextFeildStyle()),
              SizedBox(height: 20.0),
              _buildTextField(controller: namecontroller),

              // Product Price Section
              SizedBox(height: 20.0),
              Text("Product Price", style: AppWidget.lightTextFeildStyle()),
              SizedBox(height: 20.0),
              _buildTextField(controller: pricecontroller),

              // Product Detail Section
              SizedBox(height: 20.0),
              Text("Product Detail", style: AppWidget.lightTextFeildStyle()),
              SizedBox(height: 20.0),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Color(0xFFececf8),
                    borderRadius: BorderRadius.circular(20)),
                child: TextField(
                  maxLines: 6,
                  controller: detailcontroller,
                  decoration: InputDecoration(border: InputBorder.none),
                ),
              ),
              SizedBox(height: 20.0),

              // Product Category Section
              Text("Product Category", style: AppWidget.lightTextFeildStyle()),
              SizedBox(height: 20.0),
              _buildCategoryDropdown(),

              SizedBox(height: 30.0),

              // Add Product Button
              Center(
                child: ElevatedButton(
                  onPressed: uploadItem,
                  child: Text(
                    "Add Product",
                    style: TextStyle(fontSize: 22.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable text field widget
  Widget _buildTextField({required TextEditingController controller}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color(0xFFececf8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(border: InputBorder.none),
      ),
    );
  }

  // Reusable category dropdown widget
  Widget _buildCategoryDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color(0xFFececf8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          items: categoryItems
              .map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(item, style: AppWidget.semiboldTextFeildStyle()),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              categoryValue = value;
            });
          },
          dropdownColor: Colors.white,
          hint: Text("Select Category"),
          iconSize: 36,
          icon: Icon(
            Icons.arrow_drop_down,
            color: Colors.black,
          ),
          value: categoryValue,
        ),
      ),
    );
  }
}
