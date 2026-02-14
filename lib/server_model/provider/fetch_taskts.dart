import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/authentication.dart';
import '../../config/config.dart';
import '../functions_helper.dart';

class AllCampaignsProvider with ChangeNotifier {
  List<Map<String, dynamic>> _allCampaigns = [];
  List<Map<String, dynamic>> _originalCampaigns = [];

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String _errorMessage = "";

  List<String>? _selectedSocial;
  List<String>? _selectedCategories;
  List<String>? _selectedOptions;

  int _currentPage = 1;
  final int _limit = 20;

  // ----------------------------
  // SELECTION MODE & Selected Tasks
  // ----------------------------
  bool _isSelectionMode = false;
  List<String> _selectedTaskIds = [];

  // CHECK IF ANY TASKS ARE HIDDEN
  bool get hasHiddenTasks => _hiddenTasksWithExpiry.isNotEmpty;

  // ----------------------------
  // HIDDEN TASKS (SharedPreferences)
  // ----------------------------
  Map<String, String> _hiddenTasksWithExpiry = {}; // taskId -> expiry ISO string

  bool get isSelectionMode => _isSelectionMode;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  List<String> get selectedTaskIds => _selectedTaskIds;
  List<String> get hiddenTaskIds => _hiddenTasksWithExpiry.keys.toList();

  void enterSelectionMode(String taskId) {
    if (!_isSelectionMode) _isSelectionMode = true;
    if (!_selectedTaskIds.contains(taskId)) _selectedTaskIds.add(taskId);
    notifyListeners();
  }

  void toggleTaskSelection(String taskId) {
    if (_selectedTaskIds.contains(taskId)) {
      _selectedTaskIds.remove(taskId);
      if (_selectedTaskIds.isEmpty) _isSelectionMode = false;
    } else {
      _selectedTaskIds.add(taskId);
    }
    notifyListeners();
  }

  void clearSelectionMode() {
    _isSelectionMode = false;
    _selectedTaskIds.clear();
    notifyListeners();
  }

  // ----------------------------
  // RESET HIDDEN TASKS
  // ----------------------------
  Future<void> resetHiddenTasks() async {
    _hiddenTasksWithExpiry.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('hiddenTasksMap'); // remove from storage
    _applyFilters(); // refresh the campaigns list
  }

  // ----------------------------
  // HIDE TASKS WITH DURATION
  // ----------------------------
  Future<void> hideSelectedTasks(String duration) async {
    int days = int.tryParse(duration.split(" ")[0]) ?? 1; // '3 day' -> 3
    final now = DateTime.now();

    for (String taskId in _selectedTaskIds) {
      final expiry = now.add(Duration(days: days));
      _hiddenTasksWithExpiry[taskId] = expiry.toIso8601String();
    }

    await _saveHiddenTasksToPrefs();
    clearSelectionMode();
    _applyFilters();
  }

  Future<void> hideTaskLocally(String taskId) async {
    final now = DateTime.now();
    _hiddenTasksWithExpiry[taskId] = now.add(Duration(days: 1)).toIso8601String();
    await _saveHiddenTasksToPrefs();
    _applyFilters();
  }

  Future<void> _saveHiddenTasksToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('hiddenTasksMap', jsonEncode(_hiddenTasksWithExpiry));
  }

  Future<void> loadHiddenTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final hiddenJson = prefs.getString('hiddenTasksMap');
    if (hiddenJson != null) {
      _hiddenTasksWithExpiry = Map<String, String>.from(jsonDecode(hiddenJson));
    }

    // Remove expired tasks automatically
    final now = DateTime.now();
    _hiddenTasksWithExpiry.removeWhere((key, value) {
      final expiry = DateTime.tryParse(value);
      return expiry == null || expiry.isBefore(now);
    });

    _applyFilters();
  }

  // ----------------------------
  // FILTERS
  // ----------------------------
  List<Map<String, dynamic>> get allCampaigns => _allCampaigns;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  List<String>? get selectedSocial => _selectedSocial;
  List<String>? get selectedCategories => _selectedCategories;
  List<String>? get selectedOptions => _selectedOptions;

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

  void clearFilters() {
    _selectedSocial = null;
    _selectedCategories = null;
    _selectedOptions = null;
    _applyFilters();
  }

  void _applyFilters() {
    final now = DateTime.now();
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

      final isHidden = _hiddenTasksWithExpiry.containsKey(campaign['_id']) &&
          DateTime.tryParse(_hiddenTasksWithExpiry[campaign['_id']]!)?.isAfter(now) == true;

      return matchCategory && matchOption && matchSocial && !isHidden;
    }).toList();

    // ✅ Sort: oldest first
    _allCampaigns.sort((a, b) => DateTime.parse(a['createdAt']).compareTo(DateTime.parse(b['createdAt'])));

    notifyListeners();
  }

  // ----------------------------
  // FETCH DATA WITH PAGINATION
  // ----------------------------
  Future<void> fetchAllCampaigns({required BuildContext context, bool forceRefresh = false}) async {
    if (_isLoading || _isLoadingMore) return;

    if (forceRefresh) {
      _currentPage = 1;
      _hasMore = true;
      _allCampaigns.clear();
      _originalCampaigns.clear();
      _isLoading = true;
    } else {
      _isLoadingMore = true;
    }

    _errorMessage = "";
    notifyListeners();

    String? token = await Helper.getAuthToken();
    if (token == null) {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('${ApiPoints.campaignFiltered}?page=$_currentPage&limit=$_limit'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> campaigns = jsonDecode(response.body);
        if (campaigns.isEmpty || campaigns.length < _limit) {
          _hasMore = false;
        }

        _originalCampaigns.addAll(campaigns.cast<Map<String, dynamic>>());
        await loadHiddenTasks(); // refresh hidden tasks
        _applyFilters();

        _currentPage++; // next page for scroll
      } else {
        try {
          final decodedError = jsonDecode(response.body);
          _errorMessage = decodedError is Map<String, dynamic>
              ? decodedError.values.first.toString()
              : "Unexpected error format";
        } catch (e) {
          _errorMessage = "Failed to fetch Tasks";
        }
      }
    } catch (e) {
      debugPrint("❌ Exception: $e");
      _errorMessage = "Network error!";
    }

    _isLoading = false;
    _isLoadingMore = false;
    notifyListeners();
  }
}
