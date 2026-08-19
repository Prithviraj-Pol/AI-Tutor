import 'package:flutter/material.dart';
import '../widgets/ivt_card.dart';
import 'input_screen.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Learning Progress')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopMetrics(),
            const SizedBox(height: 32),
            const Text('Subject Performance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildSubjectBars(),
            const SizedBox(height: 32),
            const Text('Areas to Improve', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildWeakTopics(),
            const SizedBox(height: 24),
            _buildAiRecommendation(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTopMetrics() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildMetricCard('🔥', '7 Day', 'Streak')),
            const SizedBox(width: 16),
            Expanded(child: _buildMetricCard('📚', '48', 'Questions')),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildMetricCard('🎯', '82%', 'Accuracy')),
            const SizedBox(width: 16),
            Expanded(child: _buildMetricCard('⏱', '6h 24m', 'Learning')),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(String emoji, String value, String label) {
    return IvtCard(
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF243B6B))),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildSubjectBars() {
    return IvtCard(
      child: Column(
        children: [
          _buildProgressBar('Mathematics', 0.82),
          const SizedBox(height: 16),
          _buildProgressBar('Science', 0.74),
          const SizedBox(height: 16),
          _buildProgressBar('Social Science', 0.68),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String label, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text('${(progress * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF243B6B))),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[200],
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF6B5A)),
          borderRadius: BorderRadius.circular(4),
          minHeight: 8,
        ),
      ],
    );
  }

  Widget _buildWeakTopics() {
    return Row(
      children: [
        _buildTopicChip('Algebra'),
        const SizedBox(width: 8),
        _buildTopicChip('Trigonometry'),
      ],
    );
  }

  Widget _buildTopicChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE0E7FF)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.trending_down, size: 16, color: Color(0xFFD64545)),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Color(0xFF243B6B), fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildAiRecommendation(BuildContext context) {
    return IvtCard(
      color: const Color(0xFF243B6B),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: Color(0xFFFF6B5A), size: 32),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              "Focus on Algebra for the next 20 minutes.",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const InputScreen(initialPrompt: 'Give me 3 practice questions on Algebra')));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B5A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Start'),
          )
        ],
      ),
    );
  }
}
