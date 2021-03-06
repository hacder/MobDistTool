// Copyright (c) 2016, the Mobile App Distribution Tool project authors.
// All rights reserved. Use of this source code is governed by a
// MIT-style license that can be found in the LICENSE file.
import 'dart:convert';
import 'package:bson/bson.dart';
import '../../packages/objectory/objectory.dart';

Map propertiePerClass = {
  "MDTUser" :  ['name','email','isActivated','favoritesApplicationsUUID'],
  "admin_MDTUser" :  ['isSystemAdmin'],
  'MDTApplication' :  ['name','platform','lastVersion','adminUsers','uuid','description'],
  'admin_MDTApplication' :  ['apiKey','maxVersionSecretKey'],
  //'MDTArtifact' : ['uuid','branch','name','creationDate','version','sortIdentifier','metaDataTags'],
  'MDTArtifact' : ['uuid','name','sortIdentifier','metaDataTags','size','creationDate'],
  'admin_MDTArtifact' :  ['branch','version']
};

Map toJsonStringValues(PersistentObject object, List<String> properties){
  var json = {};
  for (var property in properties) {
    var value = object.getProperty(property);
    if (value is List) {
      //nothing
    } else if (value is PersistentObject) {
      //mongodb object
      //nothing
    } else {
      //value
      json[property] = value;
    }
  }
  return json;
}

Map toJson(PersistentObject object, {bool isAdmin:false}){
  var json = {};
  if (object != null) {
    var listProperties =  [];
    var classProperties = propertiePerClass[object.runtimeType.toString()];
    listProperties.addAll(classProperties);
    if (isAdmin) {
      listProperties.addAll(propertiePerClass['admin_${object.runtimeType.toString()}']);
    }
    for (var property in listProperties) {
      var value = object.getProperty(property);
      if (value is List) {
        //test first elt
        var firstElt = value.first;
        if ((firstElt is DbRef) || (firstElt is PersistentObject)){
          //list of object
          json[property] = listToJson(value);
        }else{
          json[property] = value;
        }
      } else if (value is PersistentObject) {
        //mongodb object
        json[property] = toJson(value, isAdmin:isAdmin);
      } else  if (value != null) {
        //value
        if (value is DateTime){
          json[property] = value.toString();
        }else {
          json[property] = value;
        }
      }
    }
  }
  return json;
}

List listToJson(List<PersistentObject> objects, {bool isAdmin:false}){
  /*if (value is DbRef) {
      return objectory.dbRef2Object(value);
    }*/
  var result = [];
  if (objects != null) {
    for (var object in objects) {
      var elt = object;
      if (object is DbRef) {
        elt = objectory.dbRef2Object(object);
      }
      result.add(toJson(elt, isAdmin:isAdmin));
    }
  }
  return result;
}

String parseTags(String tags){
  try {
    if (tags == null) {
      return null;
    }
    var object = JSON.decode(tags);
    if (object != null) {
      return JSON.encode(object);
    }
  }
  catch(e){
  }
  return null;
}

//PersistentObject objectById