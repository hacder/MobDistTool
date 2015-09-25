import 'package:mongo_dart/mongo_dart.dart';
import 'dart:async';
import 'package:objectory/objectory_console.dart';
import '../model/model.dart';

Db mongoDb = null;

//Objectory globalObjectory = nil;

Future initialize() async {
  //mongoDb =  new Db("mongodb://localhost:27017/mdt_dev");
  const Uri = "mongodb://localhost:27017/mdt_dev";
  objectory = new ObjectoryDirectConnectionImpl(Uri,registerClasses,true);
  //globalObjectory = objectory;
  return await objectory.initDomainModel();
 // return await mongoDb.open();
}
