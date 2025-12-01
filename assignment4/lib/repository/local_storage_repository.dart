import 'package:hive/hive.dart';
import '../models/activity_model.dart';

class LocalStorageRepository {
  static const String boxName = 'activities';

  Future<void> saveActivity(ActivityModel activity) async {
    final box = Hive.box<ActivityModel>(boxName);
    await box.put(activity.id, activity);
  }

  Future<List<ActivityModel>> getRecentActivities({int limit = 5}) async {
    final box = Hive.box<ActivityModel>(boxName);
    final activities = box.values.toList();
    activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return activities.take(limit).toList();
  }

  Future<void> deleteActivity(String id) async {
    final box = Hive.box<ActivityModel>(boxName);
    await box.delete(id);
  }

  Future<void> clearAll() async {
    final box = Hive.box<ActivityModel>(boxName);
    await box.clear();
  }

  Future<int> getActivityCount() async {
    final box = Hive.box<ActivityModel>(boxName);
    return box.length;
  }
}