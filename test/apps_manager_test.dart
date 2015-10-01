import 'package:test/test.dart';
import 'dart:async';
import 'package:objectory/objectory_console.dart';
import '../bin/managers/apps_manager.dart' as app_mgr;
import '../bin/managers/users_manager.dart' as user_mgr;
import '../bin/config/mongo.dart' as mongo;

Future main() async {
  await mongo.initialize();
  test("Clean database", () async {
    await objectory.dropCollections();
  });
  group("Application", () {
    test("Create app empty fields", () async {
      //null platform
      var result = false;
      try {
        var result = await app_mgr.createApplication("test", null);
      } on StateError catch (e) {
        result = true;
        expect((e is app_mgr.AppError), isTrue);
      }
      expect(result, isTrue);
      //null name
      result = false;
      try {
        var result = await app_mgr.createApplication(null, "IOS");
      } on StateError catch (e) {
        result = true;
        expect((e is app_mgr.AppError), isTrue);
      }
      expect(result, isTrue);
    });
    var appName = "test";
    var appIOS = "IOS";
    var appAndroid = "Android";
    test("Create app", () async {
      var app = await app_mgr.createApplication(appName,appIOS);
      expect(app.name, equals(appName));
      expect(app.platform, equals(appIOS));
      expect(app.adminUsers.isEmpty,isTrue);
    });
    test("Create same app", () async {
      var result = false;
      try {
        var result = await app_mgr.createApplication(appName,appIOS);
      } on StateError catch (e) {
        result = true;
        expect((e is app_mgr.AppError), isTrue);
      }
      expect(result, isTrue);
    });
    test("Create app same name, another platform", () async {
      var app = await app_mgr.createApplication(appName,appAndroid);
      expect(app.name, equals(appName));
      expect(app.platform, equals(appAndroid));
      expect(app.adminUsers.isEmpty,isTrue);
    });
    test("search app", () async {
      var app = await app_mgr.findApplication(appName,appIOS);
      expect(app.name, equals(appName));
      expect(app.platform, equals(appIOS));
      expect(app.adminUsers.isEmpty,isTrue);

      app = await app_mgr.findApplication(appName,appAndroid);
      expect(app.name, equals(appName));
      expect(app.platform, equals(appAndroid));
      expect(app.adminUsers.isEmpty,isTrue);
    });
    test("Add admin user to app", () async {
        var email = "test@user.com";
        var user = await user_mgr.createUser("user1",email,"password");
        var app = await app_mgr.findApplication(appName,appIOS);
        app.adminUsers.add(user);
        await app.save();
        expect(app.adminUsers.isEmpty,isFalse);
        //chech user
        var adminUser = app.adminUsers.first;
        expect(adminUser.email, equals(email));

        //retrieve other app
        app = await app_mgr.findApplication(appName,appAndroid);
        expect(app.adminUsers.isEmpty,isTrue);

        //delete user
        await user_mgr.deleteUserByEmail(email);
        //check user deleted
        user = await user_mgr.findUserByEmail(email);
        expect(user,isNull);
        //retrieve app and check admin users is empty
        app = await app_mgr.findApplication(appName,appIOS);
        expect(app.adminUsers.isEmpty,isTrue);
    });
  });
}