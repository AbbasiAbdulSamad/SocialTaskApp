import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../config/authentication.dart';
import '../../config/config.dart';
import '../functions_helper.dart';

class AllCampaignsProvider with ChangeNotifier {
  List<Map<String, dynamic>> _allCampaigns = [];
  List<Map<String, dynamic>> _originalCampaigns = [];

  bool _isLoading = false;
  String _errorMessage = "";

  List<String>? _selectedSocial;
  List<String>? _selectedCategories;
  List<String>? _selectedOptions;

  // Getters
  List<Map<String, dynamic>> get allCampaigns => _allCampaigns;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  List<String>? get selectedSocial => _selectedSocial;
  List<String>? get selectedCategories => _selectedCategories;
  List<String>? get selectedOptions => _selectedOptions;

  // Set Filters
  void setSelectedSocial(List<String>? social) {
    _selectedSocial = social;
    _applyFilters();
  }
  void setSelectedCategories(List<String>? categories) {
    _selectedCategories = categories;
    _applyFilters();
  }
  void setSelectedOptions(List<String>? options) {
    _selectedOptions = options;
    _applyFilters();
  }

  // Apply Filters on Original List
  void _applyFilters() {
    if ((_selectedCategories == null || _selectedCategories!.isEmpty) &&
        (_selectedOptions == null || _selectedOptions!.isEmpty) &&
        (_selectedSocial == null || _selectedSocial!.isEmpty)) {
      _allCampaigns = List<Map<String, dynamic>>.from(_originalCampaigns);
    } else {
      _allCampaigns = _originalCampaigns.where((campaign) {
        final matchCategory = _selectedCategories == null ||
            _selectedCategories!.isEmpty ||
            _selectedCategories!.contains(campaign['catagory']);

        final matchOption = _selectedOptions == null ||
            _selectedOptions!.isEmpty ||
            _selectedOptions!.contains(campaign['selectedOption']);

        final matchSocial = _selectedSocial == null ||
            _selectedSocial!.isEmpty ||
            _selectedSocial!.contains(campaign['social']);

        return matchCategory && matchOption && matchSocial;
      }).toList();
    }
    notifyListeners();
  }


  // Clear Filters
  void clearFilters() {
    _selectedSocial = null;
    _selectedCategories = null;
    _selectedOptions = null;
    _allCampaigns = List<Map<String, dynamic>>.from(_originalCampaigns);
    notifyListeners();
  }

  // Fetch Data from API
  Future<void> fetchAllCampaigns({required BuildContext context, bool forceRefresh = false}) async {
    if (!forceRefresh) {
      return;
    }

    _isLoading = true;
    _errorMessage = "";
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    String? token = await Helper.getAuthToken();
    if (token == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(ApiPoints.campaignFiltered),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        try {
          List<dynamic> campaigns = jsonDecode(response.body);
          _originalCampaigns = campaigns.cast<Map<String, dynamic>>();

          _applyFilters();

        } catch (e) {
          debugPrint("⚠️ JSON Decode Error: $e");
          _errorMessage = "Invalid response from server!";
          _allCampaigns = [];
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => Authentication()),
                  (route) => false,
            );
          });
        }
      } else {
        try {
          final decodedError = jsonDecode(response.body);
          _errorMessage = decodedError is Map<String, dynamic>
              ? decodedError.values.first.toString()
              : "Unexpected error format";
        } catch (e) {
          _errorMessage = "Failed to fetch Tasks";
        }
        _allCampaigns = [];
      }
    } catch (e) {
      debugPrint("❌ Exception: $e");
      _errorMessage = "Network error!";
      _allCampaigns = [];
    }

    _isLoading = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }
}
