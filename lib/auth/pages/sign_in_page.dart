import 'package:ds_supabase_auth/auth/providers/auth_provider.dart';
import 'package:ds_supabase_auth/auth/widgets/auth_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:open_mail_app/open_mail_app.dart';

class SignInPage extends StatefulWidget {
  static Route route(BuildContext context) => MaterialPageRoute(
        builder: (context) => const SignInPage(),
      );

  const SignInPage({Key? key}) : super(key: key);

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends AuthListener<SignInPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: SignInForm(),
        ),
      ),
    );
  }
}

class SignInForm extends HookConsumerWidget {
  const SignInForm({
    Key? key,
  }) : super(key: key);

  Future<void> _sendMagicLink(
    BuildContext context,
    WidgetRef ref,
    String email,
    ValueNotifier<bool> magicLinkSent,
  ) async {
    await ref.read(AuthProvider.provider.notifier).sendMagicLink(email);
    magicLinkSent.value = true;

    await _openInMailApp(context);
  }

  Future<void> _openInMailApp(BuildContext context) async {
    final result = await OpenMailApp.openMailApp();

    if (!result.didOpen && !result.canOpen) {
      return await showDialog(
        context: context,
        builder: (_) => const NoMailAppsFound(),
      );
    }

    await showDialog(
      context: context,
      builder: (_) => MailAppPickerDialog(
        mailApps: result.options,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final magicLinkSent = useState(false);
    final emailController = useTextEditingController();

    return AnimatedCrossFade(
      sizeCurve: Curves.easeOut,
      duration: const Duration(milliseconds: 300),
      crossFadeState: magicLinkSent.value ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      firstChild: EmailInput(
        emailController: emailController,
        onSendMagicLink: () => _sendMagicLink(context, ref, emailController.text, magicLinkSent),
      ),
      secondChild: EmailSent(
        onRestart: () => magicLinkSent.value = false,
      ),
    );
  }
}

class EmailInput extends StatelessWidget {
  final TextEditingController emailController;
  final VoidCallback onSendMagicLink;

  const EmailInput({
    Key? key,
    required this.emailController,
    required this.onSendMagicLink,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: emailController,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (value) {
            if ((value ?? '').isEmpty) {
              return 'Please enter an email';
            }
            return null;
          },
          decoration: const InputDecoration(
            labelText: 'Email',
          ),
        ),
        const SizedBox(
          height: 16,
        ),
        ElevatedButton(
          onPressed: onSendMagicLink,
          child: const Text('Sign in'),
        ),
        const SizedBox(
          height: 16,
        ),
      ],
    );
  }
}

class EmailSent extends StatelessWidget {
  final VoidCallback onRestart;
  const EmailSent({Key? key, required this.onRestart}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.mail,
          size: 72,
        ),
        Text(
          "You've got mail",
          style: Theme.of(context).textTheme.headline6,
        ),
        const SizedBox(
          height: 8,
        ),
        const Text(
          "Check your email for a magic link.",
          style: TextStyle(fontSize: 18),
        ),
        TextButton(
          onPressed: onRestart,
          child: const Text('Restart'),
        ),
      ],
    );
  }
}

class NoMailAppsFound extends StatelessWidget {
  const NoMailAppsFound({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Email"),
      content: const Text("You don't have any supported email apps installed."),
      actions: <Widget>[
        TextButton(
          child: const Text("OK"),
          onPressed: () {
            Navigator.pop(context);
          },
        )
      ],
    );
  }
}
