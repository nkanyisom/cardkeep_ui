import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:card_keep/models/loyalty_card.dart';
import 'package:card_keep/models/user.dart';
import 'package:card_keep/services/simple_auth_service.dart';

/// Simple API service for handling HTTP requests to the Spring Boot backend
class ApiService {
  static const String baseUrl = 'http://localhost:8080/api';
  final SimpleAuthService _authService;

  ApiService(this._authService);

  /// Get headers with JWT token for authenticated requests
  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    try {
      final token = _authService.jwtToken;
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    } catch (e) {
      debugPrint('Error getting JWT token: $e');
    }

    return headers;
  }

  /// Create a new loyalty card
  Future<LoyaltyCard> createCard(LoyaltyCard card) async {
    try {
      final headers = _headers;
      final response = await http
          .post(
            Uri.parse('$baseUrl/cards'),
            headers: headers,
            body: jsonEncode({
              'cardName': card.cardName,
              'barcodeData': card.barcodeData,
              'barcodeType': BarcodeTypeHelper.enumToString(card.barcodeType)
                  .toUpperCase(),
              'storeLogoUrl': card.storeLogoUrl,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return LoyaltyCard.fromJson(data);
      } else {
        throw Exception('Failed to create card: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating card: $e');
    }
  }

  /// Get all loyalty cards
  Future<List<LoyaltyCard>> getCards() async {
    try {
      final headers = _headers;
      final response = await http
          .get(
            Uri.parse('$baseUrl/cards'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        return data
            .map((json) => LoyaltyCard.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load cards: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading cards: $e');
    }
  }

  /// Update a loyalty card
  Future<LoyaltyCard> updateCard(LoyaltyCard card) async {
    try {
      final headers = _headers;
      final response = await http
          .put(
            Uri.parse('$baseUrl/cards/${card.id}'),
            headers: headers,
            body: jsonEncode({
              'cardName': card.cardName,
              'barcodeData': card.barcodeData,
              'barcodeType': BarcodeTypeHelper.enumToString(card.barcodeType)
                  .toUpperCase(),
              'storeLogoUrl': card.storeLogoUrl,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return LoyaltyCard.fromJson(data);
      } else {
        throw Exception('Failed to update card: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating card: $e');
    }
  }

  /// Delete a loyalty card
  Future<void> deleteCard(int cardId) async {
    try {
      final headers = _headers;
      final response = await http
          .delete(
            Uri.parse('$baseUrl/cards/$cardId'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete card: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting card: $e');
    }
  }
}
