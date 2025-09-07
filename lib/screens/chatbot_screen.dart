import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:krishi_sakhi/components/drawer.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({Key? key}) : super(key: key);

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<_ChatMessage> _messages = [
    _ChatMessage(
      text: 'Hello! How can I assist you today with your farming needs?',
      isUser: false,
      time: '10:00 AM',
    ),
    _ChatMessage(
      text: 'I\'m having trouble with pests on my tomato plants, Can you help?',
      isUser: true,
      time: '10:01 AM',
    ),
    _ChatMessage(
      text:
          'Of course! To better understand the issue, could you describe the pests or upload a photo of the affected plants?',
      isUser: false,
      time: '10:02 AM',
    ),
  ];
  bool _isTyping = true;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fabAnimationController,
        curve: Curves.elasticOut,
      ),
    );
    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _fabAnimationController.reverse().then((_) {
      _fabAnimationController.forward();
    });

    setState(() {
      _messages.add(
        _ChatMessage(
          text: text,
          isUser: true,
          time: DateFormat('hh:mm a').format(DateTime.now()),
        ),
      );
      _controller.clear();
      _isTyping = true;
    });
    // Simulate assistant response
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _messages.add(
          _ChatMessage(
            text:
                'Thank you for your message. I\'m analyzing your query and will provide you with the best farming advice!',
            isUser: false,
            time: DateFormat('hh:mm a').format(DateTime.now()),
          ),
        );
        _isTyping = false;
      });
    });
  }

  void _handleAttachment() {
    // Show attachment options (gallery, camera, files)
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Select Attachment',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _AttachmentOption(
                      icon: Icons.photo_camera,
                      label: 'Camera',
                      onTap: () {
                        Navigator.pop(context);
                        // Handle camera selection
                      },
                    ),
                    _AttachmentOption(
                      icon: Icons.photo_library,
                      label: 'Gallery',
                      onTap: () {
                        Navigator.pop(context);
                        // Handle gallery selection
                      },
                    ),
                    _AttachmentOption(
                      icon: Icons.insert_drive_file,
                      label: 'Files',
                      onTap: () {
                        Navigator.pop(context);
                        // Handle file selection
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  void _toggleDrawer() {
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      _scaffoldKey.currentState?.closeDrawer();
    } else {
      _scaffoldKey.currentState?.openDrawer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const CustomDrawer(),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        title: const Text(
          'Krishi Assist',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: _toggleDrawer,
          tooltip: 'Open navigation menu',
        ),
        elevation: 4,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFF6F8FA),
              Colors.green[50]!.withOpacity(0.3),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 12,
                ),
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (_isTyping && index == _messages.length) {
                    return _TypingIndicator();
                  }
                  final msg = _messages[index];
                  return _AnimatedMessage(message: msg, index: index);
                },
              ),
            ),
            _QuickActions(),
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.green.withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[100],
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.attach_file, color: Colors.grey[600]),
              onPressed: _handleAttachment,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Ask me anything about farming...',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide.none,
                  ),
                  fillColor: const Color(0xFFF8F9FA),
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                minLines: 1,
                maxLines: 4,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.green[400]!, Colors.green[600]!],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.mic, color: Colors.white),
              onPressed: () {},
            ),
          ),
          const SizedBox(width: 8),
          ScaleTransition(
            scale: _fabAnimation,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.green[600]!, Colors.green[800]!],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: _sendMessage,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedMessage extends StatefulWidget {
  final _ChatMessage message;
  final int index;

  const _AnimatedMessage({required this.message, required this.index});

  @override
  State<_AnimatedMessage> createState() => _AnimatedMessageState();
}

class _AnimatedMessageState extends State<_AnimatedMessage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300 + (widget.index * 100)),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(widget.message.isUser ? 1.0 : -1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Align(
          alignment:
              widget.message.isUser
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              crossAxisAlignment:
                  widget.message.isUser
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    gradient:
                        widget.message.isUser
                            ? LinearGradient(
                              colors: [
                                Colors.green[500]!,
                                Colors.green[600]!,
                                Colors.green[700]!,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                            : LinearGradient(
                              colors: [
                                Colors.white,
                                Colors.grey[50]!,
                                Colors.grey[100]!,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(24),
                      topRight: const Radius.circular(24),
                      bottomLeft: Radius.circular(
                        widget.message.isUser ? 24 : 8,
                      ),
                      bottomRight: Radius.circular(
                        widget.message.isUser ? 8 : 24,
                      ),
                    ),
                    border: Border.all(
                      color:
                          widget.message.isUser
                              ? Colors.green[300]!.withOpacity(0.3)
                              : Colors.grey[300]!.withOpacity(0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            widget.message.isUser
                                ? Colors.green.withOpacity(0.25)
                                : Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                        spreadRadius: 1,
                      ),
                      BoxShadow(
                        color:
                            widget.message.isUser
                                ? Colors.green.withOpacity(0.1)
                                : Colors.white.withOpacity(0.8),
                        blurRadius: 6,
                        offset: const Offset(0, 1),
                        spreadRadius: -1,
                      ),
                    ],
                  ),
                  child: Text(
                    widget.message.text,
                    style: TextStyle(
                      color:
                          widget.message.isUser ? Colors.white : Colors.black87,
                      fontSize: 16,
                      height: 1.5,
                      fontWeight:
                          widget.message.isUser
                              ? FontWeight.w500
                              : FontWeight.w400,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.message.time,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  final String time;
  _ChatMessage({required this.text, required this.isUser, required this.time});
}

class _TypingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.white, Colors.grey[50]!],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.8),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
              border: Border.all(color: Colors.grey[200]!, width: 1),
            ),
            child: CircleAvatar(
              backgroundColor: Colors.transparent,
              child: Icon(Icons.agriculture, color: Colors.green[700]),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.grey[50]!, Colors.grey[100]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.grey[300]!.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.8),
                  blurRadius: 6,
                  offset: const Offset(0, 1),
                  spreadRadius: -1,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Dot(),
                const SizedBox(width: 6),
                _Dot(delay: 200),
                const SizedBox(width: 6),
                _Dot(delay: 400),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  final int delay;
  const _Dot({this.delay = 0});
  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _animation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticInOut));

    if (widget.delay > 0) {
      Future.delayed(Duration(milliseconds: widget.delay), () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _animation,
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green[400]!, Colors.green[600]!],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _QuickActionButton(
            label: 'Weather',
            icon: Icons.cloud,
            color: Colors.blue,
          ),
          _QuickActionButton(
            label: 'Pests',
            icon: Icons.bug_report,
            color: Colors.red,
          ),
          _QuickActionButton(
            label: 'Market',
            icon: Icons.attach_money,
            color: Colors.orange,
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _QuickActionButton({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  State<_QuickActionButton> createState() => _QuickActionButtonState();
}

class _QuickActionButtonState extends State<_QuickActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) => _controller.reverse(),
        onTapCancel: () => _controller.reverse(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                widget.color.withOpacity(0.1),
                widget.color.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: widget.color.withOpacity(0.2), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 18, color: widget.color),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 13,
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

class _AttachmentOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AttachmentOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green[50],
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Icon(icon, size: 28, color: Colors.green[600]),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
