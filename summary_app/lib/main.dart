import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Summary App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false;
  String? _lastSuccessfulText;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = _textController.text.trim();
    final canSubmit = !_isLoading && text.isNotEmpty && text != _lastSuccessfulText;
    return Scaffold(
      appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.inversePrimary, title: Text(widget.title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 200, maxHeight: 400),
                child: TextField(
                  controller: _textController,
                  decoration: InputDecoration(border: OutlineInputBorder(), labelText: 'Enter text'),
                  maxLines: null,
                  minLines: 10,
                  enabled: !_isLoading,
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: canSubmit ? () => requestSummary(_textController.text.trim()) : null,
                style: ElevatedButton.styleFrom(backgroundColor: canSubmit ? Colors.blue : Colors.grey, foregroundColor: Colors.white),
                child: const Text('Summary'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> requestSummary(String text) async {
    if (_isLoading || text.isEmpty || text == _lastSuccessfulText) {
      return;
    }

    setState(() => _isLoading = true);
    final dio = Dio();
    try {
      final response = await dio.post('http://127.0.0.1:8000/summaries', data: {'text': text});

      if (!mounted) return;
      setState(() {
        _lastSuccessfulText = text;
      });

      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Summary'),
            content: Text(response.data['summary']),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } on DioException catch (e) {
      if (!context.mounted) return;

      final data = e.response?.data;
      final detail = data is Map ? data['detail'] : null;
      final message = detail is String ? detail : '요청 처리 중 오류가 발생했습니다.';

      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } finally {
      // mounted 확인 후 로딩 해제
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
