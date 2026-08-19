import 'package:flutter/material.dart';
import '../services/bluetooth_service.dart';
import '../widgets/ivt_card.dart';
import '../widgets/ivt_button.dart';
import 'input_screen.dart';
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final BleService _bleService = BleService();

  @override
  void initState() {
    super.initState();
    _bleService.addListener(_updateState);
  }

  @override
  void dispose() {
    _bleService.removeListener(_updateState);
    super.dispose();
  }

  void _updateState() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Good evening, Student 👋', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('Ready to learn something new?', style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.normal)),
          ],
        ),
        actions: [
          Tooltip(
            message: _bleService.isConnected ? 'Connected to AI Tutor Server' : 'Disconnected',
            child: Row(
              children: [
                Icon(Icons.circle, size: 12, color: _bleService.isConnected ? const Color(0xFF22A06B) : const Color(0xFFD64545)),
                const SizedBox(width: 4),
                Text(_bleService.isConnected ? 'Connected' : 'Offline', style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
          const Padding(
            padding: EdgeInsets.only(right: 16.0, left: 8.0),
            child: CircleAvatar(
              backgroundColor: Color(0xFFE0E7FF),
              child: Icon(Icons.person, color: Color(0xFF243B6B)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroCard(context),
            const SizedBox(height: 24),
            _buildQuickActions(),
            const SizedBox(height: 24),

            const Text('Continue Learning', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildContinueLearning(),
            const SizedBox(height: 24),
            const Text('AI Learning Insight', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildInsightCard(),
            const SizedBox(height: 24),
            const Text('Recent Doubts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildRecentDoubts(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    return IvtCard(
      color: const Color(0xFF243B6B),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ask AI Tutor anything.', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Get step-by-step explanations in Kannada, English or your preferred language.', style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5)),
          const SizedBox(height: 20),
          Row(
            children: [
              IvtPrimaryButton(
                label: 'Ask AI',
                icon: Icons.auto_awesome,
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const InputScreen()));
                },
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const InputScreen()));
                },
                icon: const Icon(Icons.mic, color: Colors.white),
                label: const Text('Ask by Voice', style: TextStyle(color: Colors.white)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white54),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionItem(Icons.chat_bubble_outline, 'Ask a Doubt', () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const InputScreen()));
        }),
        _buildActionItem(Icons.mic_none, 'Voice Tutor', () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const InputScreen()));
        }),
        _buildActionItem(Icons.edit_note, 'Practice', () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const InputScreen(initialPrompt: 'Give me a practice test')));
        }),
        _buildActionItem(Icons.trending_up, 'My Progress', () {}),
      ],
    );
  }

  Widget _buildActionItem(IconData icon, String label, VoidCallback onTap) {
    return Column(
      children: [
        IvtCard(
          padding: const EdgeInsets.all(16),
          onTap: onTap,
          child: Icon(icon, color: const Color(0xFF243B6B), size: 28),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildContinueLearning() {
    return IvtCard(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const InputScreen(initialPrompt: 'Let\'s practice Algebra')));
      },
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFF7F9FC), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.calculate, color: Color(0xFF243B6B), size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Mathematics', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const Text('Algebra', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: 0.68,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF6B5A)),
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          const Text('68%', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF243B6B))),
        ],
      ),
    );
  }

  Widget _buildInsightCard() {
    return IvtCard(
      color: const Color(0xFFF0F4FF),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tips_and_updates, color: Color(0xFF243B6B)),
              const SizedBox(width: 8),
              const Expanded(child: Text('You are improving in Algebra. Try 3 more practice questions today.', style: TextStyle(color: Color(0xFF243B6B), fontWeight: FontWeight.w500))),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat('82%', 'Accuracy'),
              _buildStat('48', 'Questions'),
              _buildStat('7 days', 'Streak'),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF243B6B))),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildRecentDoubts() {
    return Column(
      children: [
        _buildDoubtTile('Mathematics', 'How to factorize 9x² + 12x + 4?'),
        const SizedBox(height: 8),
        _buildDoubtTile('Science', "Explain Newton's second law"),
      ],
    );
  }

  Widget _buildDoubtTile(String subject, String question) {
    return IvtCard(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const CircleAvatar(backgroundColor: Color(0xFFF7F9FC), child: Icon(Icons.history, color: Color(0xFF243B6B), size: 18)),
        title: Text(question, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        subtitle: Text(subject, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => InputScreen(initialPrompt: question)));
        },
      ),
    );
  }
}
