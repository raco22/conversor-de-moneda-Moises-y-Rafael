import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  // Base URL de la API
  final String _baseUrl = "http://apilayer.net/api/live";

  // Método para obtener el valor de conversión de una moneda a otra
  Future<double> convertCurrency(String fromCurrency, String toCurrency, double amount) async {
    // Obtener la clave API desde el archivo .env
    String apiKey = dotenv.env['API_KEY'] ?? '';
    
    if (apiKey.isEmpty) {
      throw Exception('No se ha encontrado la API key.');
    }

    // Construir la URL con los parámetros necesarios
    final url = Uri.parse(
      '$_baseUrl?access_key=$apiKey&currencies=$fromCurrency,$toCurrency&source=USD&format=1'
    );

    try {
      // Hacer la solicitud GET a la API
      final response = await http.get(url);

      // Verificar si la respuesta es exitosa
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Verificar si la respuesta contiene tasas de cambio
        if (data['success'] == true) {
          final rates = data['quotes']; // Las tasas de cambio están aquí

          // Formato de la clave de la tasa de cambio
          final fromRate = rates['USD$fromCurrency']; // Ejemplo: 'USDUSD', 'USDGBP', etc.
          final toRate = rates['USD$toCurrency'];   // Ejemplo: 'USDUSD', 'USDEUR', etc.

          // Verificar que las tasas de cambio no sean nulas
          if (fromRate != null && toRate != null) {
            // Calcular la cantidad convertida
            double convertedAmount = (amount / fromRate) * toRate;
            return convertedAmount;
          } else {
            throw Exception('No se pudieron obtener las tasas de cambio para las monedas seleccionadas.');
          }
        } else {
          // Si la API responde con un error, mostrarlo
          throw Exception('Error en la respuesta de la API: ${data['error']['info']}');
        }
      } else {
        // Si el código de estado no es 200, lanzar un error
        throw Exception('Error al obtener los datos de la API. Código de estado: ${response.statusCode}');
      }
    } catch (e) {
      // Capturar cualquier error en la solicitud o en el procesamiento de la respuesta
      throw Exception('Error al obtener las tasas de cambio: $e');
    }
  }
}
