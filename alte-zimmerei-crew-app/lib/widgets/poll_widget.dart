// In lib/widgets/poll_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../providers/auth_provider.dart';
import '../providers/post_provider.dart';

class PollWidget extends StatefulWidget {
  final Map<String, dynamic> pollData;
  final String postId;
  final String feedType;

  const PollWidget({
    Key? key,
    required this.pollData,
    required this.postId,
    required this.feedType,
  }) : super(key: key);

  @override
  State<PollWidget> createState() => _PollWidgetState();
}

class _PollWidgetState extends State<PollWidget> {
  bool _hasVoted = false;
  String? _selectedOptionId;
  bool _isExpired = false;
  
  @override
  void initState() {
    super.initState();
    _checkVoteStatus();
    _checkExpiryStatus();
  }
  
  void _checkVoteStatus() {
    final userId = Provider.of<AuthProvider>(context, listen: false).user?.id;
    if (userId == null) return;
    
    // Check if user has already voted
    final options = List<Map<String, dynamic>>.from(widget.pollData['options'] ?? []);
    
    for (var option in options) {
      final votes = List<String>.from(option['votes'] ?? []);
      if (votes.contains(userId)) {
        setState(() {
          _hasVoted = true;
          _selectedOptionId = option['id'];
        });
        break;
      }
    }
  }
  
  void _checkExpiryStatus() {
    if (widget.pollData['endDate'] != null) {
      final endDate = DateTime.parse(widget.pollData['endDate']);
      setState(() {
        _isExpired = DateTime.now().isAfter(endDate);
      });
    }
  }
  
  void _vote(String optionId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    
    if (authProvider.user == null) return;
    
    setState(() {
      _selectedOptionId = optionId;
      _hasVoted = true;
    });
    
    try {
      await postProvider.voteInPoll(
        widget.postId, 
        widget.feedType, 
        authProvider.user!.id, 
        optionId
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to vote: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
      
      // Revert UI state if vote fails
      setState(() {
        _selectedOptionId = null;
        _hasVoted = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final options = List<Map<String, dynamic>>.from(widget.pollData['options'] ?? []);
    final question = widget.pollData['question'] ?? 'No question';
    final endDate = widget.pollData['endDate'] != null 
      ? DateTime.parse(widget.pollData['endDate']) 
      : null;
    
    // Calculate total votes
    int totalVotes = 0;
    for (var option in options) {
      totalVotes += (option['votes'] as List?)?.length ?? 0;
    }
    
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poll question
          Text(
            question,
            style: AppTextStyles.subtitle1.copyWith(fontWeight: FontWeight.bold),
          ),
          
          if (endDate != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  _isExpired ? Icons.timer_off : Icons.timer,
                  size: 14,
                  color: _isExpired ? AppColors.error : AppColors.inactive,
                ),
                const SizedBox(width: 4),
                Text(
                  _isExpired 
                    ? 'Poll ended' 
                    : 'Ends on ${endDate.day}/${endDate.month}/${endDate.year}',
                  style: AppTextStyles.caption.copyWith(
                    color: _isExpired ? AppColors.error : AppColors.inactive,
                  ),
                ),
              ],
            ),
          ],
          
          const SizedBox(height: 16),
          
          // Poll options
          ...options.map((option) {
            final optionId = option['id'];
            final optionText = option['text'];
            final votes = List<String>.from(option['votes'] ?? []);
            final voteCount = votes.length;
            final votePercentage = totalVotes > 0 
                ? (voteCount / totalVotes * 100).round() 
                : 0;
            
            final isSelected = _selectedOptionId == optionId;
            final showResults = _hasVoted || _isExpired;
            
            return GestureDetector(
              onTap: (_hasVoted || _isExpired) 
                  ? null 
                  : () => _vote(optionId),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Option text and selection indicator
                    Row(
                      children: [
                        Icon(
                          isSelected 
                              ? Icons.radio_button_checked 
                              : Icons.radio_button_unchecked,
                          color: isSelected 
                              ? AppColors.primary 
                              : AppColors.inactive,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            optionText,
                            style: AppTextStyles.bodyText1.copyWith(
                              fontWeight: isSelected 
                                  ? FontWeight.bold 
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (showResults)
                          Text(
                            '$voteCount votes',
                            style: AppTextStyles.caption,
                          ),
                      ],
                    ),
                    
                    // Progress bar for results
                    if (showResults) ...[
                      const SizedBox(height: 4),
                      Stack(
                        children: [
                          // Background
                          Container(
                            height: 8,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          // Progress
                          Container(
                            height: 8,
                            width: MediaQuery.of(context).size.width * 
                                  (votePercentage / 100) * 0.7, // Scale factor
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? AppColors.primary 
                                  : AppColors.secondary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$votePercentage%',
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isSelected 
                              ? AppColors.primary 
                              : AppColors.inactive,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
          
          // Total votes
          const SizedBox(height: 8),
          Text(
            'Total votes: $totalVotes',
            style: AppTextStyles.caption,
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }
}