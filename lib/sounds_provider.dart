import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

class SoundsProvider with ChangeNotifier {
  final soundBox = Hive.box('sounds');

  List get getSounds {
    return soundBox.values.toList();
  }

  bool get isNotEmpty {
    return soundBox.isNotEmpty;
  }

  Future<void> add({required File cachedSoundFile, File? cachedImageFile, String? name}) async {
    Sound newSound = Sound.create();
    await newSound.init(cachedSoundFile: cachedSoundFile, cachedImageFile: cachedImageFile, name: name);
    await soundBox.put(newSound.id, newSound);
    notifyListeners();
  }

  Future<void> delete(int id) async {
    await soundBox.delete(id);
    notifyListeners();
  }
}

@HiveType(typeId: 0)
class Sound {
  late File soundFile;
  File? imageFile;
  @HiveField(0)
  late String name;
  @HiveField(1)
  late int id;
  @HiveField(2)
  String? imagePath;
  @HiveField(3)
  late String soundPath;

  final prefs = SharedPreferences.getInstance();

  Sound({required this.name, required this.id, required this.soundPath, this.imagePath}) {
    soundFile = File(soundPath);
    if (imagePath != null) {
      imageFile = File(imagePath!);
    }
  }

  Sound.create();

  Future<void> init({required File cachedSoundFile, File? cachedImageFile, String? name}) async {
    id = (await prefs).getInt("count") ?? 0;
    (await prefs).setInt("count", id + 1);
    if (name != null && name.isNotEmpty) {
      this.name = name;
    } else {
      this.name = id.toString();
    }
    List<Future> futures = [];
    String directory = (await getApplicationDocumentsDirectory()).path;
    futures.add(cachedSoundFile.copy(directory + id.toString() + p.extension(cachedSoundFile.path)).then((value) {
      soundFile = value;
      soundPath = value.path;
      cachedSoundFile.delete();
    }));
    if (cachedImageFile != null) {
      futures.add(cachedImageFile.copy(directory + id.toString() + p.extension(cachedImageFile.path)).then((value) {
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
      id: fields[1] as int,
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
