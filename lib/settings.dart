import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {


  late String selectedLanguage; // Initialize it as late so it can be set asynchronously

  @override
  void initState() {
    super.initState();
    setState(() {
      _loadLanguageFromStorage();
    });
  }// Default language code

  Future<void> _loadLanguageFromStorage() async {
    final storedLanguage = GetStorage().read('language');
    selectedLanguage = storedLanguage ?? 'en_US'; // Default to English if not found
    if (storedLanguage == null) {
      Get.updateLocale(Locale('en', 'US')); // Update locale to English
    } else {
      Get.updateLocale(Locale(selectedLanguage.split('_')[0], selectedLanguage.split('_')[1]));
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Settings".tr,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        titleSpacing: 00.0,
        centerTitle: true,
        toolbarHeight: 60.2,
        toolbarOpacity: 0.8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(25),
            bottomLeft: Radius.circular(25),
          ),
        ),
        elevation: 0.00,
        backgroundColor: Color(0xFF8155BA),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildSettingsButton("Account".tr, Icons.account_circle),
            buildLanguageButton("Language".tr),
            buildSettingsButton("Appearance".tr, Icons.color_lens),
            buildSettingsButton("Privacy".tr, Icons.security),
            buildSettingsButton("About".tr, Icons.info),
          ],
        ),
      ),
    );
  }

  Widget buildSettingsButton(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: () {
          // Add functionality for each button here
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Color(0xFF8155BA),
          backgroundColor: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: Color(0xFF8155BA)),
                SizedBox(width: 8.0),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            Icon(Icons.navigate_next),
          ],
        ),
      ),
    );
  }

  Widget buildLanguageButton(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: () {
          _showLanguageDialog();
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Color(0xFF8155BA),
          backgroundColor: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.language, color: Color(0xFF8155BA)),
                SizedBox(width: 8.0),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  // Use the selected language name instead of code
                  _getLanguageName(selectedLanguage),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                Icon(Icons.navigate_next),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en_US':
        return 'English';
      case 'hi_IN':
        return 'Hindi';
      case 'ta_IN':
        return 'Tamil'.tr;
      case 'ml_IN':
        return 'Malayalam';
      case 'te_IN':
        return 'Telugu';
      default:
        return 'English';
    }
  }

  Future<void> _showLanguageDialog() async {
    String? newLanguage = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("select_language".tr, style: TextStyle(fontSize: 17)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageTile("English", "en_US"),
              //_buildLanguageTile("Hindi", "hi_IN"),
              _buildLanguageTile("Tamil", "ta_IN"),
              // _buildLanguageTile("Malayalam", "ml_IN"),
              // _buildLanguageTile("Telugu", "te_IN"),
            ],
          ),
        );
      },
    );

    if (newLanguage != null) {
      setState(() {
        selectedLanguage = newLanguage;
      });
      Get.updateLocale(Locale(newLanguage.split('_')[0], newLanguage.split('_')[1]));
      GetStorage().write('language', newLanguage); // Persist the selected language
    }
  }

  Widget _buildLanguageTile(String language, String languageCode) {
    return ListTile(
      title: Text(language),
      onTap: () {
        Navigator.pop(context, languageCode);
      },
    );
  }




}





