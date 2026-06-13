import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:cloudinary_public/cloudinary_public.dart';
import '../config.dart';

class ApiService {
  static String get baseUrl => AppConfig.baseUrl;

  // Initialize Cloudinary with credentials from config.dart
  static final cloudinary = CloudinaryPublic(
    AppConfig.cloudinaryCloudName,
    AppConfig.cloudinaryUploadPreset,
  );

  // Method to predict a single image
  static Future<Map<String, dynamic>> predictSingleImage(File imageFile) async {
    try {
      // Step 1: Upload the single image to Cloudinary
      CloudinaryResponse cloudinaryResponse = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          resourceType: CloudinaryResourceType.Image,
        ),
      );

      // Step 2: Extract the secure URL (upload failure will throw an exception)
      String imageUrl = cloudinaryResponse.secureUrl;
      if (imageUrl.isEmpty) {
        throw Exception("Cloudinary upload failed: No secure URL returned");
      }

      // Step 3: Send the URL as a single-item list to FastAPI /batch-predict
      var response = await http.post(
        Uri.parse(AppConfig.baseUrl), // Use /batch-predict endpoint
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'images': [imageUrl]}), // Send as a list with one URL
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to fetch prediction: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      throw Exception("Error during image upload or prediction: $e");
    }
  }
}