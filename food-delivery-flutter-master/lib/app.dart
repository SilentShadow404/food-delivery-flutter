import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zomato/constants/app_colors.dart';
import 'package:zomato/models/user_model.dart';
import 'package:zomato/providers/auth_provider.dart';
import 'package:zomato/providers/cart_provider.dart';
import 'package:zomato/providers/food_provider.dart';
import 'package:zomato/providers/order_provider.dart';
import 'package:zomato/screens/splash_screen.dart';
import 'package:zomato/screens/role_selection_screen.dart';
import 'package:zomato/screens/auth/login_screen.dart';
import 'package:zomato/screens/auth/register_screen.dart';
import 'package:zomato/screens/customer/customer_main_screen.dart';
import 'package:zomato/screens/vendor/vendor_main_screen.dart';
import 'package:zomato/screens/admin/admin_main_screen.dart';

class FoodDeliveryApp extends StatelessWidget {
  const FoodDeliveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FoodProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: MaterialApp(
        title: 'FoodDash - Food Delivery',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.deepOrange,
          primaryColor: AppColors.primary,
          scaffoldBackgroundColor: AppColors.background,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
            centerTitle: true,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Colors.white,
            elevation: 8,
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (_) => const SplashScreen(),
          '/role-selection': (_) => const RoleSelectionScreen(),
          '/customer-main': (_) => const CustomerMainScreen(),
          '/vendor-main': (_) => const VendorMainScreen(),
          '/admin-main': (_) => const AdminMainScreen(),
        },
        onGenerateRoute: (settings) {
          // Handle routes that need arguments
          switch (settings.name) {
            case '/login':
              final args = settings.arguments as Map<String, dynamic>?;
              final role = args?['role'] as UserRole? ?? UserRole.customer;
              return MaterialPageRoute(builder: (_) => LoginScreen(role: role));
            case '/register':
              final args = settings.arguments as Map<String, dynamic>?;
              final role = args?['role'] as UserRole? ?? UserRole.customer;
              return MaterialPageRoute(
                  builder: (_) => RegisterScreen(role: role));
          }
          return null;
        },
      ),
    );
  }
}
