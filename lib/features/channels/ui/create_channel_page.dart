import 'dart:io';
import 'dart:ui';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maarifa/core/theme/app_colors.dart';
import 'package:maarifa/core/theme/app_colors_dark.dart';
import 'package:maarifa/core/theme/theme_notifier.dart';
import 'package:maarifa/features/auth/view_model/auth_view_model.dart';
import 'package:maarifa/features/channels/for_users_channel/ui/users_joined_channels.dart';
import 'package:maarifa/features/channels/logic/channels_controller.dart';

class CreateChannelPage extends ConsumerStatefulWidget {
  const CreateChannelPage({super.key});

  @override
  CreateChannelPageState createState() => CreateChannelPageState();
}

class CreateChannelPageState extends ConsumerState<CreateChannelPage> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _purposeController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();

  String coverPhotoUrl = '';
  File? _image;
  final ImagePicker _picker = ImagePicker();

  String? _titleError;
  String? _descriptionError;
  String? _purposeError;
  bool _isSubmitting = false;
  double _submissionProgress = 0.0;
  final Duration _submissionDuration = const Duration(seconds: 5);

  final _allowedTitleRegex = RegExp(r'^[a-zA-Z0-9\s,.?!:;•-]+$');
  final _allowedDescriptionRegex = RegExp(r'^[a-zA-Z0-9\s,.?!:;•-]+$');

  @override
  void dispose() {
    _purposeController.dispose();
    _descriptionController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _submitChannel() async {
    final channelController = ref.read(channelControllerProvider);
    setState(() {
      _isSubmitting = true;
    });

    for (int i = 1; i <= 100; i++) {
      await Future.delayed(_submissionDuration ~/ 100);
      setState(() {
        _submissionProgress = i / 100;
      });
    }

    if (_image != null) {
      coverPhotoUrl = await _uploadImageToFirebase(_image!);
      final userId = ref.read(authViewModelProvider).getCurrentUser()!.uid;
      final user = await ref.read(authViewModelProvider).getUsername();

      if (!context.mounted) return;

      try {
        await channelController.createChannel(
          userId,
          _descriptionController.text,
          _titleController.text,
          _purposeController.text,
          coverPhotoUrl,
          user!,
        );

        if(!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (context) => const UsersJoinedChannelsPage()),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Channel submitted for approval'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        );
      } catch (e) {
        if(!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('You cannot create more than three channels'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        );
      }
    } else {
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Fields and Cover photo can not be empty.'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      );
    }

    // Reset submission state after process completes
    setState(() {
      _isSubmitting = false;
      _submissionProgress = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = ref.watch(themeNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Channel", style: TextStyle(fontSize: 17)),
        backgroundColor: isDarkTheme ? Colors.black26 : Colors.white,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => _pickImage(),
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[300],
                        image: _image != null
                            ? DecorationImage(image: FileImage(_image!), fit: BoxFit.cover)
                            : null,
                      ),
                      child: _image == null
                          ? const Center(child: Icon(Icons.add_a_photo, size: 50))
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text.rich(
                      TextSpan(
                        text: "Title",
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 14,
                          color: isDarkTheme ? Colors.white : Colors.black54,
                        ),
                        children: [
                          const WidgetSpan(
                            child: SizedBox(width: 5), // Adjust width for desired gap
                          ),
                          TextSpan(
                            text: "Must be unique and descriptive of your channel",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              color: isDarkTheme
                                  ? AppColorsDark.spaceCadetColor
                                  : AppColors.spaceCadetColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  _buildTextField(
                    "Title",
                    _titleController,
                    15,
                    _titleError,
                    _allowedTitleRegex,
                  ),
                  const SizedBox(height: 10),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text.rich(
                      TextSpan(
                        text: "Description",
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 14,
                          color: isDarkTheme ? Colors.white : Colors.black,
                        ),
                        children: [
                          const WidgetSpan(
                            child: SizedBox(width: 5),
                          ),
                          TextSpan(
                            text: "Describe your channel briefly for other users",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              color: isDarkTheme
                                  ? AppColorsDark.spaceCadetColor
                                  : AppColors.spaceCadetColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  _buildTextField(
                    "Description",
                    _descriptionController,
                    200,
                    _descriptionError,
                    _allowedDescriptionRegex,
                  ),
                  const SizedBox(height: 10),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text.rich(
                      TextSpan(
                        text: "Purpose",
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 14,
                          color: isDarkTheme ? Colors.white : Colors.black,
                        ),
                        children: [
                          const WidgetSpan(
                            child: SizedBox(width: 5),
                          ),
                          TextSpan(
                            text: "What will the users gain by joining your Islamic channel?",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              color: isDarkTheme
                                  ? AppColorsDark.spaceCadetColor
                                  : AppColors.spaceCadetColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  _buildTextField(
                    "Purpose",
                    _purposeController,
                    100,
                    _purposeError,
                    _allowedDescriptionRegex,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _validateFields() ? _submitChannel : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.spaceCadetColor,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Submit for Approval',
                      style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isSubmitting) // Show blur and progress indicator during submission
            _buildBlurredLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildBlurredLoadingOverlay() {
    return Stack(
      children: [
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: Container(
            color: Colors.black.withOpacity(0.2),
          ),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Submitting channel for approval...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              LinearProgressIndicator(
                value: _submissionProgress,
                minHeight: 5,
                backgroundColor: Colors.white30,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.spaceCadetColor),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
      String label,
      TextEditingController controller,
      int maxLength,
      String? errorText,
      RegExp allowedCharacters,

      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          maxLength: maxLength,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: errorText == null ? Colors.grey : Colors.red, // Change border color based on error
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: errorText == null ? Colors.blue : Colors.red, // Change color when focused
              ),
            ),
            hintText: 'Enter $label',
          ),
          style: TextStyle(
            color: errorText == null ? Colors.black : Colors.red, // Change text color if invalid
          ),
          onChanged: (value) {
            setState(() {});
            // Trigger re-validation on every change
            _validateFields();
          },
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              errorText,
              style: const TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }


  bool _validateFields() {
    setState(() {
      _titleError = _titleController.text.isEmpty
          ? null
          : (_titleError = _titleController.text.length < 5 ? "Title must be of atleast 5 characters" : (!_allowedTitleRegex.hasMatch(_titleController.text)
          ? "Only alphabets, numbers, and special characters ( _, -, . ) allowed"
          : null)) ;

      _descriptionError = _descriptionController.text.isEmpty
          ? null
          : (!_allowedDescriptionRegex.hasMatch(_descriptionController.text)
          ? "Only alphabets, numbers, and one special character ( - ) allowed"
          : null);

      _purposeError = _purposeController.text.isEmpty
          ? null
          : (!_allowedDescriptionRegex.hasMatch(_purposeController.text)
          ? "Only alphabets, numbers, and one special character ( - ) allowed"
          : null);
    });
    return _titleError == null && _descriptionError == null && _purposeError == null;
  }


  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<String> _uploadImageToFirebase(File image) async {
    final
 fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final storageRef = FirebaseStorage.instance.ref().child('coverphotos/$fileName');
    final uploadTask = storageRef.putFile(image);
    final taskSnapshot = await uploadTask;
    return await taskSnapshot.ref.getDownloadURL();
  }
}