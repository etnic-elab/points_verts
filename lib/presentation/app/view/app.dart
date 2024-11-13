import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({
    required this.tileRepository,
    required this.chatbotRepository,
    super.key,
  });

  final TileRepository tileRepository;
  final ChatbotRepository chatbotRepository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<TileRepository>(
          create: (context) => tileRepository,
        ),
        RepositoryProvider<ChatbotRepository>(
          create: (context) => chatbotRepository,
        ),
      ],
      child: const AppView(),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return MaterialApp(
          theme: EvaChatbotTheme.light(lightDynamic),
          darkTheme: EvaChatbotTheme.dark(darkDynamic),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          debugShowCheckedModeBanner: false,
          home: const ChatbotPage(),
        );
      },
    );
  }
}
