import 'package:firebase_login/library/firebase_login/widgets/form_validator.dart';

//------------------------------------------------------------------------------
enum EmailStatus { valid, invalid, noValidated }

class Email extends FormValidatorField<String, EmailStatus> {
  Email({
    required String initValue,
    EmailStatus status = EmailStatus.noValidated,
  }) : super(value: initValue, status: status);

  @override
  EmailStatus validate() {
    //return this.status = value.isEmpty ? EmailStatus.invalid : EmailStatus.valid;
    this.errorMsg = '';
    this.status = EmailStatus.valid;

    if (value.isEmpty) {
      this.errorMsg = "L'usuari és obligatori";
      this.status = EmailStatus.invalid;
    }
    return this.status;
  }

  Email copyWith({String? value, EmailStatus? status, String? errorMsg}) {
    //return Email(initValue: value, status: status)..errorMsg = errorMsg;
    return Email(
      initValue: value ?? this.value,
      status: status ?? this.status,
    )..errorMsg = errorMsg;
  }

  @override
  bool get isValid => (this.status == EmailStatus.valid);
  bool get isInvalid => (this.status == EmailStatus.invalid);
}

//------------------------------------------------------------------------------
enum PasswordStatus { valid, invalid, noValidated }

class Password extends FormValidatorField<String, PasswordStatus> {
  Password({
    required String initValue,
    PasswordStatus status = PasswordStatus.noValidated,
  }) : super(value: initValue, status: status);

  @override
  PasswordStatus validate() {
    //return this.status = value.isEmpty ? PasswordStatus.invalid : PasswordStatus.valid;
    this.errorMsg = '';
    this.status = PasswordStatus.valid;

    if (value.isEmpty) {
      this.errorMsg = 'La contrasenya és obligatoria';
      this.status = PasswordStatus.invalid;
    }
    return this.status;
  }

  Password copyWith({String? value, PasswordStatus? status, String? errorMsg}) {
    return Password(
      initValue: value ?? this.value,
      status: status ?? this.status,
    )..errorMsg = errorMsg;
  }

  @override
  bool get isValid => (this.status == PasswordStatus.valid);
  bool get isInvalid => (this.status == PasswordStatus.invalid);
}
