import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase data layer. Run supabase/schema.sql before using these methods.
class BackendService {
  BackendService._();
  static final instance = BackendService._();
  SupabaseClient get client => Supabase.instance.client;
  User? get currentUser => client.auth.currentUser;

  Future<AuthResponse> register({required String email, required String password,
    required String fullName, required String role, Map<String, dynamic> details = const {}}) async {
    if (!['student', 'driver'].contains(role)) throw ArgumentError('Role must be student or driver');
    final result = await client.auth.signUp(email: email, password: password,
      data: {'full_name': fullName, 'role': role});
    if (result.user != null && result.session != null) await client.from('profiles').upsert({
      'id': result.user!.id, 'email': email, 'full_name': fullName, 'role': role, 'details': details,
    });
    return result;
  }
  Future<AuthResponse> signIn(String email, String password) => client.auth.signInWithPassword(email: email, password: password);
  Future<void> signOut() => client.auth.signOut();
  Future<Map<String, dynamic>?> getMyProfile() async {
    final id = currentUser?.id; if (id == null) return null;
    return client.from('profiles').select().eq('id', id).maybeSingle();
  }
  Future<void> updateMyProfile(Map<String, dynamic> values) async {
    final id = currentUser?.id; if (id == null) throw StateError('Sign in first');
    await client.from('profiles').update(values).eq('id', id);
  }
  Future<String> uploadProfilePhoto(XFile image) async {
    final id = currentUser?.id; if (id == null) throw StateError('Sign in first');
    final ext = image.name.contains('.') ? image.name.split('.').last : 'jpg';
    final path = '$id/avatar_${DateTime.now().millisecondsSinceEpoch}.$ext';
    await client.storage.from('profile-photos').uploadBinary(path, await image.readAsBytes(),
      fileOptions: FileOptions(contentType: image.mimeType ?? 'image/jpeg', upsert: true));
    final url = client.storage.from('profile-photos').getPublicUrl(path);
    await updateMyProfile({'avatar_url': url}); return url;
  }

Future<List<Map<String, dynamic>>> findRides({String? destination}) async {
  var query = client
      .from('rides')
      .select('*, driver:profiles!rides_driver_id_fkey(full_name,avatar_url)')
      .eq('status', 'open');

  if (destination != null && destination.trim().isNotEmpty) {
    query = query.ilike('destination', '%${destination.trim()}%');
  }

  final result = await query.order('departure_at');

  return List<Map<String, dynamic>>.from(result);
}

  Future<void> createRide({required String pickup, required String destination, required DateTime departureAt,
    required int seats, required String vehicleType, required num fare}) async {
    final id=currentUser?.id; if(id==null) throw StateError('Sign in first');
    if(!['Shuttle','Motorcycle','Tricycle'].contains(vehicleType)) throw ArgumentError('Unsupported vehicle type');
    await client.from('rides').insert({'driver_id':id,'pickup':pickup,'destination':destination,
      'departure_at':departureAt.toIso8601String(),'seats_available':seats,'vehicle_type':vehicleType,'fare':fare,'status':'open'});
  }
  Future<void> requestRide(String rideId,{String? note}) async {
    final id=currentUser?.id; if(id==null) throw StateError('Sign in first');
    await client.from('ride_requests').insert({'ride_id':rideId,'student_id':id,'note':note});
  }
  Future<void> sendMessage({required String conversationId,required String body}) async {
    final id=currentUser?.id; if(id==null) throw StateError('Sign in first');
    await client.from('messages').insert({'conversation_id':conversationId,'sender_id':id,'body':body.trim()});
  }
  Stream<List<Map<String,dynamic>>> watchMessages(String conversationId) =>
      client.from('messages').stream(primaryKey: ['id']).map((rows) =>
        rows.where((row) => row['conversation_id'] == conversationId).toList()
          ..sort((a, b) => (a['created_at'] as String).compareTo(b['created_at'] as String)));
  Future<void> upsertDriverLocation({required double latitude,required double longitude,required double accuracy,String? activeRideId}) async {
    final id=currentUser?.id; if(id==null) throw StateError('Sign in first');
    await client.from('driver_locations').upsert({'driver_id':id,'ride_id':activeRideId,'latitude':latitude,'longitude':longitude,'accuracy_m':accuracy,'updated_at':DateTime.now().toUtc().toIso8601String()});
  }
  Stream<List<Map<String,dynamic>>> watchDriverLocation(String driverId) =>
      client.from('driver_locations').stream(primaryKey: ['driver_id']).map((rows) =>
        rows.where((row) => row['driver_id'] == driverId).toList());
  Future<void> createEmergencyAlert({required String message,required double latitude,required double longitude}) async {
    final id=currentUser?.id; if(id==null) throw StateError('Sign in first');
    await client.from('emergency_alerts').insert({'reporter_id':id,'message':message,'latitude':latitude,'longitude':longitude,'status':'open'});
  }
  Future<void> upsertStudentLocation({required String rideId, required double latitude,
    required double longitude, required double accuracy}) async {
    final id = currentUser?.id;
    if (id == null) throw StateError('Sign in first');
    await client.from('student_locations').upsert({
      'student_id': id, 'ride_id': rideId, 'latitude': latitude,
      'longitude': longitude, 'accuracy_m': accuracy,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  Future<void> clearMyStudentLocation(String rideId) async {
    final id = currentUser?.id;
    if (id == null) return;
    await client.from('student_locations').delete()
      .eq('student_id', id).eq('ride_id', rideId);
  }

  Stream<List<Map<String, dynamic>>> watchStudentLocation(String studentId, String rideId) =>
      client.from('student_locations').stream(primaryKey: ['student_id']).map((rows) =>
        rows.where((row) => row['student_id'] == studentId && row['ride_id'] == rideId).toList());

  Future<List<Map<String, dynamic>>> getMyRideRequests() async {
    final id = currentUser?.id;
    if (id == null) throw StateError('Sign in first');
    return List<Map<String, dynamic>>.from(await client
      .from('ride_requests')
      .select('id, student_id, status, ride_id, profiles:student_id(full_name), rides!inner(driver_id,pickup,destination)')
      .eq('rides.driver_id', id)
      .inFilter('status', ['pending', 'accepted']));
  }

  Future<void> savePushToken(String token,{required String platform}) async {
    final id=currentUser?.id; if(id==null) return;
    await client.from('device_tokens').upsert({'user_id':id,'token':token,'platform':platform,'updated_at':DateTime.now().toUtc().toIso8601String()});
  }
}
