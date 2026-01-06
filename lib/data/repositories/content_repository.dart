import '../models/banner_model.dart';
import '../models/blog_model.dart';
import '../models/faq_model.dart';

class ContentRepository {
  // Mock data
  final List<Banner> _banners = List.generate(3, (i) => Banner(id: 'B${i+1}', title: 'Banner ${i+1}', isActive: i.isEven));
  final List<Blog> _blogs = List.generate(5, (i) => Blog(id: 'BL${i+1}', title: 'Blog Post ${i+1}', isPublished: i.isEven));
  final List<Faq> _faqs = List.generate(7, (i) => Faq(id: 'F${i+1}', question: 'FAQ Question ${i+1}?', answer: 'This is the answer to question ${i+1}.'));

  // Banner methods
  Future<List<Banner>> getBanners() async => _banners;
  Future<void> addBanner(Banner banner) async => _banners.add(banner);
  Future<void> updateBanner(Banner banner) async {
    final index = _banners.indexWhere((b) => b.id == banner.id);
    if (index != -1) _banners[index] = banner;
  }
  Future<void> deleteBanner(String id) async => _banners.removeWhere((b) => b.id == id);

  // Blog methods
  Future<List<Blog>> getBlogs() async => _blogs;
  Future<void> addBlog(Blog blog) async => _blogs.add(blog);
  Future<void> updateBlog(Blog blog) async {
    final index = _blogs.indexWhere((b) => b.id == blog.id);
    if (index != -1) _blogs[index] = blog;
  }
  Future<void> deleteBlog(String id) async => _blogs.removeWhere((b) => b.id == id);

  // FAQ methods
  Future<List<Faq>> getFaqs() async => _faqs;
  Future<void> addFaq(Faq faq) async => _faqs.add(faq);
  Future<void> updateFaq(Faq faq) async {
    final index = _faqs.indexWhere((f) => f.id == faq.id);
    if (index != -1) _faqs[index] = faq;
  }
  Future<void> deleteFaq(String id) async => _faqs.removeWhere((f) => f.id == id);
}
