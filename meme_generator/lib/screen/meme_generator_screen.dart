import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

import 'enums.dart';
import 'dialog_builder.dart';

class MemeGeneratorScreen extends StatefulWidget {
  const MemeGeneratorScreen({Key? key}) : super(key: key);

  @override
  State<MemeGeneratorScreen> createState() => _MemeGeneratorScreenState();
}

class _MemeGeneratorScreenState extends State<MemeGeneratorScreen> {
  /// Instance of [ImagePicker] for picking picture from gallery.
  late final ImagePicker imagePicker;

  /// Instance of [ScreenshotController] for taking screenshot.
  late final ScreenshotController screenshotController;

  /// Instance of [TextEditingController] for [TextField]s.
  late TextEditingController _controller;

  /// Text in meme.
  late String memeText;

  /// Image URL in meme.
  late String memeImageUrl;

  /// Little storage of image URL's from 5 elements.
  late final List<String> savedUrls;

  /// Little storage of meme's text from 5 elements.
  late final List<String> savedText;

  /// Image from gallery.
  XFile? imageFromGallery;

  @override
  void initState() {
    _controller = TextEditingController();
    imagePicker = ImagePicker();
    screenshotController = ScreenshotController();
    memeText = 'Здесь мог бы быть ваш мем';
    savedText = [memeText];
    memeImageUrl =
        'https://i.cbc.ca/1.6713656.1679693029!/fileImage/httpImage/image.jpg_gen/derivatives/16x9_780/this-is-fine.jpg';
    savedUrls = [memeImageUrl];

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      border: Border.all(
        color: Colors.white,
        width: 2,
      ),
    );
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Screenshot(
            controller: screenshotController,
            child: ColoredBox(
              color: Colors.black,
              child: DecoratedBox(
                decoration: decoration,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 20,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        width: double.infinity,
                        height: 200,
                        child: DecoratedBox(
                          decoration: decoration,
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: imageFromGallery != null
                                ? Image.file(File(imageFromGallery!.path))
                                : Image.network(
                                    memeImageUrl,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                      ),
                      Text(
                        memeText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Impact',
                          fontSize: 40,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => dialogBulder(
                        context: context,
                        title: 'Введите URL картинки',
                        type: ContentType.image,
                        controller: _controller,
                        savedItems: savedUrls,
                        onAccept: () {
                          setState(() {
                            memeImageUrl = _controller.text.isNotEmpty
                                ? _controller.text
                                : memeImageUrl;
                            addInSaved(savedUrls, memeImageUrl);
                            imageFromGallery = null;
                          });
                        },
                        onTakeSaved: (String item) {
                          setState(() {
                            memeImageUrl = item;
                            imageFromGallery = null;
                          });
                        },
                        onTakeFromGallery: () async {
                          final XFile? image = await imagePicker.pickImage(
                            source: ImageSource.gallery,
                          );
                          setState(() {
                            imageFromGallery = image;
                          });
                        },
                      ),
                      child: const Text(
                        'Изменить картинку',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => dialogBulder(
                        context: context,
                        title: 'Введите текст',
                        type: ContentType.text,
                        controller: _controller,
                        savedItems: savedText,
                        onAccept: () {
                          setState(() {
                            memeText = _controller.text.isNotEmpty
                                ? _controller.text
                                : memeText;
                            addInSaved(savedText, memeText);
                          });
                        },
                        onTakeSaved: (String item) {
                          setState(() {
                            memeText = item;
                          });
                        },
                      ),
                      child: const Text(
                        'Изменить текст',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: takePictureAndShare,
                      child: const Text(
                        'Поделиться мемом',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Takes a picture and share in other program.
  Future<void> takePictureAndShare() async {
    await screenshotController.capture().then((Uint8List? image) async {
      if (image != null) {
        final Directory directory = await getApplicationDocumentsDirectory();
        final File file = await File('${directory.path}/image.png').create();
        await file.writeAsBytes(image);

        await Share.shareXFiles([XFile(file.path)]);
      }
    });
  }
}
