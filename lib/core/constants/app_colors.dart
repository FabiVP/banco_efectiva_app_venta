import 'package:flutter/material.dart';

class EfectivaColors {
  // Colores corporativos de Financiera Efectiva — Fuerza de Ventas
  // Mismo branding que la app cliente pero con acento en naranja para diferenciar
  static const Color azulPrincipal = Color(0xFF0047AB);
  static const Color azulOscuro = Color(0xFF002D6E);
  static const Color azulClaro = Color(0xFF1A6FEB);
  static const Color azulSuave = Color(0xFFE8F1FD);

  // Acento naranja/amarillo (tarjeta y CTAs)
  static const Color naranjaAcento = Color(0xFFFF8C00);
  static const Color amarilloAcento = Color(0xFFFFB800);
  static const Color amarilloClaro = Color(0xFFFFF3D6);

  // Verdes para éxito y estados positivos
  static const Color verdeExito = Color(0xFF00A859);
  static const Color verdeSuave = Color(0xFFE6F7EF);

  // Fondos y neutros
  static const Color grisFondo = Color(0xFFF4F6FA);
  static const Color grisClaro = Color(0xFFEEF0F5);
  static const Color blanco = Color(0xFFFFFFFF);
  static const Color negroTexto = Color(0xFF1A1A2E);
  static const Color grisTexto = Color(0xFF6B7280);
  static const Color grisSubtitulo = Color(0xFF9CA3AF);

  // Error
  static const Color rojoError = Color(0xFFE53935);
  static const Color rojoSuave = Color(0xFFFDECEC);

  // Estados de solicitud
  static const Color estadoEnviado = Color(0xFF2196F3);
  static const Color estadoEvaluacion = Color(0xFFFF9800);
  static const Color estadoAprobado = Color(0xFF4CAF50);
  static const Color estadoDesembolsado = Color(0xFF00897B);
  static const Color estadoRechazado = Color(0xFFE53935);

  // Gradientes
  static const LinearGradient gradientePrincipal = LinearGradient(
    colors: [azulOscuro, azulPrincipal, azulClaro],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gradienteHeader = LinearGradient(
    colors: [azulOscuro, azulPrincipal],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient gradienteTarjeta = LinearGradient(
    colors: [Color(0xFF0D2B5A), Color(0xFF1A4FA0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gradienteNaranja = LinearGradient(
    colors: [Color(0xFFFF8C00), Color(0xFFFFB800)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gradienteVerde = LinearGradient(
    colors: [Color(0xFF00A859), Color(0xFF00C853)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
