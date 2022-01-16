import 'package:ds_supabase_auth/auth/pages/sign_in_page.dart';
import 'package:ds_supabase_auth/auth/providers/auth_provider.dart';
import 'package:ds_supabase_auth/home/pages/home_page.dart';
import 'package:ds_supabase_auth/main.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthListener<T extends StatefulWidget> extends SupabaseAuthState<T> {
  @override
  void onUnauthenticated() {
    if (mounted) {
      providerContainer.read(AuthProvider.provider.notifier).setInitial();
      Navigator.of(context).pushReplacement(SignInPage.route(context));
    }
  }

  @override
  void onAuthenticated(Session session) {
    if (mounted) {
      providerContainer.read(AuthProvider.provider.notifier).setAuthenticated(session.user!);
      Navigator.of(context).pushReplacement(HomePage.route(context));
    }
  }

  @override
  void onErrorAuthenticating(String message) {
    if (mounted) {
      providerContainer.read(AuthProvider.provider.notifier).setError(message);
    }
  }

  @override
  void onPasswordRecovery(Session session) {
    throw UnimplementedError();
  }
}
