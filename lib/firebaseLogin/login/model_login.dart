import 'package:firebase_login/firebaseLogin/widgets/form_validator.dart';

//------------------------------------------------------------------------------
enum EmailStatus { valid, invalid, noValidated }

class Email extends FormValidatorField<String, EmailStatus> {
  Email({
    required String initValue,
    EmailStatus status = EmailStatus.noValidated,
  }) : super(value: initValue, status: status);

  @override
  EmailStatus validate() {
    return this.status = value.isEmpty ? EmailStatus.invalid : EmailStatus.valid;
  }

  Email copyWith({required String value, required EmailStatus status}) {
    return Email(initValue: value, status: status);
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
    return this.status = value.isEmpty ? PasswordStatus.invalid : PasswordStatus.valid;
  }

  Password copyWith({required String value, required PasswordStatus status}) {
    return Password(initValue: value, status: status);
  }

  @override
  bool get isValid => (this.status == PasswordStatus.valid);
  bool get isInvalid => (this.status == PasswordStatus.invalid);
}
