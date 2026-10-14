import 'package:lumen_wallets/lumen_wallets.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/generated/app_localizations.dart';
import '../theme/lumen_colors.dart';
import 'amount.dart';

/// What a connection string allows, read from its wallet before it is saved.
/// Without [grant] and not [checking], the wallet could not be reached.
class NwcGrantCard extends StatelessWidget {
  const NwcGrantCard({super.key, required this.checking, this.grant});

  final bool checking;
  final NwcGrant? grant;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = LumenColors.of(context);
    final grant = this.grant;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.surface2,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: switch ((checking, grant)) {
          (true, _) => _Note(
            icon: const SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            text: l.grantChecking,
          ),
          (false, null) => _Note(
            icon: Icon(Icons.info_outline, size: 18, color: c.text2),
            text: l.grantUnreachable,
          ),
          (false, final NwcGrant grant) => _Abilities(grant),
        },
      ),
    );
  }
}

class _Abilities extends StatelessWidget {
  const _Abilities(this.grant);

  final NwcGrant grant;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = LumenColors.of(context);
    final budget = grant.budget;
    final allowed = NwcAbility.values.where(grant.abilities.contains);
    final denied = NwcAbility.values.where((a) => !grant.abilities.contains(a));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 4,
          children: [
            _Heading(allowed.isEmpty ? l.grantCannot : l.grantCan),
            if (budget != null && grant.abilities.contains(NwcAbility.pay))
              Text(
                _budgetText(l, formatSats(context, budget.sats), budget.period),
                style: TextStyle(fontSize: 14, color: c.text2),
              ),
          ],
        ),
        for (final ability in allowed)
          _AbilityRow(ability: ability, allowed: true),
        if (allowed.isNotEmpty && denied.isNotEmpty) ...[
          const SizedBox(height: 14),
          _Heading(l.grantCannot),
        ],
        for (final ability in denied)
          _AbilityRow(ability: ability, allowed: false),
      ],
    );
  }
}

String _budgetText(AppLocalizations l, String sats, BudgetPeriod period) =>
    switch (period) {
      BudgetPeriod.day => l.budgetPerDay(sats),
      BudgetPeriod.week => l.budgetPerWeek(sats),
      BudgetPeriod.month => l.budgetPerMonth(sats),
      BudgetPeriod.year => l.budgetPerYear(sats),
      BudgetPeriod.total => l.budgetTotal(sats),
    };

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(text, style: Theme.of(context).textTheme.titleSmall),
    );
  }
}

class _AbilityRow extends StatelessWidget {
  const _AbilityRow({required this.ability, required this.allowed});

  final NwcAbility ability;
  final bool allowed;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = LumenColors.of(context);
    return MergeSemantics(
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Icon(
                allowed ? Icons.check : Icons.block,
                size: 18,
                color: allowed ? c.positive : c.text2,
                semanticLabel: allowed ? l.grantAllowed : l.grantDenied,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(switch (ability) {
                NwcAbility.readBalance => l.abilityReadBalance,
                NwcAbility.receive => l.abilityReceive,
                NwcAbility.pay => l.abilityPay,
                NwcAbility.listTransactions => l.abilityListTransactions,
              }, style: TextStyle(fontSize: 15, height: 1.3, color: c.text)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note({required this.icon, required this.text});

  final Widget icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = LumenColors.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: ExcludeSemantics(child: icon),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 15, height: 1.4, color: c.text2),
          ),
        ),
      ],
    );
  }
}
