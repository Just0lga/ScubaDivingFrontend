import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scuba_diving/colors/color_palette.dart';
import 'package:scuba_diving/screens/profile%20items/address_form_page.dart';
import 'package:scuba_diving/screens/profile%20items/contact_info_page.dart'
    show ContactInfoPage;
import 'package:scuba_diving/screens/forgot%20passwords/forgot_password_page.dart';
import 'package:scuba_diving/screens/profile%20items/languages_page.dart';
import 'package:scuba_diving/screens/login_page.dart';
import 'package:scuba_diving/screens/profile%20items/my_orders_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final List<ProfileItemModel> profileItems;

  @override
  void initState() {
    super.initState();
    profileItems = [
      ProfileItemModel(Icons.shopping_cart_outlined, "My Orders", (context) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyOrdersPage()),
        );
      }),
      ProfileItemModel(Icons.language, "Languages", (context) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LanguagesPage()),
        );
      }),
      ProfileItemModel(Icons.location_on_outlined, "My Addresses", (context) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddressManagementPage()),
        );
      }),
      ProfileItemModel(Icons.contact_support_outlined, "Contact Us", (context) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ContactInfoPage()),
        );
      }),
      ProfileItemModel(Icons.key_rounded, "Forgot Password", (context) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
        );
      }),
      ProfileItemModel(Icons.logout_outlined, "Log Out", (context) async {
        final prefs = await SharedPreferences.getInstance();

        // Kullanıcının giriş durumunu false yap
        await prefs.setBool('isLoggedIn', false);

        // userId'yi Shared Preferences'tan sil
        await prefs.remove('userId');
        print('userId Shared Preferences\'tan silindi.');

        // authToken'u Shared Preferences'tan sil (JWT'yi kaydettiyseniz)
        await prefs.remove('authToken');
        print('authToken Shared Preferences\'tan silindi.');

        // Tüm geçmiş rotaları temizleyerek Loginpage'e yönlendir
        if (context.mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const Loginpage()),
            (route) => false, // Tüm geçmiş rotaları temizle
          );
        }
      }),
    ];
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: ColorPalette.black,
          title: Text(
            "Profile",
            style: GoogleFonts.playfair(
              color: ColorPalette.white,
              fontSize: 24,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            SizedBox(height: height * 0.05),
            Expanded(
              child: ListView.builder(
                itemCount: profileItems.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      ProfileItem(
                        width: width,
                        height: height,
                        icon: profileItems[index].icon,
                        title: profileItems[index].title,
                        onTap: () => profileItems[index].onTap(context),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileItemModel {
  final IconData icon;
  final String title;
  final void Function(BuildContext context) onTap;

  ProfileItemModel(this.icon, this.title, this.onTap);
}

class ProfileItem extends StatelessWidget {
  const ProfileItem({
    super.key,
    required this.width,
    required this.height,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final double width;
  final double height;
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: height * 0.015),
      child: GestureDetector(
        onTap: onTap,
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
                      Icon(icon, color: ColorPalette.black, size: 24),
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
