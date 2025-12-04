import 'package:flutter/material.dart';
import './colors.dart';

final ThemeData customTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.dark,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.darkBlackColor,
    titleTextStyle: TextStyle(
      color: AppColors.textPrimary,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  textTheme: TextTheme(
    bodyMedium: TextStyle(color: AppColors.textPrimary), // Primary text color
    bodySmall: TextStyle(
      color: AppColors.textSecondary,
    ), // Secondary text color
    bodyLarge: TextStyle(
      color: AppColors.textPrimary,
      fontSize: 24,
    ), // Headline style
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: AppColors.primary, // Button color
    textTheme: ButtonTextTheme.primary,
  ),
  iconTheme: IconThemeData(
    color: AppColors.primary, // Icon color
  ),
  scaffoldBackgroundColor: AppColors.background, // Background color
);
