import 'package:flutter/material.dart';

import '../../core/services/app_lock_service.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  final AppLockService _appLockService = AppLockService.instance;

  bool _isLoading = true;
  bool _isLockEnabled = false;
  bool _isBiometricAvailable = false;
  bool _isBiometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final lockEnabled = await _appLockService.isLockEnabled();
    final biometricAvailable = await _appLockService.isBiometricAvailable();
    final biometricEnabled = await _appLockService.isBiometricEnabled();

    if (!mounted) {
      return;
    }

    setState(() {
      _isLockEnabled = lockEnabled;
      _isBiometricAvailable = biometricAvailable;
      _isBiometricEnabled =
          lockEnabled && biometricAvailable && biometricEnabled;
      _isLoading = false;
    });
  }

  Future<void> _createOrChangePin() async {
    final wasAlreadyEnabled = _isLockEnabled;

    if (wasAlreadyEnabled) {
      final currentPin = await _showPinDialog(
        title: 'تأیید رمز فعلی',
        description: 'برای تغییر رمز، ابتدا رمز فعلی را وارد کنید.',
        confirmText: 'تأیید',
      );

      if (currentPin == null) {
        return;
      }

      final isCurrentPinValid = await _appLockService.verifyPin(currentPin);

      if (!mounted) {
        return;
      }

      if (!isCurrentPinValid) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('رمز فعلی صحیح نیست.')));
        return;
      }
    }

    final firstPin = await _showPinDialog(
      title: wasAlreadyEnabled ? 'رمز جدید' : 'فعال‌سازی قفل برنامه',
      description: 'یک رمز ۴ تا ۶ رقمی وارد کنید.',
      confirmText: 'ادامه',
    );

    if (firstPin == null) {
      return;
    }

    final secondPin = await _showPinDialog(
      title: 'تکرار رمز',
      description: 'رمز را دوباره وارد کنید.',
      confirmText: 'ذخیره',
    );

    if (secondPin == null) {
      return;
    }

    if (firstPin != secondPin) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('دو رمز واردشده یکسان نیستند.')),
      );
      return;
    }

    try {
      await _appLockService.setPin(firstPin);

      if (!mounted) {
        return;
      }

      setState(() {
        _isLockEnabled = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            wasAlreadyEnabled
                ? 'رمز قفل برنامه تغییر کرد.'
                : 'قفل برنامه فعال شد.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ذخیره رمز با خطا روبه‌رو شد.')),
      );
    }
  }

  Future<void> _removeLock() async {
    final currentPin = await _showPinDialog(
      title: 'تأیید رمز',
      description: 'برای غیرفعال کردن قفل، رمز فعلی را وارد کنید.',
      confirmText: 'ادامه',
    );

    if (currentPin == null) {
      return;
    }

    final isValid = await _appLockService.verifyPin(currentPin);

    if (!mounted) {
      return;
    }

    if (!isValid) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('رمز واردشده صحیح نیست.')));
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('غیرفعال کردن قفل'),
          content: const Text(
            'با غیرفعال کردن قفل، رمز و تنظیمات بیومتریک حذف می‌شوند.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('انصراف'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('غیرفعال کن'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await _appLockService.removeLock();

      if (!mounted) {
        return;
      }

      setState(() {
        _isLockEnabled = false;
        _isBiometricEnabled = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('قفل برنامه غیرفعال شد.')));
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('غیرفعال کردن قفل با خطا روبه‌رو شد.')),
      );
    }
  }

  Future<void> _changeBiometric(bool value) async {
    if (!_isLockEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ابتدا قفل برنامه را با رمز فعال کنید.')),
      );
      return;
    }

    if (!_isBiometricAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('بیومتریک در این دستگاه در دسترس نیست.')),
      );
      return;
    }

    final success = await _appLockService.setBiometricEnabled(value);

    if (!mounted) {
      return;
    }

    if (!success && value) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فعال‌سازی بیومتریک انجام نشد.')),
      );
      return;
    }

    setState(() {
      _isBiometricEnabled = value;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value
              ? 'باز کردن با بیومتریک فعال شد.'
              : 'باز کردن با بیومتریک غیرفعال شد.',
        ),
      ),
    );
  }

  Future<String?> _showPinDialog({
    required String title,
    required String description,
    required String confirmText,
  }) async {
    final controller = TextEditingController();
    String? errorText;

    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            void submit() {
              final pin = controller.text.trim();

              if (!RegExp(r'^\d{4,6}$').hasMatch(pin)) {
                setDialogState(() {
                  errorText = 'رمز باید بین ۴ تا ۶ رقم باشد.';
                });
                return;
              }

              Navigator.of(dialogContext).pop(pin);
            }

            return AlertDialog(
              title: Text(title),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(description),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      labelText: 'رمز',
                      hintText: '••••',
                      errorText: errorText,
                      counterText: '',
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                    ),
                    onChanged: (_) {
                      if (errorText != null) {
                        setDialogState(() {
                          errorText = null;
                        });
                      }
                    },
                    onSubmitted: (_) => submit(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('انصراف'),
                ),
                FilledButton(onPressed: submit, child: Text(confirmText)),
              ],
            );
          },
        );
      },
    );

    controller.dispose();

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('امنیت')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            _isLockEnabled
                                ? Icons.lock_rounded
                                : Icons.lock_open_rounded,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isLockEnabled
                                    ? 'قفل برنامه فعال است'
                                    : 'قفل برنامه غیرفعال است',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _isLockEnabled
                                    ? 'برای ورود به روزینو باید رمز یا بیومتریک تأیید شود.'
                                    : 'برای محافظت از کارهای شخصی خود می‌توانید قفل برنامه را فعال کنید.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'رمز قفل',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          _isLockEnabled
                              ? Icons.password_rounded
                              : Icons.add_moderator_outlined,
                        ),
                        title: Text(
                          _isLockEnabled ? 'تغییر رمز' : 'فعال‌سازی با رمز',
                        ),
                        subtitle: Text(
                          _isLockEnabled
                              ? 'برای تغییر رمز، ابتدا رمز فعلی تأیید می‌شود.'
                              : 'یک رمز ۴ تا ۶ رقمی برای روزینو بسازید.',
                        ),
                        trailing: const Icon(Icons.chevron_left_rounded),
                        onTap: _createOrChangePin,
                      ),
                      if (_isLockEnabled) ...[
                        Divider(height: 1, color: colorScheme.outlineVariant),
                        ListTile(
                          leading: Icon(
                            Icons.lock_open_rounded,
                            color: colorScheme.error,
                          ),
                          title: Text(
                            'غیرفعال کردن قفل',
                            style: TextStyle(color: colorScheme.error),
                          ),
                          subtitle: const Text(
                            'برای حذف قفل، رمز فعلی لازم است.',
                          ),
                          onTap: _removeLock,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'بیومتریک',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  child: SwitchListTile(
                    secondary: const Icon(Icons.fingerprint_rounded),
                    title: const Text('باز کردن با اثرانگشت یا چهره'),
                    subtitle: Text(
                      !_isBiometricAvailable
                          ? 'بیومتریک در این دستگاه در دسترس نیست.'
                          : !_isLockEnabled
                          ? 'ابتدا قفل برنامه را با رمز فعال کنید.'
                          : 'در صورت ناموفق بودن، همیشه می‌توانید از رمز استفاده کنید.',
                    ),
                    value: _isBiometricEnabled,
                    onChanged: _isBiometricAvailable && _isLockEnabled
                        ? _changeBiometric
                        : null,
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.shield_outlined, color: colorScheme.primary),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'رمز به‌صورت متن ساده ذخیره نمی‌شود. تغییر یا حذف رمز نیز فقط پس از تأیید رمز فعلی انجام می‌شود.',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
