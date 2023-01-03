import 'package:fiverr_signurl_aws/locator.dart';
import 'package:fiverr_signurl_aws/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:transparent_image/transparent_image.dart';

import 'details.dart';

class Home extends ConsumerStatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  final _image = StateProvider<File?>((ref) => null);
  final _uploading = StateProvider<bool>((ref) => false);
  final picker = ImagePicker();
  String? _uploadFileURL;

  final images = StateProvider<List<String>>((ref) => []);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    return Scaffold(
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add_a_photo),
          onPressed: () {
            chooseImage(ref).then((file) => file == null
                ? null
                : showDialog(
                    builder: (context) => AlertDialog(
                          title: const Text('Confirm Upload ?'),
                          content: ImageDialog(image: file),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Cancel')),
                            TextButton(
                                onPressed: () {
                                  uploadFile(ref);
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Confirm'))
                          ],
                        ),
                    context: context));
          },
        ),
        body: Stack(
          children: [
                 if (!ref.watch(_uploading)) Hero(
                tag: 'imageHero',
                child: MasonryGridView.count(
                  itemCount: ref.watch(images).length,
                  crossAxisCount: 2,
                  itemBuilder: (context, index) => GestureDetector(
                    child: Container(
                      margin: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12)),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 0))
                          ]),
                      child: ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(12)),
                        child: FadeInImage.memoryNetwork(
                          placeholder: kTransparentImage,
                          image: ref.watch(images)[index],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) {
                        return DetailScreen(ref.watch(images)[index]);
                      }));
                    },
                  ),
                  // staggeredTileBuilder: (index) =>
                  //     StaggeredTile.count(1, index.isEven ? 1.2 : 1.8)),
                )),
            if (ref.watch(_uploading))
              Opacity(
                  opacity: 0.5,
                  child: Container(
                      color: Colors.white,
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: Center(child: CircularProgressIndicator()))),
          ],
        ));
  }

  Future<File?> chooseImage(WidgetRef ref) async {
    return picker.pickImage(source: ImageSource.gallery).then((pickedFile) {
      if (pickedFile?.path != null) {
        ref.read(_image.notifier).state = File(pickedFile!.path);
        return File(pickedFile.path);
      }
    });
  }

  Future<void> retrieveLostData(WidgetRef ref) async {
    final LostDataResponse response = await picker.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      ref.read(_image.notifier).state = File(response.file!.path);
    } else {
      print(response.file);
    }
  }

  Future uploadFile(WidgetRef ref) async {
    ref.read(_uploading.notifier).state = true;
    locator
        .get<Services>()
        .getAwsSignedUrl()
        .then((value) => locator
                .get<Services>()
                .uploadWithAwsSignedUrl(file: ref.watch(_image)!, url: value)
                .then((val) {
              print(val);
              ref.read(images.notifier).state = [val, ...ref.watch(images)];
            }).onError((error, stackTrace) {
              print("Error: $error: $stackTrace:");
            }))
        .whenComplete(() => ref.read(_uploading.notifier).state = false)
        .onError((error, stackTrace) {
      print("Error: $error: $stackTrace:");
    });
  }
}

class ImageDialog extends StatelessWidget {
  const ImageDialog({
    Key? key,
    required this.image,
  }) : super(key: key);
  final File image;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 3,
      width: double.infinity,
      decoration: BoxDecoration(
          image: DecorationImage(
              image: Image.file(image).image, fit: BoxFit.cover)),
    );
  }
}
