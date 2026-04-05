import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:krishi_sakhi/models/farm_project.dart';
import 'package:krishi_sakhi/screens/Project_Details/analytics_screen.dart';
import 'package:krishi_sakhi/screens/Project_Details/fields_map.dart';
import 'package:krishi_sakhi/screens/Project_Details/home.dart'
    show DashboardScreen;
import 'package:krishi_sakhi/screens/Project_Details/profile.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:video_thumbnail/video_thumbnail.dart';

class ProjectScreen extends StatefulWidget {
  final FarmProject? project;
  final Map<String, dynamic>? advisoryResponse;

  const ProjectScreen({super.key, this.project, this.advisoryResponse});

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen>
    with TickerProviderStateMixin {
  static const String _llmBaseUrl = String.fromEnvironment(
    'LLM_BASE_URL',
    defaultValue: 'https://api.groq.com/openai/v1',
  );
  static const String _llmModel = String.fromEnvironment(
    'LLM_MODEL',
    defaultValue: 'meta-llama/llama-4-maverick-17b-128e-instruct',
  );
  static const String _llmApiKey = String.fromEnvironment(
    'LLM_API_KEY',
    defaultValue: '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',
  );

  final ImagePicker _picker = ImagePicker();

  int _currentIndex = 0;
  late AnimationController _fabController;
  late AnimationController _navController;
  late Animation<double> _navAnimation;
  bool _showQuickActions = false;

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      DashboardScreen(
        project: widget.project,
        advisoryResponse: widget.advisoryResponse,
      ),
      FieldMapScreen(project: widget.project),
      AnalyticsScreen(project: widget.project),
      InventoryScreen(),
    ];
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _navController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _navAnimation = CurvedAnimation(
      parent: _navController,
      curve: Curves.easeOutBack,
    );
    _navController.forward();
  }

  @override
  void dispose() {
    _fabController.dispose();
    _navController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.03),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: KeyedSubtree(
              key: ValueKey(_currentIndex),
              child: _screens[_currentIndex],
            ),
          ),
          if (_showQuickActions) _buildQuickActionsOverlay(),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: _buildFloatingNavDock(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsOverlay() {
    return GestureDetector(
      onTap: () => setState(() => _showQuickActions = false),
      child: Container(
        color: Colors.black54,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 80),
              _buildQuickActionItem(
                Icons.camera_alt_rounded,
                'Scan Crop',
                _onScanCropTapped,
              ),
              const SizedBox(height: 30),
              // _buildQuickActionItem(Icons.mic_rounded, 'Voice Query', () {}),
              // const SizedBox(height: 16),
              // _buildQuickActionItem(Icons.add_task_rounded, 'Add Task', () {}),
              // const SizedBox(height: 32),
              GestureDetector(
                onTap: () => setState(() => _showQuickActions = false),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Color(0xFF1B5E20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionItem(
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: () {
        setState(() => _showQuickActions = false);
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF1B5E20), size: 22),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF1B5E20),
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onScanCropTapped() async {
    await _showScanSourceSheet();
  }

  Future<void> _showScanSourceSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Scan Crop for Pests',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1B5E20),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Pick camera or gallery, then choose photo or video.',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                _buildScanSourceCard(
                  icon: Icons.camera_alt_rounded,
                  title: 'Camera',
                  subtitle: 'Capture a fresh photo or short video',
                  onPhotoTap: () {
                    Navigator.of(sheetContext).pop();
                    _pickAndAnalyzeMedia(
                      source: ImageSource.camera,
                      asVideo: false,
                    );
                  },
                  onVideoTap: () {
                    Navigator.of(sheetContext).pop();
                    _pickAndAnalyzeMedia(
                      source: ImageSource.camera,
                      asVideo: true,
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildScanSourceCard(
                  icon: Icons.photo_library_rounded,
                  title: 'Gallery',
                  subtitle: 'Choose existing photo or video',
                  onPhotoTap: () {
                    Navigator.of(sheetContext).pop();
                    _pickAndAnalyzeMedia(
                      source: ImageSource.gallery,
                      asVideo: false,
                    );
                  },
                  onVideoTap: () {
                    Navigator.of(sheetContext).pop();
                    _pickAndAnalyzeMedia(
                      source: ImageSource.gallery,
                      asVideo: true,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildScanSourceCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onPhotoTap,
    required VoidCallback onVideoTap,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF7FBF8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD7EBDD)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFF1B5E20).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFF1B5E20), size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPhotoTap,
                  icon: const Icon(Icons.image_rounded),
                  label: const Text('Photo'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1B5E20),
                    side: const BorderSide(color: Color(0xFF8CC79A)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onVideoTap,
                  icon: const Icon(Icons.videocam_rounded),
                  label: const Text('Video'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1B5E20),
                    side: const BorderSide(color: Color(0xFF8CC79A)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndAnalyzeMedia({
    required ImageSource source,
    required bool asVideo,
  }) async {
    try {
      XFile? picked;
      if (asVideo) {
        picked = await _picker.pickVideo(
          source: source,
          maxDuration: const Duration(seconds: 30),
        );
      } else {
        picked = await _picker.pickImage(
          source: source,
          maxWidth: 1920,
          imageQuality: 88,
        );
      }

      if (!mounted || picked == null) {
        return;
      }

      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return FractionallySizedBox(
            heightFactor: 0.96,
            child: _ScanAnalysisBottomSheet(
              mediaFile: File(picked!.path),
              isVideo: asVideo,
              llmBaseUrl: _llmBaseUrl,
              llmModel: _llmModel,
              llmApiKey: _llmApiKey,
            ),
          );
        },
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not open media: $error')));
    }
  }

  Widget _buildFloatingNavDock() {
    return ScaleTransition(
      scale: _navAnimation,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.95),
              Colors.white.withOpacity(0.85),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1B5E20).withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(0, Icons.space_dashboard_rounded, 'Home'),
            _buildNavItem(1, Icons.terrain_rounded, 'Fields'),
            _buildCenterActionButton(),
            _buildNavItem(2, Icons.insights_rounded, 'Stats'),
            _buildNavItem(3, Icons.person_rounded, 'Inventory'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _currentIndex = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient:
              isSelected
                  ? const LinearGradient(
                    colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                  : null,
          borderRadius: BorderRadius.circular(20),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: const Color(0xFF2E7D32).withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                  : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey.shade500,
                size: 22,
              ),
            ),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isSelected ? 1.0 : 0.0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: isSelected ? 14 : 0,
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterActionButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        setState(() => _showQuickActions = true);
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF43A047), Color(0xFF1B5E20)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1B5E20).withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(seconds: 2),
              builder: (context, value, child) {
                return Container(
                  width: 50 + (value * 6),
                  height: 50 + (value * 6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3 * (1 - value)),
                      width: 2,
                    ),
                  ),
                );
              },
            ),
            const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 26,
            ),
          ],
        ),
      ),
    );
  }
}

class _ScanLanguage {
  final String code;
  final String name;
  final String ttsLocale;
  final String sttLocale;
  final String promptInstruction;

  const _ScanLanguage({
    required this.code,
    required this.name,
    required this.ttsLocale,
    required this.sttLocale,
    required this.promptInstruction,
  });
}

class _ScanAnalysisBottomSheet extends StatefulWidget {
  final File mediaFile;
  final bool isVideo;
  final String llmBaseUrl;
  final String llmModel;
  final String llmApiKey;

  const _ScanAnalysisBottomSheet({
    required this.mediaFile,
    required this.isVideo,
    required this.llmBaseUrl,
    required this.llmModel,
    required this.llmApiKey,
  });

  @override
  State<_ScanAnalysisBottomSheet> createState() =>
      _ScanAnalysisBottomSheetState();
}

class _ScanAnalysisBottomSheetState extends State<_ScanAnalysisBottomSheet> {
  static const List<_ScanLanguage> _languages = [
    _ScanLanguage(
      code: 'en',
      name: 'English',
      ttsLocale: 'en-IN',
      sttLocale: 'en_IN',
      promptInstruction:
          'Respond only in simple English for a farmer with practical steps.',
    ),
    _ScanLanguage(
      code: 'ta',
      name: 'தமிழ்',
      ttsLocale: 'ta-IN',
      sttLocale: 'ta_IN',
      promptInstruction:
          'Respond only in Tamil (தமிழ்) with simple village-friendly words.',
    ),
    _ScanLanguage(
      code: 'ml',
      name: 'മലയാളം',
      ttsLocale: 'ml-IN',
      sttLocale: 'ml_IN',
      promptInstruction:
          'Respond only in Malayalam (മലയാളം) with simple farmer-friendly words.',
    ),
  ];

  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _stt = stt.SpeechToText();
  final TextEditingController _followUpController = TextEditingController();
  final ScrollController _followUpScrollController = ScrollController();

  bool _isAnalyzing = true;
  bool _isSpeaking = false;
  bool _isListening = false;
  bool _ttsReady = false;
  bool _sttReady = false;

  _ScanLanguage _selectedLanguage = _languages.first;
  String _analysisText = '';
  String? _errorText;

  Uint8List? _previewBytes;
  String _previewMimeType = 'image/jpeg';
  String _listeningDraft = '';
  final List<_FollowUpEntry> _followUpEntries = <_FollowUpEntry>[];

  @override
  void initState() {
    super.initState();
    _initializeVoice();
    unawaited(_prepareAndAnalyzeInitialMedia());
  }

  @override
  void dispose() {
    _followUpController.dispose();
    _followUpScrollController.dispose();
    if (_ttsReady) {
      unawaited(_tts.stop());
    }
    if (_sttReady) {
      _stt.stop();
    }
    super.dispose();
  }

  Future<void> _initializeVoice() async {
    try {
      await _tts.setSharedInstance(true);
      await _tts.setSpeechRate(0.45);
      await _tts.setPitch(1.0);
      await _tts.setVolume(1.0);
      _tts.setStartHandler(() {
        if (mounted) {
          setState(() => _isSpeaking = true);
        }
      });
      _tts.setCompletionHandler(() {
        if (mounted) {
          setState(() => _isSpeaking = false);
        }
      });
      _tts.setErrorHandler((_) {
        if (mounted) {
          setState(() => _isSpeaking = false);
        }
      });
      _ttsReady = true;
      await _applyLanguageToTts();
    } catch (_) {
      _ttsReady = false;
    }

    _sttReady = await _stt.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (mounted) {
            setState(() => _isListening = false);
          }
        }
      },
      onError: (_) {
        if (mounted) {
          setState(() => _isListening = false);
        }
      },
    );
  }

  Future<void> _applyLanguageToTts() async {
    if (!_ttsReady) {
      return;
    }
    try {
      await _tts.setLanguage(_selectedLanguage.ttsLocale);
    } catch (_) {
      await _tts.setLanguage('en-IN');
    }
  }

  Future<void> _prepareAndAnalyzeInitialMedia() async {
    setState(() {
      _isAnalyzing = true;
      _errorText = null;
    });

    try {
      final mediaPayload = await _buildMediaPayload();
      if (mediaPayload == null) {
        throw Exception('Could not read media for analysis');
      }

      _previewBytes = mediaPayload.bytes;
      _previewMimeType = mediaPayload.mimeType;

      final analysis = await _requestAnalysis(
        mediaPayload: mediaPayload,
        userPrompt:
            'Analyze only pest and disease evidence in this crop media. Ignore unrelated details. Return only pest/disease result and practical farm action.',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _analysisText = analysis;
        _isAnalyzing = false;
      });

      await _speakCurrentAnalysis();
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorText = error.toString();
        _isAnalyzing = false;
      });
    }
  }

  Future<_PreparedMedia?> _buildMediaPayload() async {
    if (!widget.mediaFile.existsSync()) {
      return null;
    }

    if (widget.isVideo) {
      final thumbnailBytes = await VideoThumbnail.thumbnailData(
        video: widget.mediaFile.path,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 1280,
        quality: 82,
      );

      if (thumbnailBytes == null) {
        return null;
      }

      return _PreparedMedia(
        bytes: thumbnailBytes,
        mimeType: 'image/jpeg',
        note:
            'Source is a video. Analysis is based on an extracted representative frame.',
      );
    }

    final bytes = await widget.mediaFile.readAsBytes();
    final lowerPath = widget.mediaFile.path.toLowerCase();
    final mimeType = lowerPath.endsWith('.png') ? 'image/png' : 'image/jpeg';

    return _PreparedMedia(bytes: bytes, mimeType: mimeType, note: '');
  }

  Future<String> _requestAnalysis({
    required _PreparedMedia mediaPayload,
    required String userPrompt,
  }) async {
    if (widget.llmApiKey.trim().isEmpty) {
      throw Exception('LLM_API_KEY is missing. Please pass --dart-define.');
    }

    final uri = _buildChatCompletionsUri(widget.llmBaseUrl);
    final imageDataUrl =
        'data:${mediaPayload.mimeType};base64,${base64Encode(mediaPayload.bytes)}';
    final fallbackModels =
        <String>[
          widget.llmModel,
          'meta-llama/llama-4-maverick-17b-128e-instruct',
          'meta-llama/llama-4-scout-17b-16e-instruct',
        ].toSet().toList();

    Object? lastError;

    for (final model in fallbackModels) {
      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${widget.llmApiKey}',
            },
            body: jsonEncode({
              'model': model,
              'messages': [
                {'role': 'system', 'content': _buildSystemPrompt()},
                {
                  'role': 'user',
                  'content': [
                    {
                      'type': 'text',
                      'text': '${mediaPayload.note}\n$userPrompt',
                    },
                    {
                      'type': 'image_url',
                      'image_url': {'url': imageDataUrl},
                    },
                  ],
                },
              ],
              'temperature': 0.35,
              'max_tokens': 900,
              'stream': false,
            }),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final content =
            decoded['choices']?[0]?['message']?['content']?.toString().trim() ??
            '';
        if (content.isEmpty) {
          throw Exception('LLM returned empty analysis.');
        }
        return _normalizeAnalysisOutput(content);
      }

      final shouldTryFallback = _isRetiredOrMissingModelError(response.body);
      lastError = Exception(
        'LLM request failed (${response.statusCode}) with model "$model": ${response.body}',
      );

      if (!shouldTryFallback) {
        throw lastError;
      }
    }

    throw lastError ??
        Exception('All configured models failed for this LLM request.');
  }

  String _normalizeAnalysisOutput(String content) {
    final trimmed = content.trim();
    if (trimmed.toUpperCase().startsWith('NOT_AGRI')) {
      return 'This media is not agri related. Please upload a crop photo or video.';
    }
    return trimmed;
  }

  bool _isRetiredOrMissingModelError(String responseBody) {
    try {
      final decoded = jsonDecode(responseBody) as Map<String, dynamic>;
      final error = decoded['error'];
      if (error is! Map<String, dynamic>) {
        return false;
      }

      final code = error['code']?.toString().toLowerCase() ?? '';
      if (code == 'model_decommissioned' || code == 'model_not_found') {
        return true;
      }

      final message = error['message']?.toString().toLowerCase() ?? '';
      return message.contains('decommissioned') ||
          message.contains('model') &&
              (message.contains('not found') || message.contains('retired'));
    } catch (_) {
      return false;
    }
  }

  Uri _buildChatCompletionsUri(String baseUrl) {
    final trimmed = baseUrl.trim();
    if (trimmed.isEmpty) {
      return Uri.parse('https://api.groq.com/openai/v1/chat/completions');
    }

    final parsed = Uri.parse(trimmed);
    final path = parsed.path.toLowerCase();
    if (path.endsWith('/chat/completions')) {
      return parsed;
    }

    // Ensure resolve keeps the v1 segment when callers pass .../openai/v1.
    final normalized = trimmed.endsWith('/') ? trimmed : '$trimmed/';
    return Uri.parse(normalized).resolve('chat/completions');
  }

  String _buildSystemPrompt() {
    return '''
You are KrishiSakhi crop health assistant for Indian farmers.
First, check whether the media is agriculture-related (crop, farm plant, leaf, stem, fruit, field, pest, or disease context).
If the media is not agriculture-related, respond with exactly this single line and nothing else:
NOT_AGRI: This media is not agri related. Please upload a crop photo or video.
If agriculture-related, analyze the uploaded crop media only for pests and plant diseases.
Do not discuss soil, irrigation, weather, yield, market, policy, nutrition, or any unrelated topic.
If no pest/disease is visible, clearly say that no visible pest/disease was detected.
Always explain in clear farmer-friendly language, practical and direct.
Avoid medical/legal disclaimers unless safety-critical.
If uncertain, be honest and suggest what additional close-up photo or field check is needed.
${_selectedLanguage.promptInstruction}
Return strict Markdown only.
Output exactly these sections and nothing else:
## Pest/Disease Finding
## Confidence
## What To Do Today
## 7-Day Treatment Plan
## Prevention
''';
  }

  Future<void> _onAskFollowUp() async {
    final question = _followUpController.text.trim();
    if (question.isEmpty || _previewBytes == null) {
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _errorText = null;
    });

    try {
      final nextAnswer = await _requestAnalysis(
        mediaPayload: _PreparedMedia(
          bytes: _previewBytes!,
          mimeType: _previewMimeType,
          note:
              widget.isVideo
                  ? 'Source is a video frame extracted for analysis.'
                  : '',
        ),
        userPrompt:
            'Previous analysis:\n$_analysisText\n\nFarmer follow-up question: $question\n\nAnswer only for pest/disease context, keep it practical, and return strict Markdown using the same section headings.',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _analysisText = nextAnswer;
        _followUpEntries.add(
          _FollowUpEntry(question: question, answer: nextAnswer),
        );
        _isAnalyzing = false;
      });

      _followUpController.clear();
      _scrollFollowUpAnswersToBottom();
      await _speakCurrentAnalysis();
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorText = error.toString();
        _isAnalyzing = false;
      });
    }
  }

  void _scrollFollowUpAnswersToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_followUpScrollController.hasClients) {
        return;
      }
      _followUpScrollController.animateTo(
        _followUpScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _startVoiceInput() async {
    if (!_sttReady) {
      _showSnack('Voice input is not available on this device.');
      return;
    }

    if (_isListening) {
      await _stt.stop();
      setState(() => _isListening = false);
      return;
    }

    setState(() {
      _isListening = true;
      _listeningDraft = '';
    });

    await _stt.listen(
      localeId: _selectedLanguage.sttLocale,
      listenFor: const Duration(seconds: 25),
      pauseFor: const Duration(seconds: 3),
      onResult: (result) {
        if (!mounted) {
          return;
        }
        setState(() {
          _listeningDraft = result.recognizedWords;
          _followUpController.text = _listeningDraft;
          _followUpController.selection = TextSelection.collapsed(
            offset: _followUpController.text.length,
          );
        });
      },
    );
  }

  Future<void> _speakCurrentAnalysis() async {
    if (!_ttsReady || _analysisText.trim().isEmpty) {
      return;
    }

    if (_isSpeaking) {
      await _tts.stop();
      return;
    }

    await _applyLanguageToTts();
    await _tts.speak(_analysisText);
  }

  void _showSnack(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          _buildTopBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPreviewCard(),
                  const SizedBox(height: 14),
                  _buildLanguageAndVoiceControls(),
                  const SizedBox(height: 14),
                  _buildAnalysisCard(),
                  const SizedBox(height: 14),
                  _buildFollowUpCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 10, 4),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 4,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const Expanded(
            child: Text(
              'Pest Detection Analysis',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1B5E20),
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewCard() {
    final mediaTypeLabel =
        widget.isVideo ? 'Video frame analyzed' : 'Photo analyzed';
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF6FBF7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD8ECDD)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                widget.isVideo ? Icons.videocam_rounded : Icons.image_rounded,
                color: const Color(0xFF1B5E20),
              ),
              const SizedBox(width: 8),
              Text(
                mediaTypeLabel,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1B5E20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: double.infinity,
              height: 210,
              child:
                  _previewBytes == null
                      ? Container(
                        color: Colors.black12,
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator(),
                      )
                      : Image.memory(_previewBytes!, fit: BoxFit.cover),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageAndVoiceControls() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E5E5)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<_ScanLanguage>(
                value: _selectedLanguage,
                isExpanded: true,
                items:
                    _languages
                        .map(
                          (lang) => DropdownMenuItem<_ScanLanguage>(
                            value: lang,
                            child: Text(lang.name),
                          ),
                        )
                        .toList(),
                onChanged: (value) async {
                  if (value == null) {
                    return;
                  }
                  setState(() => _selectedLanguage = value);
                  await _applyLanguageToTts();
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        IconButton.filledTonal(
          onPressed: _startVoiceInput,
          icon: Icon(_isListening ? Icons.stop_rounded : Icons.mic_rounded),
          tooltip: 'Voice question',
        ),
        const SizedBox(width: 8),
        IconButton.filled(
          onPressed:
              _analysisText.trim().isEmpty ? null : _speakCurrentAnalysis,
          icon: Icon(
            _isSpeaking ? Icons.volume_off_rounded : Icons.volume_up_rounded,
          ),
          tooltip: 'Speak analysis',
          style: IconButton.styleFrom(
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysisCard() {
    if (_isAnalyzing) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFFE082)),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2.2),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Analyzing crop media for pest signs...',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    }

    if (_errorText != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEBEE),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFFCDD2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Analysis failed',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Color(0xFFB71C1C),
              ),
            ),
            const SizedBox(height: 8),
            Text(_errorText!, style: const TextStyle(color: Color(0xFF5D1A1A))),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _prepareAndAnalyzeInitialMedia,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry analysis'),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FFF9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDCEFD9)),
      ),
      child: MarkdownBody(
        data: _analysisText,
        selectable: true,
        styleSheet: MarkdownStyleSheet(
          p: const TextStyle(
            fontSize: 15,
            height: 1.45,
            color: Color(0xFF17321A),
          ),
          h2: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1B5E20),
          ),
          listBullet: const TextStyle(fontSize: 15, color: Color(0xFF17321A)),
        ),
      ),
    );
  }

  Widget _buildFollowUpCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDDE3F7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ask follow-up in your language',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          if (_isListening) ...[
            const SizedBox(height: 6),
            Text(
              _listeningDraft.isEmpty ? 'Listening...' : _listeningDraft,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
            ),
          ],
          const SizedBox(height: 10),
          TextField(
            controller: _followUpController,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(
              hintText:
                  'Example: இது நிச்சயமாக எந்த பூச்சி? / ഇത് ഏത് കീടമാണ്?',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isAnalyzing ? null : _onAskFollowUp,
              icon: const Icon(Icons.send_rounded),
              label: const Text('Ask and get spoken answer'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1B5E20),
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Answers (scroll)',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Container(
            height: 210,
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFD2DCF3)),
            ),
            child:
                _followUpEntries.isEmpty
                    ? Center(
                      child: Text(
                        'Ask a question to see answers here.',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    )
                    : ListView.separated(
                      controller: _followUpScrollController,
                      itemCount: _followUpEntries.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final entry = _followUpEntries[index];
                        return Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFF),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE1E7F8)),
                          ),
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Q: ${entry.question}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  color: Color(0xFF2E3A5F),
                                ),
                              ),
                              const SizedBox(height: 6),
                              MarkdownBody(
                                data: entry.answer,
                                selectable: true,
                                styleSheet: MarkdownStyleSheet(
                                  p: const TextStyle(
                                    fontSize: 13,
                                    height: 1.35,
                                    color: Color(0xFF1A284A),
                                  ),
                                  h2: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF1B5E20),
                                  ),
                                  listBullet: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF1A284A),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

class _FollowUpEntry {
  final String question;
  final String answer;

  const _FollowUpEntry({required this.question, required this.answer});
}

class _PreparedMedia {
  final Uint8List bytes;
  final String mimeType;
  final String note;

  const _PreparedMedia({
    required this.bytes,
    required this.mimeType,
    required this.note,
  });
}
