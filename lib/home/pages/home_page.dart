import 'package:ds_supabase_auth/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerWidget {
  static Route route(BuildContext context) => MaterialPageRoute(
        builder: (context) => const HomePage(),
      );

  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(AuthProvider.provider);

    return Scaffold(
      body: authState.maybeWhen(
        authenticated: (user) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                user.email ?? 'No email found',
                style: Theme.of(context).textTheme.headline6,
              ),
              Text(
                user.id,
                style: Theme.of(context).textTheme.bodyText1,
              ),
            ],
          ),
        ),
        orElse: () => const SizedBox.shrink(),
      ),
    );
  }
}
