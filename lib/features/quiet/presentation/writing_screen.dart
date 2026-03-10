import 'package:app_quiet/features/auth/presentation/controllers/auth_controller.dart';
import 'package:app_quiet/features/quiet/domain/usecases/publish_post.dart';
import 'package:flutter/material.dart';

import 'package:app_quiet/features/quiet/domain/entities/post.dart';

import 'package:app_quiet/core/logger/logger.dart';
import 'package:provider/provider.dart';

class WritingScreen extends StatefulWidget {
  final PublishPost publishPost;
  final Logger logger;

  const WritingScreen({
    super.key,
    required this.publishPost,
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

    if (content.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Post cannot be empty")));
      return;
    }

    setState(() => _isLoading = true);

    final post = Post.create(_controller.text.trim());
    try {
      final result = await widget.publishPost(post);

      result.fold(
        (failure) {
          widget.logger.error(failure.message);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(failure.message)));
        },
        (_) {
          _controller.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Post added successfully")),
          );
        },
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                final controller = context.read<AuthController>();

                await controller.logout();
              },
            ),

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
