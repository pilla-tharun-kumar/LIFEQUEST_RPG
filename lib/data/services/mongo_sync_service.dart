import 'dart:convert';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:hive/hive.dart';
import '../../core/config.dart';

class MongoSyncService {
  static late Box<String> _pendingSyncsBox;

  static Future<void> initialize() async {
    // Open a simple Hive box to queue pending synchronization tasks when offline
    _pendingSyncsBox = await Hive.openBox<String>('pending_syncs');
    
    // Process any items left over from previous sessions
    if (RpgConfig.isMongoSyncEnabled) {
      Future.microtask(() => processOfflineQueue());
    }
  }

  /// Pushes a document change to MongoDB Atlas
  static Future<void> syncDocument({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    if (!RpgConfig.isMongoSyncEnabled) {
      return;
    }

    final filter = {"id": documentId};
    final update = {"\$set": data};

    final payloadString = jsonEncode({
      "action": "updateOne",
      "collection": collection,
      "documentId": documentId,
      "body": {
        "filter": filter,
        "update": update,
      }
    });

    try {
      final success = await _sendRequest(
        action: "updateOne",
        collection: collection,
        body: {
          "filter": filter,
          "update": update,
        },
      );

      if (!success) {
        // Queue payload locally if connection failed
        await _pendingSyncsBox.put(DateTime.now().toIso8601String(), payloadString);
        print("💾 [MongoSync] Offline: Queued quest/profile change locally.");
      }
    } catch (e) {
      await _pendingSyncsBox.put(DateTime.now().toIso8601String(), payloadString);
      print("💾 [MongoSync] Connection Error: Queued change locally. ($e)");
    }
  }

  /// Deletes a document from MongoDB Atlas
  static Future<void> deleteDocument({
    required String collection,
    required String documentId,
  }) async {
    if (!RpgConfig.isMongoSyncEnabled) {
      return;
    }

    final filter = {"id": documentId};

    final payloadString = jsonEncode({
      "action": "deleteOne",
      "collection": collection,
      "documentId": documentId,
      "body": {
        "filter": filter
      }
    });

    try {
      final success = await _sendRequest(
        action: "deleteOne",
        collection: collection,
        body: {
          "filter": filter
        },
      );

      if (!success) {
        await _pendingSyncsBox.put(DateTime.now().toIso8601String(), payloadString);
      }
    } catch (e) {
      await _pendingSyncsBox.put(DateTime.now().toIso8601String(), payloadString);
    }
  }

  /// Attempts to process all queued sync actions
  static Future<void> processOfflineQueue() async {
    if (!RpgConfig.isMongoSyncEnabled || _pendingSyncsBox.isEmpty) {
      return;
    }

    print("🔄 [MongoSync] Checking offline queue: ${_pendingSyncsBox.length} tasks pending...");
    final keys = List<String>.from(_pendingSyncsBox.keys);

    for (var key in keys) {
      final taskJson = _pendingSyncsBox.get(key);
      if (taskJson == null) continue;

      try {
        final task = jsonDecode(taskJson);
        final String action = task["action"];
        final String collection = task["collection"];
        final Map<String, dynamic> body = Map<String, dynamic>.from(task["body"]);

        final success = await _sendRequest(
          action: action, 
          collection: collection,
          body: body,
        );
        if (success) {
          await _pendingSyncsBox.delete(key);
          print("✅ [MongoSync] Successfully synced queued task: $key");
        } else {
          // Break cycle if server is still unreachable
          break;
        }
      } catch (e) {
        print("⚠️ [MongoSync] Error running queued task: $e");
        await _pendingSyncsBox.delete(key); // clear corrupted task
      }
    }
  }

  /// Performs the actual socket connection to MongoDB Atlas and executes the action
  static Future<bool> _sendRequest({
    required String action,
    required String collection,
    required Map<String, dynamic> body,
  }) async {
    mongo.Db? db;
    try {
      db = await mongo.Db.create(RpgConfig.mongoUri);
      await db.open().timeout(const Duration(seconds: 4));
      
      final coll = db.collection(collection);

      if (action == "updateOne") {
        final filter = Map<String, dynamic>.from(body["filter"]);
        final update = Map<String, dynamic>.from(body["update"]);
        await coll.updateOne(filter, update, upsert: true);
        return true;
      } else if (action == "deleteOne") {
        final filter = Map<String, dynamic>.from(body["filter"]);
        await coll.deleteOne(filter);
        return true;
      }
      
      return false;
    } catch (e) {
      print("❌ [MongoSync] Database Connection Exception: $e");
      return false;
    } finally {
      if (db != null) {
        try {
          await db.close();
        } catch (_) {}
      }
    }
  }
}
