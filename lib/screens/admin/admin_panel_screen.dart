import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/data_film.dart';
import '../../models/movie_models.dart';
import '../../providers/movie_provider.dart';
import '../../services/firestore_service.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        title: const Text(
          'Admin Panel',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Tambah Film',
            onPressed: () => _showAddMovieDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
            onPressed: () async {
              await authState.logout();
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Consumer<MovieProvider>(
        builder: (context, provider, _) {
          if (provider.movies.isEmpty) {
            return const Center(
              child: Text('Belum ada film', style: TextStyle(color: Colors.grey)),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.movies.length,
            itemBuilder: (context, i) {
              final movie = provider.movies[i];
              return _MovieAdminCard(movie: movie);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddMovieDialog(context),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Film'),
      ),
    );
  }

  void _showAddMovieDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _AddMovieSheet(),
    );
  }
}

class _MovieAdminCard extends StatelessWidget {
  final MovieModel movie;
  const _MovieAdminCard({required this.movie});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: movie.imagePath.startsWith('http')
              ? Image.network(
                  movie.imagePath,
                  width: 50,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, e, stack) => _posterPlaceholder(),
                )
              : Image.asset(
                  movie.imagePath,
                  width: 50,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, e, stack) => _posterPlaceholder(),
                ),
        ),
        title: Text(
          movie.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${movie.genre} • ${movie.year} • ⭐ ${movie.rating}',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
          onPressed: () => _confirmDelete(context),
        ),
      ),
    );
  }

  Widget _posterPlaceholder() {
    return Container(
      width: 50,
      height: 70,
      color: const Color(0xFF1A237E).withValues(alpha: 0.1),
      child: const Icon(Icons.movie_outlined, color: Colors.grey),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Film'),
        content: Text('Hapus "${movie.title}" dari daftar film?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await FirestoreService().deleteMovie(movie.title);
                if (context.mounted) {
                  context.read<MovieProvider>().loadMovies();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('"${movie.title}" berhasil dihapus'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal menghapus: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

class _AddMovieSheet extends StatefulWidget {
  const _AddMovieSheet();

  @override
  State<_AddMovieSheet> createState() => _AddMovieSheetState();
}

class _AddMovieSheetState extends State<_AddMovieSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _genreCtrl = TextEditingController();
  final _synopsisCtrl = TextEditingController();
  final _durationCtrl = TextEditingController(text: '120 min');
  final _yearCtrl = TextEditingController();
  final _ageRatingCtrl = TextEditingController(text: 'SU');
  final _imagePathCtrl = TextEditingController();
  final _trailerPathCtrl = TextEditingController();
  final _castCtrl = TextEditingController();
  double _rating = 7.5;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _genreCtrl.dispose();
    _synopsisCtrl.dispose();
    _durationCtrl.dispose();
    _yearCtrl.dispose();
    _ageRatingCtrl.dispose();
    _imagePathCtrl.dispose();
    _trailerPathCtrl.dispose();
    _castCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final movie = MovieModel(
      title: _titleCtrl.text.trim(),
      genre: _genreCtrl.text.trim(),
      synopsis: _synopsisCtrl.text.trim(),
      duration: _durationCtrl.text.trim(),
      year: _yearCtrl.text.trim(),
      ageRating: _ageRatingCtrl.text.trim(),
      imagePath: _imagePathCtrl.text.trim(),
      trailerPath: _trailerPathCtrl.text.trim().isEmpty
          ? null
          : _trailerPathCtrl.text.trim(),
      cast: _castCtrl.text.trim(),
      rating: _rating,
    );

    try {
      await FirestoreService().addMovie(movie);
      if (mounted) {
        context.read<MovieProvider>().loadMovies();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${movie.title}" berhasil ditambahkan!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      maxChildSize: 0.97,
      minChildSize: 0.5,
      expand: false,
      builder: (_, scrollCtrl) => Form(
        key: _formKey,
        child: ListView(
          controller: scrollCtrl,
          padding: EdgeInsets.fromLTRB(
            20,
            16,
            20,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text(
              'Tambah Film Baru',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A237E),
              ),
            ),
            const SizedBox(height: 20),

            _buildField(_titleCtrl, 'Judul Film *', Icons.movie_outlined, required: true),
            const SizedBox(height: 12),
            _buildField(_genreCtrl, 'Genre (pisah koma) *', Icons.category_outlined, required: true),
            const SizedBox(height: 12),
            _buildField(
              _synopsisCtrl,
              'Sinopsis *',
              Icons.description_outlined,
              required: true,
              maxLines: 4,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildField(_durationCtrl, 'Durasi', Icons.timer_outlined)),
                const SizedBox(width: 12),
                Expanded(child: _buildField(_yearCtrl, 'Tahun', Icons.calendar_today_outlined)),
                const SizedBox(width: 12),
                Expanded(child: _buildField(_ageRatingCtrl, 'Rating Usia', Icons.shield_outlined)),
              ],
            ),
            const SizedBox(height: 16),

            // Rating slider
            Row(
              children: [
                const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Rating: ${_rating.toStringAsFixed(1)}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            Slider(
              value: _rating,
              min: 0,
              max: 10,
              divisions: 100,
              activeColor: const Color(0xFF1A237E),
              onChanged: (v) => setState(() => _rating = v),
            ),
            const SizedBox(height: 4),

            _buildField(
              _imagePathCtrl,
              'URL Poster (GitHub CDN) *',
              Icons.image_outlined,
              required: true,
              hint: 'https://cdn.jsdelivr.net/gh/...',
            ),
            const SizedBox(height: 12),
            _buildField(
              _trailerPathCtrl,
              'URL Trailer (opsional)',
              Icons.play_circle_outline,
              hint: 'https://cdn.jsdelivr.net/gh/...',
            ),
            const SizedBox(height: 12),
            _buildField(_castCtrl, 'Pemeran (pisah koma)', Icons.people_outline),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.save_rounded),
                label: Text(_isSaving ? 'Menyimpan...' : 'Simpan Film'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    bool required = false,
    int maxLines = 1,
    String? hint,
  }) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF1A237E), size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1A237E), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      validator: required
          ? (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null
          : null,
    );
  }
}
