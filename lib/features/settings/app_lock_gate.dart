import 'package:flutter/material.dart';

import '../../core/services/app_lock_service.dart';

class AppLockGate extends StatefulWidget {
  final Widget child;

  const AppLockGate({super.key, required this.child});

  @override
  State<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends State<AppLockGate> with WidgetsBindingObserver {
  final AppLockService _appLockService = AppLockService.instance;
  final TextEditingController _pinController = TextEditingController();

  bool _isLoading = true;
  bool _isLocked = false;
  bool _isBiometricEnabled = false;
  bool _isAuthenticating = false;
  bool _obscurePin = true;
  bool _wasBackgrounded = false;

  String? _errorText;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _initialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pinController.dispose();

    super.dispose();
  }

  Future<void> _initialize() async {
    final lockEnabled = await _appLockService.isLockEnabled();

    if (!lockEnabled) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _isLocked = false;
      });

      return;
    }

    final biometricEnabled = await _appLockService.isBiometricEnabled();

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
      _isLocked = true;
      _isBiometricEnabled = biometricEnabled;
    });

    if (biometricEnabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _authenticateWithBiometrics();
        }
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _wasBackgrounded = true;
      return;
    }

    if (state == AppLifecycleState.resumed &&
        _wasBackgrounded &&
        !_isAuthenticating) {
      _wasBackgrounded = false;
      _lockAfterResume();
    }
  }

  Future<void> _lockAfterResume() async {
    final lockEnabled = await _appLockService.isLockEnabled();

    if (!mounted || !lockEnabled) {
      return;
    }

    final biometricEnabled = await _appLockService.isBiometricEnabled();

    if (!mounted) {
      return;
    }

    setState(() {
      _isLocked = true;
      _isBiometricEnabled = biometricEnabled;
      _pinController.clear();
      _errorText = null;
    });

    if (biometricEnabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _authenticateWithBiometrics();
        }
      });
    }
  }

  Future<void> _verifyPin() async {
    final pin = _pinController.text.trim();

    if (!RegExp(r'^\d{4,6}$').hasMatch(pin)) {
      setState(() {
        _errorText = 'رمز باید بین ۴ تا ۶ رقم باشد.';
      });

      return;
    }

    FocusScope.of(context).unfocus();

    final isValid = await _appLockService.verifyPin(pin);

    if (!mounted) {
      return;
    }

    if (!isValid) {
      setState(() {
        _errorText = 'رمز واردشده صحیح نیست.';
        _pinController.clear();
      });

      return;
    }

    _unlock();
  }

  Future<void> _authenticateWithBiometrics() async {
    if (_isAuthenticating || !_isLocked) {
      return;
    }

    setState(() {
      _isAuthenticating = true;
      _errorText = null;
    });

    final authenticated = await _appLockService.authenticateWithBiometrics();

    if (!mounted) {
      return;
    }

    setState(() {
      _isAuthenticating = false;
    });

    if (authenticated) {
      _unlock();
    }
  }

  void _unlock() {
    if (!mounted) {
      return;
    }

    setState(() {
      _isLocked = false;
      _pinController.clear();
      _errorText = null;
    });
  }

  Widget _buildLoadingScreen() {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }

  Widget _buildLockScreen(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Icon(
                      Icons.lock_rounded,
                      size: 42,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'روزینو قفل است',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'برای ادامه، رمز برنامه را وارد کنید.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 28),
                  TextField(
                    controller: _pinController,
                    autofocus: !_isBiometricEnabled,
                    obscureText: _obscurePin,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      letterSpacing: 8,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      labelText: 'رمز',
                      hintText: '••••',
                      counterText: '',
                      errorText: _errorText,
                      prefixIcon: const Icon(Icons.password_rounded),
                      suffixIcon: IconButton(
                        tooltip: _obscurePin ? 'نمایش رمز' : 'مخفی کردن رمز',
                        onPressed: () {
                          setState(() {
                            _obscurePin = !_obscurePin;
                          });
                        },
                        icon: Icon(
                          _obscurePin
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                    onChanged: (_) {
                      if (_errorText != null) {
                        setState(() {
                          _errorText = null;
                        });
                      }
                    },
                    onSubmitted: (_) => _verifyPin(),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _verifyPin,
                      icon: const Icon(Icons.lock_open_rounded),
                      label: const Text('باز کردن روزینو'),
                    ),
                  ),
                  if (_isBiometricEnabled) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _isAuthenticating
                            ? null
                            : _authenticateWithBiometrics,
                        icon: _isAuthenticating
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.fingerprint_rounded),
                        label: Text(
                          _isAuthenticating
                              ? 'در حال بررسی...'
                              : 'باز کردن با بیومتریک',
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        size: 18,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'اطلاعات روزینو تا زمان باز شدن قفل نمایش داده نمی‌شوند.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingScreen();
    }

    if (_isLocked) {
      return _buildLockScreen(context);
    }

    return widget.child;
  }
}
