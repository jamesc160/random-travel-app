import 'dart:developer';
import 'dart:io';

import 'package:blog/model/blog.dart';
import 'package:blog/services/db_service.dart';
import 'package:flutter/material.dart';
import 'create_blog.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

//  Main Home Page //

class _HomePageState extends State<HomePage> {
  List<Blog> _blogs = [];
  @override
  void initState() {
    super.initState();
    _fatchBlogs();
  }

  _fatchBlogs() {
    DataBaseService.instance.getBlogs().then((value) {
      setState(() {
        _blogs = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const <Widget>[
              Text(
                'Travel',
                style: TextStyle(fontSize: 22),
              ),
              Text('Blog', style: TextStyle(fontSize: 22, color: Colors.green))
            ]),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: ListView.builder(
        shrinkWrap: true,
        itemCount: _blogs.length,
        itemBuilder: (context, index) {
          final blog = _blogs[index];
          return ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CreateBlog(),
                    settings: RouteSettings(arguments: blog)),
              ).then((value) {
                if (value != null) {
                  _fatchBlogs();
                }
              });
            },
            title: Text(blog.title),
            subtitle: Text('${blog.name}, ${blog.body}, ${blog.formatedDate} '),
            leading: blog.imagePath != null
                ? CircleAvatar(
                    backgroundImage: FileImage(File(blog.imagePath!)),
                  )
                : const Icon(Icons.image_not_supported_outlined),
            trailing: IconButton(
                onPressed: () async {
                  DataBaseService.instance.deleteBlog(blog).then((value) {
                    _fatchBlogs();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Removed successfully'),
                      duration: Duration(seconds: 1),
                    ));
                  });
                },
                icon: const Icon(Icons.delete)),
          );
        },
      ),
      floatingActionButton: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FloatingActionButton(
                onPressed: () async {
                  Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const CreateBlog()))
                      .then((value) {
                    if (value != null) {
                      _fatchBlogs();
                    }
                  });
                },
                child: const Icon(Icons.add_a_photo))
          ],
        ),
      ),
    );
  }
}
