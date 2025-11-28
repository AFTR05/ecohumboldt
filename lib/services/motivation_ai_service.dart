import 'dart:convert';
import 'package:http/http.dart' as http;

class MotivationAIService {
  static final String _apiKey = String.fromEnvironment("GEMINI_API_KEY");

  /// Cache para evitar hacer múltiples peticiones por usuario
  static final Map<String, String> _cachedPhrases = {};

  /// Retorna una frase motivacional MUY corta y ambiental
  /// personalizada según el programa del usuario.
  Future<String> generateMotivation({
    required String program,
    required String uid,
  }) async {
    // 1. Si el usuario ya tiene frase en caché → devolverla
    if (_cachedPhrases.containsKey(uid)) {
      return _cachedPhrases[uid]!;
    }

    if (_apiKey.isEmpty) {
      return "🌿 Sigue aportando al planeta.";
    }

    final url = Uri.parse(
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$_apiKey",
    );

    final payload = {
      "contents": [
        {
          "parts": [
            {
              "text":
                  "Crea una frase motivacional muy corta (máximo 12 palabras), "
                  "ecológica, positiva y personalizada para un estudiante del programa: $program. "
                  "Debe ser ambiental, inspiradora y adecuada para una app sostenible. "
                  "Responde solo la frase."
            }
          ]
        }
      ]
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      final data = jsonDecode(response.body);

      final text = data["candidates"]?[0]?["content"]?["parts"]?[0]?["text"]
          ?.toString()
          .trim();

      final phrase =
          (text != null && text.isNotEmpty) ? text : "🌿 Sigue aportando al planeta.";

      // 2. Guardar en caché para no repetir la petición nunca más
      _cachedPhrases[uid] = phrase;

      return phrase;
    } catch (e) {
      return "🌿 Pequeñas acciones crean grandes cambios.";
    }
  }
}
