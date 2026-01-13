import 'package:flutter/material.dart';
import '../api/gemini_api.dart';

class ChatScreen extends StatefulWidget {
  final String apiKey;

  const ChatScreen({super.key, required this.apiKey});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  late GeminiApi _geminiApi;
  bool _isLoading = false;

  // Jiji Color Palette
  static const Color _surfaceColorHigh = Color(0xFF28292A);
  static const Color _primaryBlue = Color(0xFF4A90E2);
  static const Color _primaryPurple = Color(0xFFC58AF9);
  static const Color _primaryPink = Color(0xFFFF8B7D);

  @override
  void initState() {
    super.initState();
    _geminiApi = GeminiApi(apiKey: widget.apiKey);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _isLoading) return;

    setState(() {
      _messages.add(ChatMessage(text: message, isUser: true));
      _isLoading = true;
    });
    _messageController.clear();
    _scrollToBottom();

    try {
      final history = _messages
          .take(_messages.length - 1)
          .map((m) => m.toGeminiFormat())
          .toList();

      debugPrint('Sending message: $message');

      // Use non-streaming call first for debugging
      final response = await _geminiApi.sendMessage(
        message: message,
        conversationHistory: history,
      );

      debugPrint('Response received: $response');

      setState(() {
        _messages.add(ChatMessage(text: response, isUser: false));
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error: $e');
      setState(() {
        _messages.add(
          ChatMessage(text: 'Error: ${e.toString()}', isUser: false),
        );
        _isLoading = false;
      });
    }
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.5,
            colors: [
              Color(0xFF2E1A47), // Deep Violet
              Color(0xFF0F0F11), // Almost Black
            ],
          ),
        ),
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: _messages.isEmpty && !_isLoading
                      ? _buildWelcomeScreen()
                      : _buildMessageList(),
                ),
                const SizedBox(height: 100), // Space for floating input
              ],
            ),
            Positioned(left: 0, right: 0, bottom: 0, child: _buildInputArea()),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent, // Transparent for seamless look
      elevation: 0,
      centerTitle: false,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Jiji Agent',
            style: TextStyle(
              color: Color(0xFFE3E3E3),
              fontSize: 22,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: _surfaceColorHigh,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _primaryBlue.withOpacity(0.3)),
            ),
            child: const Text(
              'AI WAIFU',
              style: TextStyle(
                color: _primaryBlue,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.history_outlined, color: Color(0xFFC4C7C5)),
          onPressed: () {},
        ),
        IconButton(
          icon: const CircleAvatar(
            radius: 14,
            backgroundColor: _primaryBlue,
            child: Text(
              'U',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          onPressed: () {},
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildWelcomeScreen() {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'How can I help?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFE3E3E3),
                ),
              ),
              const SizedBox(height: 32),
              // Suggestion chips grid
              SizedBox(
                height: 200, // Fixed height for grid
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildSuggestionCard(
                      'Tell me a fun fact!',
                      Icons.auto_awesome,
                    ),
                    _buildSuggestionCard('Recommend an anime', Icons.tv),
                    _buildSuggestionCard('Write a cute poem', Icons.favorite),
                    _buildSuggestionCard('Help with coding', Icons.code),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionCard(String text, IconData icon) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _messageController.text = text;
            _sendMessage();
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _primaryPurple.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: _primaryPurple, size: 20),
                ),
                Text(
                  text,
                  style: const TextStyle(
                    color: Color(0xFFE3E3E3),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.fromLTRB(
        16,
        kToolbarHeight + MediaQuery.of(context).padding.top + 16,
        16,
        130, // Bottom padding for input area
      ),
      itemCount: _messages.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < _messages.length) {
          return _buildMessageBubble(_messages[index]);
        } else {
          return _buildThinkingIndicator();
        }
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;

    if (isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 24, left: 40),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: SelectableText(
            message.text,
            style: const TextStyle(
              color: Color(0xFFE3E3E3),
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ),
      );
    }

    // AI Message
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            margin: const EdgeInsets.only(right: 16, top: 0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _primaryPurple.withOpacity(0.5),
                width: 1.5,
              ),
              image: const DecorationImage(
                image: NetworkImage(
                  "https://api.dicebear.com/7.x/avataaars/png?seed=Jiji&backgroundColor=b6e3f4",
                ), // Anime-style avatar placeholder
                fit: BoxFit.cover,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Jiji",
                  style: TextStyle(
                    color: _primaryPink,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _primaryPurple.withOpacity(0.1),
                        _primaryPurple.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    border: Border.all(color: _primaryPurple.withOpacity(0.2)),
                  ),
                  child: SelectableText(
                    message.text,
                    style: const TextStyle(
                      color: Color(0xFFE3E3E3),
                      fontSize: 16,
                      height: 1.6,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Action buttons for AI response
                Row(
                  children: [
                    _buildIconAction(Icons.volume_up_outlined),
                    _buildIconAction(Icons.favorite_border),
                    _buildIconAction(Icons.thumb_down_alt_outlined),
                    _buildIconAction(Icons.copy_outlined),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconAction(IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Icon(icon, color: const Color(0xFFC4C7C5), size: 18),
    );
  }

  Widget _buildThinkingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _primaryBlue.withOpacity(0.3),
                width: 1.5,
              ),
              image: const DecorationImage(
                image: NetworkImage(
                  "https://api.dicebear.com/7.x/avataaars/png?seed=Jiji&backgroundColor=b6e3f4",
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Jiji",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: 60,
                  child: LinearProgressIndicator(
                    backgroundColor: _surfaceColorHigh,
                    color: _primaryBlue,
                    minHeight: 2,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 20,
        bottom: MediaQuery.of(context).padding.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3), // Glassy background
        border: const Border(top: BorderSide(color: Colors.transparent)),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            const SizedBox(width: 8),
            // Plus button
            IconButton(
              icon: const Icon(
                Icons.add_circle_outline,
                color: Color(0xFFC4C7C5),
              ),
              onPressed: () {},
            ),
            Expanded(
              child: TextField(
                controller: _messageController,
                style: const TextStyle(color: Color(0xFFE3E3E3), fontSize: 16),
                decoration: const InputDecoration(
                  hintText: 'Enter a prompt here',
                  hintStyle: TextStyle(color: Color(0xFF8E918F)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.mic_none_outlined,
                color: Color(0xFFC4C7C5),
              ),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.send_rounded, color: _primaryBlue),
              onPressed: _sendMessage,
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}
