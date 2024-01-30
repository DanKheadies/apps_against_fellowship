//import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'package:apps_against_fellowship/blocs/blocs.dart';

class ProfilePhoto extends StatefulWidget {
  const ProfilePhoto({
    super.key,
  });

  @override
  State<ProfilePhoto> createState() => _ProfilePhotoState();
}

class _ProfilePhotoState extends State<ProfilePhoto> {
  // late XFile? image;

  Future<void> pickImage(BuildContext context) async {
    late dynamic pickedImage;
    var scaffContext = ScaffoldMessenger.of(context);
    var userBlocContext = BlocProvider.of<UserBloc>(context);

    try {
      if (kIsWeb) {
        pickedImage = await FilePicker.platform.pickFiles(
          allowMultiple: false,
          type: FileType.custom,
          allowedExtensions: ['png', 'jpg', 'jpeg', 'heic'],
        );
      } else {
        pickedImage = await ImagePicker().pickImage(
          source: ImageSource.gallery,
        );
      }

      if (pickedImage == null) {
        scaffContext.showSnackBar(
          const SnackBar(
            content: Text('No image was selected.'),
          ),
        );
      } else {
        late Uint8List fileBytes;
        late String fileName;

        if (kIsWeb) {
          fileBytes = (pickedImage as FilePickerResult).files.first.bytes!;
          fileName = pickedImage.files.first.name;
        } else {
          fileBytes = await (pickedImage as XFile).readAsBytes();
          fileName = pickedImage.name;
        }

        print('updating via profile photo');

        userBlocContext.add(
          UpdateUserImage(
            bytes: fileBytes,
            imageName: fileName,
          ),
        );
      }
    } catch (err) {
      print('pick image err: $err');
      scaffContext.showSnackBar(
        const SnackBar(
          content: Text('There was an error selecting your image.'),
        ),
      );
    }
  }

  Future<void> removeImage(BuildContext context) async {
    context.read<UserBloc>().add(
          DeleteProfilePhoto(),
        );
  }

  // Future<void> pickImageDevice(BuildContext context) async {
  //   print('image device');
  //   var scaffContext = ScaffoldMessenger.of(context);
  //   var userBlocContext = BlocProvider.of<UserBloc>(context);

  //   try {
  //     var image = await ImagePicker().pickImage(
  //       source: ImageSource.gallery,
  //     );

  //     if (image == null) {
  //       scaffContext.showSnackBar(
  //         const SnackBar(
  //           content: Text('No image was selected.'),
  //         ),
  //       );
  //     } else {
  //       final imageTemp = XFile(image.path);

  //       setState(() {
  //         image = imageTemp;
  //       });

  //       // final Uint8List fileBytes = image.files.first.bytes!;
  //       final Uint8List fileBytes = await image!.readAsBytes();
  //       // final String fileName = image.files.first.name;
  //       final String fileName = image!.name;

  //       // TODO: repository?
  //       print('updating via profile photo');

  //       userBlocContext.add(
  //         UpdateUserImage(
  //           bytes: fileBytes,
  //           imageName: fileName,
  //         ),
  //       );
  //     }
  //   } catch (err) {
  //     print('pick image err: $err');
  //     scaffContext.showSnackBar(
  //       const SnackBar(
  //         content: Text('There was an error selecting your image.'),
  //       ),
  //     );
  //   }
  // }

  // Future<void> pickImageWeb(BuildContext context) async {
  //   var scaffContext = ScaffoldMessenger.of(context);
  //   var userBlocContext = BlocProvider.of<UserBloc>(context);

  //   try {
  //     FilePickerResult? image = await FilePicker.platform.pickFiles(
  //       allowMultiple: false,
  //       type: FileType.custom,
  //       allowedExtensions: ['png', 'jpg', 'jpeg', 'heic'],
  //     );

  //     if (image == null) {
  //       scaffContext.showSnackBar(
  //         const SnackBar(
  //           content: Text('No image was selected.'),
  //         ),
  //       );
  //     } else if (image.files.isNotEmpty) {
  //       final Uint8List fileBytes = image.files.first.bytes!;
  //       final String fileName = image.files.first.name;

  //       userBlocContext.add(
  //         UpdateUserImage(
  //           bytes: fileBytes,
  //           imageName: fileName,
  //         ),
  //       );
  //     }
  //   } catch (err) {
  //     scaffContext.showSnackBar(
  //       const SnackBar(
  //         content: Text('There was an error selecting your image.'),
  //       ),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              SizedBox(
                width: 250,
                height: 250,
                child: state.userStatus == UserStatus.photoUpload
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : state.user.avatarUrl != ''
                        ? Image.network(state.user.avatarUrl)
                        : Container(
                            width: 250,
                            height: 250,
                            color: Theme.of(context).colorScheme.background,
                            child: Icon(
                              Icons.person,
                              size: 144,
                              color: Theme.of(context).colorScheme.surface,
                            ),
                          ),
              ),
              Container(
                padding: const EdgeInsets.only(
                  top: 10,
                ),
                width: 250,
                child: TextButton(
                  onPressed: state.userStatus == UserStatus.photoUpload
                      ? null
                      : () => pickImage(context),
                  // : kIsWeb
                  //     ? () => pickImageWeb(context)
                  //     : () => pickImageDevice(context),
                  child: const Text('Upload Photo'),
                ),
              ),
              state.user.avatarUrl != ''
                  ? Container(
                      padding: const EdgeInsets.only(
                        top: 20,
                      ),
                      width: 250,
                      child: TextButton(
                        // TODO: prompt 'Are you sure?'
                        onPressed: state.userStatus == UserStatus.photoUpload
                            ? null
                            : () => removeImage(context),
                        child: const Text('Remove Photo'),
                      ),
                    )
                  : const SizedBox(),
            ],
          ),
        );
      },
    );
  }
}
