import 'package:lumen_wallets/lumen_wallets.dart';
import 'package:lumen_wallets/src/nwc/nwc_grant.dart' show nwcGrant;
import 'package:ndk/ndk.dart' show GetBudgetResponse;
import 'package:test/test.dart';

GetBudgetResponse _budget(Map<String, dynamic> result) =>
    GetBudgetResponse.deserialize({
      'result_type': 'get_budget',
      'result': result,
    });

void main() {
  test('keeps the abilities Lumen uses', () {
    final grant = nwcGrant({
      'get_info',
      'get_balance',
      'make_invoice',
      'lookup_invoice',
    }, null);

    expect(grant.abilities, {NwcAbility.readBalance, NwcAbility.receive});
    expect(grant.budget, isNull);
  });

  test('reads a renewing budget in sats', () {
    final grant = nwcGrant(
      {'pay_invoice'},
      _budget({
        'used_budget': 1000,
        'total_budget': 50000000,
        'renewal_period': 'monthly',
      }),
    );

    expect(grant.budget?.sats, 50000);
    expect(grant.budget?.period, BudgetPeriod.month);
  });

  test('a budget that never renews is a total', () {
    final grant = nwcGrant({
      'pay_invoice',
    }, _budget({'total_budget': 21000, 'renewal_period': 'never'}));

    expect(grant.budget?.period, BudgetPeriod.total);
  });

  test('an empty budget answer means no limit', () {
    expect(nwcGrant({'pay_invoice'}, _budget({})).budget, isNull);
  });
}
