abstract class FormValidatorField<T, E> {
  final T value;
  E status;

  FormValidatorField({
    required this.value,
    required this.status,
  });

  E validate();
  bool get isValid;
}

// -----------------------------------------------------------------------------
enum FormValidatorStatus { noValidated, valid, invalid, submissionInProgress, submissionSuccess, submissionFailure }

class FormValidator {
  static FormValidatorStatus validate(List<FormValidatorField> fields) {
    for (var field in fields) {
      field.validate();
    }
    return fields.every((field) => field.isValid) ? FormValidatorStatus.valid : FormValidatorStatus.invalid;
  }
}
