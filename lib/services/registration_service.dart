import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/emailjs_config.dart';

class RegistrationException implements Exception {
  const RegistrationException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class RegistrationService {
  RegistrationService({http.Client? client}) : _client = client ?? http.Client();

  static final Uri _endpoint =
      Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

  final http.Client _client;

  Future<void> submit({
    required String name,
    required String profession,
    required String email,
  }) async {
    if (!EmailJsConfig.isConfigured) {
      throw const RegistrationException(
        'EmailJS n’est pas configuré dans cette version de l’application.',
      );
    }

    final now = DateTime.now().toUtc().toIso8601String();
    final cleanName = name.trim();
    final cleanProfession = profession.trim();
    final cleanEmail = email.trim().toLowerCase();

    try {
      final response = await _client
          .post(
            _endpoint,
            headers: const <String, String>{
              'Accept': 'application/json, text/plain, */*',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(<String, dynamic>{
              'service_id': EmailJsConfig.serviceId,
              'template_id': EmailJsConfig.templateId,
              'user_id': EmailJsConfig.publicKey,
              'template_params': <String, String>{
                // Variables principales du modèle EmailJS « Contact Us ».
                'name': cleanName,
                'profession': cleanProfession,
                'email': cleanEmail,
                'date': now,
                'time': now,
                'title': 'Nouvelle inscription DroneAtlas',
                'message': 'Nom : $cleanName\n'
                    'Profession : $cleanProfession\n'
                    'E-mail : $cleanEmail\n'
                    'Date : $now',

                // Variables de destination et alias utiles si le modèle évolue.
                'to_email': EmailJsConfig.receiverEmail,
                'to_name': 'Novateur221',
                'from_name': cleanName,
                'reply_to': cleanEmail,
                'user_name': cleanName,
                'user_profession': cleanProfession,
                'user_email': cleanEmail,
                'application_name': 'DroneAtlas Nova',
                'submitted_at': now,
                'subject': 'Nouvelle inscription DroneAtlas — $cleanName',
              },
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final details = response.body.trim();
        throw RegistrationException(
          details.isEmpty
              ? 'EmailJS a refusé l’envoi (code ${response.statusCode}).'
              : 'EmailJS ${response.statusCode} : $details',
          statusCode: response.statusCode,
        );
      }
    } on TimeoutException {
      throw const RegistrationException(
        'Le serveur EmailJS ne répond pas. Vérifie Internet puis réessaie.',
      );
    } on http.ClientException catch (error) {
      throw RegistrationException(
        'Connexion à EmailJS impossible : ${error.message}',
      );
    } on RegistrationException {
      rethrow;
    } catch (error) {
      throw RegistrationException(
        'Erreur d’envoi EmailJS : $error',
      );
    }
  }

  void dispose() => _client.close();
}
