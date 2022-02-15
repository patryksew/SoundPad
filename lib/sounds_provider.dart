import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class SoundsProvider with ChangeNotifier {
  SoundsProvider(this.onlineMode) {
    fetchFromCloud();
    uploadSounds();
  }

  void uploadSounds() {
    getSounds.where((sound) => !sound.isUploadedToServer).forEach((sound) => addToCloud(sound));
  }

  Future<bool> Function() onlineMode;
  final soundBox = Hive.box('sounds');

  List<Sound> get getSounds {
    return soundBox.values.whereType<Sound>().toList();
  }

  bool get isNotEmpty {
    return soundBox.isNotEmpty;
  }

  Future<void> fetchFromCloud() async {
    if (!(await onlineMode())) return;
    List<String> keys = soundBox.keys.whereType<String>().toList();
    final ref = FirebaseFirestore.instance.collection('/users/${FirebaseAuth.instance.currentUser!.uid}/sounds');
    var docsToFetch = (await ref.get()).docs.where((doc) => !keys.contains(doc.id));
    for (var doc in docsToFetch) {
      addFromCloud(doc);
    }
  }

  Future<void> addFromCloud(QueryDocumentSnapshot<Map<String, dynamic>> doc) async {
    Sound newSound = Sound.create();
    Reference ref = FirebaseStorage.instance.ref().child('user_sounds').child(FirebaseAuth.instance.currentUser!.uid);
    var imageData = await ref.child(doc.id + '.jpg').getData();
    Uint8List soundData = (await ref.child(doc.id + doc['soundExtension']).getData())!;
    await newSound.initFromBytes(
        soundBytes: soundData,
        soundExtension: doc['soundExtension'],
        imageBytes: imageData,
        name: doc['name'],
        id: doc.id);
    await soundBox.put(newSound.id, newSound);
    notifyListeners();
  }

  Future<void> add({required File cachedSoundFile, File? cachedImageFile, String? name}) async {
    Sound newSound = Sound.create();
    await newSound.init(cachedSoundFile: cachedSoundFile, cachedImageFile: cachedImageFile, name: name);
    if (await onlineMode()) addToCloud(newSound);
    await soundBox.put(newSound.id, newSound);
    notifyListeners();
  }

  void addToCloud(Sound newSound) {
    Reference ref = FirebaseStorage.instance.ref().child('user_sounds').child(FirebaseAuth.instance.currentUser!.uid);
    Reference? refImage;
    final refSound = ref.child(newSound.id + p.extension(newSound.soundPath));
    refSound.putFile(newSound.soundFile);
    if (newSound.imageFile != null) {
      refImage = ref.child(newSound.id + '.jpg');
      refImage.putFile(newSound.imageFile!);
    }
    FirebaseFirestore.instance
        .collection('/users/${FirebaseAuth.instance.currentUser!.uid}/sounds')
        .doc(newSound.id)
        .set({
      'soundExtension': p.extension(refSound.name),
      'name': newSound.name,
    }).then((_) => newSound.isUploadedToServer = true);
  }

  Future<void> delete(String id) async {
    Sound sound = await soundBox.get(id);
    sound.soundFile.delete();
    sound.imageFile?.delete();
    await soundBox.delete(id);
    if (await onlineMode()) deleteFromCloud(id);
    notifyListeners();
  }

  Future<void> deleteFromCloud(String id) async {
    Reference ref = FirebaseStorage.instance.ref().child('user_sounds').child(FirebaseAuth.instance.currentUser!.uid);
    var doc = FirebaseFirestore.instance.collection('/users/${FirebaseAuth.instance.currentUser!.uid}/sounds').doc(id);
    String soundExtension = (await doc.get())['soundExtension'];
    var soundRef = ref.child(id + soundExtension);
    var imageRef = ref.child(id + '.jpg');
    imageRef.delete();
    soundRef.delete();
    doc.delete();
  }
}

@HiveType(typeId: 0)
class Sound {
  late File soundFile;
  File? imageFile;
  @HiveField(0)
  late String name;
  @HiveField(1)
  late String id;
  @HiveField(2)
  String? imagePath;
  @HiveField(3)
  late String soundPath;
  @HiveField(4)
  bool isUploadedToServer = false;

  Sound({required this.name, required this.id, required this.soundPath, this.imagePath}) {
    soundFile = File(soundPath);
    if (imagePath != null) {
      imageFile = File(imagePath!);
    }
  }

  ///Only creates a new instance
  Sound.create();

  Future<void> initFromBytes(
      {required Uint8List soundBytes,
      Uint8List? imageBytes,
      required String soundExtension,
      required id,
      String? name}) async {
    this.id = id;
    if (name != null && name.isNotEmpty) {
      this.name = name;
    } else {
      this.name = 'Sound';
    }

    List<Future> futures = [];
    String directory = (await getApplicationDocumentsDirectory()).path;
    futures.add(File(directory + '/' + id.toString() + soundExtension).writeAsBytes(soundBytes).then(((val) {
      soundFile = val;
      soundPath = val.path;
    })));
    if (imageBytes != null) {
      futures.add(File(directory + '/' + id.toString() + '.jpg').writeAsBytes(imageBytes).then(((val) {
        imageFile = val;
        imagePath = val.path;
      })));
    }
    await Future.wait(futures);
  }

  Future<void> init({required File cachedSoundFile, File? cachedImageFile, String? name}) async {
    id = DateTime.now().millisecondsSinceEpoch.toString();

    if (name != null && name.isNotEmpty) {
      this.name = name;
    } else {
      this.name = 'Sound';
    }
    List<Future> futures = [];
    String directory = (await getApplicationDocumentsDirectory()).path;
    futures.add(cachedSoundFile.copy(directory + '/' + id.toString() + p.extension(cachedSoundFile.path)).then((value) {
      soundFile = value;
      soundPath = value.path;
      cachedSoundFile.delete();
    }));
    if (cachedImageFile != null) {
      futures.add(cachedImageFile
          .copy(directory + '/' + id.toString() + '.jpg' /* p.extension(cachedImageFile.path) */)
          .then((value) {
        imageFile = value;
        imagePath = value.path;
        cachedImageFile.delete();
      }));
    }
    await Future.wait(futures);
  }
}

class SoundAdapter extends TypeAdapter<Sound> {
  @override
  final int typeId = 0;

  @override
  Sound read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Sound(
      name: fields[0] as String,
      id: fields[1] as String,
      soundPath: fields[3] as String,
      imagePath: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Sound obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.imagePath)
      ..writeByte(3)
      ..write(obj.soundPath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is SoundAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}
