class Validators {
  static String? requerido(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es requerido';
    }
    return null;
  }

  static String? codigoEmpleado(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa tu código de empleado';
    }
    if (value.length < 4) {
      return 'Código inválido';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingresa tu contraseña';
    }
    if (value.length < 4) {
      return 'La contraseña debe tener al menos 4 caracteres';
    }
    return null;
  }

  static String? dni(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa el número de DNI';
    }
    if (value.length != 8 || int.tryParse(value) == null) {
      return 'El DNI debe tener 8 dígitos';
    }
    return null;
  }

  static String? telefono(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa el teléfono';
    }
    if (value.length < 9) {
      return 'Teléfono inválido';
    }
    return null;
  }

  static String? monto(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa el monto';
    }
    final monto = double.tryParse(value);
    if (monto == null || monto <= 0) {
      return 'Monto inválido';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa el correo electrónico';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Correo electrónico inválido';
    }
    return null;
  }
}
