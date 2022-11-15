import 'dart:developer';
import 'dart:io' show File;
import 'package:blog/model/blog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/db_service.dart';

class CreateBlog extends StatefulWidget {
  const CreateBlog({Key? key}) : super(key: key);

  @override
  State<CreateBlog> createState() => _CreateBlogState();
}

class _CreateBlogState extends State<CreateBlog> {
  File? image2;
  final _picker = ImagePicker();
  late TextEditingController _dateController;
  late Blog _blog;
  File? selectedImage;
  final _formKey = GlobalKey<FormState>();
  bool toUpdate = false;
  @override
  void initState() {
    super.initState();
    _blog = Blog(name: '', title: '', date: DateTime.now(), body: '');
    _dateController = TextEditingController();
  }

  Future getImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(
        () {
          selectedImage = File(image.path);
          _blog.imagePath = image.path;
        },
      );
    }
  }

//    Firebase Upload Code  //
// uploadBlog() async {
//   if (selectedImage != null) {
//     StorageReference firebaseStorageRef = FirebaseFirestore.instance
//         .ref()
//         .child("blogImages")
//         .child("$randomAlphaNumeric(9).jpg");
//     final StorageUploadTask task = firebaseStorageRef.putFile(selectedImage);
//     var downloadUrl = await (await task.onComplete).ref.getDownloadURL();
//     print("this is url");
//   } else {}
// }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final blog = ModalRoute.of(context)!.settings.arguments as Blog?;
    if (blog != null) {
      _dateController.text = blog.formatedDate;
      setState(() {
        _blog = blog;
        toUpdate = true;
        if (_blog.imagePath != null) {
          selectedImage = File(_blog.imagePath!);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Row(
          // Top of Screen Text //

          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            Text(
              'Travel',
              style: TextStyle(fontSize: 22),
            ),
            Text('Blog', style: TextStyle(fontSize: 22, color: Colors.green))
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0.0,

        // Top of Screen widget  //

        actions: <Widget>[
          GestureDetector(
            // Upload Button //
            onTap: () {},
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: const Icon(Icons.upload_file),
            ),
          ),
        ],
      ),
      // Next Widget //
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: SingleChildScrollView(
          child: Column(
            // Get Image Button //

            children: <Widget>[
              GestureDetector(
                  onTap: getImage,
                  // Image Return //
                  child: selectedImage != null
                      ? Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          width: MediaQuery.of(context).size.width,
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.file(selectedImage!,
                                  fit: BoxFit.cover)),
                        )

                      // Hold Image Box //

                      : Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          height: 150,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6)),
                          width: MediaQuery.of(context).size.width,
                          child: const Icon(Icons.add_a_photo,
                              color: Colors.black))),

              // Text Boxes Code //

              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        validator: _validator,
                        decoration: const InputDecoration(hintText: 'Name'),
                        initialValue: _blog.name,
                        onChanged: (val) => _blog.name = val,
                      ),
                      TextFormField(
                        validator: _validator,
                        decoration: const InputDecoration(hintText: 'Title'),
                        initialValue: _blog.title,
                        onChanged: (val) => _blog.title = val,
                      ),
                      TextFormField(
                        validator: _validator,
                        controller: _dateController,
                        onTap: () async {
                          final selectedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1990),
                              lastDate: DateTime(2050));
                          if (selectedDate != null) {
                            _blog.date = selectedDate;
                            _dateController.text =
                                DateFormat('dd-MM-yyyy').format(selectedDate);
                          }
                        },
                        readOnly: true,
                        decoration: const InputDecoration(hintText: 'Date'),
                      ),
                      TextFormField(
                        validator: _validator,
                        initialValue: _blog.body,
                        maxLines: null,
                        decoration:
                            const InputDecoration(hintText: 'Blog Body'),
                        onChanged: (val) => _blog.body = val,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 5),

              ElevatedButton(
                child: Text('${toUpdate ? 'Update' : 'Save'} data'),
                onPressed: () async {
                  if (selectedImage == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Please add a picture'),
                      duration: Duration(seconds: 1),
                    ));
                    return;
                  }
                  if (!_formKey.currentState!.validate()) {
                    return;
                  }
                  final inserted = toUpdate
                      ? await DataBaseService.instance
                          .updateBlog(oldBlogId: _blog.id, newBlog: _blog)
                      : await DataBaseService.instance.insert(_blog);
                  if (inserted && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                          '${toUpdate ? 'Updated' : 'Added'} successfully'),
                      duration: const Duration(seconds: 1),
                    ));
                    Navigator.pop(context, true);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _validator(String? input) => input != null && input.trim().isNotEmpty
      ? null
      : 'Please provide a value';
}
