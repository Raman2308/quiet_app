import 'package:flutter/material.dart';

import 'package:app_quiet/features/quiet/domain/entities/post.dart';
import 'package:app_quiet/features/quiet/domain/repositories/post_repository.dart';

import 'package:app_quiet/core/logger/logger.dart';

class WritingScreen extends StatefulWidget {
  final PostRepository postRepository;
  final Logger logger;

  const WritingScreen({
    super.key,
    required this.postRepository,
    required this.logger,
  });

  @override
  State<WritingScreen> createState() => _WritingScreenState();
}

class _WritingScreenState extends State<WritingScreen> {
  final TextEditingController _controller = TextEditingController();

  bool _isLoading = false;

  Future<void> _submit() async {
    final content = _controller.text.trim();

    /// Validation
    if (content.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Post cannot be empty")));
      return;
    }

    setState(() => _isLoading = true);

    /// Create Post entity using factory
    final post = Post.create(content);

    final result = await widget.postRepository.addPost(post);

    result.fold(
      (failure) {
        widget.logger.error("WritingScreen | Failure | ${failure.message}");

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.message)));
      },
      (_) {
        widget.logger.info("WritingScreen | Success");

        _controller.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Post added successfully")),
        );
      },
    );

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Write Post")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: "Write something...",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Submit"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
