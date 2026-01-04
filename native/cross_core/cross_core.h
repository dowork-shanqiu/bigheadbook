#pragma once

#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
  double amount;
  const char* currency;
  const char* note;
} CrossCoreTransaction;

typedef struct {
  double balance;
  int totalCount;
} CrossCoreSummary;

// Initialize resources. Return 0 on success.
int crosscore_init(void);

// Add a transaction. Returns 0 on success.
int crosscore_add_transaction(double amount, const char* currency, const char* note);

// Query summary; summary pointer must be valid.
int crosscore_query_summary(CrossCoreSummary* summary);

#ifdef __cplusplus
}  // extern "C"
#endif
