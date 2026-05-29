import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:zomato/constants/app_colors.dart';
import 'package:zomato/models/food_item_model.dart';
import 'package:zomato/providers/auth_provider.dart';
import 'package:zomato/providers/food_provider.dart';
import 'package:zomato/services/logger_service.dart';
import 'package:zomato/widgets/custom_button.dart';
import 'package:zomato/widgets/custom_text_field.dart';

class AddEditFoodScreen extends StatefulWidget {
  final FoodItem? food; // null = add, non-null = edit
  const AddEditFoodScreen({super.key, this.food});

  @override
  State<AddEditFoodScreen> createState() => _AddEditFoodScreenState();
}

class _AddEditFoodScreenState extends State<AddEditFoodScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _discountCtrl;
  String _category = 'Fast Food';
  String _imagePath = 'assets/images/food.jpeg';
  File? _pickedImageFile; // actual file from camera/gallery
  final ImagePicker _picker = ImagePicker();

  bool get isEditing => widget.food != null;

  final _categories = [
    'Burgers',
    'Pizza',
    'Coffee & Tea',
    'Pakistani',
    'Fast Food',
    'Desserts',
    'Beverages'
  ];
  final _images = [
    'assets/images/food.jpeg',
    'assets/images/junk.jpeg',
    'assets/images/burger.jpeg',
    'assets/images/pizza.jpeg',
    'assets/images/cofee.jpeg',
    'assets/images/verCofee.jpeg',
    'assets/images/beer.jpeg',
  ];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.food?.name ?? '');
    _descCtrl = TextEditingController(text: widget.food?.description ?? '');
    _priceCtrl = TextEditingController(
        text: widget.food?.price.toInt().toString() ?? '');
    _discountCtrl = TextEditingController(
        text: widget.food?.discount.toInt().toString() ?? '0');
    _category = widget.food?.category ?? 'Fast Food';
    _imagePath = widget.food?.imagePath ?? 'assets/images/food.jpeg';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _discountCtrl.dispose();
    super.dispose();
  }

  /// Requests camera or gallery permission then opens the picker.
  Future<void> _pickImage(ImageSource source) async {
    final permission =
        source == ImageSource.camera ? Permission.camera : Permission.photos;
    final status = await permission.request();

    if (status.isPermanentlyDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content:
                Text('Permission permanently denied. Enable it in Settings.')));
        openAppSettings();
      }
      return;
    }

    if (!status.isGranted) {
      log.warning('[AddFood] Permission denied for $source');
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Permission denied.')));
      }
      return;
    }

    try {
      final xFile = await _picker.pickImage(
          source: source, imageQuality: 80, maxWidth: 800);
      if (xFile != null) {
        log.info('[AddFood] Image picked: ${xFile.path}');
        setState(() {
          _pickedImageFile = File(xFile.path);
        });
      }
    } catch (e, s) {
      log.error('[AddFood] pickImage failed', e, s);
    }
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Take a photo'),
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Choose from gallery'),
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(isEditing ? 'Edit Item' : 'Add New Item'),
          centerTitle: true),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Image selector
            Text('Select Image',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 10),
            // Show picked image if available
            if (_pickedImageFile != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(_pickedImageFile!,
                    height: 120, width: double.infinity, fit: BoxFit.cover),
              ),
              SizedBox(height: 8),
            ],
            // Camera / gallery button
            OutlinedButton.icon(
              icon: Icon(Icons.add_a_photo, color: AppColors.vendorColor),
              label: Text('Take / Choose Photo',
                  style: TextStyle(color: AppColors.vendorColor)),
              style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.vendorColor),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              onPressed: _showPickerOptions,
            ),
            SizedBox(height: 10),
            Text('Or pick a preset image:',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            SizedBox(height: 8),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _images.length,
                itemBuilder: (ctx, i) => GestureDetector(
                  onTap: () => setState(() {
                    _imagePath = _images[i];
                    _pickedImageFile = null; // clear custom pick
                  }),
                  child: Container(
                    width: 80,
                    height: 80,
                    margin: EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: (_pickedImageFile == null &&
                                  _imagePath == _images[i])
                              ? AppColors.vendorColor
                              : AppColors.divider,
                          width: (_pickedImageFile == null &&
                                  _imagePath == _images[i])
                              ? 3
                              : 1),
                      image: DecorationImage(
                          image: AssetImage(_images[i]), fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),

            CustomTextField(
                hint: 'Food Name',
                controller: _nameCtrl,
                prefixIcon: Icons.fastfood,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter food name' : null),
            SizedBox(height: 14),
            CustomTextField(
                hint: 'Description',
                controller: _descCtrl,
                prefixIcon: Icons.description,
                maxLines: 3,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter description' : null),
            SizedBox(height: 14),

            Text('Category',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12)),
              child: DropdownButton<String>(
                value: _category,
                isExpanded: true,
                underline: SizedBox(),
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),
            ),
            SizedBox(height: 14),
            Row(children: [
              Expanded(
                  child: CustomTextField(
                      hint: 'Price (Rs)',
                      controller: _priceCtrl,
                      prefixIcon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter price';
                        if (double.tryParse(v) == null) return 'Invalid price';
                        return null;
                      })),
              SizedBox(width: 14),
              Expanded(
                  child: CustomTextField(
                      hint: 'Discount %',
                      controller: _discountCtrl,
                      prefixIcon: Icons.local_offer,
                      keyboardType: TextInputType.number)),
            ]),
            SizedBox(height: 30),

            CustomButton(
              text: isEditing ? 'Update Item' : 'Add Item',
              color: AppColors.vendorColor,
              onPressed: _save,
            ),
          ]),
        ),
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final foodProv = context.read<FoodProvider>();
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser!;

    // Use picked file path if available, otherwise the selected asset path
    final finalImagePath = _pickedImageFile?.path ?? _imagePath;

    final food = FoodItem(
      id: isEditing ? widget.food!.id : 'f${foodProv.nextFoodId}',
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      category: _category,
      imagePath: finalImagePath,
      price: double.parse(_priceCtrl.text),
      discount: double.tryParse(_discountCtrl.text) ?? 0,
      rating: isEditing ? widget.food!.rating : 0,
      reviewCount: isEditing ? widget.food!.reviewCount : 0,
      vendorId: user.id,
      vendorName: user.restaurantName ?? user.name,
    );

    if (isEditing) {
      foodProv.updateFood(food);
    } else {
      foodProv.addFood(food);
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(isEditing ? 'Item updated!' : 'Item added!'),
        backgroundColor: AppColors.success));
    Navigator.pop(context);
  }
}
