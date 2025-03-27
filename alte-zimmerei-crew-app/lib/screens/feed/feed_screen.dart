import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/post_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_message.dart';
import '../../widgets/empty_state.dart';
import 'components/post_card.dart';
import 'create_post_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializePostProvider();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _initializePostProvider() {
    // Initialize post provider
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    postProvider.initializePosts();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
      }
    });
  }

  void _navigateToCreatePost() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isOwner = authProvider.isOwner;
    final feedType = _tabController.index == 0 ? 'news' : 'general';
    
    // Only owners can post in news feed
    if (_tabController.index == 0 && !isOwner) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only owners can post in the News feed'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreatePostScreen(feedType: feedType),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final postProvider = Provider.of<PostProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Feed',
        showBackButton: false,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isSearching)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search posts...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  // Implement search functionality
                },
              ),
            ),
          TabBar(
            controller: _tabController,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.inactive,
            tabs: const [
              Tab(text: 'News'),
              Tab(text: 'General'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // News Feed
                _buildFeedContent(postProvider.newsPosts, 'news'),
                
                // General Feed
                _buildFeedContent(postProvider.generalPosts, 'general'),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreatePost,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFeedContent(List posts, String feedType) {
    if (posts.isEmpty) {
      return EmptyState(
        message: 'No posts yet. Be the first to post!',
        icon: Icons.post_add,
        actionText: 'Create Post',
        onActionPressed: _navigateToCreatePost,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        // Refresh posts
        final postProvider = Provider.of<PostProvider>(context, listen: false);
        postProvider.initializePosts();
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return PostCard(post: post);
        },
      ),
    );
  }
}

