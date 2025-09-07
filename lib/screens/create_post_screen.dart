import 'package:flutter/material.dart';
import 'dart:io';

class CreatePostScreen extends StatefulWidget {
  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();

  File? _selectedMedia;
  bool _isVideo = false;

  List<String> _popularTags = [
    'Irrigation',
    'Organic Farming',
    'Crop Management',
    'Soil Health',
    'Pest Control',
    'Fertilizers',
    'Harvesting',
    'Seeds',
    'Weather',
    'Technology',
    'Sustainability',
    'Greenhouse',
    'Livestock',
  ];

  List<String> _selectedTags = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF1F8E9),
      appBar: AppBar(
        title: Text(
          'Create Post',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Color(0xFF2E7D32),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF1F8E9), Color(0xFFF1F8E9)],
            stops: [0.0, 0.3],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                _buildMediaUploadSection(),
                SizedBox(height: 24),
                _buildTitleField(),
                SizedBox(height: 20),
                _buildTagsSection(),
                SizedBox(height: 20),
                _buildDescriptionField(),
                SizedBox(height: 30),
                _buildCreatePostButton(),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMediaUploadSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.photo_camera, color: Color(0xFF2E7D32), size: 24),
              SizedBox(width: 8),
              Text(
                'Add Media',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          if (_selectedMedia != null) ...[
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Color(0xFF4CAF50), width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child:
                    _isVideo
                        ? Container(
                          color: Colors.black87,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.play_circle_filled,
                                  color: Colors.white,
                                  size: 48,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Video Selected',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        )
                        : Image.file(_selectedMedia!, fit: BoxFit.cover),
              ),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: () => setState(() => _selectedMedia = null),
                  icon: Icon(Icons.delete, color: Colors.red),
                  label: Text('Remove', style: TextStyle(color: Colors.red)),
                ),
                SizedBox(width: 16),
                TextButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.edit, color: Color(0xFF4CAF50)),
                  label: Text(
                    'Change',
                    style: TextStyle(color: Color(0xFF4CAF50)),
                  ),
                ),
              ],
            ),
          ] else ...[
            GestureDetector(
              onTap: () {},
              child: Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Color(0xFF4CAF50),
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: Color(0xFFF1F8E9),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_upload,
                      color: Color(0xFF4CAF50),
                      size: 40,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tap to Upload Image or Video',
                      style: TextStyle(
                        color: Color(0xFF2E7D32),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'From Gallery or Camera',
                      style: TextStyle(color: Color(0xFF4CAF50), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildTitleField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.title, color: Color(0xFF2E7D32), size: 24),
              SizedBox(width: 8),
              Text(
                'Title',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: 'Enter your agricultural project title...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Color(0xFF4CAF50)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Color(0xFF2E7D32), width: 2),
              ),
              prefixIcon: Icon(Icons.agriculture, color: Color(0xFF4CAF50)),
              filled: true,
              fillColor: Color(0xFFF8FFF8),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a project title';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTagsSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_offer, color: Color(0xFF2E7D32), size: 24),
              SizedBox(width: 8),
              Text(
                'Tags',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Selected tags
          if (_selectedTags.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  _selectedTags
                      .map(
                        (tag) => Chip(
                          label: Text(
                            tag,
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Color(0xFF4CAF50),
                          deleteIcon: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 18,
                          ),
                          onDeleted:
                              () => setState(() => _selectedTags.remove(tag)),
                        ),
                      )
                      .toList(),
            ),
            SizedBox(height: 12),
          ],

          // Popular tags
          Text(
            'Popular Tags:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2E7D32),
            ),
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                _popularTags
                    .map(
                      (tag) => GestureDetector(
                        onTap: () {
                          if (!_selectedTags.contains(tag)) {
                            setState(() => _selectedTags.add(tag));
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color:
                                _selectedTags.contains(tag)
                                    ? Color(0xFF4CAF50)
                                    : Color(0xFFE8F5E8),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Color(0xFF4CAF50)),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              color:
                                  _selectedTags.contains(tag)
                                      ? Colors.white
                                      : Color(0xFF2E7D32),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.description, color: Color(0xFF2E7D32), size: 24),
              SizedBox(width: 8),
              Text(
                'Description',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            maxLines: 6,
            decoration: InputDecoration(
              hintText:
                  'Describe your agricultural project, methods used, challenges faced, results achieved...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Color(0xFF4CAF50)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Color(0xFF2E7D32), width: 2),
              ),
              filled: true,
              fillColor: Color(0xFFF8FFF8),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a description';
              }
              if (value.length < 20) {
                return 'Description should be at least 20 characters long';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCreatePostButton() {
    return Container(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _createPost,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.publish, size: 24),
            SizedBox(width: 12),
            Text(
              'Create Post',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _createPost() {
    if (_formKey.currentState!.validate()) {
      // Show success dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 28),
                SizedBox(width: 8),
                Text('Success!'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your agricultural post has been created successfully!'),
                SizedBox(height: 12),
                Text(
                  'Title: ${_titleController.text}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                if (_selectedTags.isNotEmpty) ...[
                  SizedBox(height: 8),
                  Text('Tags: ${_selectedTags.join(", ")}'),
                ],
                if (_selectedMedia != null) ...[
                  SizedBox(height: 8),
                  Text('Media: ${_isVideo ? "Video" : "Image"} attached'),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _resetForm();
                },
                child: Text('OK', style: TextStyle(color: Color(0xFF2E7D32))),
              ),
            ],
          );
        },
      );
    }
  }

  void _resetForm() {
    _titleController.clear();
    _descriptionController.clear();
    _tagsController.clear();
    setState(() {
      _selectedMedia = null;
      _selectedTags.clear();
      _isVideo = false;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }
}
