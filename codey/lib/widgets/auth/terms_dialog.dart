import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

Future<String>? _termsTextFuture;

Future<String> _loadTermsText() {
  return _termsTextFuture ??= rootBundle.loadString('assets/terms.txt');
}

Future<void> showTermsDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Uvjeti korištenja'),
        content: SizedBox(
          width: 600,
          child: FutureBuilder<String>(
            future: _loadTermsText(),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const SizedBox(
                  height: 120,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return Text(
                  'Greška pri učitavanju uvjeta korištenja.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                );
              }
              return SingleChildScrollView(
                child: SelectableText(snapshot.data ?? ''),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Zatvori'),
          ),
        ],
      );
    },
  );
}
