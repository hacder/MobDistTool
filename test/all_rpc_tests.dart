// Copyright (c) 2016, Rémi Groult.
// All rights reserved. Use of this source code is governed by a
// MIT-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:core';
import 'package:test/test.dart';
import 'dart:io';
import 'dart:convert';
import 'rpc/user_service_test.dart' as users;
import 'rpc/app_service_test.dart' as apps;
import 'rpc/artifact_service_test.dart' as artifacts;
import 'rpc/rpc_commons.dart';
import '../bin/server.dart' as server;
import '../server/config/src/mongo.dart' as mongo;
import '../server/config/config.dart' as config;
void main()  {

  allTests();

  test("close database", ()  {
     mongo.close();
  });
}

void allTests() {
  //start server
  HttpServer httpServer = null;

  test("start server", () async {
    httpServer =  await server.startServer(resetDatabaseContent:true);

  });

  test("configure values", () async {
    baseUrlHost = "http://${httpServer.address.host}:${httpServer.port}";
    print('baseUrlHost : $baseUrlHost');
    config.currentLoadedConfig[config.MDT_SERVER_URL] = baseUrlHost;
  });

  users.allTests();
  apps.allTests();

  test("reset database before artifacts tests", ()  async {
    await mongo.dropCollections();
  });

  artifacts.allTests();

  test("stop server", () async  {
    // HttpApiResponse response = await _sendRequest('GET', 'get/simple');
    await server.stopServer(force:true);
    print('server stopped');
  });
}