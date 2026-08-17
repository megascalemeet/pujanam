import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class RecentPurchaseNotification extends StatefulWidget {
  final String currentProductTitle;

  const RecentPurchaseNotification({
    super.key,
    required this.currentProductTitle,
  });

  @override
  State<RecentPurchaseNotification> createState() => _RecentPurchaseNotificationState();
}

class _RecentPurchaseNotificationState extends State<RecentPurchaseNotification> with TickerProviderStateMixin {
  OverlayEntry? _overlayEntry;
  Timer? _initialTimer;
  Timer? _periodicTimer;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  final List<Map<String, String>> _fakeData = [
    {'city': 'Delhi', 'time': 'just now'},
    {'city': 'Mumbai', 'time': '5 minutes ago'},
    {'city': 'Ahmedabad', 'time': '8 minutes ago'},
    {'city': 'Surat', 'time': '12 minutes ago'},
    {'city': 'Bangalore', 'time': '18 minutes ago'},
    {'city': 'Jaipur', 'time': '22 minutes ago'},
    {'city': 'Pune', 'time': '28 minutes ago'},
    {'city': 'Chennai', 'time': '35 minutes ago'},
    {'city': 'Hyderabad', 'time': '42 minutes ago'},
    {'city': 'Kolkata', 'time': '50 minutes ago'},
  ];

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));

    _initialTimer = Timer(
      Duration(seconds: 8 + Random().nextInt(5)),
      _showNotification,
    );

    _periodicTimer = Timer.periodic(
      Duration(seconds: 35 + Random().nextInt(25)),
      (timer) {
        if (mounted && _overlayEntry == null) {
          _showNotification();
        }
      },
    );
  }

  void _showNotification() {
    if (!mounted || _overlayEntry != null) return;

    final data = (_fakeData..shuffle()).first;
    final city = data['city']!;
    final time = data['time']!;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 100,
        left: 16,
        right: 16,
        child: SlideTransition(
          position: _slideAnimation,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: _hideNotification,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color.fromRGBO(111, 10, 15, 0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromRGBO(111, 10, 15, 0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color.fromRGBO(111, 10, 15, 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: Color.fromRGBO(111, 10, 15, 1),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Someone in $city just bought',
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            widget.currentProductTitle,
                            style: const TextStyle(
                              color: Color.fromRGBO(111, 10, 15, 1),
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            time,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                      onPressed: _hideNotification,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (mounted) {
      Overlay.of(context).insert(_overlayEntry!);
      _slideController.forward();
    }

    Timer(const Duration(seconds: 6), _hideNotification);
  }

  void _hideNotification() {
    _slideController.reverse().then((_) {
      if (mounted) {
        _removeOverlay();
      }
    });
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _initialTimer?.cancel();
    _periodicTimer?.cancel();
    _slideController.dispose();
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
