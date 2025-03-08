// resources_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Resource model
class Resource {
  final String id;
  final String title;
  final String description;
  final String type; // book, article, video, etc.
  final String thumbnailUrl;
  final String author;
  final String date;

  Resource({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.thumbnailUrl,
    required this.author,
    required this.date,
  });
}

class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({Key? key}) : super(key: key);

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = false;
  List<Resource> _resources = [];

  @override
  void initState() {
    super.initState();
    _loadInitialResources();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Load initial resources
  Future<void> _loadInitialResources() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate loading resources from API or database
    await Future.delayed(const Duration(milliseconds: 800));

    // Mock data - replace with actual data fetching in production
    _resources = [
      Resource(
        id: '1',
        title: 'Recovery Strategies for Substance Use',
        description: 'A comprehensive guide on effective recovery methods and coping strategies for addiction.',
        type: 'book',
        thumbnailUrl: 'assets/images/book_recovery.jpg', // Replace with actual path
        author: 'Dr. Sarah Johnson',
        date: '2023',
      ),
      Resource(
        id: '2',
        title: 'Mindfulness Meditation for Recovery',
        description: 'Learn how mindfulness practices can support your recovery journey and promote wellness.',
        type: 'video',
        thumbnailUrl: 'assets/images/video_mindfulness.jpg', // Replace with actual path
        author: 'Michael Chang',
        date: '2024',
      ),
      Resource(
        id: '3',
        title: 'Building a Support Network',
        description: 'This article explains how to create and maintain a supportive community during recovery.',
        type: 'article',
        thumbnailUrl: 'assets/images/article_support.jpg', // Replace with actual path
        author: 'Emma Wilson',
        date: 'March 2024',
      ),
      Resource(
        id: '4',
        title: 'Healthy Habits: Nutrition and Exercise in Recovery',
        description: 'A guide to developing healthy physical habits that support sustained recovery.',
        type: 'book',
        thumbnailUrl: 'assets/images/book_habits.jpg', // Replace with actual path
        author: 'Dr. Robert Chen',
        date: '2022',
      ),
      Resource(
        id: '5',
        title: 'Relapse Prevention Strategies',
        description: 'Evidence-based techniques to identify triggers and prevent relapse.',
        type: 'article',
        thumbnailUrl: 'assets/images/article_relapse.jpg', // Replace with actual path
        author: 'Jennifer Adams',
        date: 'January 2024',
      ),
    ];

    setState(() {
      _isLoading = false;
    });
  }

  // Search for resources
  Future<void> _searchResources(String query) async {
    setState(() {
      _searchQuery = query;
      _isLoading = true;
    });

    // Simulate API call with delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Filter resources based on query
    if (query.isEmpty) {
      await _loadInitialResources();
    } else {
      setState(() {
        _resources = _resources
            .where((resource) =>
        resource.title.toLowerCase().contains(query.toLowerCase()) ||
            resource.description.toLowerCase().contains(query.toLowerCase()) ||
            resource.author.toLowerCase().contains(query.toLowerCase()) ||
            resource.type.toLowerCase().contains(query.toLowerCase()))
            .toList();
        _isLoading = false;
      });
    }
  }

  // Get icon for resource type
  IconData _getIconForResourceType(String type) {
    switch (type.toLowerCase()) {
      case 'book':
        return Icons.book;
      case 'article':
        return Icons.article;
      case 'video':
        return Icons.video_library;
      case 'podcast':
        return Icons.headset;
      case 'website':
        return Icons.language;
      default:
        return Icons.description;
    }
  }

  // Get color for resource type
  Color _getColorForResourceType(String type) {
    switch (type.toLowerCase()) {
      case 'book':
        return const Color(0xFF6E77F6); // Primary color from your UI
      case 'article':
        return Colors.teal;
      case 'video':
        return Colors.red.shade700;
      case 'podcast':
        return Colors.purple;
      case 'website':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Resources',
          style: TextStyle(
            color: Color(0xFF6E77F6), // Primary color from your UI
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        // leading: IconButton(
        //   icon: const Icon(
        //     Icons.arrow_back_ios,
        //     color: Color(0xFF6E77F6), // Primary color from your UI
        //   ),
        //   onPressed: () => Navigator.pop(context),
        // ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search for resources...',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey[600],
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: Colors.grey[600],
                      ),
                      onPressed: () {
                        _searchController.clear();
                        _searchResources('');
                      },
                    )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                  ),
                  onChanged: (value) => _searchResources(value),
                ),
              ),

              const SizedBox(height: 20),

              // Resource Categories
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCategoryChip('All', true),
                    _buildCategoryChip('Books', false),
                    _buildCategoryChip('Articles', false),
                    _buildCategoryChip('Videos', false),
                    _buildCategoryChip('Podcasts', false),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Results heading
              Text(
                _searchQuery.isEmpty ? 'Recommended Resources' : 'Search Results',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 12),

              // Results list
              Expanded(
                child: _isLoading
                    ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF6E77F6), // Primary color from your UI
                  ),
                )
                    : _resources.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No resources found',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  itemCount: _resources.length,
                  itemBuilder: (context, index) {
                    final resource = _resources[index];
                    return _buildResourceCard(resource);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        backgroundColor: Colors.grey[200],
        selectedColor: const Color(0xFF6E77F6), // Primary color from your UI
        selected: isSelected,
        onSelected: (selected) {
          // Implement category filtering
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildResourceCard(Resource resource) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to resource detail screen
          // Navigator.push(context, MaterialPageRoute(builder: (context) => ResourceDetailScreen(resource: resource)));
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 80,
                  height: 100,
                  color: Colors.grey[200],
                  child: resource.thumbnailUrl.startsWith('assets/')
                      ? Image.asset(
                    'placeholder.jpg', // Use placeholder for now
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(
                          _getIconForResourceType(resource.type),
                          size: 36,
                          color: _getColorForResourceType(resource.type),
                        ),
                      );
                    },
                  )
                      : Image.network(
                    resource.thumbnailUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(
                          _getIconForResourceType(resource.type),
                          size: 36,
                          color: _getColorForResourceType(resource.type),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Resource Type Chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getColorForResourceType(resource.type).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        resource.type.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _getColorForResourceType(resource.type),
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Title
                    Text(
                      resource.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // Author and Date
                    Text(
                      '${resource.author} • ${resource.date}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Description
                    Text(
                      resource.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[800],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Additional screens needed for resource functionality

// Resource Detail Screen
class ResourceDetailScreen extends StatelessWidget {
  final Resource resource;

  const ResourceDetailScreen({Key? key, required this.resource}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          resource.type.capitalize(),
          style: const TextStyle(
            color: Color(0xFF6E77F6), // Primary color from your UI
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color(0xFF6E77F6), // Primary color from your UI
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.share,
              color: Color(0xFF6E77F6), // Primary color from your UI
            ),
            onPressed: () {
              // Implement share functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resource image/thumbnail
            Container(
              width: double.infinity,
              height: 200,
              color: Colors.grey[200],
              child: resource.thumbnailUrl.startsWith('assets/')
                  ? Image.asset(
                'placeholder.jpg', // Use placeholder for now
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Icon(
                      _getIconForResourceType(resource.type),
                      size: 80,
                      color: _getColorForResourceType(resource.type),
                    ),
                  );
                },
              )
                  : Image.network(
                resource.thumbnailUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Icon(
                      _getIconForResourceType(resource.type),
                      size: 80,
                      color: _getColorForResourceType(resource.type),
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Resource Type Chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getColorForResourceType(resource.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      resource.type.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getColorForResourceType(resource.type),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Title
                  Text(
                    resource.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Author and Date
                  Text(
                    '${resource.author} • ${resource.date}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Description
                  Text(
                    resource.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[800],
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Implement access resource
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6E77F6), // Primary color from your UI
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            _getAccessButtonText(resource.type),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: () {
                          // Implement save for later
                        },
                        icon: Icon(
                          Icons.bookmark_border,
                          color: Colors.grey[700],
                          size: 30,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Related resources
                  const Text(
                    'Related Resources',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Related resources list - mocked for now
                  // In a real app, you'd fetch related resources based on tags or categories
                  const Text(
                    'No related resources found',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getAccessButtonText(String type) {
    switch (type.toLowerCase()) {
      case 'book':
        return 'READ NOW';
      case 'article':
        return 'READ ARTICLE';
      case 'video':
        return 'WATCH VIDEO';
      case 'podcast':
        return 'LISTEN NOW';
      case 'website':
        return 'VISIT WEBSITE';
      default:
        return 'ACCESS RESOURCE';
    }
  }

  IconData _getIconForResourceType(String type) {
    switch (type.toLowerCase()) {
      case 'book':
        return Icons.book;
      case 'article':
        return Icons.article;
      case 'video':
        return Icons.video_library;
      case 'podcast':
        return Icons.headset;
      case 'website':
        return Icons.language;
      default:
        return Icons.description;
    }
  }

  Color _getColorForResourceType(String type) {
    switch (type.toLowerCase()) {
      case 'book':
        return const Color(0xFF6E77F6); // Primary color from your UI
      case 'article':
        return Colors.teal;
      case 'video':
        return Colors.red.shade700;
      case 'podcast':
        return Colors.purple;
      case 'website':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}

// Extension to capitalize first letter of a string
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}