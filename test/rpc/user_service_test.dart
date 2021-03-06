// Copyright (c) 2016, Rémi Groult.
// All rights reserved. Use of this source code is governed by a
// MIT-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:core';
import 'package:test/test.dart';
import 'dart:io';
import 'dart:convert';
import '../../bin/server.dart' as server;
import 'rpc_commons.dart';
import 'rpc_utilities.dart';
import '../../server/managers/managers.dart' as mgrs;
import '../../server/config/config.dart' as config;
void main() {
  //start server
  HttpServer httpServer = null;

  test("start server", () async {
    httpServer = await server.startServer(resetDatabaseContent:true);
  });

  test("configure values", () async {
    baseUrlHost = "http://${httpServer.address.host}:${httpServer.port}";
    print('baseUrlHost : $baseUrlHost');
  });

  allTests();

  test("stop server", () async  {
    // HttpApiResponse response = await _sendRequest('GET', 'get/simple');
    await server.stopServer(force:true);
    print('server stopped');
  });
/*
  test("stop server", () async {
    // HttpApiResponse response = await _sendRequest('GET', 'get/simple');
    var result = httpServer.close(force:true);
  });*/
}

Future loginTest(String login, String password, {bool mustSuccessful:true, String name}) async {
  //reset auth header
  /* TO DO FIX because auth with header seems to have a bug
  */
  lastAuthorizationHeader = '';
  var response =  await sendRequest('POST', '/api/users/v1/login', body:'username=${login}&password=${password}', contentType:'application/x-www-form-urlencoded');
  print("response ${response.body}");
  var responseJson = parseResponse(response);
  if (mustSuccessful) {
    print("name $name, login $login, password $password, received ${responseJson['data']}");
    expect(response.statusCode, equals(200));
    expect(responseJson["data"]["email"], equals(login));
    if (name != null) {
      expect(responseJson["data"]["name"], equals(name));
    }
  } else {
    expect(response.statusCode, equals(401));
  }
}
/*
Future registerUser(Map userInfos,{bool mustSuccessful:true}) async{
  var response = await sendRequest('POST', '/api/users/v1/register', body: JSON.encode(userInfos));
  if (mustSuccessful){
    expect(response.statusCode, equals(200));
    var responseJson = parseResponse(response);
    expect(responseJson["data"]["name"], equals(userInfos["name"]));
    expect(responseJson["data"]["email"], equals(userInfos["email"]));
  }else {
    expect(response.statusCode, equals(400));
  }
}*/

void allTests() {

  config.loadConfig();

  test("Create sysadmin", () async {
    await mgrs.createSysAdminIfNeeded();
  });

  test("Authent KO", () async {
    await loginTest("toto", "titi", mustSuccessful:false);
  });

  var userRegistration = {"email":"test@test.com", "password":"passwd", "name":"toto"};
  test("Register KO email", () async {
    var userWithoutEmail = new Map.from(userRegistration);
    userWithoutEmail.remove("email");

    var response = await sendRequest('POST', '/api/users/v1/register', body: JSON.encode(userWithoutEmail));
    expect(response.statusCode, equals(400));
    var responseJson = parseResponse(response);
    expect(responseJson["error"]["code"], equals(400));

  });

  test("Register KO password", () async {
    var userWithoutPassword = new Map.from(userRegistration);
    userWithoutPassword.remove("password");

    var response = await sendRequest('POST', '/api/users/v1/register', body: JSON.encode(userWithoutPassword));
    expect(response.statusCode, equals(400));
    var responseJson = parseResponse(response);
    expect(responseJson["error"]["code"], equals(400));

  });

  test("Register KO name", () async {
    var userWithoutName = new Map.from(userRegistration);
    userWithoutName.remove("name");

    var response = await sendRequest('POST', '/api/users/v1/register', body: JSON.encode(userWithoutName));
    expect(response.statusCode, equals(400));
    var responseJson = parseResponse(response);
    expect(responseJson["error"]["code"], equals(400));

  });

  test("Register OK", () async {
    await registerUser(userRegistration,mustSuccessful:true);
    /*var response = await sendRequest('POST', '/api/users/v1/register', body: JSON.encode(userRegistration));
    //print("response ${response.body}");
    expect(response.statusCode, equals(200));
    var responseJson = parseResponse(response);
    expect(responseJson["data"]["name"], equals(userRegistration["name"]));
    expect(responseJson["data"]["email"], equals(userRegistration["email"]));*/
  });

  test("Authent OK", () async {
    await loginTest(userRegistration["email"], userRegistration["password"], mustSuccessful:true,name:userRegistration["name"]);
  });

  test("Retrieve Me", () async {
    var response = await sendRequest('GET','/api/users/v1/me');
    expect(response.statusCode, equals(200));
    var responseJson = parseResponse(response);
    expect(responseJson["data"]["email"], equals(userRegistration["email"]));
    expect(responseJson["data"]["name"], equals(userRegistration["name"]));
  });

  test("Authent Admin OK", () async {
    await loginTest(config.currentLoadedConfig[config.MDT_SYSADMIN_INITIAL_EMAIL],config.currentLoadedConfig[config.MDT_SYSADMIN_INITIAL_PASSWORD], mustSuccessful:true, name:"admin");
  });

  test("All Users  OK", () async {
    var response = await sendRequest('GET','/api/users/v1/all');
    expect(response.statusCode, equals(200));
    var responseJson = parseResponse(response);
    expect(responseJson["list"].length, equals(2));
  });

  test("Update User",() async {
    var userUpdate = {"email":userRegistration["email"], "activated":false, "name":"newName"};
    var response = await sendRequest('PUT','/api/users/v1/user' ,body: JSON.encode(userUpdate));
    expect(response.statusCode, equals(200));
    var responseJson = parseResponse(response);
    expect(responseJson["data"]["name"], equals("newName"));
    expect(responseJson["data"]["isActivated"], equals(false));
  });

  test("Delete User",() async {
    var response = await sendRequest('DELETE','/api/users/v1/user?email=${userRegistration["email"]}');
    expect(response.statusCode, equals(200));
    //try to login must failed
    await loginTest(userRegistration["email"], userRegistration["password"], mustSuccessful:false);
  });
}