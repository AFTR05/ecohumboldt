import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class ImageAIValidator {
  static const String _apiKey = String.fromEnvironment("GEMINI_API_KEY");

  Future<bool> validateImageFlexible({
    required Uint8List imageBytes,
    required String expectedLabel, // Ej: "botella", "bicicleta"
  }) async {
    try {
      final String base64Image = base64Encode(imageBytes);

      final url = Uri.parse(
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$_apiKey",
      );

      final payload = {
        "contents": [
          {
            "parts": [
              {
                "text":
                    "Analiza la imagen. RESPONDE SOLO 'si' o 'no'. "
                    "¿La imagen contiene algo que se parezca a: $expectedLabel ? "
                    "Sé flexible: si el objeto es similar, está parcialmente visible, no es perfecto "
                    "Si es un termo personal, Quiero saber si aparece un ENVASE REUTILIZABLE para beber agua, como:- termos metálicos (acero inoxidable, aluminio)- botellas deportivas resistentes- botellas reutilizables gruesas (Nalgene, Camelbak, etc.)- botellas tipo termo con tapa rosca o tapa deportiva- envases diseñados para ser rellenados muchas veces"
                    "o hay variaciones, responde 'si'. "
                    "Solo responde 'no' si no hay absolutamente nada relacionado."
              },
              {
                "inline_data": {
                  "mime_type": "image/jpeg",
                  "data": base64Image,
                }
              }
            ]
          }
        ]
      };

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      final data = jsonDecode(response.body);

      final text = data["candidates"]?[0]?["content"]?["parts"]?[0]?["text"]
          ?.toString()
          .trim()
          .toLowerCase();

      if (text == null) return false;

      return text.contains("si");
    } catch (e) {
      print("Gemini exception: $e");
      return false;
    }
  }
}
