//! ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnnouncementsPage extends StatefulWidget {
  const AnnouncementsPage({super.key});

  @override
  State<AnnouncementsPage> createState() => _AnnouncementsPageState();
}

class _AnnouncementsPageState extends State<AnnouncementsPage> {
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  bool _isLoading = true;
  List<Announcement> _announcements = [];

  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
  }

  Future<void> _loadAnnouncements() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance
              .collection('announcements')
              .orderBy('date', descending: true)
              .get();

      final List<Announcement> loadedAnnouncements = [];

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        // Convert Timestamp to DateTime
        final date =
            data['date'] is Timestamp
                ? (data['date'] as Timestamp).toDate()
                : DateTime.now();

        loadedAnnouncements.add(
          Announcement(
            id: doc.id,
            title: data['title'] ?? 'Untitled',
            content: data['content'] ?? '',
            date: date,
            category: data['category'] ?? 'General',
            isUrgent: data['isUrgent'] ?? false,
          ),
        );
      }

      setState(() {
        _announcements = loadedAnnouncements;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading announcements: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<String> get _categories {
    final Set<String> categories = {'All'};
    for (var announcement in _announcements) {
      categories.add(announcement.category);
    }
    return categories.toList();
  }

  List<Announcement> get _filteredAnnouncements {
    return _announcements.where((announcement) {
      final matchesFilter =
          _selectedFilter == 'All' || announcement.category == _selectedFilter;
      final matchesSearch =
          _searchController.text.isEmpty ||
          announcement.title.toLowerCase().contains(
            _searchController.text.toLowerCase(),
          ) ||
          announcement.content.toLowerCase().contains(
            _searchController.text.toLowerCase(),
          );
      return matchesFilter && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Column(children: [_buildSearchBar(), _buildFilterChips()]),
          ),
          _isLoading
              ? SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: Colors.red.shade900),
                ),
              )
              : _buildAnnouncementsList(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to admin panel for announcement creation
          Navigator.pop(context);
        },
        backgroundColor: Colors.red.shade900,
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        label: const Text('Back', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      backgroundColor: Colors.red.shade900,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: const Text(
          'Announcements',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Colors.red.shade800, Colors.red.shade900],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -50,
                top: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            _isSearching ? Icons.close : Icons.search,
            color: Colors.white,
          ),
          onPressed: () {
            setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) {
                _searchController.clear();
              }
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.filter_list, color: Colors.white),
          onPressed: () {
            // Add additional filter options
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSearchBar() {
    if (!_isSearching) return const SizedBox.shrink();

    return FadeInDown(
      duration: const Duration(milliseconds: 300),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search announcements...',
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear, color: Colors.grey),
              onPressed: () {
                _searchController.clear();
                setState(() {});
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: Colors.red.shade900),
            ),
          ),
          onChanged: (value) => setState(() {}),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: _selectedFilter == category,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = selected ? category : 'All';
                });
              },
              backgroundColor: Colors.white,
              selectedColor: Colors.red.shade50,
              checkmarkColor: Colors.red.shade900,
              labelStyle: TextStyle(
                color:
                    _selectedFilter == category
                        ? Colors.red.shade900
                        : Colors.black87,
                fontWeight:
                    _selectedFilter == category
                        ? FontWeight.bold
                        : FontWeight.normal,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color:
                      _selectedFilter == category
                          ? Colors.red.shade900
                          : Colors.grey.shade300,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnnouncementsList() {
    if (_filteredAnnouncements.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.announcement_outlined,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No announcements found',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try adjusting your filters or search terms',
                style: TextStyle(fontSize: 16, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: OutlinedButton(
                onPressed: _loadAnnouncements,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red.shade900,
                  side: BorderSide(color: Colors.red.shade900),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.refresh),
                    SizedBox(width: 8),
                    Text('Refresh Announcements'),
                  ],
                ),
              ),
            );
          }

          final announcement = _filteredAnnouncements[index - 1];
          return FadeInUp(
            duration: Duration(milliseconds: 300 + (index * 100)),
            child: _buildAnnouncementCard(announcement),
          );
        }, childCount: _filteredAnnouncements.length + 1),
      ),
    );
  }

  Widget _buildAnnouncementCard(Announcement announcement) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showAnnouncementDetails(announcement),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.announcement,
                          color:
                              announcement.isUrgent
                                  ? Colors.red
                                  : Colors.red.shade900,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            announcement.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      announcement.category,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                announcement.content,
                style: TextStyle(fontSize: 14, color: Colors.black54),
                textAlign: TextAlign.right,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              Text(
                _formatDate(announcement.date),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAnnouncementDetails(Announcement announcement) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.red.shade900,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  announcement.isUrgent
                                      ? Icons.warning
                                      : Icons.info_outline,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  announcement.category,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        announcement.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatDate(announcement.date),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (announcement.isUrgent)
                          Container(
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.warning, color: Colors.red.shade900),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'This is an urgent announcement that requires immediate attention',
                                    style: TextStyle(
                                      color: Colors.red.shade900,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Text(
                          announcement.content,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.6,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM d, y').format(date);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class Announcement {
  final String id;
  final String title;
  final String content;
  final DateTime date;
  final String category;
  final bool isUrgent;

  Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.category,
    this.isUrgent = false,
  });
}
