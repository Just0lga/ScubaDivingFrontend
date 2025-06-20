import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scuba_diving/colors/color_palette.dart';
import 'package:scuba_diving/screens/category_page.dart';

class WhichCategory extends StatefulWidget {
  const WhichCategory({super.key, required this.CategoryName});
  final String CategoryName;

  @override
  State<WhichCategory> createState() => _WhichCategoryState();
}

class _WhichCategoryState extends State<WhichCategory> {
  late int id;
  late List<CategoryItemModel> categoriesNames;

  @override
  void initState() {
    super.initState();
    id = _getCategoryId(widget.CategoryName);
    categoriesNames = _getList(id);
  }

  int _getCategoryId(String name) {
    switch (name.toLowerCase()) {
      case 'scuba diving':
        return 1;
      case 'spearfishing':
        return 2;
      case 'swimming':
        return 3;
      case 'special offers':
        return 4;
      default:
        return 4;
    }
  }

  List<CategoryItemModel> _getList(int id) {
    switch (id) {
      case 1:
        return [
          CategoryItemModel('Dress', 5),
          CategoryItemModel('Mask', 6),
          CategoryItemModel('Diving Tank', 7),
          CategoryItemModel('Palette', 8),
          CategoryItemModel('Snorkel', 9),
        ];
      case 2:
        return [
          CategoryItemModel('Mask', 10),
          CategoryItemModel('Dress', 11),
          CategoryItemModel('Palette', 12),
          CategoryItemModel('Glove', 13),
          CategoryItemModel('Harpoon', 14),
        ];
      case 3:
        return [
          CategoryItemModel('Shoes and Slippers', 15),
          CategoryItemModel('Bonnet', 16),
          CategoryItemModel('Pool Bag', 17),
          CategoryItemModel('Swim Goggles', 18),
          CategoryItemModel('Mask-Snorkel', 19),
        ];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorPalette.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: ColorPalette.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.CategoryName,
          style: GoogleFonts.playfair(color: ColorPalette.white, fontSize: 24),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(height: height * 0.05),
          Expanded(
            child: ListView.builder(
              itemCount: categoriesNames.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    CategoryItem(
                      width: width,
                      height: height,
                      title: categoriesNames[index].title,
                      id: categoriesNames[index].id,
                      categoryTitle: categoriesNames[index].title,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryItemModel {
  final String title;
  final int id;
  CategoryItemModel(this.title, this.id);
}

class CategoryItem extends StatelessWidget {
  const CategoryItem({
    super.key,
    required this.width,
    required this.height,
    required this.title,
    required this.id,
    required this.categoryTitle,
  });

  final double width;
  final double height;
  final String title;
  final int id;
  final String categoryTitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: height * 0.015),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => CategoryPage(
                    categoryId: id,
                    categoryTitle: categoryTitle,
                  ),
            ),
          );
        },
        child: SizedBox(
          width: width * 0.85,
          height: height * 0.06,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SizedBox(width: width * 0.02),
                      Text(
                        title,
                        style: GoogleFonts.playfair(
                          color: ColorPalette.black,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.arrow_forward_ios_outlined,
                    color: ColorPalette.black,
                    size: 20,
                  ),
                ],
              ),
              SizedBox(height: height * 0.01),
              Container(
                width: width * 0.85,
                height: 1,
                color: ColorPalette.black,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
