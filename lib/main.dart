import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Para cargar variables .env
import 'package:cached_network_image/cached_network_image.dart'; // Para imágenes en red
import 'package:google_fonts/google_fonts.dart'; // Para fuentes desde Google Fonts
import 'api_service.dart';

void main() async {
  // Carga el archivo .env
  await dotenv.load(fileName: ".env");

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Conversor de Moneda',
      theme: ThemeData(
        primarySwatch: Colors.amber,
        appBarTheme: AppBarTheme(
          titleTextStyle: GoogleFonts.libreBaskerville(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          backgroundColor: Colors.amber,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: CurrencyConverter(),
    );
  }
}

class CurrencyConverter extends StatefulWidget {
  @override
  _CurrencyConverterState createState() => _CurrencyConverterState();
}

class _CurrencyConverterState extends State<CurrencyConverter> {
  final TextEditingController _amountController = TextEditingController();
  String _fromCurrency = 'EUR'; // moneda base
  String _toCurrency = 'GBP'; // inicial
  double _convertedAmount = 0.0;
  bool _isLoading = false;
  String _errorMessage = '';

  // Lista de monedas permitidas
  final List<String> _currencies = ['EUR', 'GBP', 'CAD', 'PLN'];

  Future<void> _convert() async {
    setState(() {
      _isLoading = true;
      _errorMessage = ''; // Limpiar el mensaje de error antes de todoo
    });

    try {
      double amount = double.parse(_amountController.text);
      double result = await ApiService()
          .convertCurrency(_fromCurrency, _toCurrency, amount);
      setState(() {
        _convertedAmount = result;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversor de Moneda'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Imagen de fondo cargada desde la URL del google
          CachedNetworkImage(
            imageUrl:
                'https://drive.google.com/uc?export=view&id=10Q_Vg6zBLyH0nqL1Hju353JyiqoWoYEd',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            placeholder: (context, url) =>
                const Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
          // Contenido principal
          
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 30),
                TextField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    labelText: 'Cantidad',
                    labelStyle:
                        GoogleFonts.libreBaskerville(color: Colors.white),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                  ),
                  style: GoogleFonts.libreBaskerville(color: Colors.white),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 30),

                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20), // Bordes
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5), // Sombra opaca
                        spreadRadius: 3, // Extiende sombra
                        blurRadius: 8, // Desenfoque sombra
                        offset: Offset(0, 4), // Desplazamiento sombra
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20), // Bordes redondeaados
                    child: Image.asset(
                      'assets/my_animation.gif',
                      height: 150,
                      width: 150,
                      fit: BoxFit.cover,
                      alignment: Alignment.center, // Centra la imagen
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Dropdown para seleccionar la moneda de origen
                DropdownButton<String>(
                  value: _fromCurrency,
                  onChanged: (value) {
                    setState(() {
                      _fromCurrency = value!;
                    });
                  },
                  items: _currencies.map((String currency) {
                    return DropdownMenuItem<String>(
                      value: currency,
                      child: Text(
                        currency,
                        style:
                            GoogleFonts.libreBaskerville(color: Colors.white),
                      ),
                    );
                  }).toList(),
                  dropdownColor: Colors.amber,
                ),
                SizedBox(height: 16),
                // Dropdown para seleccionar la moneda de destino
                DropdownButton<String>(
                  value: _toCurrency,
                  onChanged: (value) {
                    setState(() {
                      _toCurrency = value!;
                    });
                  },
                  items: _currencies.map((String currency) {
                    return DropdownMenuItem<String>(
                      value: currency,
                      child: Text(
                        currency,
                        style:
                            GoogleFonts.libreBaskerville(color: Colors.white),
                      ),
                    );
                  }).toList(),
                  dropdownColor: Colors.amber,
                ),
                SizedBox(height: 16),
                // Botón para realizar la conversión
                ElevatedButton(
                  onPressed: _isLoading ? null : _convert,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator()
                      : Text(
                          'Procesar',
                          style:
                              GoogleFonts.libreBaskerville(color: Colors.black),
                        ),
                ),
                SizedBox(height: 50),
                // Mostrar el resultado de la conversión
                if (_convertedAmount > 0)
                  Text(
                    '$_convertedAmount $_toCurrency',
                    style: GoogleFonts.libreBaskerville(
                        fontSize: 24, color: Colors.white),
                  ),
                // Muetro el mensaje de error si hay
                if (_errorMessage.isNotEmpty)
                  Text(
                    _errorMessage,
                    style: GoogleFonts.libreBaskerville(color: Colors.red),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
