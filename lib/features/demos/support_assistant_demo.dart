import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_typography.dart';
import 'demo_kit.dart';

/// AI Solutions demo: a scripted help-desk assistant. Replies come from
/// simple keyword matching so visitors can feel the conversation flow; no
/// AI model is connected, and the UI says so.
class SupportAssistantDemo extends StatefulWidget {
  const SupportAssistantDemo({super.key});

  @override
  State<SupportAssistantDemo> createState() => _SupportAssistantDemoState();
}

class _Message {
  const _Message(this.text, {required this.fromUser});

  final String text;
  final bool fromUser;
}

class _SupportAssistantDemoState extends State<SupportAssistantDemo> {
  static const _suggestions = ['Track my order', 'Return policy', 'Delivery times', 'Talk to a person'];

  static const _replies = <(List<String>, String)>[
    (
      ['track', 'order', 'where'],
      'You can track any order from "My Orders". Share your order number (for example #48213) and a real assistant would fetch its live status here.',
    ),
    (
      ['return', 'refund', 'exchange'],
      'Returns are accepted within 7 days of delivery for unused items. Refunds reach the original payment method in 5–7 working days.',
    ),
    (['deliver', 'shipping', 'days', 'time'], 'Metro cities usually receive orders in 2–3 days; other locations take 4–6 days.'),
    (
      ['price', 'cost', 'discount', 'offer'],
      'Current offers are shown on the home page. First-time customers get 10% off with code WELCOME10 (sample).',
    ),
    (['hello', 'hi', 'hey'], 'Hello! Ask me about orders, returns or delivery.'),
  ];

  final _input = TextEditingController();
  final _scroll = ScrollController();
  final List<_Message> _messages = [const _Message('Hi! I am the HelpDesk assistant. How can I help today?', fromUser: false)];
  bool _typing = false;
  bool _handedOff = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  String _replyTo(String text) {
    final q = text.toLowerCase();
    if (q.contains('person') || q.contains('human') || q.contains('agent')) {
      _handedOff = true;
      return 'Sure. I have passed this chat to the support team with your messages so far, so you will not need to repeat yourself.';
    }
    for (final (keys, reply) in _replies) {
      if (keys.any(q.contains)) return reply;
    }
    return 'I am not sure about that yet. Try one of the suggestions, or ask to talk to a person.';
  }

  void _send(String raw) {
    final text = raw.trim();
    if (text.isEmpty || _typing) return;
    _input.clear();
    setState(() {
      _messages.add(_Message(text, fromUser: true));
      _typing = true;
    });
    _toBottom();
    _timer = Timer(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() {
        _typing = false;
        _messages.add(_Message(_replyTo(text), fromUser: false));
      });
      _toBottom();
    });
  }

  void _toBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent, duration: AppMotion.lift, curve: AppMotion.ease);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            height: 560,
            decoration: BoxDecoration(
              color: DemoColors.page,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: DemoColors.line),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  color: AppColors.midnightNavy,
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(color: AppColors.electricBlue, shape: BoxShape.circle),
                        child: const Icon(Icons.support_agent_rounded, color: AppColors.white, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'HelpDesk Assistant',
                              style: AppTypography.body(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.white,
                                height: 1.2,
                              ),
                            ),
                            Text(
                              _handedOff ? 'Handed off to the support team' : 'Scripted demo · no AI model connected',
                              style: AppTypography.body(fontSize: 12, color: AppColors.electricBlueTint, height: 1.3),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: _scroll,
                    padding: const EdgeInsets.all(14),
                    children: [
                      for (final m in _messages) _Bubble(message: m),
                      if (_typing) const _Bubble(message: _Message('Typing…', fromUser: false), muted: true),
                    ],
                  ),
                ),
                SizedBox(
                  height: 48,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    itemCount: _suggestions.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (_, i) => DemoChip(label: _suggestions[i], selected: false, onTap: () => _send(_suggestions[i])),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: DemoField(label: 'Type a message', controller: _input, onSubmitted: _send),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        tooltip: 'Send',
                        onPressed: () => _send(_input.text),
                        style: IconButton.styleFrom(backgroundColor: AppColors.electricBlue, minimumSize: const Size(48, 48)),
                        icon: const Icon(Icons.send_rounded, color: AppColors.white),
                      ),
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

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message, this.muted = false});

  final _Message message;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final user = message.fromUser;
    return Align(
      alignment: user ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 380),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: user ? AppColors.electricBlue : DemoColors.panel,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(user ? 16 : 4),
            bottomRight: Radius.circular(user ? 4 : 16),
          ),
          border: user ? null : Border.all(color: DemoColors.line),
        ),
        child: Text(
          message.text,
          style: AppTypography.body(
            fontSize: 14,
            color: user ? AppColors.white : (muted ? DemoColors.muted : DemoColors.ink),
            height: 1.5,
          ),
        ),
      ),
    );
  }
}
