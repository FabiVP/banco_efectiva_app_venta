import 'package:flutter/material.dart';

class EfectivaColors {
  // ──────────────────────────────────────────────
  // SISTEMA DE DISEÑO — Financiera Efectiva
  // Corporativo · Profesional · Alta legibilidad
  // Light: 65% blanco/gris · 25% azul · 10% texto
  // Dark : 65% negro/gris oscuro · 25% azul · 10% blanco
  // ──────────────────────────────────────────────

  // ── Tokens adaptativos (usar en widgets con BuildContext) ──
  static Color superficie_(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark
          ? negroSuperficie
          : blanco;

  static Color fondoCard_(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark
          ? const Color(0xFF1C2440)
          : blanco;

  static Color textoPrimario_(BuildContext ctx) =>
      Theme.of(ctx).colorScheme.onSurface;

  static Color textoSecundario_(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark
          ? const Color(0xFF9BA8C0)
          : textoSecundario;

  static Color iconoSecundario_(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark
          ? const Color(0xFF9BA8C0)
          : textoSecundario;

  // ── Primario ──
  static const Color azulCorporativo = Color(0xFF1565F5);

  // ── Blancos y Superficies (65%) ──
  static const Color blanco = Color(0xFFFFFFFF);
  static const Color fondo = Color(0xFFF5F7FA);
  static const Color superficie = Color(0xFFFFFFFF);
  static const Color inputBg = Color(0xFFF9FAFB);

  // ── Grises ──
  static const Color grisBordeClaro = Color(0xFFE5E7EB);
  static const Color grisBorde = Color(0xFFD1D5DB);
  static const Color grisMedio = Color(0xFF9CA3AF);
  static const Color grisPlaceholder = Color(0xFF9CA3AF);
  static const Color grisTexto = Color(0xFF6B7280);

  // ── Texto de alto contraste (10%) ──
  static const Color textoPrimario = Color(0xFF111827);
  static const Color textoSecundario = Color(0xFF6B7280);
  static const Color textoDisabled = Color(0xFF9CA3AF);

  // ── Azules corporativos (25%) ──
  static const Color azulOscuro = Color(0xFF0D47A1);
  static const Color azulMedio = Color(0xFF1976D2);
  static const Color azulClaro = Color(0xFF42A5F5);
  static const Color azulSuave = Color(0xFFE3F2FD);
  static const Color azulFondo = Color(0xFFF0F5FF);

  // ── Semánticos ──
  static const Color rojoError = Color(0xFFEF4444);
  static const Color rojoSuave = Color(0xFFFEE2E2);
  static const Color verdeExito = Color(0xFF10B981);
  static const Color verdeSuave = Color(0xFFD1FAE5);
  static const Color naranjaAcento = Color(0xFFF97316);
  static const Color naranjaSuave = Color(0xFFFFEDD5);
  static const Color amberExito = Color(0xFFF59E0B);
  static const Color amberSuave = Color(0xFFFEF3C7);

  // ── Estados de solicitud ──
  static const Color estadoEnviado = Color(0xFF3B82F6);
  static const Color estadoEvaluacion = Color(0xFFF59E0B);
  static const Color estadoAprobado = Color(0xFF10B981);
  static const Color estadoDesembolsado = Color(0xFF0EA5E9);
  static const Color estadoRechazado = Color(0xFFEF4444);

  // ── Tipos de visita ──
  static const Color visitaRenovacion = Color(0xFF10B981);
  static const Color visitaProspeccion = Color(0xFF3B82F6);
  static const Color visitaSeguimiento = Color(0xFF1565F5);
  static const Color visitaCobranza = Color(0xFFEF4444);

  // ── Colores de dashboard ──
  static const Color dashboardMorado = Color(0xFF7C3AED);
  static const Color dashboardVerde = Color(0xFF059669);

  // ── Gradientes ──
  static const LinearGradient gradientePrincipal = LinearGradient(
    colors: [Color(0xFF1565F5), Color(0xFF1E6BFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gradienteAzulOscuro = LinearGradient(
    colors: [Color(0xFF0D47A1), Color(0xFF1565F5)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient gradienteCard = LinearGradient(
    colors: [Color(0xFF0D2B5A), Color(0xFF1A4FA0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gradienteAmbar = LinearGradient(
    colors: [Color(0xFFF97316), Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gradienteVerde = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Aliases de compatibilidad ──
  static const Color azulPrincipal = azulCorporativo;
  static const Color azulInstitucional = azulCorporativo;
  static const Color azulCorporativo2 = azulCorporativo;
  static const Color azulSecundario = azulMedio;
  static const Color negroTexto = textoPrimario;
  static const Color grisSubtitulo = grisTexto;
  static const Color grisCard = superficie;
  static const Color grisClaro = grisBordeClaro;
  static const Color grisFondo = fondo;
  static const Color blancoHueso = blanco;
  static const Color blancoFondo = Color(0xFFF5F5F5);
  static const Color amarilloAcento = amberExito;
  static const Color amarilloClaro = amberSuave;
  static const Color rojoErrorOld = rojoError;
  static const Color negroFondo = Color(0xFF0F172A);
  static const Color negroSuperficie = Color(0xFF1E293B);
  static const Color grisOscuro = Color(0xFF334155);
  static const Color grisCarbon = Color(0xFF2A3450);
  static const Color crema = Color(0xFFF5F0E8);
  static const Color cremaOpaco = Color(0x80F5F0E8);
  static const Color doradoClaro = Color(0xFFD4AF37);

  // ── Aliases de gradientes ──
  static const LinearGradient gradienteHeader = gradientePrincipal;
  static const LinearGradient gradienteNaranja = gradienteAmbar;
  static const LinearGradient gradienteTarjeta = gradienteCard;
  static const LinearGradient gradienteDark = LinearGradient(
    colors: [Color(0xFF0F172A), Color(0xFF0A1E4A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient gradienteExito = gradienteVerde;
}
