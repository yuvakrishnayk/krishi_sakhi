import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

// ─────────────────────────────────────────
//  GROQ CONFIG
// ─────────────────────────────────────────
const _kGroqApiKey = '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';
const _kGroqModel = 'openai/gpt-oss-120b'; // or 'llama3-70b-8192'
const _kGroqUrl = 'https://api.groq.com/openai/v1/chat/completions';

// ─────────────────────────────────────────
//  LANGUAGE CONFIG
// ─────────────────────────────────────────
class _Lang {
  final String code;
  final String name;
  final String flag;
  final String ttsLocale;
  final String sttLocale;
  final String systemPromptHint;

  const _Lang({
    required this.code,
    required this.name,
    required this.flag,
    required this.ttsLocale,
    required this.sttLocale,
    required this.systemPromptHint,
  });
}

const _languages = <_Lang>[
  _Lang(
    code: 'en',
    name: 'English',
    flag: '🇬🇧',
    ttsLocale: 'en-IN',
    sttLocale: 'en_IN',
    systemPromptHint: 'Respond in English.',
  ),
  _Lang(
    code: 'ta',
    name: 'தமிழ்',
    flag: '🇮🇳',
    ttsLocale: 'ta-IN',
    sttLocale: 'ta_IN',
    systemPromptHint:
        'Respond only in Tamil (தமிழ்). Use simple vocabulary a rural farmer can understand.',
  ),
  _Lang(
    code: 'hi',
    name: 'हिन्दी',
    flag: '🇮🇳',
    ttsLocale: 'hi-IN',
    sttLocale: 'hi_IN',
    systemPromptHint:
        'Respond only in Hindi (हिंदी). Use simple words a farmer can understand.',
  ),
  _Lang(
    code: 'te',
    name: 'తెలుగు',
    flag: '🇮🇳',
    ttsLocale: 'te-IN',
    sttLocale: 'te_IN',
    systemPromptHint:
        'Respond only in Telugu (తెలుగు). Keep language simple for farmers.',
  ),
  _Lang(
    code: 'kn',
    name: 'ಕನ್ನಡ',
    flag: '🇮🇳',
    ttsLocale: 'kn-IN',
    sttLocale: 'kn_IN',
    systemPromptHint:
        'Respond only in Kannada (ಕನ್ನಡ). Use simple, rural-friendly language.',
  ),
  _Lang(
    code: 'ml',
    name: 'മലയാളം',
    flag: '🇮🇳',
    ttsLocale: 'ml-IN',
    sttLocale: 'ml_IN',
    systemPromptHint:
        'Respond only in Malayalam (മലയാളം). Use simple, rural-friendly language.',
  ),
  _Lang(
    code: 'mr',
    name: 'मराठी',
    flag: '🇮🇳',
    ttsLocale: 'mr-IN',
    sttLocale: 'mr_IN',
    systemPromptHint:
        'Respond only in Marathi (मराठी). Use simple, rural-friendly language.',
  ),
  _Lang(
    code: 'gu',
    name: 'ગુજરાતી',
    flag: '🇮🇳',
    ttsLocale: 'gu-IN',
    sttLocale: 'gu_IN',
    systemPromptHint:
        'Respond only in Gujarati (ગુજરાતી). Use simple, rural-friendly language.',
  ),
  _Lang(
    code: 'bn',
    name: 'বাংলা',
    flag: '🇮🇳',
    ttsLocale: 'bn-IN',
    sttLocale: 'bn_IN',
    systemPromptHint:
        'Respond only in Bengali (বাংলা). Use simple, rural-friendly language.',
  ),
  _Lang(
    code: 'pa',
    name: 'ਪੰਜਾਬੀ',
    flag: '🇮🇳',
    ttsLocale: 'pa-IN',
    sttLocale: 'pa_IN',
    systemPromptHint:
        'Respond only in Punjabi (ਪੰਜਾਬੀ). Use simple, rural-friendly language.',
  ),
];

// ─────────────────────────────────────────
//  SYSTEM PROMPT BUILDER
// ─────────────────────────────────────────
String _buildSystemPrompt(_Lang lang) => '''
You are KrishiSakhi, an expert AI assistant dedicated to helping Indian farmers.
Your role:
- Guide farmers on crop diseases, pest management, fertilizer schedules, irrigation, and weather.
- Advise on government schemes (PM-KISAN, Fasal Bima, etc.) and MSP.
- Suggest crop selection based on season, soil, and region.
- Provide market price trends and where to sell produce.
- Use simple, practical language without jargon.
- If you don't know something, honestly say so and suggest consulting a local Krishi Sevak.
- Always be warm, empathetic, and encouraging to the farmer.
- Keep answers concise (3–5 sentences) unless a detailed explanation is needed.
- Always reply in the selected language for this chat.
- Never mix in another language unless the user explicitly asks for translation.
${lang.systemPromptHint}
''';

String _localizedGreeting(_Lang lang) {
  switch (lang.code) {
    case 'ta':
      return '🌱 வணக்கம்! நான் KrishiSakhi, உங்கள் தனிப்பட்ட விவசாய உதவியாளர்.\n\nஇதுபற்றி என்னிடம் கேளுங்கள்:\n• பயிர்கள் & பூச்சிகள்\n• வானிலை & பாசனம்\n• சந்தை விலை\n• அரசு திட்டங்கள்\n\nநீங்கள் உங்கள் மொழியிலேயே பேசலாம்! 🎤';
    case 'ml':
      return '🌱 നമസ്കാരം! ഞാൻ KrishiSakhi, നിങ്ങളുടെ വ്യക്തിഗത കൃഷി സഹായിയാണ്.\n\nഎന്നോട് ഇതെക്കുറിച്ച് ചോദിക്കാം:\n• വിളകൾ & കീടങ്ങൾ\n• കാലാവസ്ഥ & ജലസേചനം\n• വിപണി വിലകൾ\n• സർക്കാർ പദ്ധതികൾ\n\nനിങ്ങൾക്ക് നിങ്ങളുടെ ഭാഷയിൽ തന്നെ സംസാരിക്കാം! 🎤';
    default:
      return '🌱 Vanakkam! I am KrishiSakhi, your personal farming assistant.\n\nAsk me anything about:\n• Crops & pests\n• Weather & irrigation\n• Market prices\n• Government schemes\n\nYou can also speak in your language! 🎤';
  }
}

String _localizedAppBarSubtitle(_Lang lang) {
  switch (lang.code) {
    case 'ta':
      return 'விவசாயிகளுக்கான ஸ்மார்ட் உதவியாளர் • ${lang.flag} ${lang.name}';
    case 'ml':
      return 'കർഷകർക്കുള്ള സ്മാർട്ട് സഹായകൻ • ${lang.flag} ${lang.name}';
    default:
      return 'Farmer\'s Smart Assistant • ${lang.flag} ${lang.name}';
  }
}

String _localizedInputHint(_Lang lang) {
  switch (lang.code) {
    case 'ta':
      return 'பயிர்கள், பூச்சிகள், சந்தை பற்றி கேளுங்கள்...';
    case 'ml':
      return 'വിളകൾ, കീടങ്ങൾ, വിപണി എന്നിവയെക്കുറിച്ച് ചോദിക്കൂ...';
    default:
      return 'Ask about crops, pests, market...';
  }
}

String _localizedListeningText(_Lang lang) {
  switch (lang.code) {
    case 'ta':
      return 'கேட்டு கொண்டிருக்கிறது... இப்போது பேசுங்கள்';
    case 'ml':
      return 'കേൾക്കുന്നു... ഇനി സംസാരിക്കൂ';
    default:
      return 'Listening... speak now';
  }
}

String _localizedAttachmentTitle(_Lang lang) {
  switch (lang.code) {
    case 'ta':
      return 'படத்தை இணைக்கவும்';
    case 'ml':
      return 'ചിത്രം ചേർക്കുക';
    default:
      return 'Attach Image';
  }
}

String _localizedAttachmentSubtitle(_Lang lang) {
  switch (lang.code) {
    case 'ta':
      return 'AI பகுப்பாய்வுக்காக உங்கள் பயிர் படத்தை பதிவேற்றுங்கள்';
    case 'ml':
      return 'AI വിശകലനത്തിനായി നിങ്ങളുടെ വിളയുടെ ചിത്രം അപ്‌ലോഡ് ചെയ്യുക';
    default:
      return 'Upload your crop image for AI analysis';
  }
}

String _localizedSelectLanguageTitle(_Lang lang) {
  switch (lang.code) {
    case 'ta':
      return 'மொழியைத் தேர்ந்தெடுக்கவும்';
    case 'ml':
      return 'ഭാഷ തിരഞ്ഞെടുക്കുക';
    default:
      return 'Select Language';
  }
}

String _localizedClearChatTitle(_Lang lang) {
  switch (lang.code) {
    case 'ta':
      return 'அரட்டை அழிக்கவும்';
    case 'ml':
      return 'ചാറ്റ് മായ്ക്കുക';
    default:
      return 'Clear Chat';
  }
}

String _localizedClearChatContent(_Lang lang) {
  switch (lang.code) {
    case 'ta':
      return 'நீங்கள் அனைத்து செய்திகளையும் அழிக்க விரும்புகிறீர்களா?';
    case 'ml':
      return 'എല്ലാ സന്ദേശങ്ങളും മായ്ക്കണമെന്നു നിങ്ങൾക്ക് ഉറപ്പാണോ?';
    default:
      return 'Are you sure you want to clear all messages?';
  }
}

String _localizedCancelLabel(_Lang lang) {
  switch (lang.code) {
    case 'ta':
      return 'ரத்து';
    case 'ml':
      return 'റദ്ദാക്കുക';
    default:
      return 'Cancel';
  }
}

String _localizedClearLabel(_Lang lang) {
  switch (lang.code) {
    case 'ta':
      return 'அழி';
    case 'ml':
      return 'മായ്ക്കുക';
    default:
      return 'Clear';
  }
}

String _localizedImagePrompt(_Lang lang) {
  switch (lang.code) {
    case 'ta':
      return 'இந்த பயிர் படத்தைப் பார்த்து, தெரியும் நோய்கள், பூச்சிகள், அல்லது பிரச்சினைகள் ஏதேனும் உள்ளதா என்பதைச் சொல்லுங்கள்.';
    case 'ml':
      return 'ഈ വിളയുടെ ചിത്രം പരിശോധിച്ച് കാണുന്ന രോഗങ്ങൾ, കീടങ്ങൾ, അല്ലെങ്കിൽ പ്രശ്നങ്ങൾ ഉണ്ടോ എന്ന് പറയുക.';
    default:
      return 'Please analyze this crop image and tell me if there are any diseases, pests, or issues visible.';
  }
}

String _localizedQuickActionLabel(_QuickActionData action, _Lang lang) {
  switch (lang.code) {
    case 'ta':
      switch (action.labelEn) {
        case 'Weather':
          return 'வானிலை';
        case 'Pests':
          return 'பூச்சிகள்';
        case 'Market':
          return 'சந்தை';
        case 'Crops':
          return 'பயிர்கள்';
        case 'Schemes':
          return 'திட்டங்கள்';
        case 'Irrigation':
          return 'பாசனம்';
      }
      break;
    case 'ml':
      switch (action.labelEn) {
        case 'Weather':
          return 'കാലാവസ്ഥ';
        case 'Pests':
          return 'കീടങ്ങൾ';
        case 'Market':
          return 'വിപണി';
        case 'Crops':
          return 'വിളകൾ';
        case 'Schemes':
          return 'പദ്ധതികൾ';
        case 'Irrigation':
          return 'ജലസേചനം';
      }
      break;
  }

  return action.labelEn;
}

String _localizedQuickActionPrompt(_QuickActionData action, _Lang lang) {
  switch (lang.code) {
    case 'ta':
      switch (action.labelEn) {
        case 'Weather':
          return 'இந்தியாவின் வழக்கமான பருவமழை வானிலையை வைத்து இன்று என் வயலில் நான் என்ன செய்ய வேண்டும்?';
        case 'Pests':
          return 'என் பயிர்களில் மஞ்சள் இலைகள் உள்ளன, மேலும் சிறிய பூச்சிகள் தெரிகின்றன. இது எந்த பூச்சியாக இருக்கலாம், அதை எப்படி கட்டுப்படுத்துவது?';
        case 'Market':
          return 'அரிசி மற்றும் கோதுமைக்கான தற்போதைய சந்தை நிலை என்ன? நல்ல விலை பெற என் விளைபொருளை எங்கே விற்க வேண்டும்?';
        case 'Crops':
          return 'இந்த பருவத்தில் தமிழ்நாட்டில் வளர்க்க சிறந்த பயிர்கள் எவை, எந்த உரங்களை பயன்படுத்த வேண்டும்?';
        case 'Schemes':
          return 'இப்போது விவசாயிகளுக்கு என்ன அரசு திட்டங்கள் உள்ளன? PM-KISAN-க்கு எப்படி விண்ணப்பிப்பது?';
        case 'Irrigation':
          return 'என் தக்காளி பயிருக்கு சொட்டு பாசனத்தை எப்படி அமைக்க வேண்டும்? சிறந்த நீர்ப்பாசன அட்டவணை என்ன?';
      }
      break;
    case 'ml':
      switch (action.labelEn) {
        case 'Weather':
          return 'ഇന്ത്യയിലെ സാധാരണ മൺസൂൺ കാലാവസ്ഥയെ അടിസ്ഥാനമാക്കി ഇന്ന് എന്റെ വയലിൽ ഞാൻ എന്ത് ചെയ്യണം?';
        case 'Pests':
          return 'എന്റെ വിളകളിൽ മഞ്ഞ ഇലകൾ കാണുന്നു, ചെറുകീടങ്ങളും കാണുന്നു. ഇത് ഏത് കീടമായിരിക്കാം, എങ്ങനെ നിയന്ത്രിക്കാം?';
        case 'Market':
          return 'അരി, ഗോതമ്പ് എന്നിവയ്ക്കുള്ള നിലവിലെ വിപണി നില എന്താണ്? നല്ല വില ലഭിക്കാൻ എന്റെ ഉൽപ്പന്നങ്ങൾ എവിടെ വിൽക്കണം?';
        case 'Crops':
          return 'ഈ സീസണിൽ തമിഴ്നാട്ടിൽ വളർത്താൻ ഏറ്റവും നല്ല വിളകൾ ഏതാണ്, ഏത് വളങ്ങൾ ഉപയോഗിക്കണം?';
        case 'Schemes':
          return 'ഇപ്പോൾ കർഷകര്ക്ക് ലഭ്യമായ സർക്കാർ പദ്ധതികൾ ഏതൊക്കെ? PM-KISAN-ന് എങ്ങനെ അപേക്ഷിക്കാം?';
        case 'Irrigation':
          return 'എന്റെ തക്കാളി വിളയ്ക്ക് drip irrigation എങ്ങനെ സജ്ജീകരിക്കണം? മികച്ച വെള്ളമൊഴിക്കല്‍ സമയക്രമം എന്താണ്?';
      }
      break;
  }

  return action.promptEn;
}

// ─────────────────────────────────────────
//  QUICK ACTION CONFIG
// ─────────────────────────────────────────
class _QuickActionData {
  final IconData icon;
  final String labelEn;
  final Color color;
  final String promptEn;

  const _QuickActionData({
    required this.icon,
    required this.labelEn,
    required this.color,
    required this.promptEn,
  });
}

const _quickActions = <_QuickActionData>[
  _QuickActionData(
    icon: Icons.cloud_outlined,
    labelEn: 'Weather',
    color: Color(0xFF2196F3),
    promptEn:
        'What should I do in my farm today based on typical monsoon weather in India?',
  ),
  _QuickActionData(
    icon: Icons.bug_report_outlined,
    labelEn: 'Pests',
    color: Color(0xFFE53935),
    promptEn:
        'My crops have yellow leaves and I see small insects on them. What pest could this be and how do I treat it?',
  ),
  _QuickActionData(
    icon: Icons.trending_up_outlined,
    labelEn: 'Market',
    color: Color(0xFFF57C00),
    promptEn:
        'What are the current market trends for rice and wheat? Where should I sell my produce to get a good price?',
  ),
  _QuickActionData(
    icon: Icons.grass_outlined,
    labelEn: 'Crops',
    color: Color(0xFF43A047),
    promptEn:
        'Which crops are best to grow this season in Tamil Nadu and what fertilizers should I use?',
  ),
  _QuickActionData(
    icon: Icons.account_balance_outlined,
    labelEn: 'Schemes',
    color: Color(0xFF7B1FA2),
    promptEn:
        'What government schemes are available for farmers right now? How do I apply for PM-KISAN?',
  ),
  _QuickActionData(
    icon: Icons.water_drop_outlined,
    labelEn: 'Irrigation',
    color: Color(0xFF0097A7),
    promptEn:
        'How should I set up drip irrigation for my tomato crop? What is the optimal watering schedule?',
  ),
];

// ─────────────────────────────────────────
//  DATA MODEL
// ─────────────────────────────────────────
class _Msg {
  final String text;
  final bool isUser;
  final String time;
  final File? image;
  final bool isError;

  _Msg({
    required this.text,
    required this.isUser,
    required this.time,
    this.image,
    this.isError = false,
  });
}

// ─────────────────────────────────────────
//  MAIN CHATBOT SCREEN
// ─────────────────────────────────────────
class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen>
    with TickerProviderStateMixin {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _picker = ImagePicker();

  // Speech
  final _stt = stt.SpeechToText();
  final _tts = FlutterTts();
  bool _sttAvailable = false;
  bool _ttsAvailable = false;
  bool _isListening = false;
  bool _isSpeaking = false;

  // State
  final List<_Msg> _messages = [];
  bool _isTyping = false;
  bool _hasText = false;
  _Lang _selectedLang = _languages[0]; // default English
  String _listeningText = '';

  // Conversation history for Groq (multi-turn)
  final List<Map<String, String>> _history = [];

  // Animation
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _requestMicrophonePermission();
    _initSpeech();
    _initTts();
    _addGreeting();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.15).animate(_pulseCtrl);

    _controller.addListener(() {
      setState(() => _hasText = _controller.text.trim().isNotEmpty);
    });
  }

  void _addGreeting() {
    _messages.add(
      _Msg(
        text: _localizedGreeting(_selectedLang),
        isUser: false,
        time: DateFormat('hh:mm a').format(DateTime.now()),
      ),
    );
  }

  // ─── PERMISSIONS ──────────────────────
  Future<void> _requestMicrophonePermission() async {
    if (Platform.isAndroid || Platform.isIOS) {
      final status = await Permission.microphone.request();
      if (status.isDenied) {
        _showSnack(
          'Microphone permission denied. Voice features may not work.',
        );
      } else if (status.isPermanentlyDenied) {
        openAppSettings();
      }
    }
  }

  // ─── SPEECH ───────────────────────────
  Future<void> _initSpeech() async {
    _sttAvailable = await _stt.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() => _isListening = false);
          if (_listeningText.isNotEmpty) {
            _controller.text = _listeningText;
            setState(() => _hasText = true);
          }
        }
      },
      onError: (e) => setState(() => _isListening = false),
    );
    setState(() {});
  }

  Future<void> _initTts() async {
    try {
      await _tts.setSharedInstance(true);
      await _tts.setIosAudioCategory(IosTextToSpeechAudioCategory.ambient, [
        IosTextToSpeechAudioCategoryOptions.allowBluetooth,
        IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
        IosTextToSpeechAudioCategoryOptions.mixWithOthers,
      ]);
      _tts.setStartHandler(() => setState(() => _isSpeaking = true));
      _tts.setCompletionHandler(() => setState(() => _isSpeaking = false));
      _tts.setErrorHandler((_) => setState(() => _isSpeaking = false));
      await _tts.setSpeechRate(0.45);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      _ttsAvailable = true;
      await _applyTtsLanguage();
    } on MissingPluginException {
      _ttsAvailable = false;
    } catch (_) {
      _ttsAvailable = false;
    }
  }

  Future<void> _applyTtsLanguage() async {
    if (!_ttsAvailable) return;
    try {
      await _tts.setLanguage(_selectedLang.ttsLocale);
    } on MissingPluginException {
      _ttsAvailable = false;
    }
  }

  void _startListening() async {
    if (!_sttAvailable) {
      _showSnack('Microphone not available on this device');
      return;
    }

    // Check microphone permission before listening
    final micStatus = await Permission.microphone.status;
    if (micStatus.isDenied) {
      final result = await Permission.microphone.request();
      if (result.isDenied || result.isPermanentlyDenied) {
        _showSnack('Microphone permission is required for voice input');
        return;
      }
    }

    HapticFeedback.mediumImpact();
    setState(() {
      _isListening = true;
      _listeningText = '';
      _controller.clear();
    });
    await _stt.listen(
      localeId: _selectedLang.sttLocale,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      onResult: (result) {
        setState(() {
          _listeningText = result.recognizedWords;
          _controller.text = _listeningText;
          _hasText = _listeningText.isNotEmpty;
        });
        if (result.finalResult && _listeningText.isNotEmpty) {
          _sendMessage();
        }
      },
    );
  }

  void _stopListening() {
    _stt.stop();
    setState(() => _isListening = false);
  }

  Future<void> _speakMessage(String text) async {
    if (!_ttsAvailable) return;
    if (_isSpeaking) {
      await _tts.stop();
      setState(() => _isSpeaking = false);
      return;
    }
    await _applyTtsLanguage();
    await _tts.speak(_markdownToSpeechText(text));
  }

  String _markdownToSpeechText(String text) {
    var spoken = text;

    spoken = spoken.replaceAll(RegExp(r'''```[\s\S]*?```'''), '');
    spoken = spoken.replaceAll(RegExp(r'''`([^`]+)`'''), r'$1');
    spoken = spoken.replaceAll(RegExp(r'''!\[([^\]]*)\]\(([^)]+)\)'''), r'$1');
    spoken = spoken.replaceAll(RegExp(r'''\[([^\]]+)\]\(([^)]+)\)'''), r'$1');
    spoken = spoken.replaceAll(
      RegExp(r'''^\s{0,3}#{1,6}\s+''', multiLine: true),
      '',
    );
    spoken = spoken.replaceAll(
      RegExp(r'''^\s*[-*+]\s+''', multiLine: true),
      '',
    );
    spoken = spoken.replaceAll(
      RegExp(r'''^\s*\d+\.\s+''', multiLine: true),
      '',
    );
    spoken = spoken.replaceAll(RegExp(r'''\*\*([^*]+)\*\*'''), r'$1');
    spoken = spoken.replaceAll(RegExp(r'''__([^_]+)__'''), r'$1');
    spoken = spoken.replaceAll(RegExp(r'''\*([^*]+)\*'''), r'$1');
    spoken = spoken.replaceAll(RegExp(r'''_([^_]+)_'''), r'$1');
    spoken = spoken.replaceAll('>', '');
    spoken = spoken.replaceAll(RegExp(r'''\n{3,}'''), '\n\n');
    spoken = spoken.replaceAll(RegExp(r'''[ \t]+'''), ' ');

    return spoken.trim();
  }

  // ─── GROQ API ─────────────────────────
  Future<void> _sendMessage({String? overrideText, File? imageFile}) async {
    final text = (overrideText ?? _controller.text).trim();
    if (text.isEmpty && imageFile == null) return;

    HapticFeedback.lightImpact();
    final now = DateFormat('hh:mm a').format(DateTime.now());

    setState(() {
      if (text.isNotEmpty || imageFile != null) {
        _messages.add(
          _Msg(text: text, isUser: true, time: now, image: imageFile),
        );
      }
      _controller.clear();
      _hasText = false;
      _isTyping = true;
    });

    _scrollToBottom();

    // Build conversation history entry
    final userContent =
        imageFile != null
            ? '${text.isNotEmpty ? text : "I have uploaded a crop image. Please analyze it."}'
            : text;

    _history.add({'role': 'user', 'content': userContent});

    try {
      final messages = [
        {'role': 'system', 'content': _buildSystemPrompt(_selectedLang)},
        ..._history,
      ];

      final response = await http
          .post(
            Uri.parse(_kGroqUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_kGroqApiKey',
            },
            body: jsonEncode({
              'model': _kGroqModel,
              'messages': messages,
              'max_tokens': 512,
              'temperature': 0.7,
              'stream': false,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply =
            data['choices'][0]['message']['content']?.toString().trim() ??
            'Sorry, I could not generate a response.';

        _history.add({'role': 'assistant', 'content': reply});

        setState(() {
          _messages.add(
            _Msg(
              text: reply,
              isUser: false,
              time: DateFormat('hh:mm a').format(DateTime.now()),
            ),
          );
          _isTyping = false;
        });

        // Auto-speak the reply
        await _speakMessage(reply);
      } else {
        final err = jsonDecode(response.body);
        _handleError(
          'API Error ${response.statusCode}: ${err['error']?['message'] ?? 'Unknown error'}',
        );
      }
    } on TimeoutException {
      _handleError('Request timed out. Please check your connection.');
    } catch (e) {
      _handleError('Error: $e');
    }

    _scrollToBottom();
  }

  void _handleError(String msg) {
    setState(() {
      _isTyping = false;
      _messages.add(
        _Msg(
          text: '⚠️ $msg',
          isUser: false,
          time: DateFormat('hh:mm a').format(DateTime.now()),
          isError: true,
        ),
      );
    });
  }

  // ─── IMAGE ATTACHMENT ─────────────────
  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context);
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        imageQuality: 85,
      );
      if (picked != null) {
        final file = File(picked.path);
        await _sendMessage(
          overrideText: _localizedImagePrompt(_selectedLang),
          imageFile: file,
        );
      }
    } catch (e) {
      _showSnack('Could not pick image: $e');
    }
  }

  void _showAttachmentSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (_) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _localizedAttachmentTitle(_selectedLang),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _localizedAttachmentSubtitle(_selectedLang),
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _attachBtn(
                      Icons.camera_alt_rounded,
                      'Camera',
                      Colors.green,
                      () => _pickImage(ImageSource.camera),
                    ),
                    _attachBtn(
                      Icons.photo_library_rounded,
                      'Gallery',
                      Colors.blue,
                      () => _pickImage(ImageSource.gallery),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  Widget _attachBtn(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Icon(icon, size: 28, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  // ─── LANGUAGE PICKER ──────────────────
  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (_) => Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _localizedSelectLanguageTitle(_selectedLang),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20),
                  ),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _languages.length,
                    itemBuilder: (_, i) {
                      final lang = _languages[i];
                      final selected = lang.code == _selectedLang.code;
                      return ListTile(
                        leading: Text(
                          lang.flag,
                          style: const TextStyle(fontSize: 24),
                        ),
                        title: Text(
                          lang.name,
                          style: TextStyle(
                            fontWeight:
                                selected ? FontWeight.bold : FontWeight.normal,
                            color:
                                selected
                                    ? const Color(0xFF2E7D32)
                                    : Colors.black87,
                          ),
                        ),
                        trailing:
                            selected
                                ? const Icon(
                                  Icons.check_circle,
                                  color: Color(0xFF2E7D32),
                                )
                                : null,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        tileColor:
                            selected
                                ? const Color(0xFF2E7D32).withOpacity(0.06)
                                : null,
                        onTap: () async {
                          setState(() {
                            _selectedLang = lang;
                            if (_history.isEmpty && _messages.isNotEmpty) {
                              _messages[0] = _Msg(
                                text: _localizedGreeting(lang),
                                isUser: false,
                                time: _messages[0].time,
                              );
                            }
                          });
                          await _applyTtsLanguage();
                          Navigator.pop(context);
                          _showSnack(
                            _ttsAvailable
                                ? 'Language changed to ${lang.name}'
                                : 'Language changed to ${lang.name}. Voice output is unavailable on this device.',
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }

  // ─── UTILS ────────────────────────────
  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(_localizedClearChatTitle(_selectedLang)),
            content: Text(_localizedClearChatContent(_selectedLang)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(_localizedCancelLabel(_selectedLang)),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _messages.clear();
                    _history.clear();
                    _addGreeting();
                  });
                  Navigator.pop(context);
                },
                child: Text(
                  _localizedClearLabel(_selectedLang),
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _pulseCtrl.dispose();
    _tts.stop();
    _stt.stop();
    super.dispose();
  }

  // ─────────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF4F6F0),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          _buildQuickActions(),
          _buildInputBar(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF1B5E20),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Colors.white),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.agriculture, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'KrishiSakhi AI',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                Text(
                  _localizedAppBarSubtitle(_selectedLang),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.75),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Text(_selectedLang.flag, style: const TextStyle(fontSize: 20)),
          onPressed: _showLanguagePicker,
          tooltip: 'Change language',
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onSelected: (v) {
            if (v == 'clear') _clearChat();
          },
          itemBuilder:
              (_) => [
                const PopupMenuItem(
                  value: 'clear',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Clear Chat'),
                    ],
                  ),
                ),
              ],
        ),
      ],
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      itemCount: _messages.length + (_isTyping ? 1 : 0),
      itemBuilder: (_, i) {
        if (_isTyping && i == _messages.length) {
          return const _TypingBubble();
        }
        return _MessageBubble(
          msg: _messages[i],
          onSpeak: (text) => _speakMessage(text),
          isSpeaking: _isSpeaking,
        );
      },
    );
  }

  Widget _buildQuickActions() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(height: 1, color: const Color(0xFFE8F5E9)),
          SizedBox(
            height: 56,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _quickActions.length,
              itemBuilder: (_, i) {
                final qa = _quickActions[i];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _QuickChip(
                    icon: qa.icon,
                    label: _localizedQuickActionLabel(qa, _selectedLang),
                    color: qa.color,
                    onTap:
                        () => _sendMessage(
                          overrideText: _localizedQuickActionPrompt(
                            qa,
                            _selectedLang,
                          ),
                        ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isListening)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    ScaleTransition(
                      scale: _pulseAnim,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _listeningText.isNotEmpty
                            ? _listeningText
                            : _localizedListeningText(_selectedLang),
                        style: TextStyle(
                          color: Colors.red[700],
                          fontSize: 13,
                          fontStyle:
                              _listeningText.isEmpty
                                  ? FontStyle.italic
                                  : FontStyle.normal,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _stopListening,
                      child: const Icon(
                        Icons.stop_circle,
                        color: Colors.red,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Attach
                _InputIconBtn(
                  icon: Icons.attach_file_rounded,
                  color: Colors.grey[600]!,
                  bgColor: Colors.grey[100]!,
                  onTap: _showAttachmentSheet,
                ),
                const SizedBox(width: 8),
                // Text field
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFFE8F5E9),
                        width: 1.5,
                      ),
                      color: const Color(0xFFF9FBF9),
                    ),
                    child: TextField(
                      controller: _controller,
                      maxLines: 4,
                      minLines: 1,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: _localizedInputHint(_selectedLang),
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      style: const TextStyle(fontSize: 14, height: 1.4),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Mic / Send
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child:
                      _hasText
                          ? _InputIconBtn(
                            key: const ValueKey('send'),
                            icon: Icons.send_rounded,
                            color: Colors.white,
                            bgColor: const Color(0xFF2E7D32),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF43A047), Color(0xFF1B5E20)],
                            ),
                            onTap: _sendMessage,
                          )
                          : _InputIconBtn(
                            key: const ValueKey('mic'),
                            icon:
                                _isListening
                                    ? Icons.stop_rounded
                                    : Icons.mic_rounded,
                            color: Colors.white,
                            bgColor:
                                _isListening
                                    ? Colors.red
                                    : const Color(0xFF2E7D32),
                            gradient:
                                _isListening
                                    ? null
                                    : const LinearGradient(
                                      colors: [
                                        Color(0xFF43A047),
                                        Color(0xFF1B5E20),
                                      ],
                                    ),
                            onTap:
                                _isListening ? _stopListening : _startListening,
                          ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
//  MESSAGE BUBBLE
// ─────────────────────────────────────────
class _MessageBubble extends StatefulWidget {
  final _Msg msg;
  final Future<void> Function(String) onSpeak;
  final bool isSpeaking;

  const _MessageBubble({
    required this.msg,
    required this.onSpeak,
    required this.isSpeaking,
  });

  @override
  State<_MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<_MessageBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _slide = Tween<Offset>(
      begin: Offset(widget.msg.isUser ? 0.3 : -0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _fade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isUser = widget.msg.isUser;
    return SlideTransition(
      position: _slide,
      child: FadeTransition(
        opacity: _fade,
        child: Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.78,
            ),
            margin: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // Avatar + bubble row
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (!isUser) ...[
                      Container(
                        width: 28,
                        height: 28,
                        margin: const EdgeInsets.only(right: 6, bottom: 4),
                        decoration: const BoxDecoration(
                          color: Color(0xFF2E7D32),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.agriculture,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ],
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          gradient:
                              isUser
                                  ? const LinearGradient(
                                    colors: [
                                      Color(0xFF43A047),
                                      Color(0xFF1B5E20),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                  : widget.msg.isError
                                  ? LinearGradient(
                                    colors: [Colors.red[50]!, Colors.red[100]!],
                                  )
                                  : const LinearGradient(
                                    colors: [Colors.white, Color(0xFFF1F8E9)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(20),
                            topRight: const Radius.circular(20),
                            bottomLeft: Radius.circular(isUser ? 20 : 4),
                            bottomRight: Radius.circular(isUser ? 4 : 20),
                          ),
                          border: Border.all(
                            color:
                                isUser
                                    ? const Color(0xFF81C784).withOpacity(0.3)
                                    : widget.msg.isError
                                    ? Colors.red[200]!
                                    : const Color(0xFFE8F5E9),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  isUser
                                      ? const Color(0xFF2E7D32).withOpacity(0.2)
                                      : Colors.black.withOpacity(0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.msg.image != null) ...[
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  widget.msg.image!,
                                  height: 160,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                            if (widget.msg.text.isNotEmpty)
                              isUser
                                  ? Text(
                                    widget.msg.text,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14.5,
                                      height: 1.55,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  )
                                  : MarkdownBody(
                                    data: widget.msg.text,
                                    selectable: true,
                                    styleSheet: MarkdownStyleSheet.fromTheme(
                                      Theme.of(context),
                                    ).copyWith(
                                      p: TextStyle(
                                        color:
                                            widget.msg.isError
                                                ? Colors.red[800]
                                                : const Color(0xFF1A1A1A),
                                        fontSize: 14.5,
                                        height: 1.55,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      h1: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        height: 1.4,
                                      ),
                                      h2: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        height: 1.4,
                                      ),
                                      h3: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        height: 1.4,
                                      ),
                                      strong: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                      em: const TextStyle(
                                        fontStyle: FontStyle.italic,
                                      ),
                                      listBullet: TextStyle(
                                        color:
                                            widget.msg.isError
                                                ? Colors.red[800]
                                                : const Color(0xFF1A1A1A),
                                        fontSize: 14.5,
                                        height: 1.55,
                                      ),
                                      a: TextStyle(
                                        color:
                                            widget.msg.isError
                                                ? Colors.red[700]
                                                : const Color(0xFF2E7D32),
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ),
                    if (isUser) ...[
                      Container(
                        width: 28,
                        height: 28,
                        margin: const EdgeInsets.only(left: 6, bottom: 4),
                        decoration: const BoxDecoration(
                          color: Color(0xFF81C784),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ],
                  ],
                ),
                // Time + speak button
                Padding(
                  padding: EdgeInsets.only(
                    top: 4,
                    left: isUser ? 0 : 34,
                    right: isUser ? 34 : 0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.msg.time,
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                      if (!isUser && !widget.msg.isError) ...[
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => widget.onSpeak(widget.msg.text),
                          child: Icon(
                            widget.isSpeaking
                                ? Icons.stop_circle_outlined
                                : Icons.volume_up_outlined,
                            size: 15,
                            color: const Color(0xFF66BB6A),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
//  TYPING INDICATOR
// ─────────────────────────────────────────
class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.only(right: 6, bottom: 4),
            decoration: const BoxDecoration(
              color: Color(0xFF2E7D32),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.agriculture, color: Colors.white, size: 16),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _AnimDot(delay: 0),
                const SizedBox(width: 5),
                _AnimDot(delay: 200),
                const SizedBox(width: 5),
                _AnimDot(delay: 400),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimDot extends StatefulWidget {
  final int delay;
  const _AnimDot({required this.delay});

  @override
  State<_AnimDot> createState() => _AnimDotState();
}

class _AnimDotState extends State<_AnimDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _a;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _a = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
    if (widget.delay > 0) {
      _c.stop();
      Future.delayed(Duration(milliseconds: widget.delay), () {
        if (mounted) _c.repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _a,
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Color(0xFF43A047),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
//  QUICK CHIP
// ─────────────────────────────────────────
class _QuickChip extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_QuickChip> createState() => _QuickChipState();
}

class _QuickChipState extends State<_QuickChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _s;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _s = Tween<double>(
      begin: 1.0,
      end: 0.93,
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _s,
      child: GestureDetector(
        onTapDown: (_) => _c.forward(),
        onTapUp: (_) {
          _c.reverse();
          widget.onTap();
        },
        onTapCancel: () => _c.reverse(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: widget.color.withOpacity(0.09),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: widget.color.withOpacity(0.25), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 16, color: widget.color),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: widget.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
//  INPUT ICON BUTTON
// ─────────────────────────────────────────
class _InputIconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bgColor;
  final Gradient? gradient;
  final VoidCallback onTap;

  const _InputIconBtn({
    super.key,
    required this.icon,
    required this.color,
    required this.bgColor,
    this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: gradient == null ? bgColor : null,
          gradient: gradient,
          shape: BoxShape.circle,
          boxShadow:
              gradient != null
                  ? [
                    BoxShadow(
                      color: bgColor.withOpacity(0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : null,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}
