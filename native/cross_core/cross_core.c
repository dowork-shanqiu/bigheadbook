#include "cross_core.h"

static double g_balance = 0.0;
static int g_total_count = 0;

int crosscore_init(void) {
  g_balance = 0.0;
  g_total_count = 0;
  return 0;
}

int crosscore_add_transaction(double amount, const char* currency, const char* note) {
  (void)currency;
  (void)note;
  g_balance += amount;
  g_total_count += 1;
  return 0;
}

int crosscore_query_summary(CrossCoreSummary* summary) {
  if (!summary) {
    return -1;
  }
  summary->balance = g_balance;
  summary->totalCount = g_total_count;
  return 0;
}
