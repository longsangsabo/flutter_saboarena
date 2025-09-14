import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/supabase_config.dart';

/// Storage service for handling file uploads and downloads with Supabase Storage
class SupabaseStorageService {
  static final _client = SupabaseConfig.client;

  // Storage bucket names
  static const String avatarsBucket = 'avatars';
  static const String clubLogosBucket = 'club-logos';
  static const String tournamentBannersBucket = 'tournament-banners';
  static const String matchMediaBucket = 'match-media';
  static const String chatFilesBucket = 'chat-files';

  // =====================================================
  // AVATAR OPERATIONS
  // =====================================================

  /// Upload user avatar
  static Future<String?> uploadAvatar(File file, String userId) async {
    try {
      final fileName = '$userId-${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = '$userId/$fileName';
      
      await _client.storage
          .from(avatarsBucket)
          .upload(path, file, fileOptions: const FileOptions(upsert: true));
      
      return _client.storage.from(avatarsBucket).getPublicUrl(path);
    } catch (e) {
      print('Error uploading avatar: $e');
      return null;
    }
  }

  /// Upload avatar from bytes
  static Future<String?> uploadAvatarFromBytes(
    Uint8List bytes, 
    String userId,
    String fileName,
  ) async {
    try {
      final path = '$userId/$fileName';
      
      await _client.storage
          .from(avatarsBucket)
          .uploadBinary(path, bytes, fileOptions: const FileOptions(upsert: true));
      
      return _client.storage.from(avatarsBucket).getPublicUrl(path);
    } catch (e) {
      print('Error uploading avatar from bytes: $e');
      return null;
    }
  }

  /// Delete user avatar
  static Future<bool> deleteAvatar(String userId, String fileName) async {
    try {
      final path = '$userId/$fileName';
      await _client.storage.from(avatarsBucket).remove([path]);
      return true;
    } catch (e) {
      print('Error deleting avatar: $e');
      return false;
    }
  }

  /// Get avatar URL
  static String? getAvatarUrl(String userId, String fileName) {
    try {
      final path = '$userId/$fileName';
      return _client.storage.from(avatarsBucket).getPublicUrl(path);
    } catch (e) {
      print('Error getting avatar URL: $e');
      return null;
    }
  }

  // =====================================================
  // CLUB LOGO OPERATIONS
  // =====================================================

  /// Upload club logo
  static Future<String?> uploadClubLogo(File file, String clubId) async {
    try {
      final fileName = '$clubId-logo-${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = '$clubId/$fileName';
      
      await _client.storage
          .from(clubLogosBucket)
          .upload(path, file, fileOptions: const FileOptions(upsert: true));
      
      return _client.storage.from(clubLogosBucket).getPublicUrl(path);
    } catch (e) {
      print('Error uploading club logo: $e');
      return null;
    }
  }

  /// Upload club logo from bytes
  static Future<String?> uploadClubLogoFromBytes(
    Uint8List bytes, 
    String clubId,
    String fileName,
  ) async {
    try {
      final path = '$clubId/$fileName';
      
      await _client.storage
          .from(clubLogosBucket)
          .uploadBinary(path, bytes, fileOptions: const FileOptions(upsert: true));
      
      return _client.storage.from(clubLogosBucket).getPublicUrl(path);
    } catch (e) {
      print('Error uploading club logo from bytes: $e');
      return null;
    }
  }

  /// Delete club logo
  static Future<bool> deleteClubLogo(String clubId, String fileName) async {
    try {
      final path = '$clubId/$fileName';
      await _client.storage.from(clubLogosBucket).remove([path]);
      return true;
    } catch (e) {
      print('Error deleting club logo: $e');
      return false;
    }
  }

  // =====================================================
  // TOURNAMENT BANNER OPERATIONS
  // =====================================================

  /// Upload tournament banner
  static Future<String?> uploadTournamentBanner(File file, String tournamentId) async {
    try {
      final fileName = '$tournamentId-banner-${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = '$tournamentId/$fileName';
      
      await _client.storage
          .from(tournamentBannersBucket)
          .upload(path, file, fileOptions: const FileOptions(upsert: true));
      
      return _client.storage.from(tournamentBannersBucket).getPublicUrl(path);
    } catch (e) {
      print('Error uploading tournament banner: $e');
      return null;
    }
  }

  /// Upload tournament banner from bytes
  static Future<String?> uploadTournamentBannerFromBytes(
    Uint8List bytes, 
    String tournamentId,
    String fileName,
  ) async {
    try {
      final path = '$tournamentId/$fileName';
      
      await _client.storage
          .from(tournamentBannersBucket)
          .uploadBinary(path, bytes, fileOptions: const FileOptions(upsert: true));
      
      return _client.storage.from(tournamentBannersBucket).getPublicUrl(path);
    } catch (e) {
      print('Error uploading tournament banner from bytes: $e');
      return null;
    }
  }

  // =====================================================
  // MATCH MEDIA OPERATIONS
  // =====================================================

  /// Upload match media (photos/videos)
  static Future<String?> uploadMatchMedia(File file, String matchId, String mediaType) async {
    try {
      final extension = file.path.split('.').last;
      final fileName = '$matchId-$mediaType-${DateTime.now().millisecondsSinceEpoch}.$extension';
      final path = '$matchId/$fileName';
      
      await _client.storage
          .from(matchMediaBucket)
          .upload(path, file, fileOptions: const FileOptions(upsert: false));
      
      return _client.storage.from(matchMediaBucket).getPublicUrl(path);
    } catch (e) {
      print('Error uploading match media: $e');
      return null;
    }
  }

  /// Upload match media from bytes
  static Future<String?> uploadMatchMediaFromBytes(
    Uint8List bytes, 
    String matchId,
    String mediaType,
    String fileName,
  ) async {
    try {
      final path = '$matchId/$fileName';
      
      await _client.storage
          .from(matchMediaBucket)
          .uploadBinary(path, bytes, fileOptions: const FileOptions(upsert: false));
      
      return _client.storage.from(matchMediaBucket).getPublicUrl(path);
    } catch (e) {
      print('Error uploading match media from bytes: $e');
      return null;
    }
  }

  /// Get match media files
  static Future<List<FileObject>> getMatchMediaFiles(String matchId) async {
    try {
      final response = await _client.storage
          .from(matchMediaBucket)
          .list(path: matchId);
      return response;
    } catch (e) {
      print('Error getting match media files: $e');
      return [];
    }
  }

  // =====================================================
  // CHAT FILES OPERATIONS
  // =====================================================

  /// Upload chat file
  static Future<String?> uploadChatFile(File file, String chatContext, String senderId) async {
    try {
      final extension = file.path.split('.').last;
      final fileName = '$senderId-${DateTime.now().millisecondsSinceEpoch}.$extension';
      final path = '$chatContext/$fileName';
      
      await _client.storage
          .from(chatFilesBucket)
          .upload(path, file, fileOptions: const FileOptions(upsert: false));
      
      return _client.storage.from(chatFilesBucket).getPublicUrl(path);
    } catch (e) {
      print('Error uploading chat file: $e');
      return null;
    }
  }

  // =====================================================
  // GENERAL OPERATIONS
  // =====================================================

  /// Get file info
  static Future<FileObject?> getFileInfo(String bucket, String path) async {
    try {
      final response = await _client.storage
          .from(bucket)
          .list(path: path);
      return response.isNotEmpty ? response.first : null;
    } catch (e) {
      print('Error getting file info: $e');
      return null;
    }
  }

  /// Download file as bytes
  static Future<Uint8List?> downloadFile(String bucket, String path) async {
    try {
      final response = await _client.storage
          .from(bucket)
          .download(path);
      return response;
    } catch (e) {
      print('Error downloading file: $e');
      return null;
    }
  }

  /// Delete file
  static Future<bool> deleteFile(String bucket, String path) async {
    try {
      await _client.storage.from(bucket).remove([path]);
      return true;
    } catch (e) {
      print('Error deleting file: $e');
      return false;
    }
  }

  /// Get signed URL for private files
  static Future<String?> getSignedUrl(String bucket, String path, {int expiresIn = 3600}) async {
    try {
      final response = await _client.storage
          .from(bucket)
          .createSignedUrl(path, expiresIn);
      return response;
    } catch (e) {
      print('Error getting signed URL: $e');
      return null;
    }
  }

  /// Create storage bucket (admin operation)
  static Future<bool> createBucket(String bucketName, {bool isPublic = true}) async {
    try {
      await _client.storage.createBucket(
        bucketName,
        BucketOptions(
          public: isPublic,
          allowedMimeTypes: ['image/jpeg', 'image/png', 'image/gif', 'video/mp4', 'application/pdf'],
          fileSizeLimit: '50MB',
        ),
      );
      return true;
    } catch (e) {
      print('Error creating bucket: $e');
      return false;
    }
  }

  /// List all buckets
  static Future<List<Bucket>> listBuckets() async {
    try {
      final response = await _client.storage.listBuckets();
      return response;
    } catch (e) {
      print('Error listing buckets: $e');
      return [];
    }
  }

  /// Get bucket details
  static Future<Bucket?> getBucket(String bucketName) async {
    try {
      final response = await _client.storage.getBucket(bucketName);
      return response;
    } catch (e) {
      print('Error getting bucket: $e');
      return null;
    }
  }

  /// Empty bucket
  static Future<bool> emptyBucket(String bucketName) async {
    try {
      await _client.storage.emptyBucket(bucketName);
      return true;
    } catch (e) {
      print('Error emptying bucket: $e');
      return false;
    }
  }

  /// Delete bucket
  static Future<bool> deleteBucket(String bucketName) async {
    try {
      await _client.storage.deleteBucket(bucketName);
      return true;
    } catch (e) {
      print('Error deleting bucket: $e');
      return false;
    }
  }

  // =====================================================
  // HELPER METHODS
  // =====================================================

  /// Get file extension from path
  static String getFileExtension(String path) {
    return path.split('.').last.toLowerCase();
  }

  /// Check if file is image
  static bool isImageFile(String path) {
    final extension = getFileExtension(path);
    return ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension);
  }

  /// Check if file is video
  static bool isVideoFile(String path) {
    final extension = getFileExtension(path);
    return ['mp4', 'avi', 'mov', 'mkv', 'webm'].contains(extension);
  }

  /// Generate unique file name
  static String generateUniqueFileName(String originalName, String prefix) {
    final extension = getFileExtension(originalName);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '$prefix-$timestamp.$extension';
  }

  /// Get human readable file size
  static String getFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}