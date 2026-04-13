import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'theme.dart';
import 'onboarding.dart';
import 'admin.dart';
import 'home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  
  // Apertura Box necessari per il Titan Shield e il Ricettario
  await Hive.openBox('adminBox');
  await Hive.openBox('familyBox');
  await Hive.openBox('savedRecipesBox');
  await Hive.openBox('customRecipesBox');
  await Hive.openBox('historyBox');

  runApp(const BioChefApp());
}

class BioChefApp extends StatelessWidget {
  const BioChefApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box('adminBox').listenable(),
      builder: (context, Box box, _) {
        final bool hasAcceptedLegal = box.get('hasAcceptedLegal', defaultValue: false);
        final bool isLoggedIn = box.get('isLoggedIn', defaultValue: false);

        Widget home;
        if (!hasAcceptedLegal) {
          home = const OnboardingLegalScreen();
        } else if (!isLoggedIn) {
          home = const AdminRegistrationScreen();
        } else {
          home = const HomeScreen();
        }

        return MaterialApp(
          title: 'BioChef AI',
          debugShowCheckedModeBanner: false,
          theme: BC.getTheme(context),
          home: home,
        );
      },
    );
  }
}
