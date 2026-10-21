import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app_providers.dart';
import '../../../core/sources/source_dto.dart';
import '../../../l10n/app_localizations.dart';
import '../../../sources/yandex/yandex_auth.dart';

/// Вход по OAuth device flow: показываем код, пользователь подтверждает его на
/// странице Яндекса, приложение только опрашивает выдачу токена.
Future<void> showYandexLogin(BuildContext context, WidgetRef ref) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _YandexLoginSheet(),
    );

class _YandexLoginSheet extends ConsumerStatefulWidget {
  const _YandexLoginSheet();

  @override
  ConsumerState<_YandexLoginSheet> createState() => _YandexLoginSheetState();
}

class _YandexLoginSheetState extends ConsumerState<_YandexLoginSheet> {
  DeviceLogin? _login;
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    final source = ref.read(yandexSourceProvider);
    if (source == null) {
      setState(() => _error = AppLocalizations.of(context).authNotBuilt);
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
      _login = null;
    });
    try {
      final login = await source.requestDeviceLogin();
      if (!mounted) return;
      setState(() {
        _login = login;
        _busy = false;
      });

      final ok = await source.completeDeviceLogin(login);
      if (!mounted) return;
      if (ok) {
        Navigator.of(context).pop();
      } else {
        setState(() => _error = AppLocalizations.of(context).authNotConfirmed);
      }
    } on YandexAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = e.message;
      });
    } on Object {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = AppLocalizations.of(context).issueUnknown;
      });
    }
  }

  Future<void> _copyCode(String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).authCodeCopied(code)),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _openVerification(DeviceLogin login) async {
    final opened = await launchUrl(
      login.verificationUri,
      mode: LaunchMode.externalApplication,
    );
    if (!opened && mounted) {
      setState(() => _error = AppLocalizations.of(context).authBrowserFailed('${login.verificationUri}'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(yandexAuthStateProvider).value ?? const AuthUnknown();
    final l = AppLocalizations.of(context);
    final login = _login;
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.authTitle, style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            if (auth is AuthReady)
              Text(l.authDone(auth.login))
            else if (_busy && login == null)
              Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Text(l.authRequestingCode),
                ],
              )
            else if (login != null) ...[
              Text(l.authCodeIntro, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 12),
              _CodeTile(
                code: login.userCode,
                onCopy: () => _copyCode(login.userCode),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _openVerification(login),
                  icon: const Icon(Icons.open_in_new),
                  label: Text(l.authOpenPage),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                login.verificationUri.toString(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(l.authWaitingCode),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                FilledButton.tonal(
                  onPressed: _busy ? null : _start,
                  child: Text(l.authRetry),
                ),
                const Spacer(),
                if (auth is AuthReady)
                  TextButton(
                    onPressed: () async {
                      await ref.read(yandexSourceProvider)?.signOut();
                      if (context.mounted) Navigator.of(context).pop();
                    },
                    child: Text(l.authSignOut),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Код крупно и по тапу копируется — с телефона его иначе не перенести.
class _CodeTile extends StatelessWidget {
  const _CodeTile({required this.code, required this.onCopy});

  final String code;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.secondaryContainer,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onCopy,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  code,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    letterSpacing: 6,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSecondaryContainer,
                  ),
                ),
              ),
              Icon(Icons.copy_rounded, color: scheme.onSecondaryContainer),
            ],
          ),
        ),
      ),
    );
  }
}
