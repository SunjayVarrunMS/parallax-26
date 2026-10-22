// the help screen: the FAQ list and the contact form

import 'package:flutter/material.dart';

import '../api/help_api.dart';
import '../theme.dart';
import '../widgets/buttons.dart';
import '../widgets/form_parts.dart';
import '../widgets/page_heading.dart';
import '../widgets/page_shell.dart';
import '../widgets/panels.dart';

// one question and its answer
class _Faq {
  const _Faq(this.question, this.answer);

  final String question;
  final String answer;
}

const List<_Faq> _faqs = [
  _Faq(
    "When and where is PARALLAX '26?",
    'It runs from 20 to 22 November, on campus. Every venue, with directions, is on the campus guide page.',
  ),
  _Faq(
    'Do I need a ticket to come in?',
    'Walking around is free with a college ID. Some events have a fee, shown on the events page and in the fee summary when you register.',
  ),
  _Faq(
    'How do I know my registration worked?',
    'You get a confirmation panel straight after you register. Every registration, workshop booking and merch order also shows up on My bookings.',
  ),
  _Faq(
    'Can I get a refund?',
    'Cancel from My bookings and the fee is returned within five working days. If we cancel an event, everyone gets a full refund without asking.',
  ),
  _Faq(
    'Where do I pick up my merch?',
    'Collect it from the merch desk next to the food court. Bring a college ID and the order id from My bookings.',
  ),
  _Faq(
    'I lost something. What now?',
    'Lost and found is at the help desk by the main stage. Describe the item in the form below and we will check the box for you.',
  ),
];

const List<String> _topics = [
  'Tickets and registration',
  'Workshops',
  'Refunds',
  'Merch',
  'Lost and found',
  'Something else',
];

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  String _topic = _topics.first;
  bool _submitting = false;
  String _submitError = '';
  String _doneText = '';
  final Set<int> _openFaqs = {};

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  String? _validateMessage(String? value) {
    if ((value ?? '').trim() == '') {
      return errText('Write a message.');
    }
    return null;
  }

  void _showDone(String? ticketId) {
    setState(() {
      _doneText = 'Got it. Your ticket number is #$ticketId.';
    });
  }

  Future<void> _handleSubmit() async {
    if (_submitting) {
      return;
    }
    setState(() {
      _submitError = '';
    });
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _submitting = true;
    });
    String? ticketId;
    try {
      final result = await submitContact(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _topic,
        _messageController.text,
      );
      ticketId = result['ticketId'] as String;
    } catch (error) {
      debugPrint(error.toString());
    }
    if (!mounted) return;
    _showDone(ticketId);
    setState(() {
      _submitting = false;
    });
  }

  void _resetForm() {
    setState(() {
      _nameController.clear();
      _emailController.clear();
      _messageController.clear();
      _topic = _topics.first;
      _submitError = '';
      _doneText = '';
    });
  }

  Widget _buildFaqItem(PlxColors c, int index) {
    final faq = _faqs[index];
    final open = _openFaqs.contains(index);
    return Container(
      decoration: BoxDecoration(
        border: index == _faqs.length - 1 ? null : Border(bottom: BorderSide(color: c.lineSoft)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => setState(() {
              if (open) {
                _openFaqs.remove(index);
              } else {
                _openFaqs.add(index);
              }
            }),
            child: Container(
              constraints: const BoxConstraints(minHeight: 52),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    child: Text(open ? '-' : '+', style: monoStyle(weight: FontWeight.w800, color: c.accent)),
                  ),
                  Expanded(
                    child: Text(
                      faq.question,
                      style: monoStyle(weight: FontWeight.w800, color: const Color(0xFF8FF3FF), height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (open)
            Padding(
              padding: const EdgeInsets.fromLTRB(42, 0, 20, 18),
              child: Text(
                faq.answer,
                style: monoStyle(size: 14, color: const Color(0xFFD9F7FF)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFaq(PlxColors c) {
    return PlxPanel(
      barLeft: '>FAQ',
      barRight: '[6 ANSWERS]',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [for (int i = 0; i < _faqs.length; i++) _buildFaqItem(c, i)],
      ),
    );
  }

  Widget _buildDone(PlxColors c) {
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.all(color: c.green, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PanelBar('>Message sent', color: c.green),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_doneText, style: displayStyle(size: 28, color: c.ink)),
                const SizedBox(height: 18),
                PlxButton(label: 'Send another message', kind: ButtonKind.outline, onPressed: _resetForm),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(PlxColors c) {
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.all(color: c.cyan, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PanelBar('>Contact the desk'),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PlxTextField(label: 'Full name', controller: _nameController, validator: validateName),
                  const SizedBox(height: 18),
                  PlxTextField(
                    label: 'Email',
                    controller: _emailController,
                    validator: validateEmail,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 18),
                  PlxDropdown(
                    label: 'Topic',
                    value: _topic,
                    options: {for (final topic in _topics) topic: topic},
                    onChanged: (value) => setState(() => _topic = value),
                  ),
                  const SizedBox(height: 18),
                  PlxTextField(
                    label: 'Message',
                    controller: _messageController,
                    validator: _validateMessage,
                    hint: "Where's my ticket?",
                    keyboardType: TextInputType.multiline,
                    maxLines: 5,
                  ),
                  if (_submitError != '') ...[
                    const SizedBox(height: 18),
                    FormErrorText(_submitError),
                  ],
                  const SizedBox(height: 18),
                  PlxButton(
                    label: _submitting ? 'Sending...' : 'Send',
                    expand: true,
                    onPressed: _submitting ? null : _handleSubmit,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = PlxColors.of(context);

    final faq = _buildFaq(c);
    final formSide = _doneText != '' ? _buildDone(c) : _buildForm(c);

    Widget layout;
    if (MediaQuery.sizeOf(context).width < 1000) {
      layout = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [faq, const SizedBox(height: 28), formSide],
      );
    } else {
      layout = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 6, child: faq),
          const SizedBox(width: 32),
          Expanded(flex: 5, child: formSide),
        ],
      );
    }

    return PageShell(
      currentPath: '/help',
      child: PageContainer(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const PageHeading(
                eyebrow: '>> PARALLAX / 08',
                title: "We're around",
                description: 'Small questions. Big questions. "Where did I leave my bag?" questions.',
              ),
              const SizedBox(height: 40),
              layout,
            ],
          ),
        ),
      ),
    );
  }
}
