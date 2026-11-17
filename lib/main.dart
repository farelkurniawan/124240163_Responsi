import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'controllers/controllers.dart';
import 'views/auth_view.dart';
import 'views/home_view.dart';
import 'views/wishlist_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('users'); 
  await Hive.openBox('wishlist'); 

  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final String loggedInUser = prefs.getString('loggedInUser') ?? '';

  final authController = Get.put(AuthController(), permanent: true);
  authController.isLoggedIn.value = isLoggedIn;
  authController.currentUser.value = loggedInUser;

  Get.put(ProductController(), permanent: true);

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'ShoppingHub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
        ),
      ),
      initialRoute: isLoggedIn ? '/home' : '/login',
      getPages: [
        GetPage(name: '/login', page: () => const AuthView()),
        GetPage(name: '/home', page: () => const HomeView()),
        GetPage(name: '/wishlist', page: () => const WishlistView()),
      ],
    );
  }
}
