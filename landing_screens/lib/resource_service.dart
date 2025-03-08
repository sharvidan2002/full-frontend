// resource_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Resource model
class Resource {
  final String id;
  final String title;
  final String description;
  final String type; // book, article, video, etc.
  final String thumbnailUrl;
  final String author;
  final String date;
  final String url; // URL to access the resource
  final List<String> tags;
  final bool isFavorite;

  Resource({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.thumbnailUrl,
    required this.author,
    required this.date,
    required this.url,
    this.tags = const [],
    this.isFavorite = false,
  });

  factory Resource.fromJson(Map<String, dynamic> json) {
    return Resource(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: json['type'],
      thumbnailUrl: json['thumbnailUrl'],
      author: json['author'],
      date: json['date'],
      url: json['url'],
      tags: List<String>.from(json['tags'] ?? []),
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'thumbnailUrl': thumbnailUrl,
      'author': author,
      'date': date,
      'url': url,
      'tags': tags,
      'isFavorite': isFavorite,
    };
  }

  Resource copyWith({
    String? id,
    String? title,
    String? description,
    String? type,
    String? thumbnailUrl,
    String? author,
    String? date,
    String? url,
    List<String>? tags,
    bool? isFavorite,
  }) {
    return Resource(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      author: author ?? this.author,
      date: date ?? this.date,
      url: url ?? this.url,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

class ResourceService {
  static const String _baseUrl = 'https://api.yourapp.com/resources'; // Replace with actual API
  static const String _favoritesKey = 'favorite_resources';

  // Fetch all resources
  static Future<List<Resource>> fetchAllResources() async {
    try {
      // In a real app, you would fetch from an API
      // final response = await http.get(Uri.parse('$_baseUrl/all'));

      // For now, return mock data
      await Future.delayed(const Duration(milliseconds: 800)); // Simulate network delay

      // Mock data
      final List<Resource> mockResources = [
        Resource(
          id: '1',
          title: 'Recovery Strategies for Substance Use',
          description: 'A comprehensive guide on effective recovery methods and coping strategies for addiction. This book provides practical advice and evidence-based approaches to build a sustainable recovery path.',
          type: 'book',
          thumbnailUrl: 'assets/images/book_recovery.jpg',
          author: 'Dr. Sarah Johnson',
          date: '2023',
          url: 'https://example.com/book1',
          tags: ['recovery', 'strategies', 'substance-use'],
        ),
        Resource(
          id: '2',
          title: 'Mindfulness Meditation for Recovery',
          description: 'Learn how mindfulness practices can support your recovery journey and promote wellness. This video tutorial guides you through simple, effective mindfulness techniques.',
          type: 'video',
          thumbnailUrl: 'assets/images/video_mindfulness.jpg',
          author: 'Michael Chang',
          date: '2024',
          url: 'https://example.com/video1',
          tags: ['mindfulness', 'meditation', 'wellness'],
        ),
        Resource(
          id: '3',
          title: 'Building a Support Network',
          description: 'This article explains how to create and maintain a supportive community during recovery. It includes tips for identifying supportive relationships and navigating difficult conversations.',
          type: 'article',
          thumbnailUrl: 'assets/images/article_support.jpg',
          author: 'Emma Wilson',
          date: 'March 2024',
          url: 'https://example.com/article1',
          tags: ['support', 'community', 'relationships'],
        ),
        Resource(
          id: '4',
          title: 'Healthy Habits: Nutrition and Exercise in Recovery',
          description: 'A guide to developing healthy physical habits that support sustained recovery. This comprehensive resource covers nutrition basics, meal planning, and exercise routines suitable for different stages of recovery.',
          type: 'book',
          thumbnailUrl: 'assets/images/book_habits.jpg',
          author: 'Dr. Robert Chen',
          date: '2022',
          url: 'https://example.com/book2',
          tags: ['nutrition', 'exercise', 'healthy-habits'],
        ),
        Resource(
          id: '5',
          title: 'Relapse Prevention Strategies',
          description: 'Evidence-based techniques to identify triggers and prevent relapse. This article provides practical tools for developing a personalized relapse prevention plan.',
          type: 'article',
          thumbnailUrl: 'assets/images/article_relapse.jpg',
          author: 'Jennifer Adams',
          date: 'January 2024',
          url: 'https://example.com/article2',
          tags: ['relapse-prevention', 'triggers', 'planning'],
        ),
        Resource(
          id: '6',
          title: 'Understanding the Science of Addiction',
          description: 'An informative podcast series exploring the neuroscience behind addiction and recovery. Each episode features expert interviews and the latest research findings.',
          type: 'podcast',
          thumbnailUrl: 'assets/images/podcast_science.jpg',
          author: 'Dr. David Liu',
          date: '2023',
          url: 'https://example.com/podcast1',
          tags: ['science', 'neuroscience', 'addiction'],
        ),
        Resource(
          id: '7',
          title: 'Recovery Journaling Techniques',
          description: 'Learn how therapeutic writing can aid in processing emotions and tracking progress during recovery. Includes journal prompts and guided exercises.',
          type: 'article',
          thumbnailUrl: 'assets/images/article_journaling.jpg',
          author: 'Lisa Parker',
          date: 'April 2024',
          url: 'https://example.com/article3',
          tags: ['journaling', 'reflection', 'emotional-processing'],
        ),
        Resource(
          id: '8',
          title: 'Coping with Cravings',
          description: 'A practical video guide demonstrating effective techniques for managing cravings and urges. Features real-life examples and expert advice.',
          type: 'video',
          thumbnailUrl: 'assets/images/video_cravings.jpg',
          author: 'James Wilson',
          date: '2023',
          url: 'https://example.com/video2',
          tags: ['cravings', 'coping-strategies', 'urges'],
        ),
      ];

      // Load favorites and update the mock data
      final favorites = await _getFavoriteResourceIds();
      return mockResources.map((resource) {
        return resource.copyWith(
          isFavorite: favorites.contains(resource.id),
        );
      }).toList();

    } catch (e) {
      print('Error fetching resources: $e');
      return [];
    }
  }

  // Search resources
  static Future<List<Resource>> searchResources(String query) async {
    try {
      // In a real app, you would search via an API
      // final response = await http.get(Uri.parse('$_baseUrl/search?q=$query'));

      // For now, filter the mock data
      final allResources = await fetchAllResources();

      if (query.isEmpty) {
        return allResources;
      }

      final lowercaseQuery = query.toLowerCase();
      return allResources.where((resource) =>
      resource.title.toLowerCase().contains(lowercaseQuery) ||
          resource.description.toLowerCase().contains(lowercaseQuery) ||
          resource.author.toLowerCase().contains(lowercaseQuery) ||
          resource.type.toLowerCase().contains(lowercaseQuery) ||
          resource.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery))
      ).toList();
    } catch (e) {
      print('Error searching resources: $e');
      return [];
    }
  }

  // Filter resources by type
  static Future<List<Resource>> filterResourcesByType(String type) async {
    try {
      final allResources = await fetchAllResources();

      if (type.isEmpty || type.toLowerCase() == 'all') {
        return allResources;
      }

      return allResources
          .where((resource) => resource.type.toLowerCase() == type.toLowerCase())
          .toList();
    } catch (e) {
      print('Error filtering resources: $e');
      return [];
    }
  }

  // Get resource by ID
  static Future<Resource?> getResourceById(String id) async {
    try {
      final allResources = await fetchAllResources();
      return allResources.firstWhere((resource) => resource.id == id);
    } catch (e) {
      print('Error getting resource by ID: $e');
      return null;
    }
  }

  // Get related resources
  static Future<List<Resource>> getRelatedResources(Resource resource) async {
    try {
      final allResources = await fetchAllResources();

      // Filter out the current resource
      final otherResources = allResources
          .where((r) => r.id != resource.id)
          .toList();

      // Find resources with matching tags
      if (resource.tags.isNotEmpty) {
        return otherResources
            .where((r) => r.tags.any((tag) => resource.tags.contains(tag)))
            .toList();
      }

      // If no tags, return resources of the same type
      return otherResources
          .where((r) => r.type == resource.type)
          .toList();
    } catch (e) {
      print('Error getting related resources: $e');
      return [];
    }
  }

  // Toggle favorite resource
  static Future<bool> toggleFavorite(String resourceId) async {
    try {
      final favorites = await _getFavoriteResourceIds();

      if (favorites.contains(resourceId)) {
        favorites.remove(resourceId);
      } else {
        favorites.add(resourceId);
      }

      await _saveFavoriteResourceIds(favorites);
      return favorites.contains(resourceId);
    } catch (e) {
      print('Error toggling favorite: $e');
      return false;
    }
  }

  // Get favorite resources
  static Future<List<Resource>> getFavoriteResources() async {
    try {
      final favorites = await _getFavoriteResourceIds();
      final allResources = await fetchAllResources();

      return allResources
          .where((resource) => favorites.contains(resource.id))
          .map((resource) => resource.copyWith(isFavorite: true))
          .toList();
    } catch (e) {
      print('Error getting favorite resources: $e');
      return [];
    }
  }

  // Get favorite resource IDs from local storage
  static Future<List<String>> _getFavoriteResourceIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoriteList = prefs.getStringList(_favoritesKey) ?? [];
      return favoriteList;
    } catch (e) {
      print('Error getting favorite resource IDs: $e');
      return [];
    }
  }

  // Save favorite resource IDs to local storage
  static Future<void> _saveFavoriteResourceIds(List<String> favoriteIds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_favoritesKey, favoriteIds);
    } catch (e) {
      print('Error saving favorite resource IDs: $e');
    }
  }
}