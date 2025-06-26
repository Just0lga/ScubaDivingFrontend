import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:scuba_diving/colors/color_palette.dart';
import 'package:scuba_diving/main.dart';
import 'package:scuba_diving/models/address.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _AddressFormPageState extends State<AddressFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _fullAddressController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _zipcodeController;
  late TextEditingController _countryController;
  late bool _isDefault;

  bool _isSaving = false;
  String? _authToken;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.address?.title ?? '');
    _fullAddressController = TextEditingController(
      text: widget.address?.fullAddress ?? '',
    );
    _cityController = TextEditingController(text: widget.address?.city ?? '');
    _stateController = TextEditingController(text: widget.address?.state ?? '');
    _zipcodeController = TextEditingController(
      text: widget.address?.zipcode ?? '',
    );
    _countryController = TextEditingController(
      text: widget.address?.country ?? '',
    );
    _isDefault = widget.address?.isDefault ?? false;

    _loadAuthToken();
  }

  Future<void> _loadAuthToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _authToken = prefs.getString('authToken');
    });
    if (_authToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Authentication token missing. Please log in.'),
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_authToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Authentication required to save address.'),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final Address newOrUpdatedAddress = Address(
      id: widget.address?.id,
      userId: widget.userId,
      title: _titleController.text,
      fullAddress: _fullAddressController.text,
      city: _cityController.text,
      state: _stateController.text,
      zipcode: _zipcodeController.text,
      country: _countryController.text,
      isDefault: _isDefault,
    );

    final Map<String, dynamic> body = newOrUpdatedAddress.toJson();
    String apiUrl;
    http.Response response;

    try {
      if (widget.address == null) {
        apiUrl = '$API_BASE_URL/api/Address';
        response = await http.post(
          Uri.parse(apiUrl),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $_authToken',
          },
          body: jsonEncode(body),
        );
      } else {
        apiUrl =
            '$API_BASE_URL/api/Address/${widget.userId}/${widget.address!.id}';
        response = await http.put(
          Uri.parse(apiUrl),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $_authToken',
          },
          body: jsonEncode(body),
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.address == null
                  ? 'Address added successfully!'
                  : 'Address updated successfully!',
            ),
            backgroundColor: ColorPalette.success,
          ),
        );
        widget.onSave(true);
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to save address: ${response.statusCode} - ${response.body}',
            ),
            backgroundColor: ColorPalette.error,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving address: $e'),
          backgroundColor: ColorPalette.error,
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _fullAddressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipcodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.address == null ? 'Add New Address' : 'Edit Address',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: ColorPalette.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: ColorPalette.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: ColorPalette.white),
          onPressed: () {
            widget.onSave(false);
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(
                _titleController,
                'Title (e.g., Home, Work)',
                validator: _requiredValidator,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                _fullAddressController,
                'Full Address',
                maxLines: 3,
                validator: _requiredValidator,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                _cityController,
                'City',
                validator: _requiredValidator,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                _stateController,
                'State/Province',
                validator: _requiredValidator,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                _zipcodeController,
                'Zip Code',
                validator: _requiredValidator,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                _countryController,
                'Country',
                validator: _requiredValidator,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: Text(
                  'Set as Default Address',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: ColorPalette.black,
                  ),
                ),
                value: _isDefault,
                onChanged: (bool value) {
                  setState(() {
                    _isDefault = value;
                  });
                },
                activeColor: ColorPalette.primary,
              ),
              const SizedBox(height: 24),
              _isSaving
                  ? const CircularProgressIndicator(color: ColorPalette.primary)
                  : ElevatedButton(
                    onPressed: _saveAddress,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorPalette.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      widget.address == null ? 'Add Address' : 'Update Address',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String labelText, {
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.poppins(color: ColorPalette.black),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: GoogleFonts.poppins(color: ColorPalette.black70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: ColorPalette.black70),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: ColorPalette.primary, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: ColorPalette.black.withOpacity(0.3),
            width: 1,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: ColorPalette.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: ColorPalette.error, width: 2),
        ),
      ),
      validator: validator,
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field cannot be empty';
    }
    return null;
  }
}

class AddressFormPage extends StatefulWidget {
  final Address? address;
  final String userId;
  final Function(bool) onSave;

  const AddressFormPage({
    Key? key,
    this.address,
    required this.userId,
    required this.onSave,
  }) : super(key: key);

  @override
  State<AddressFormPage> createState() => _AddressFormPageState();
}

class AddressManagementPage extends StatefulWidget {
  const AddressManagementPage({super.key});

  @override
  State<AddressManagementPage> createState() => _AddressManagementPageState();
}

class _AddressManagementPageState extends State<AddressManagementPage> {
  List<Address> _addresses = [];
  bool _isLoading = true;
  String? _currentUserId;
  String _errorMessage = '';
  String? _authToken;

  @override
  void initState() {
    super.initState();
    _loadUserDataAndFetchAddresses();
  }

  Future<void> _loadUserDataAndFetchAddresses() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _currentUserId = prefs.getString('userId');
    _authToken = prefs.getString('authToken');

    if (_currentUserId == null || _authToken == null) {
      setState(() {
        _errorMessage = 'User not logged in or authentication token missing.';
        _isLoading = false;
      });
      return;
    }
    await _fetchAddresses();
  }

  Future<void> _fetchAddresses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    if (_currentUserId == null || _authToken == null) {
      setState(() {
        _errorMessage = 'User ID or Auth Token is missing.';
        _isLoading = false;
      });
      return;
    }

    final String apiUrl = '$API_BASE_URL/api/Address/all/$_currentUserId';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $_authToken',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> addressData = jsonDecode(response.body);
        setState(() {
          _addresses =
              addressData.map((json) => Address.fromJson(json)).toList();
        });
      } else {
        setState(() {
          _errorMessage =
              'Failed to load addresses: ${response.statusCode} - ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching addresses: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteAddress(int id) async {
    final bool? confirm = await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Address'),
            content: const Text(
              'Are you sure you want to delete this address?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
    });

    if (_currentUserId == null || _authToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Authentication error. Cannot delete address.'),
        ),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final String apiUrl = '$API_BASE_URL/api/Address/$_currentUserId/$id';

    try {
      final response = await http.delete(
        Uri.parse(apiUrl),
        headers: <String, String>{'Authorization': 'Bearer $_authToken'},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Address deleted successfully!')),
        );
        _fetchAddresses();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to delete address: ${response.statusCode} - ${response.body}',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error deleting address: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleAddressFormSave(bool needsRefresh) async {
    if (needsRefresh) {
      await _fetchAddresses();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Addresses',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: ColorPalette.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: ColorPalette.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: ColorPalette.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          if (_currentUserId != null)
            IconButton(
              icon: const Icon(Icons.add, color: ColorPalette.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => AddressFormPage(
                          userId: _currentUserId!,
                          onSave: _handleAddressFormSave,
                        ),
                  ),
                );
              },
            ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage.isNotEmpty
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _errorMessage,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: ColorPalette.error,
                      fontSize: 16,
                    ),
                  ),
                ),
              )
              : _addresses.isEmpty
              ? Center(
                child: Text(
                  'No addresses found. Add a new one!',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: ColorPalette.black70,
                  ),
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _addresses.length,
                itemBuilder: (context, index) {
                  final address = _addresses[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12.0),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: ColorPalette.white,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 16.0,
                        right: 16.0,
                        top: 4,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  address.title,
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: ColorPalette.black,
                                  ),
                                ),
                              ),
                              if (address.isDefault)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: ColorPalette.primary.withOpacity(
                                      0.2,
                                    ),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    'Default',
                                    style: GoogleFonts.poppins(
                                      color: ColorPalette.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          Text(
                            address.fullAddress,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: ColorPalette.black70,
                            ),
                          ),
                          Text(
                            '${address.city}, ${address.state} ${address.zipcode}',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: ColorPalette.black70,
                            ),
                          ),
                          Text(
                            address.country,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: ColorPalette.black70,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: ColorPalette.primary,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => AddressFormPage(
                                            address: address,
                                            userId: _currentUserId!,
                                            onSave: _handleAddressFormSave,
                                          ),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: ColorPalette.error,
                                ),
                                onPressed: () => _deleteAddress(address.id!),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
