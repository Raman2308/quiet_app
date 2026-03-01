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
    setState(() => _isLoading = true);

    final post = Post(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: _controller.text,
      createdAt: DateTime.now(),
    );

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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Post added successfully")),
        );
      },
    );

    setState(() => _isLoading = false);
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
              decoration: const InputDecoration(hintText: "Write something..."),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}
