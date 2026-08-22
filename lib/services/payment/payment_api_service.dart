import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart';
import '../../models/payment/payment_models.dart';
import '../../models/orders/order_models.dart';

class PaymentApiService {
  Future<PaymentOptionsResponse> fetchPaymentOptions(String sessionToken) async {
    final url = '${ApiConstants.checkoutBaseUrl}/checkout/session/$sessionToken/payment-options';
    debugPrint('========== FETCH PAYMENT OPTIONS ==========');
    debugPrint('URL: $url');

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'x-api-key': ApiConstants.checkoutApiKey,
      },
    );

    debugPrint('Status Code: ${response.statusCode}');
    debugPrint('Response: ${response.body}');
    debugPrint('============================================');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return PaymentOptionsResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load payment options: ${response.statusCode}');
    }
  }

  Future<PaymentInitiateResponse> initiatePayment(String sessionToken, String paymentMethod, String idempotencyKey) async {
    final url = '${ApiConstants.checkoutBaseUrl}/checkout/session/$sessionToken/payment/initiate';
    debugPrint('========== INITIATE PAYMENT ==========');
    debugPrint('URL: $url');
    debugPrint('Payment Method: $paymentMethod');
    debugPrint('Idempotency Key: $idempotencyKey');

    // Standardize payment method code to match the API expectations (e.g. CARD, UPI, WALLET)
    final String paymentMethodCode = paymentMethod.toLowerCase();

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': ApiConstants.checkoutApiKey,
        'idempotency-key': idempotencyKey,
      },
      body: json.encode({
        'gateway': 'easebuzz',
        'paymentMethodCode': paymentMethodCode,
      }),
    );

    debugPrint('Status Code: ${response.statusCode}');
    debugPrint('Response: ${response.body}');
    debugPrint('=======================================');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return PaymentInitiateResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to initiate payment: ${response.statusCode} - ${response.body}');
    }
  }

  Future<PaymentVerifyResponse> verifyPayment(String sessionToken, Map<String, dynamic> verifyData) async {
    final url = '${ApiConstants.checkoutBaseUrl}/checkout/session/$sessionToken/payment/easebuzz/verify';
    debugPrint('========== VERIFY PAYMENT (EASEBUZZ) ==========');
    debugPrint('URL: $url');
    debugPrint('Payload: ${json.encode(verifyData)}');

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': ApiConstants.checkoutApiKey,
      },
      body: json.encode(verifyData),
    );

    debugPrint('Status Code: ${response.statusCode}');
    debugPrint('Response: ${response.body}');
    debugPrint('================================================');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return PaymentVerifyResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to verify payment: ${response.statusCode} - ${response.body}');
    }
  }

  Future<bool> failPayment(String sessionToken, Map<String, dynamic> failData) async {
    final url = '${ApiConstants.checkoutBaseUrl}/checkout/session/$sessionToken/payment/failure';
    debugPrint('========== FAIL PAYMENT ==========');
    debugPrint('URL: $url');
    debugPrint('Payload: ${json.encode(failData)}');

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': ApiConstants.checkoutApiKey,
      },
      body: json.encode(failData),
    );

    debugPrint('Status Code: ${response.statusCode}');
    debugPrint('Response: ${response.body}');
    debugPrint('===================================');

    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<OrderSummaryResponse> fetchOrderSummary(String sessionToken) async {
    final url = '${ApiConstants.checkoutBaseUrl}/checkout/session/$sessionToken/order-summary';
    debugPrint('========== FETCH ORDER SUMMARY ==========');
    debugPrint('URL: $url');

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'x-api-key': ApiConstants.checkoutApiKey,
      },
    );

    debugPrint('Status Code: ${response.statusCode}');
    debugPrint('Response: ${response.body}');
    debugPrint('=========================================');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return OrderSummaryResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load order summary: ${response.statusCode}');
    }
  }

  Future<Order> fetchOrderDetails(String orderId) async {
    final url = '${ApiConstants.checkoutBaseUrl}/v1/customer-portal/orders/$orderId';
    final prefs = await SharedPreferences.getInstance();
    final platformToken = prefs.getString('platformToken') ?? '';

    debugPrint('========== FETCH ORDER DETAILS ==========');
    debugPrint('URL: $url');
    debugPrint('Platform Token: $platformToken');

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'x-api-key': ApiConstants.checkoutApiKey,
        'x-store-origin': ApiConstants.storeOrigin,
        'Authorization': 'Bearer $platformToken',
      },
    );

    debugPrint('Status Code: ${response.statusCode}');
    debugPrint('Response: ${response.body}');
    debugPrint('=========================================');

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = json.decode(response.body);
      final dynamic data = body['data'];
      return Order.fromJson(data);
    } else {
      throw Exception('Failed to load order details: ${response.statusCode}');
    }
  }
}
