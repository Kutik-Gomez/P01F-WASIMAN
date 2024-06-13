import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TokenManager {
  static const _key = 'jwt_token';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  static Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

class ComentarioPagina extends StatefulWidget {
  final int viajeId;

  ComentarioPagina({required this.viajeId});

  @override
  _ComentarioPaginaState createState() => _ComentarioPaginaState();
}

class _ComentarioPaginaState extends State<ComentarioPagina> {
  final _comentarioController = TextEditingController();
  final _calificacionController = TextEditingController();
  bool _isLoading = false;

  Future<void> _mostrarDialogo(String mensaje) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 60),
              SizedBox(height: 16),
              Text(mensaje),
            ],
          ),
        );
      },
    );

    await Future.delayed(Duration(seconds: 2));
    Navigator.of(context).pop();
  }

  Future<void> _enviarComentario() async {
    final comentario = _comentarioController.text;
    final calificacion = int.tryParse(_calificacionController.text);

    if (comentario.isEmpty ||
        calificacion == null ||
        calificacion < 1 ||
        calificacion > 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Ingrese un comentario y una calificación válida (entre 1 y 5)')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final token = await TokenManager.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Token no disponible. Por favor, inicie sesión de nuevo.')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final uri = Uri.parse('http://localhost:7777/api/comentarios/crear');
    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'viajeId': widget.viajeId,
        'comentario': comentario,
        'calificacion': calificacion,
      }),
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 201) {
      await _mostrarDialogo('Comentario enviado con éxito');
      Navigator.pop(context);
    } else {
      final responseData = json.decode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Error al enviar el comentario: ${responseData['error'] ?? response.body}')),
      );
    }
  }

  @override
  void dispose() {
    _comentarioController.dispose();
    _calificacionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Comparte tu opinión',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xff688C6A),
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 100),
            Icon(
              FontAwesomeIcons.solidCommentDots,
              size: 90,
              color: Color(0xff0E402E),
            ),
            SizedBox(height: 30),
            TextField(
              controller: _comentarioController,
              decoration: InputDecoration(
                labelText: 'Comentario',
                labelStyle: TextStyle(fontSize: 18),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.orange,
                    width: 2.0,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 10,
                ),
                suffixIcon: Icon(
                  FontAwesomeIcons.pen,
                  color: Color(0xff0E402E),
                  size: 28,
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _calificacionController,
              decoration: InputDecoration(
                labelText: 'Calificación (1-5)',
                labelStyle: TextStyle(fontSize: 18),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.orange,
                    width: 2.0,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 10,
                ),
                suffixIcon: Icon(
                  FontAwesomeIcons.solidStar,
                  color: Color(0xff0E402E),
                  size: 28,
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _enviarComentario,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      child: Text(
                        'ENVIAR',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xff0E402E),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xffF29F05),
                      elevation: 4,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
