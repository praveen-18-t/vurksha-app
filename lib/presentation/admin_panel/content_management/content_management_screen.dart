import 'package:flutter/material.dart';
import '../../../../data/models/banner_model.dart' as models;
import '../../../../data/models/blog_model.dart' as models;
import '../../../../data/models/faq_model.dart' as models;
import '../../../../data/repositories/content_repository.dart';

class ContentManagementScreen extends StatefulWidget {
  const ContentManagementScreen({super.key});

  @override
  State<ContentManagementScreen> createState() => _ContentManagementScreenState();
}

class _ContentManagementScreenState extends State<ContentManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ContentRepository _contentRepository = ContentRepository();

  late Future<List<models.Banner>> _bannersFuture;
  late Future<List<models.Blog>> _blogsFuture;
  late Future<List<models.Faq>> _faqsFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchContent();
  }

  void _fetchContent() {
    setState(() {
      _bannersFuture = _contentRepository.getBanners();
      _blogsFuture = _contentRepository.getBlogs();
      _faqsFuture = _contentRepository.getFaqs();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Content Management', style: theme.textTheme.headlineMedium),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Banners'), Tab(text: 'Blogs'), Tab(text: 'FAQs')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFutureList<models.Banner>(_bannersFuture, _buildBannerList),
          _buildFutureList<models.Blog>(_blogsFuture, _buildBlogList),
          _buildFutureList<models.Faq>(_faqsFuture, _buildFaqList),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddButtonPressed,
        tooltip: 'Add Content',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFutureList<T>(Future<List<T>> future, Widget Function(List<T>) builder) {
    return FutureBuilder<List<T>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No content found.'));
        }
        return builder(snapshot.data!);},
    );
  }

  // Banner List
  Widget _buildBannerList(List<models.Banner> items) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          title: Text(item.title),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            Switch(value: item.isActive, onChanged: (val) async {
              await _contentRepository.updateBanner(models.Banner(id: item.id, title: item.title, isActive: val));
              _fetchContent();
            }),
            IconButton(icon: const Icon(Icons.delete), onPressed: () async {
              await _contentRepository.deleteBanner(item.id);
              _fetchContent();
            }),
          ]),
        );
      },
    );
  }

  // Blog List
  Widget _buildBlogList(List<models.Blog> items) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          title: Text(item.title),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            Switch(value: item.isPublished, onChanged: (val) async {
              await _contentRepository.updateBlog(models.Blog(id: item.id, title: item.title, isPublished: val));
              _fetchContent();
            }),
            IconButton(icon: const Icon(Icons.delete), onPressed: () async {
              await _contentRepository.deleteBlog(item.id);
              _fetchContent();
            }),
          ]),
        );
      },
    );
  }

  // FAQ List
  Widget _buildFaqList(List<models.Faq> items) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          title: Text(item.question),
          subtitle: Text(item.answer),
          trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () async {
            await _contentRepository.deleteFaq(item.id);
            _fetchContent();
          }),
        );
      },
    );
  }

  void _onAddButtonPressed() {
    // For simplicity, we'll just add a new banner for now.
    // A more complete implementation would show a dialog based on the current tab.
    _showAddBannerDialog();
  }

  void _showAddBannerDialog() {
    final formKey = GlobalKey<FormState>();
    String title = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Banner'),
        content: Form(
          key: formKey,
          child: TextFormField(
            decoration: const InputDecoration(labelText: 'Banner Title'),
            validator: (val) => val!.isEmpty ? 'Title is required' : null,
            onSaved: (val) => title = val!,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                await _contentRepository.addBanner(models.Banner(id: 'B${DateTime.now().millisecond}', title: title, isActive: true));
                _fetchContent();
                if (!context.mounted) return;
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
