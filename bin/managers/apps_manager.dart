import 'dart:async';
import 'package:objectory/objectory_console.dart';
import '../model/model.dart';
import 'errors.dart';

/*
class MDTApplication extends MDTBaseObject {
  String name;
  String platform;
  List<MDTUser> adminUsers;
  MDTArtifact lastVersion;
}
 */

class AppError extends StateError {
  AppError(String msg) : super(msg);
}

var appCollection = objectory[MDTApplication];

Future<MDTApplication> createApplication(String name, String platform,{MTDUser adminUser}) async {
  if (name == null || name.isEmpty) {
    //return new Future.error(new StateError("bad state"));
    throw new AppError('name must be not null');
  }
  if (platform == null || platform.isEmpty) {
    throw new AppError('platform must be not null');
  }

  //find another app
  var existingApp = await appCollection.findOne(where.eq('name', name,'platform',platform));
  if (existingApp != null) {
    //app already exist
    throw new AppError('App already exist with this name and platform');
  }

  var createdApp = new MDTApplication()
    ..name = name
    ..platform = platform;

  if (adminUser != null)
    createdApp.adminUsers.add(adminUser);

  return await createdApp.save();
}