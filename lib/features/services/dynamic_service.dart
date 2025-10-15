import 'dart:convert';
import 'package:http/http.dart' as http;

class DynamicService {
  final String baseUrl = 'https://api.example.com/v1';

  Future<List<dynamic>> getEntities(String endpoint, String? tenantId, {int? limit}) async {
    final url = '$baseUrl$endpoint${tenantId != null ? '?tenant_id=$tenantId' : ''}${limit != null ? '&limit=$limit' : ''}';
    final response = await http.get(Uri.parse(url));
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to load entities');
  }

  Future<Map<String, dynamic>> getEntityStats(String entityKey, String endpoint, String? tenantId) async {
    final url = '$baseUrl$endpoint/stats${tenantId != null ? '?tenant_id=$tenantId' : ''}';
    final response = await http.get(Uri.parse(url));
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return {};
  }

  Future<dynamic> createEntity(String endpoint, Map<String, dynamic> data, String? tenantId) async {
    if (tenantId != null) data['tenant_id'] = tenantId;
    
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    
    if (response.statusCode == 201) {
      return json.decode(response.body);
    }
    throw Exception('Failed to create entity');
  }
}
