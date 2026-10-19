# Cheque Management Testing Guide

This document provides test payloads for cheque management operations.

---

## 🧪 Testing Confirm Cheque

Use the payload below to test cheque confirmation.

### Test Payload

```json
{
  "AccountNumber": "2000593979",
  "ChequeNumber": "12082379",
  "Amount": "20000",
  "SecurityNumber": "3557294",
  "ChequeDate": "2025-01-02",
  "BeneficiaryName": "TAOBA NIG.ENTERPRISES",
  "IdentificationMode": "SELF",
  "UserToken": "12345678",
  "SerialNumber": "3021326"
}
```

### ⚠️ Important Notes

* **UserToken:** Always use `12345678` (static for testing)
* **ChequeNumber:** Change this value for each test
* All other fields can remain the same

---

## 🛑 Testing Stop Cheque

Use the payload below to test stop cheque functionality.

### Test Payload

```json
{
  "AccountNumber": "2000593979",
  "ChequeNumber": "12082333",
  "Amount": "20000",
  "StopChequeReason": "Frud",
  "UserToken": "12345678"
}
```

### ⚠️ Important Notes

* **UserToken:** Always use `12345678` (static for testing)
* **ChequeNumber:** Change this value for each test
* All other fields can remain the same

---

## 📌 Summary

* ✅ UserToken is always `12345678`
* 🔄 Change ChequeNumber for each test

---
Happy testing 🧪