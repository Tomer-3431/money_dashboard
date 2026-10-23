import 'package:flutter/material.dart';

/// ---------------------------------------------------------------------------
/// theme_constants.dart
/// Central design system for the finance dashboard – LIGHT and DARK.
///
/// How it works:
///  * [AppColors] is a ThemeExtension holding one full palette.
///    `AppColors.light` and `AppColors.dark` are the two palettes.
///  * Read colors anywhere with `context.colors.primary` – they switch
///    automatically with the theme.
///  * Text styles: `context.h1`, `context.standard`, `context.label` ...
///  * Requires Flutter 3.27+ (Material 3, CardThemeData, withValues).
/// ---------------------------------------------------------------------------

// ============================================================================
// 1. COLORS  (one palette per brightness)
// ============================================================================
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    // Brand
    required this.primary,
    required this.primaryHover,
    required this.primaryLight,
    required this.onPrimary,
    required this.secondary,
    // Surfaces
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    // Text
    required this.text,
    required this.textSecondary,
    required this.textDisabled,
    // Interaction
    required this.hover,
    required this.pressed,
    // Lines
    required this.border,
    required this.divider,
    // Finance semantics
    required this.income,
    required this.expense,
    required this.savings,
    required this.investment,
    // Status
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
    // Charts
    required this.chart,
  });

  // --- Brand ---------------------------------------------------------------
  final Color primary;
  final Color primaryHover; // button hover / pressed
  final Color primaryLight; // tints: selected rows, chips, badges
  final Color onPrimary; // text/icons on top of primary
  final Color secondary;

  // --- Surfaces ------------------------------------------------------------
  final Color background; // app canvas
  final Color surface; // cards, dialogs, inputs
  final Color surfaceAlt; // subtle fills, table headers

  // --- Text ----------------------------------------------------------------
  final Color text;
  final Color textSecondary;
  final Color textDisabled;

  // --- Interaction ---------------------------------------------------------
  final Color hover;
  final Color pressed;

  // --- Lines ---------------------------------------------------------------
  final Color border;
  final Color divider;

  // --- Finance semantics ---------------------------------------------------
  final Color income;
  final Color expense;
  final Color savings;
  final Color investment;

  // --- Status --------------------------------------------------------------
  final Color success;
  final Color warning;
  final Color error;
  final Color info;

  // --- Chart palette (use in order for pies / bars / lines) ----------------
  final List<Color> chart;

  // ---------------------------------------------------------------------------
  // LIGHT PALETTE
  // ---------------------------------------------------------------------------
  static const AppColors light = AppColors(
    primary: Color(0xFF4F46E5), // Indigo
    primaryHover: Color(0xFF3730A3),
    primaryLight: Color(0xFFE0E7FF),
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFF0EA5A4), // Teal
    background: Color(0xFFF8FAFC),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFF1F5F9),
    text: Color(0xFF0F172A),
    textSecondary: Color(0xFF64748B),
    textDisabled: Color(0xFF94A3B8),
    hover: Color(0xFFEEF2FF),
    pressed: Color(0xFFE0E7FF),
    border: Color(0xFFE2E8F0),
    divider: Color(0xFFE2E8F0),
    income: Color(0xFF10B981),
    expense: Color(0xFFEF4444),
    savings: Color(0xFF3B82F6),
    investment: Color(0xFF8B5CF6),
    success: Color(0xFF10B981),
    warning: Color(0xFFF59E0B),
    error: Color(0xFFEF4444),
    info: Color(0xFF3B82F6),
    chart: [
      Color(0xFF4F46E5),
      Color(0xFF0EA5A4),
      Color(0xFFF59E0B),
      Color(0xFFEC4899),
      Color(0xFF3B82F6),
      Color(0xFF8B5CF6),
      Color(0xFF10B981),
      Color(0xFFEF4444),
    ],
  );

  // ---------------------------------------------------------------------------
  // DARK PALETTE
  // Deep navy-slate surfaces (not pure black) with lighter, slightly softer
  // accents so everything keeps good contrast without glaring.
  // ---------------------------------------------------------------------------
  static const AppColors dark = AppColors(
    primary: Color(0xFF818CF8), // Lighter indigo for contrast on dark
    primaryHover: Color(0xFFA5B4FC), // Hover gets lighter (not darker)
    primaryLight: Color(0xFF2A2D5E),
    onPrimary: Color(0xFF0B1020),
    secondary: Color(0xFF2DD4BF),
    background: Color(0xFF0B1120),
    surface: Color(0xFF111827),
    surfaceAlt: Color(0xFF1B2433),
    text: Color(0xFFF1F5F9),
    textSecondary: Color(0xFF94A3B8),
    textDisabled: Color(0xFF64748B),
    hover: Color(0xFF1A2336),
    pressed: Color(0xFF243049),
    border: Color(0xFF263244),
    divider: Color(0xFF1F2A3B),
    income: Color(0xFF34D399),
    expense: Color(0xFFF87171),
    savings: Color(0xFF60A5FA),
    investment: Color(0xFFA78BFA),
    success: Color(0xFF34D399),
    warning: Color(0xFFFBBF24),
    error: Color(0xFFF87171),
    info: Color(0xFF60A5FA),
    chart: [
      Color(0xFF818CF8),
      Color(0xFF2DD4BF),
      Color(0xFFFBBF24),
      Color(0xFFF472B6),
      Color(0xFF60A5FA),
      Color(0xFFA78BFA),
      Color(0xFF34D399),
      Color(0xFFF87171),
    ],
  );

  // --- ThemeExtension plumbing ---------------------------------------------
  @override
  AppColors copyWith({
    Color? primary,
    Color? primaryHover,
    Color? primaryLight,
    Color? onPrimary,
    Color? secondary,
    Color? background,
    Color? surface,
    Color? surfaceAlt,
    Color? text,
    Color? textSecondary,
    Color? textDisabled,
    Color? hover,
    Color? pressed,
    Color? border,
    Color? divider,
    Color? income,
    Color? expense,
    Color? savings,
    Color? investment,
    Color? success,
    Color? warning,
    Color? error,
    Color? info,
    List<Color>? chart,
  }) =>
      AppColors(
        primary: primary ?? this.primary,
        primaryHover: primaryHover ?? this.primaryHover,
        primaryLight: primaryLight ?? this.primaryLight,
        onPrimary: onPrimary ?? this.onPrimary,
        secondary: secondary ?? this.secondary,
        background: background ?? this.background,
        surface: surface ?? this.surface,
        surfaceAlt: surfaceAlt ?? this.surfaceAlt,
        text: text ?? this.text,
        textSecondary: textSecondary ?? this.textSecondary,
        textDisabled: textDisabled ?? this.textDisabled,
        hover: hover ?? this.hover,
        pressed: pressed ?? this.pressed,
        border: border ?? this.border,
        divider: divider ?? this.divider,
        income: income ?? this.income,
        expense: expense ?? this.expense,
        savings: savings ?? this.savings,
        investment: investment ?? this.investment,
        success: success ?? this.success,
        warning: warning ?? this.warning,
        error: error ?? this.error,
        info: info ?? this.info,
        chart: chart ?? this.chart,
      );

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      primary: l(primary, other.primary),
      primaryHover: l(primaryHover, other.primaryHover),
      primaryLight: l(primaryLight, other.primaryLight),
      onPrimary: l(onPrimary, other.onPrimary),
      secondary: l(secondary, other.secondary),
      background: l(background, other.background),
      surface: l(surface, other.surface),
      surfaceAlt: l(surfaceAlt, other.surfaceAlt),
      text: l(text, other.text),
      textSecondary: l(textSecondary, other.textSecondary),
      textDisabled: l(textDisabled, other.textDisabled),
      hover: l(hover, other.hover),
      pressed: l(pressed, other.pressed),
      border: l(border, other.border),
      divider: l(divider, other.divider),
      income: l(income, other.income),
      expense: l(expense, other.expense),
      savings: l(savings, other.savings),
      investment: l(investment, other.investment),
      success: l(success, other.success),
      warning: l(warning, other.warning),
      error: l(error, other.error),
      info: l(info, other.info),
      chart: t < 0.5 ? chart : other.chart,
    );
  }
}

// ============================================================================
// CONTEXT SHORTCUTS  →  context.colors.primary, context.h1, context.label ...
// ============================================================================
extension AppThemeContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  TextTheme get _tt => Theme.of(this).textTheme;
  TextStyle get h1 => _tt.headlineLarge!;
  TextStyle get h2 => _tt.headlineMedium!;
  TextStyle get h3 => _tt.headlineSmall!;
  TextStyle get h4 => _tt.titleLarge!;
  TextStyle get standard => _tt.bodyMedium!;
  TextStyle get label => _tt.labelMedium!;
  TextStyle get caption => _tt.bodySmall!;
}

// ============================================================================
// LAYOUT TOKENS (same in light & dark)
// ============================================================================
class AppSpacing {
  AppSpacing._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

class AppRadius {
  AppRadius._();
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;

  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
}

class AppShadows {
  AppShadows._();

  /// Soft card shadow; deeper in dark mode so cards still separate from the canvas.
  static List<BoxShadow> card(BuildContext context) => [
        BoxShadow(
          color: context.isDark
              ? const Color(0x66000000)
              : const Color(0x0F0F172A),
          blurRadius: context.isDark ? 24 : 16,
          offset: const Offset(0, 4),
        ),
      ];
}

// ============================================================================
// 2. APP BAR THEME
// ============================================================================
class AppBarStyles {
  AppBarStyles._();

  static AppBarTheme build(AppColors c) => AppBarTheme(
        backgroundColor: c.surface,
        foregroundColor: c.text,
        surfaceTintColor: Colors.transparent, // no M3 tint on scroll
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        toolbarHeight: 64,
        titleSpacing: AppSpacing.lg,
        iconTheme: IconThemeData(color: c.textSecondary, size: 22),
        actionsIconTheme: IconThemeData(color: c.textSecondary, size: 22),
        shape: Border(bottom: BorderSide(color: c.border, width: 1)),
        titleTextStyle: TextStyle(
          color: c.text,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      );
}

// ============================================================================
// 3. TEXT THEME  (h1, h2, h3, h4, standard, label)
// ----------------------------------------------------------------------------
// AppTextStyles = shape only (size, weight, spacing) – no color, so it is
// reusable in both modes. Colors are applied in AppTextTheme.build().
// Prefer `context.h1` etc. – they come with the right color for the theme.
// ============================================================================
class AppTextStyles {
  AppTextStyles._();

  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    height: 1.25,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.8,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 26,
    height: 1.3,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 21,
    height: 1.35,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
  );

  static const TextStyle h4 = TextStyle(
    fontSize: 17,
    height: 1.4,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
  );

  static const TextStyle standard = TextStyle(
    fontSize: 14,
    height: 1.5,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle label = TextStyle(
    fontSize: 12,
    height: 1.4,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    height: 1.4,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  // --- Finance extras (colorless: inherit the text color, or copyWith) ------
  /// Big KPI numbers. Tabular figures keep digits aligned.
  static const TextStyle amountLarge = TextStyle(
    fontSize: 36,
    height: 1.2,
    fontWeight: FontWeight.w700,
    letterSpacing: -1,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Numbers inside tables / lists.
  static const TextStyle amount = TextStyle(
    fontSize: 14,
    height: 1.5,
    fontWeight: FontWeight.w600,
    fontFeatures: [FontFeature.tabularFigures()],
  );
}

class AppTextTheme {
  AppTextTheme._();

  /// Maps the named styles onto Flutter's TextTheme so built-in widgets
  /// (ListTile, DataTable, dialogs…) pick them up automatically.
  static TextTheme build(AppColors c) => TextTheme(
        headlineLarge: AppTextStyles.h1.copyWith(color: c.text),
        headlineMedium: AppTextStyles.h2.copyWith(color: c.text),
        headlineSmall: AppTextStyles.h3.copyWith(color: c.text),
        titleLarge: AppTextStyles.h4.copyWith(color: c.text),
        titleMedium: AppTextStyles.standard.copyWith(color: c.text),
        titleSmall: AppTextStyles.label.copyWith(color: c.textSecondary),
        bodyLarge: AppTextStyles.standard.copyWith(color: c.text),
        bodyMedium: AppTextStyles.standard.copyWith(color: c.text),
        bodySmall: AppTextStyles.caption.copyWith(color: c.textSecondary),
        labelLarge: AppTextStyles.button, // buttons set their own color
        labelMedium: AppTextStyles.label.copyWith(color: c.textSecondary),
        labelSmall: AppTextStyles.caption.copyWith(color: c.textSecondary),
      );
}

// ============================================================================
// 4. INPUT DECORATIONS  (text, number, date, selective, boolean)
// ============================================================================
class AppInputDecorations {
  AppInputDecorations._();

  static OutlineInputBorder _border(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: AppRadius.mdAll,
        borderSide: BorderSide(color: color, width: width),
      );

  /// Base decoration applied app-wide through ThemeData.
  static InputDecorationTheme build(AppColors c) => InputDecorationTheme(
        filled: true,
        fillColor: c.surface,
        hoverColor: c.hover,
        isDense: false,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 14,
        ),
        labelStyle:
            AppTextStyles.standard.copyWith(color: c.textSecondary),
        floatingLabelStyle: AppTextStyles.label.copyWith(
          color: c.primary,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: AppTextStyles.standard.copyWith(color: c.textDisabled),
        helperStyle: AppTextStyles.caption.copyWith(color: c.textSecondary),
        errorStyle: AppTextStyles.caption.copyWith(color: c.error),
        prefixIconColor: c.textSecondary,
        suffixIconColor: c.textSecondary,
        border: _border(c.border),
        enabledBorder: _border(c.border),
        focusedBorder: _border(c.primary, 1.8),
        errorBorder: _border(c.error),
        focusedErrorBorder: _border(c.error, 1.8),
        disabledBorder: _border(c.border.withValues(alpha: 0.6)),
      );

  // --- Text ----------------------------------------------------------------
  static InputDecoration text({
    String? label,
    String? hint,
    IconData? icon,
    String? helper,
  }) =>
      InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helper,
        prefixIcon: icon != null ? Icon(icon, size: 20) : null,
      );

  // --- Number (amounts) ----------------------------------------------------
  /// Use with: keyboardType: TextInputType.numberWithOptions(decimal: true)
  static InputDecoration number({
    String? label,
    String? hint,
    String currencySymbol = '₪',
    String? helper,
  }) =>
      InputDecoration(
        labelText: label,
        hintText: hint ?? '0.00',
        helperText: helper,
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: AppSpacing.md, right: 6),
          child: Center(
            widthFactor: 1,
            // Builder so the symbol follows the current theme color.
            child: Builder(
              builder: (context) => Text(
                currencySymbol,
                style: AppTextStyles.amount
                    .copyWith(color: context.colors.textSecondary),
              ),
            ),
          ),
        ),
      );

  // --- Date ----------------------------------------------------------------
  /// Use with: readOnly: true, onTap: () => showDatePicker(...)
  static InputDecoration date({
    String? label,
    String? hint,
    String? helper,
  }) =>
      InputDecoration(
        labelText: label,
        hintText: hint ?? 'DD/MM/YYYY',
        helperText: helper,
        suffixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
      );

  // --- Selective (dropdown / category picker) ------------------------------
  /// Use with DropdownButtonFormField.
  static InputDecoration selective({
    String? label,
    String? hint,
    IconData? icon,
    String? helper,
  }) =>
      InputDecoration(
        labelText: label,
        hintText: hint ?? 'Select…',
        helperText: helper,
        prefixIcon: icon != null ? Icon(icon, size: 20) : null,
      );

  // --- Boolean (switch / checkbox row) -------------------------------------
  /// Borderless – wrap a Switch / Checkbox:
  ///   InputDecorator(
  ///     decoration: AppInputDecorations.boolean(label: 'Recurring'),
  ///     child: Switch(value: v, onChanged: ...))
  static InputDecoration boolean({String? label, String? helper}) =>
      InputDecoration(
        labelText: label,
        helperText: helper,
        filled: false,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      );
}

// ============================================================================
// 5. APP THEME  (light + dark)
// ============================================================================
class AppTheme {
  AppTheme._();

  static final ThemeData light = _build(AppColors.light, Brightness.light);
  static final ThemeData dark = _build(AppColors.dark, Brightness.dark);

  static ThemeData _build(AppColors c, Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: c.primary,
      brightness: brightness,
    ).copyWith(
      primary: c.primary,
      onPrimary: c.onPrimary,
      secondary: c.secondary,
      surface: c.surface,
      onSurface: c.text,
      error: c.error,
      outline: c.border,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      extensions: <ThemeExtension<dynamic>>[c], // enables context.colors
      scaffoldBackgroundColor: c.background,
      canvasColor: c.background,
      hoverColor: c.hover,
      splashColor: c.pressed.withValues(alpha: 0.5),
      highlightColor: Colors.transparent,
      dividerColor: c.divider,
      visualDensity: VisualDensity.adaptivePlatformDensity, // compact on desktop

      // Core themes
      appBarTheme: AppBarStyles.build(c),
      textTheme: AppTextTheme.build(c),
      inputDecorationTheme: AppInputDecorations.build(c),

      // Cards – the building block of a dashboard
      cardTheme: CardThemeData(
        color: c.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.lgAll,
          side: BorderSide(color: c.border),
        ),
      ),

      dividerTheme: DividerThemeData(color: c.divider, thickness: 1, space: 1),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          elevation: const WidgetStatePropertyAll(0),
          textStyle: const WidgetStatePropertyAll(AppTextStyles.button),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
          ),
          foregroundColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.disabled)
                  ? c.textSecondary
                  : c.onPrimary),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) return c.surfaceAlt;
            if (states.contains(WidgetState.pressed) ||
                states.contains(WidgetState.hovered)) {
              return c.primaryHover;
            }
            return c.primary;
          }),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          textStyle: const WidgetStatePropertyAll(AppTextStyles.button),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
          ),
          foregroundColor: WidgetStatePropertyAll(c.text),
          side: WidgetStatePropertyAll(BorderSide(color: c.border)),
          backgroundColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.hovered)
                  ? c.hover
                  : Colors.transparent),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          textStyle: const WidgetStatePropertyAll(AppTextStyles.button),
          foregroundColor: WidgetStatePropertyAll(c.primary),
          overlayColor: WidgetStatePropertyAll(c.hover),
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: AppRadius.smAll),
          ),
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: c.primary,
        foregroundColor: c.onPrimary,
        elevation: 2,
        hoverElevation: 4,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
      ),

      iconTheme: IconThemeData(color: c.textSecondary, size: 22),

      // Lists / navigation
      listTileTheme: ListTileThemeData(
        selectedTileColor: c.primaryLight,
        selectedColor: c.primary,
        iconColor: c.textSecondary,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      ),

      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: c.surface,
        indicatorColor: c.primaryLight,
        selectedIconTheme: IconThemeData(color: c.primary),
        unselectedIconTheme: IconThemeData(color: c.textSecondary),
        selectedLabelTextStyle:
            AppTextStyles.label.copyWith(color: c.primary),
        unselectedLabelTextStyle:
            AppTextStyles.label.copyWith(color: c.textSecondary),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: c.primaryLight,
        labelTextStyle: WidgetStatePropertyAll(
          AppTextStyles.label.copyWith(color: c.textSecondary),
        ),
      ),

      // Tables (transactions list)
      dataTableTheme: DataTableThemeData(
        headingTextStyle: AppTextStyles.label.copyWith(
          color: c.textSecondary,
          fontWeight: FontWeight.w600,
        ),
        dataTextStyle: AppTextStyles.standard.copyWith(color: c.text),
        headingRowColor: WidgetStatePropertyAll(c.surfaceAlt),
        dataRowColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.hovered) ? c.hover : c.surface),
        dividerThickness: 1,
      ),

      // Form controls
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        side: BorderSide(color: c.textDisabled, width: 1.5),
        checkColor: WidgetStatePropertyAll(c.onPrimary),
        fillColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? c.primary
                : Colors.transparent),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStatePropertyAll(
          brightness == Brightness.dark ? c.text : Colors.white,
        ),
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? c.primary
                : c.textDisabled.withValues(alpha: 0.6)),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),

      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: AppInputDecorations.build(c),
        textStyle: AppTextStyles.standard.copyWith(color: c.text),
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(c.surface),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: AppRadius.mdAll,
              side: BorderSide(color: c.border),
            ),
          ),
        ),
      ),

      popupMenuTheme: PopupMenuThemeData(
        color: c.surface,
        surfaceTintColor: Colors.transparent,
        textStyle: AppTextStyles.standard.copyWith(color: c.text),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.mdAll,
          side: BorderSide(color: c.border),
        ),
      ),

      // Overlays
      dialogTheme: DialogThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        titleTextStyle: AppTextStyles.h3.copyWith(color: c.text),
        contentTextStyle: AppTextStyles.standard.copyWith(color: c.text),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
      ),

      // Inverted surface: dark bubble in light mode, light bubble in dark mode.
      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.text,
        contentTextStyle:
            AppTextStyles.standard.copyWith(color: c.background),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
      ),

      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: c.text,
          borderRadius: AppRadius.smAll,
        ),
        textStyle: AppTextStyles.caption.copyWith(color: c.background),
        waitDuration: const Duration(milliseconds: 500), // nice on desktop
      ),

      chipTheme: ChipThemeData(
        backgroundColor: c.surfaceAlt,
        selectedColor: c.primaryLight,
        labelStyle: AppTextStyles.label.copyWith(color: c.text),
        side: BorderSide.none,
        shape: const StadiumBorder(),
      ),

      datePickerTheme: DatePickerThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: c.primary,
        linearTrackColor: c.surfaceAlt,
      ),

      scrollbarTheme: ScrollbarThemeData(
        thumbColor:
            WidgetStatePropertyAll(c.textDisabled.withValues(alpha: 0.6)),
        radius: const Radius.circular(8),
        thickness: const WidgetStatePropertyAll(6),
      ),
    );
  }
}

// ============================================================================
// THEME MODE SWITCHING (optional helper)
// ----------------------------------------------------------------------------
// Holds the user's choice. Default follows the Windows / phone system setting.
// ============================================================================
final ValueNotifier<ThemeMode> appThemeMode = ValueNotifier(ThemeMode.system);

// ============================================================================
// USAGE
// ----------------------------------------------------------------------------
// main.dart:
//   ValueListenableBuilder<ThemeMode>(
//     valueListenable: appThemeMode,
//     builder: (_, mode, __) => MaterialApp(
//       title: 'Finance Dashboard',
//       theme: AppTheme.light,
//       darkTheme: AppTheme.dark,
//       themeMode: mode,
//       home: const DashboardPage(),
//     ),
//   );
//
// Toggle from anywhere (e.g. an IconButton in the AppBar):
//   appThemeMode.value =
//       context.isDark ? ThemeMode.light : ThemeMode.dark;
//
// In widgets:
//   Text('Balance', style: context.label)
//   Text('₪12,480', style: AppTextStyles.amountLarge)      // inherits text color
//   Text('+₪500', style: AppTextStyles.amount.copyWith(color: context.colors.income))
//   Container(color: context.colors.surface, ...)
//   TextFormField(decoration: AppInputDecorations.number(label: 'Amount'))
// ============================================================================
