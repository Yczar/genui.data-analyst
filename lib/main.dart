import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:genui_firebase_ai/genui_firebase_ai.dart';
import 'package:genui_google_generative_ai/genui_google_generative_ai.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logging/logging.dart';

import 'catalog.dart';
import 'firebase_options_stub.dart';
// Conditionally import non-web version so we can read from shell env vars in
import 'io_get_api_key.dart' if (dart.library.html) 'web_get_api_key.dart';
import 'message.dart';

/// Enum for selecting which AI backend to use.
enum AiBackend {
  /// Use Firebase AI
  firebase,

  /// Use Google Generative AI
  googleGenerativeAi,
}

/// Configuration for which AI backend to use.
/// Change this value to switch between backends.
const AiBackend aiBackend = AiBackend.googleGenerativeAi;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Only initialize Firebase if using firebase backend
  if (aiBackend == AiBackend.firebase) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  configureGenUiLogging(level: Level.ALL);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Data Analyst',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF6C63FF),
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6C63FF),
          secondary: Color(0xFF03DAC6),
          surface: Color(0xFF1E1E1E),
          background: Color(0xFF121212),
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.nunitoTextTheme(ThemeData.dark().textTheme),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF2C2C2C),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
        ),
      ),
      home: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<MessageController> _messages = [];
  late final GenUiConversation _genUiConversation;
  late final GenUiManager _genUiManager;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final Catalog catalog = DataAnalystCatalog.catalog;
    _genUiManager = GenUiManager(catalog: catalog);

    final systemInstruction = '''You are a Data Analyst assistant.
Your goal is to help the user visualize data.
When the user provides data or asks for a visualization, use the appropriate
widget from the catalog (`line_chart`, `pie_chart`, `data_table`).

If the user provides raw data (CSV or text), parse it and show it in a table AND a chart if possible.
Always acknowledge the user's request.

IMPORTANT: When you generate UI in a response, you MUST always create
a new surface with a unique `surfaceId`. Do NOT reuse or update
existing `surfaceId`s. Each UI response must be in its own new surface.

${GenUiPromptFragments.basicChat}''';

    // Create the appropriate content generator based on configuration
    final ContentGenerator contentGenerator = switch (aiBackend) {
      AiBackend.googleGenerativeAi => () {
        return GoogleGenerativeAiContentGenerator(
          catalog: catalog,
          systemInstruction: systemInstruction,
          apiKey: getApiKey(),
        );
      }(),
      AiBackend.firebase => FirebaseAiContentGenerator(
        catalog: catalog,
        systemInstruction: systemInstruction,
      ),
    };

    _genUiConversation = GenUiConversation(
      genUiManager: _genUiManager,
      contentGenerator: contentGenerator,
      onSurfaceAdded: _handleSurfaceAdded,
      onTextResponse: _onTextResponse,
      onError: (error) {
        genUiLogger.severe(
          'Error from content generator',
          error.error,
          error.stackTrace,
        );
      },
    );
  }

  void _handleSurfaceAdded(SurfaceAdded surface) {
    if (!mounted) return;
    setState(() {
      _messages.add(
        MessageController(surfaceId: surface.surfaceId, isUser: false),
      );
    });
    _scrollToBottom();
  }

  void _onTextResponse(String text) {
    if (!mounted) return;
    setState(() {
      _messages.add(MessageController(text: text, isUser: false));
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.analytics_rounded,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Data Analyst',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      setState(() {
                        _messages.clear();
                      });
                    },
                  ),
                ],
              ),
            ),

            // Chat Area
            Expanded(
              child: _messages.isEmpty
                  ? _buildWelcomeView()
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final MessageController message = _messages[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: MessageView(message, _genUiConversation.host),
                        );
                      },
                    ),
            ),

            // Loading Indicator
            ValueListenableBuilder(
              valueListenable: _genUiConversation.isProcessing,
              builder: (_, isProcessing, _) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: isProcessing ? 40 : 0,
                  child: isProcessing
                      ? Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Analyzing...',
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.color,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                );
              },
            ),

            // Input Area
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _textController,
                        decoration: const InputDecoration(
                          hintText: 'Ask a question or paste data...',
                          prefixIcon: Icon(Icons.auto_awesome_outlined),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                        minLines: 1,
                        maxLines: 5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FloatingActionButton(
                    onPressed: _sendMessage,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: const Icon(
                      Icons.arrow_upward_rounded,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.insights,
            size: 64,
            color: Theme.of(context).primaryColor.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'Ready to visualize your data?',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Paste a CSV or ask me to generate a chart.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildSuggestionChip('Show me a pie chart of expenses'),
              _buildSuggestionChip('Plot sales growth for 2024'),
              _buildSuggestionChip('Create a table from this data...'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String label) {
    return ActionChip(
      label: Text(label),
      onPressed: () {
        _textController.text = label;
      },
      backgroundColor: Theme.of(context).cardColor,
      elevation: 2,
    );
  }

  void _sendMessage() {
    final String text = _textController.text;
    if (text.isEmpty) {
      return;
    }
    _textController.clear();

    setState(() {
      _messages.add(MessageController(text: text, isUser: true));
    });

    _scrollToBottom();

    unawaited(_genUiConversation.sendRequest(UserMessage([TextPart(text)])));
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _genUiConversation.dispose();
    super.dispose();
  }
}
