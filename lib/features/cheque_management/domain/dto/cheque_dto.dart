class ConfirmChequeDto {
  final String accountNumber;
  final String chequeNumber;
  final double amount;
  final String securityNumber;
  final String chequeDate;
  final String beneficiaryName;
  final String identificationMode;
  final String userToken;

  ConfirmChequeDto({
    required this.accountNumber,
    required this.chequeNumber,
    required this.amount,
    required this.securityNumber,
    required this.chequeDate,
    required this.beneficiaryName,
    required this.identificationMode,
    required this.userToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'AccountNumber': accountNumber,
      'ChequeNumber': chequeNumber,
      'Amount': amount,
      'SecurityNumber': securityNumber,
      'ChequeDate': chequeDate,
      'BeneficiaryName': beneficiaryName,
      'IdentificationMode': identificationMode,
      'UserToken': userToken,
    };
  }
}

class StopChequeDto {
  final String accountNumber;
  final String chequeNumber;
  final double amount;
  final String stopChequeReason;
  final String userToken;

  StopChequeDto({
    required this.accountNumber,
    required this.chequeNumber,
    required this.amount,
    required this.stopChequeReason,
    required this.userToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'AccountNumber': accountNumber,
      'ChequeNumber': chequeNumber,
      'Amount': amount,
      'StopChequeReason': stopChequeReason,
      'UserToken': userToken,
    };
  }
}
