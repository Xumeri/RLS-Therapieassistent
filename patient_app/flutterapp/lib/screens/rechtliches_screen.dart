import 'package:flutter/material.dart';



class LegalTextScreen extends StatefulWidget {
  final String title;
  final String? text;
  final String? assetPath;
  final bool isMandatory;
  final VoidCallback? onAccept;
  final String buttonLabel;


  const LegalTextScreen({
    super.key,
    required this.title,
    this.text,
    this.assetPath,
    required this.isMandatory,
    required this.buttonLabel,
    this.onAccept
  });

  @override
  State<LegalTextScreen> createState() => _LegalTextScreen();
}

class _LegalTextScreen extends State<LegalTextScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme
              .of(context)
              .colorScheme
              .inversePrimary,
          title: Text(widget.title),
        ),
        body: PopScope(
            canPop: (!widget.isMandatory),
            onPopInvokedWithResult: (bool didPop, Object? result) {
              debugPrint('Back navigation invoked: $didPop');
            }, child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: widget.assetPath != null
                    ? FutureBuilder<String>(
                        future: DefaultAssetBundle.of(context).loadString(widget.assetPath!),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          if (snapshot.hasError) {
                            return Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Center(child: Text('Fehler beim Laden: ${snapshot.error}')),
                            );
                          }
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              snapshot.data ?? '',
                              style: const TextStyle(fontSize: 16),
                            ),
                          );
                        },
                      )
                    : Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          widget.text ?? '',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
              ),
            ),
            if (widget.isMandatory)
              ElevatedButton.icon(
                icon: Icon(Icons.done_all_sharp),
                onPressed: widget.onAccept, label: Text(widget.buttonLabel),
              )
          ],
        )
        )
    );
  }
}