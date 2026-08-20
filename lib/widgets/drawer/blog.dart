import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class BlogListScreen extends StatefulWidget {
  const BlogListScreen({super.key});

  @override
  _BlogListScreenState createState() => _BlogListScreenState();
}

class _BlogListScreenState extends State<BlogListScreen>
    with SingleTickerProviderStateMixin {
  List<dynamic> blogs = [];
  bool isLoading = true;
  String errorMessage = '';
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;
  ScrollController? _scrollController;

  String _searchQuery = '';
  final List<String> _filterOptions = ['All', 'Recent', 'Popular'];
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut),
    );
    fetchBlogs();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _scrollController?.dispose();
    super.dispose();
  }

  Future<void> fetchBlogs() async {
    setState(() => isLoading = true);
    final url = Uri.parse('https://new-test.megascale.co.in/api/p1/blogs');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          blogs = data['blogs'] ?? [];
          isLoading = false;
          errorMessage = blogs.isEmpty ? 'No blogs available' : '';
        });
        _animationController?.forward();
      } else {
        _handleError('Server error: ${response.statusCode}');
      }
    } catch (e) {
      _handleError('Failed to fetch blogs: $e');
    }
  }

  void _handleError(String message) {
    setState(() {
      errorMessage = message;
      isLoading = false;
    });
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy • HH:mm').format(date);
    } catch (e) {
      return dateString;
    }
  }

  String _stripHtml(String htmlString) {
    try {
      final document = parse(htmlString);
      final text = document.body?.text.trim() ?? htmlString;
      return text.length > 150 ? '${text.substring(0, 150)}...' : text;
    } catch (e) {
      return htmlString;
    }
  }

  List<dynamic> _getFilteredBlogs() {
    if (_searchQuery.isEmpty && _selectedFilter == 'All') {
      return blogs;
    }

    List<dynamic> filteredBlogs = List.from(blogs);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filteredBlogs = filteredBlogs.where((blog) {
        final title = blog['title']?.toString().toLowerCase() ?? '';
        final handle = blog['handle']?.toString().toLowerCase() ?? '';
        final query = _searchQuery.toLowerCase();
        return title.contains(query) || handle.contains(query);
      }).toList();
    }

    // Apply category filter
    if (_selectedFilter != 'All') {
      switch (_selectedFilter) {
        case 'Recent':
          filteredBlogs.sort((a, b) {
            final dateA =
                DateTime.tryParse(a['updated_at'] ?? '') ?? DateTime(1970);
            final dateB =
                DateTime.tryParse(b['updated_at'] ?? '') ?? DateTime(1970);
            return dateB.compareTo(dateA);
          });
          filteredBlogs = filteredBlogs.take(5).toList();
          break;
        case 'Popular':
          // This would be based on a popularity metric if available
          // For now, let's use the number of articles as a proxy
          filteredBlogs.sort((a, b) {
            final articlesA = (a['articles'] as List?)?.length ?? 0;
            final articlesB = (b['articles'] as List?)?.length ?? 0;
            return articlesB.compareTo(articlesA);
          });
          break;
        case 'Favorites':
          // This would use stored favorites
          // For demo purposes, let's pick blogs with 'commentable' true as favorites
          filteredBlogs = filteredBlogs
              .where(
                (blog) =>
                    blog['commentable'] == true ||
                    blog['commentable'] == 'true',
              )
              .toList();
          break;
      }
    }

    return filteredBlogs;
  }

  Color _getBlogCardColor(int index) {
    // Create a sequence of pastel colors
    final colors = [
      const Color(0xFFE3F2FD), // Light Blue
      const Color(0xFFE8F5E9), // Light Green
      const Color(0xFFFFF3E0), // Light Orange
      const Color(0xFFF3E5F5), // Light Purple
      const Color(0xFFE0F7FA), // Light Cyan
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;
    final isMediumScreen = screenSize.width < 600;
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(111, 10, 15, 1),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Blogs',
              style: TextStyle(
                color: Colors.white,
                fontSize: isSmallScreen ? 18 : (isMediumScreen ? 20 : 22),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              '${blogs.length} blogs available',
              style: TextStyle(
                color: Colors.white70,
                fontSize: isSmallScreen ? 12 : (isMediumScreen ? 14 : 16),
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            height: 50,
            color: Colors.white,
            child: _buildFilterTabs(),
          ),
        ),
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _scrollController?.animateTo(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
          fetchBlogs();
        },
        backgroundColor: Color.fromRGBO(111, 10, 15, 1),
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: _filterOptions.length,
      itemBuilder: (context, index) {
        final option = _filterOptions[index];
        final isSelected = option == _selectedFilter;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedFilter = option;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isSelected
                      ? Color.fromRGBO(111, 10, 15, 1)
                      : Colors.transparent,
                  width: 3,
                ),
              ),
            ),
            child: Text(
              option,
              style: TextStyle(
                color: isSelected
                    ? Color.fromRGBO(111, 10, 15, 1)
                    : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: Color.fromRGBO(111, 10, 15, 1),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading blogs...',
              style: TextStyle(
                color: Color.fromRGBO(111, 10, 15, 1),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (errorMessage.isNotEmpty) {
      return _buildErrorView();
    }

    final filteredBlogs = _getFilteredBlogs();

    if (filteredBlogs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No blogs match your search',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try different search terms or filters',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ],
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation!,
      child: _buildBlogList(filteredBlogs),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              'https://cdn-icons-png.flaticon.com/512/6195/6195678.png',
              height: 120,
              width: 120,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.error_outline,
                color: Colors.redAccent,
                size: 80,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Oops! Something went wrong',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: Colors.redAccent),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              errorMessage,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.blueGrey[700]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: fetchBlogs,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                backgroundColor: Color.fromRGBO(111, 10, 15, 1),
                foregroundColor: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlogList(List<dynamic> blogs) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: blogs.length,
      itemBuilder: (context, index) {
        final blog = blogs[index];
        return AnimatedBuilder(
          animation: _animationController!,
          builder: (context, child) {
            final delay = index * 0.2;
            final startDelay = delay < 1.0 ? delay : 1.0;
            final endDelay = (startDelay + 0.4) <= 1.0
                ? (startDelay + 0.4)
                : 1.0; // Ensure end <= 1.0

            final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: _animationController!,
                curve: Interval(
                  startDelay,
                  endDelay, // Use the corrected endDelay
                  curve: Curves.easeOut,
                ),
              ),
            );
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.2, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildBlogCard(blog, index),
          ),
        );
      },
    );
  }

  Widget _buildBlogCard(dynamic blog, int index) {
    final hasArticles = blog['articles'] != null && blog['articles'].isNotEmpty;
    final articleCount = hasArticles ? blog['articles'].length : 0;
    final cardColor = _getBlogCardColor(index);

    return Card(
      elevation: 4,
      color: cardColor,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Blog Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color.fromRGBO(111, 10, 15, 1).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(111, 10, 15, 1).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.article,
                    color: Color.fromRGBO(111, 10, 15, 1),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        blog['title'] ?? 'Untitled Blog',
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.tag, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            blog['handle'] ?? 'Unknown',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _formatDate(blog['updated_at'] ?? ''),
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(
                      111,
                      10,
                      15,
                      1,
                    ).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$articleCount ${articleCount == 1 ? 'Article' : 'Articles'}',
                    style: TextStyle(
                      color: Color.fromRGBO(111, 10, 15, 1),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Blog Details
          ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            title: Text(
              'Blog Details',
              style: TextStyle(
                color: Color.fromRGBO(111, 10, 15, 1),
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              'ID: ${blog['id'] ?? 'N/A'} • Created: ${_formatDate(blog['created_at'] ?? '')}',
              style: const TextStyle(fontSize: 12),
            ),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [
              _buildInfoRow(
                icon: Icons.mode_comment,
                title: 'Comment',
                value: '${blog['commentable'] ?? 'N/A'}',
              ),
              _buildInfoRow(
                icon: Icons.tag,
                title: 'Tags',
                value: blog['tags'] ?? 'N/A',
              ),
              if (hasArticles) ...[
                const Divider(height: 24),
                Text(
                  'Articles',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Color.fromRGBO(111, 10, 15, 1),
                  ),
                ),
                const SizedBox(height: 12),
                ...blog['articles'].map<Widget>(
                  (article) => _buildArticleCard(article),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[700]),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Text(
              '$title:',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[800], fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleCard(dynamic article) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        title: Text(
          article['title'] ?? 'Untitled Article',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: Text(
          'ID: ${article['id']}',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          const Divider(height: 1),
          const SizedBox(height: 12),
          Text(
            _stripHtml(article['body_html'] ?? 'No content available'),
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 14,
              height: 1.5,
            ),
          ),
          if (article['body_html'] != null &&
              _stripHtml(article['body_html']).length > 150) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ArticleDetailScreen(article: article),
                    ),
                  );
                },
                child: const Text(
                  'Read More',
                  style: TextStyle(
                    color: Color.fromRGBO(
                      111,
                      10,
                      15,
                      1,
                    ), // Using the new color here
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ArticleDetailScreen extends StatelessWidget {
  final dynamic article;

  const ArticleDetailScreen({super.key, required this.article});

  String _stripHtml(String htmlString) {
    try {
      final document = parse(htmlString);
      return document.body?.text.trim() ?? htmlString;
    } catch (e) {
      return htmlString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(111, 10, 15, 1),
        title: Text(
          article['title'] ?? 'Article',
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              article['title'] ?? 'Untitled Article',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: const Color.fromRGBO(111, 10, 15, 1),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ID: ${article['id']}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            const Divider(height: 32),
            Text(
              _stripHtml(article['body_html'] ?? 'No content available'),
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
