import 'package:ndk/domain_layer/usecases/nwc/consts/budget_renewal_period.dart';
import 'package:ndk/ndk.dart' show GetBudgetResponse, NwcMethod;

/// What Lumen does with an NWC connection, each backed by a NIP-47 method.
enum NwcAbility {
  readBalance,
  receive,
  pay,
  listTransactions;

  String get method => switch (this) {
    readBalance => NwcMethod.GET_BALANCE.name,
    receive => NwcMethod.MAKE_INVOICE.name,
    pay => NwcMethod.PAY_INVOICE.name,
    listTransactions => NwcMethod.LIST_TRANSACTIONS.name,
  };
}

enum BudgetPeriod { day, week, month, year, total }

class NwcBudget {
  const NwcBudget({required this.sats, required this.period});

  final int sats;
  final BudgetPeriod period;
}

/// What a connection string lets Lumen do, as its wallet describes it.
class NwcGrant {
  const NwcGrant({required this.abilities, this.budget});

  final Set<NwcAbility> abilities;

  /// The spending limit, or null when payments are not capped.
  final NwcBudget? budget;
}

/// Reads the methods a connection allows and its `get_budget` answer.
NwcGrant nwcGrant(Set<String> methods, GetBudgetResponse? budget) {
  final total = budget?.totalBudgetSats ?? 0;
  return NwcGrant(
    abilities: {
      for (final ability in NwcAbility.values)
        if (methods.contains(ability.method)) ability,
    },
    budget: total <= 0
        ? null
        : NwcBudget(
            sats: total,
            period: switch (budget!.renewalPeriod) {
              BudgetRenewalPeriod.daily => BudgetPeriod.day,
              BudgetRenewalPeriod.weekly => BudgetPeriod.week,
              BudgetRenewalPeriod.monthly => BudgetPeriod.month,
              BudgetRenewalPeriod.yearly => BudgetPeriod.year,
              BudgetRenewalPeriod.never => BudgetPeriod.total,
            },
          ),
  );
}
