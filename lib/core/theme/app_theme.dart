import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: EfectivaColors.azulCorporativo,
      scaffoldBackgroundColor: EfectivaColors.fondo,
      colorScheme: ColorScheme.fromSeed(
        seedColor: EfectivaColors.azulCorporativo,
        primary: EfectivaColors.azulCorporativo,
        onPrimary: EfectivaColors.blanco,
        secondary: EfectivaColors.azulMedio,
        onSecondary: EfectivaColors.blanco,
        surface: EfectivaColors.blanco,
        onSurface: EfectivaColors.textoPrimario,
        error: EfectivaColors.rojoError,
        onError: EfectivaColors.blanco,
        brightness: Brightness.light,
      ),
      textTheme: _buildTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: EfectivaColors.azulCorporativo,
        foregroundColor: EfectivaColors.blanco,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: EfectivaColors.blanco,
        ),
        iconTheme: const IconThemeData(color: EfectivaColors.blanco),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: EfectivaColors.azulCorporativo,
          foregroundColor: EfectivaColors.blanco,
          disabledBackgroundColor: EfectivaColors.grisBordeClaro,
          disabledForegroundColor: EfectivaColors.grisPlaceholder,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: EfectivaColors.azulCorporativo,
          disabledForegroundColor: EfectivaColors.grisPlaceholder,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(color: EfectivaColors.azulCorporativo),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: EfectivaColors.azulCorporativo,
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: EfectivaColors.blanco,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: EfectivaColors.grisBorde),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: EfectivaColors.grisBorde),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: EfectivaColors.azulCorporativo, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: EfectivaColors.rojoError),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: EfectivaColors.rojoError, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: EfectivaColors.grisBordeClaro),
        ),
        labelStyle: GoogleFonts.inter(
          color: EfectivaColors.textoSecundario,
          fontSize: 13,
        ),
        hintStyle: GoogleFonts.inter(
          color: EfectivaColors.grisPlaceholder,
          fontSize: 13,
        ),
        errorStyle: GoogleFonts.inter(
          color: EfectivaColors.rojoError,
          fontSize: 12,
        ),
      ),
      cardTheme: CardThemeData(
        color: EfectivaColors.blanco,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide.none,
        ),
        margin: const EdgeInsets.symmetric(vertical: 5),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: EfectivaColors.blanco,
        selectedItemColor: EfectivaColors.azulCorporativo,
        unselectedItemColor: EfectivaColors.grisMedio,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
      bottomAppBarTheme: const BottomAppBarThemeData(
        color: EfectivaColors.blanco,
        elevation: 10,
      ),
      dividerTheme: const DividerThemeData(
        color: EfectivaColors.grisBordeClaro,
        thickness: 1,
        space: 0,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return EfectivaColors.azulCorporativo;
          }
          return EfectivaColors.blanco;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return EfectivaColors.azulCorporativo.withValues(alpha: 0.5);
          }
          return EfectivaColors.grisBordeClaro;
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return EfectivaColors.azulCorporativo;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(EfectivaColors.blanco),
        side: const BorderSide(color: EfectivaColors.grisMedio, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return EfectivaColors.azulCorporativo;
          }
          return EfectivaColors.grisMedio;
        }),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: EfectivaColors.grisBordeClaro,
        labelStyle: GoogleFonts.inter(
          color: EfectivaColors.textoPrimario,
          fontSize: 13,
        ),
        selectedColor: EfectivaColors.azulSuave,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: EfectivaColors.blanco,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: EfectivaColors.azulCorporativo,
        foregroundColor: EfectivaColors.blanco,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: EfectivaColors.azulCorporativo,
        linearTrackColor: EfectivaColors.grisBordeClaro,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: EfectivaColors.azulCorporativo,
        inactiveTrackColor: EfectivaColors.grisBordeClaro,
        thumbColor: EfectivaColors.azulCorporativo,
        overlayColor: EfectivaColors.azulCorporativo.withValues(alpha: 0.12),
        valueIndicatorColor: EfectivaColors.azulCorporativo,
        valueIndicatorTextStyle: GoogleFonts.inter(
          color: EfectivaColors.blanco,
          fontSize: 12,
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: EfectivaColors.azulCorporativo,
        unselectedLabelColor: EfectivaColors.grisMedio,
        indicatorColor: EfectivaColors.azulCorporativo,
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: EfectivaColors.textoPrimario,
        contentTextStyle: GoogleFonts.inter(
          color: EfectivaColors.blanco,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: EfectivaColors.blanco,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: EfectivaColors.blanco,
        indicatorColor: EfectivaColors.azulSuave,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(
              color: EfectivaColors.azulCorporativo,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            );
          }
          return GoogleFonts.inter(
            color: EfectivaColors.grisMedio,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: EfectivaColors.azulCorporativo);
          }
          return const IconThemeData(color: EfectivaColors.grisMedio);
        }),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: EfectivaColors.blanco,
        headerBackgroundColor: EfectivaColors.azulCorporativo,
        headerForegroundColor: EfectivaColors.blanco,
        dayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return EfectivaColors.blanco;
          }
          return EfectivaColors.textoPrimario;
        }),
        dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return EfectivaColors.azulCorporativo;
          }
          return Colors.transparent;
        }),
        todayForegroundColor:
            WidgetStateProperty.all(EfectivaColors.azulCorporativo),
        todayBackgroundColor:
            WidgetStateProperty.all(EfectivaColors.azulSuave),
      ),
      expansionTileTheme: ExpansionTileThemeData(
        backgroundColor: EfectivaColors.blanco,
        collapsedBackgroundColor: EfectivaColors.blanco,
        iconColor: EfectivaColors.textoSecundario,
        collapsedIconColor: EfectivaColors.textoSecundario,
        textColor: EfectivaColors.textoPrimario,
        collapsedTextColor: EfectivaColors.textoPrimario,
      ),
      listTileTheme: ListTileThemeData(
        textColor: EfectivaColors.textoPrimario,
        iconColor: EfectivaColors.textoSecundario,
      ),
      badgeTheme: BadgeThemeData(
        backgroundColor: EfectivaColors.rojoError,
        textColor: EfectivaColors.blanco,
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: EfectivaColors.blanco,
        hourMinuteColor: EfectivaColors.fondo,
        hourMinuteTextColor: EfectivaColors.textoPrimario,
        dayPeriodColor: EfectivaColors.fondo,
        dayPeriodTextColor: EfectivaColors.textoPrimario,
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: EfectivaColors.blanco,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: EfectivaColors.grisBorde),
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: EfectivaColors.azulCorporativo,
      scaffoldBackgroundColor: EfectivaColors.negroFondo,
      colorScheme: ColorScheme.dark(
        primary: EfectivaColors.azulCorporativo,
        onPrimary: EfectivaColors.blanco,
        secondary: EfectivaColors.azulClaro,
        onSecondary: EfectivaColors.textoPrimario,
        surface: EfectivaColors.negroSuperficie,
        onSurface: EfectivaColors.blanco,
        error: EfectivaColors.rojoError,
        onError: EfectivaColors.blanco,
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        headlineLarge: GoogleFonts.inter(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: EfectivaColors.blanco,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: EfectivaColors.blanco,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: EfectivaColors.blanco,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: EfectivaColors.blanco,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: const Color(0xFFE2E8F0),
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF94A3B8),
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF64748B),
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: EfectivaColors.blanco,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: EfectivaColors.azulCorporativo,
        foregroundColor: EfectivaColors.blanco,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: EfectivaColors.blanco,
        ),
        iconTheme: const IconThemeData(color: EfectivaColors.blanco),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: EfectivaColors.azulCorporativo,
          foregroundColor: EfectivaColors.blanco,
          disabledBackgroundColor: EfectivaColors.grisCarbon,
          disabledForegroundColor: EfectivaColors.grisMedio,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: EfectivaColors.azulClaro,
          disabledForegroundColor: EfectivaColors.grisMedio,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(color: EfectivaColors.azulClaro),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: EfectivaColors.grisOscuro,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: EfectivaColors.grisCarbon),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: EfectivaColors.grisCarbon),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: EfectivaColors.azulCorporativo, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: EfectivaColors.rojoError),
        ),
        labelStyle: GoogleFonts.inter(
          color: EfectivaColors.grisMedio,
          fontSize: 13,
        ),
        hintStyle: GoogleFonts.inter(
          color: const Color(0xFF6B7CA3),
          fontSize: 13,
        ),
      ),
      cardTheme: CardThemeData(
        color: EfectivaColors.negroSuperficie,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        margin: const EdgeInsets.symmetric(vertical: 5),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: EfectivaColors.negroSuperficie,
        selectedItemColor: EfectivaColors.azulCorporativo,
        unselectedItemColor: const Color(0xFF6B7CA3),
        type: BottomNavigationBarType.fixed,
        elevation: 10,
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: EfectivaColors.grisCarbon,
        thickness: 1,
        space: 0,
      ),
    );
  }

  static TextTheme _buildTextTheme() {
    return GoogleFonts.interTextTheme().copyWith(
      headlineLarge: GoogleFonts.inter(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        color: EfectivaColors.textoPrimario,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: EfectivaColors.textoPrimario,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: EfectivaColors.textoPrimario,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: EfectivaColors.textoPrimario,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: EfectivaColors.textoPrimario,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: EfectivaColors.textoSecundario,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: EfectivaColors.grisMedio,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: EfectivaColors.blanco,
      ),
    );
  }
}
