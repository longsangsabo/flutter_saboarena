import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mime_type/mime_type.dart';

Future<String?> uploadData(String path, Uint8List data) async {
  try {
    final supabase = Supabase.instance.client;
    
    // Extract bucket and file path
    final pathParts = path.split('/');
    final bucket = pathParts.first;
    final filePath = pathParts.skip(1).join('/');
    
    // Upload to Supabase Storage
    await supabase.storage
        .from(bucket)
        .uploadBinary(filePath, data, 
          fileOptions: FileOptions(
            contentType: mime(path),
            upsert: true,
          )
        );
    
    // Get public URL
    final publicUrl = supabase.storage
        .from(bucket)
        .getPublicUrl(filePath);
    
    return publicUrl;
  } catch (e) {
    print('Error uploading to Supabase Storage: $e');
    return null;
  }
}
