import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  var req = http.MultipartRequest(
    'POST', 
    Uri.parse('https://api.cloudinary.com/v1_1/fc6sdriz/image/upload')
  );
  req.fields['upload_preset'] = 'flutter_upload';
  req.files.add(http.MultipartFile.fromBytes('file', [1,2,3,4], filename: 'test.jpg'));
  
  var res = await req.send();
  var body = await res.stream.bytesToString();
  print('STATUS: ${res.statusCode}');
  print('BODY: $body');
}
