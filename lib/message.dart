import 'package:flutter/material.dart';
import 'package:genui/genui.dart';

class MessageController {
  MessageController({this.text, this.surfaceId, this.isUser = false})
    : assert((surfaceId == null) != (text == null));

  final String? text;
  final String? surfaceId;
  final bool isUser;
}

class MessageView extends StatefulWidget {
  const MessageView(this.controller, this.host, {super.key});

  final MessageController controller;
  final GenUiHost host;

  @override
  State<MessageView> createState() => _MessageViewState();
}

class _MessageViewState extends State<MessageView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String? surfaceId = widget.controller.surfaceId;
    final bool isUser = widget.controller.isUser;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.85,
            ),
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: surfaceId != null
                ? EdgeInsets.zero
                : const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: surfaceId != null
                ? null
                : BoxDecoration(
                    color: isUser
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: isUser
                          ? const Radius.circular(20)
                          : const Radius.circular(4),
                      bottomRight: isUser
                          ? const Radius.circular(4)
                          : const Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
            child: surfaceId != null
                ? GenUiSurface(host: widget.host, surfaceId: surfaceId)
                : Text(
                    widget.controller.text ?? '',
                    style: TextStyle(
                      color: isUser ? Colors.white : null,
                      fontSize: 16,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
