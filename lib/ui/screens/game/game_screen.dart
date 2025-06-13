import 'dart:math';
import 'package:english_connect/core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  // Danh sách các từ cho nhiều level
  final List<String> words = [
    "HELLO",
    "WORLD",
    "FLUTTER",
    "MOBILE",
    "CODING",
    "GAME",
    "LEVEL",
    "SMART",
    "BRAIN",
    "PUZZLE",
  ];

  int currentLevel = 0;
  late String correctWord;
  late List<String> letters;
  final List<Offset> points = [];
  final List<int> selectedIndexes = [];

  final Map<int, GlobalKey> keyMap = {};

  Offset? currentDragPosition;

  // Animation controllers
  late AnimationController _celebrationController;
  late AnimationController _shakeController;
  late Animation<double> _celebrationAnimation;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeLevel();
    _setupAnimations();
  }

  void _initializeLevel() {
    correctWord = words[currentLevel];
    letters = correctWord.split('')..shuffle();
    keyMap.clear();
    for (var i = 0; i < letters.length; i++) {
      keyMap[i] = GlobalKey();
    }
  }

  void _setupAnimations() {
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _celebrationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _celebrationController, curve: Curves.elasticOut),
    );

    _shakeAnimation = Tween<double>(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticInOut),
    );
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _playSuccessSound() {
    HapticFeedback.lightImpact();
    // Rung nhẹ khi thành công
  }

  void _playErrorSound() {
    HapticFeedback.heavyImpact();
    // Rung mạnh khi sai
  }

  void _showSuccessPopup(String result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.celebration, color: Colors.orange, size: 30),
                SizedBox(width: 10),
                Text("Xuất sắc!", style: TextStyle(color: Colors.green)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Bạn đã tìm đúng từ: $result",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  "Level ${currentLevel + 1} hoàn thành!",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            actions: [
              if (currentLevel < words.length - 1)
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _nextLevel();
                  },
                  child: const Text("Level tiếp theo"),
                ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _resetCurrentLevel();
                },
                child: Text(
                  currentLevel < words.length - 1 ? "Chơi lại" : "Chơi từ đầu",
                ),
              ),
            ],
          ),
    );
  }

  void _showErrorPopup(String result) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.close, color: Colors.red, size: 30),
                SizedBox(width: 10),
                Text("Thử lại!", style: TextStyle(color: Colors.red)),
              ],
            ),
            content: Text(
              "Bạn đã chọn: $result\nHãy thử lại!",
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _resetCurrentLevel();
                },
                child: const Text("Thử lại"),
              ),
            ],
          ),
    );
  }

  void _nextLevel() {
    setState(() {
      currentLevel = (currentLevel + 1) % words.length;
      selectedIndexes.clear();
      points.clear();
      _initializeLevel();
    });
  }

  void _resetCurrentLevel() {
    setState(() {
      selectedIndexes.clear();
      points.clear();
      letters = correctWord.split('')..shuffle();
    });
  }

  List<Widget> _buildLetterCircle(Size screenSize) {
    final double radius = min(screenSize.width, screenSize.height) * 0.25;
    final center = Offset(screenSize.width / 2, (screenSize.height - 100) / 2);
    final circleSize = 60.0;

    final startAngle = -pi / 2;
    final angleStep = 2 * pi / letters.length;

    return List.generate(letters.length, (i) {
      final angle = startAngle + angleStep * i;
      final dx = center.dx + radius * cos(angle);
      final dy = center.dy + radius * sin(angle);

      return AnimatedBuilder(
        animation: _celebrationAnimation,
        builder: (context, child) {
          final scale =
              selectedIndexes.contains(i)
                  ? 1.0 + (_celebrationAnimation.value * 0.3)
                  : 1.0;
          return AnimatedBuilder(
            animation: _shakeAnimation,
            builder: (context, child) {
              final shakeOffset =
                  selectedIndexes.contains(i)
                      ? Offset(
                        (_shakeAnimation.value *
                            sin(_shakeAnimation.value * 2 * pi)),
                        0,
                      )
                      : Offset.zero;

              return Positioned(
                left: dx - circleSize / 2 + shakeOffset.dx,
                top: dy - circleSize / 2 + shakeOffset.dy,
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    key: keyMap[i],
                    width: circleSize,
                    height: circleSize,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color:
                          selectedIndexes.contains(i)
                              ? Colors.blue[600]
                              : Colors.blue,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: selectedIndexes.contains(i) ? 3 : 1,
                          blurRadius: selectedIndexes.contains(i) ? 8 : 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      letters[i],
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("${Strings.level} ${currentLevel + 1}"),
        backgroundColor: Colors.blue[100],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetCurrentLevel,
          ),
          IconButton(
            icon: const Icon(Icons.skip_next),
            onPressed: currentLevel < words.length - 1 ? _nextLevel : null,
          ),
        ],
      ),
      body: Container(
        width: screenSize.width,
        height: screenSize.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[50]!, Colors.blue[100]!],
          ),
        ),
        child: Listener(
          onPointerDown: (details) {
            setState(() {
              points.clear();
              selectedIndexes.clear();
              currentDragPosition = null;
            });
          },
          onPointerMove: (details) {
            // Sử dụng localPosition thay vì globalPosition
            final localPosition = details.localPosition;

            for (int i = 0; i < letters.length; i++) {
              final key = keyMap[i]!;
              final box = key.currentContext?.findRenderObject() as RenderBox?;
              if (box != null) {
                final position = box.localToGlobal(Offset.zero);
                final size = box.size;
                final rect = position & size;

                if (rect.contains(details.position) &&
                    !selectedIndexes.contains(i)) {
                  // Tính toán vị trí trung tâm của chữ cái
                  final screenSize = MediaQuery.of(context).size;
                  final double radius =
                      min(screenSize.width, screenSize.height) * 0.25;
                  final center = Offset(
                    screenSize.width / 2,
                    (screenSize.height - 100) / 2,
                  );

                  final startAngle = -pi / 2;
                  final angleStep = 2 * pi / letters.length;
                  final angle = startAngle + angleStep * i;

                  final letterCenter = Offset(
                    center.dx + radius * cos(angle),
                    center.dy + radius * sin(angle),
                  );

                  // Phát âm thanh khi chọn chữ cái
                  HapticFeedback.selectionClick();

                  setState(() {
                    selectedIndexes.add(i);
                    // Thêm vị trí trung tâm chữ cái để đường vẽ đúng
                    points.add(letterCenter);
                    // Đặt currentDragPosition để có thể vẽ đường từ chữ cái này
                    currentDragPosition = localPosition;
                  });
                  return;
                }
              }
            }

            setState(() {
              currentDragPosition = localPosition;
            });
          },
          onPointerUp: (details) {
            String result = selectedIndexes.map((i) => letters[i]).join();
            if (result == correctWord) {
              _playSuccessSound();
              _celebrationController.forward().then((_) {
                _celebrationController.reset();
                _showSuccessPopup(result);
              });
            } else {
              _playErrorSound();
              _shakeController.forward().then((_) {
                _shakeController.reset();
              });
              _showErrorPopup(result);
            }
            setState(() {
              currentDragPosition = null;
            });
          },
          child: Stack(
            children: [
              // 1. Lớp vẽ dây (nằm sau)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: PathPainter(points, currentDragPosition),
                    size: Size.infinite,
                  ),
                ),
              ),
              // 2. Chữ cái với animation
              ..._buildLetterCircle(screenSize),
              // 3. Level progress
              Positioned(
                top: 20,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${Strings.progress}: ${currentLevel + 1}/${words.length}",
                      ),
                      SizedBox(width: 10),
                      // Hiển thị thanh tiến độ
                      LinearProgressIndicator(
                        value: (currentLevel + 1) / words.length,
                        borderRadius: BorderRadius.circular(10),
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ).expand(),
                    ],
                  ),
                ),
              ),
              // 4. Celebration particles
              if (_celebrationAnimation.value > 0)
                ...List.generate(20, (i) {
                  final random = Random(i);
                  return Positioned(
                    left: random.nextDouble() * screenSize.width,
                    top: random.nextDouble() * screenSize.height,
                    child: AnimatedBuilder(
                      animation: _celebrationAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _celebrationAnimation.value,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color:
                                  Colors.primaries[i % Colors.primaries.length],
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}

// Extension helper
extension on Widget {
  Widget expand() => Expanded(child: this);
}

class PathPainter extends CustomPainter {
  final List<Offset> points;
  final Offset? currentDrag;

  PathPainter(this.points, this.currentDrag);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty && currentDrag == null) return;

    // Vẽ đường nối chính với gradient
    final paint =
        Paint()
          ..shader = LinearGradient(
            colors: [Colors.orange, Colors.deepOrange],
          ).createShader(
            Rect.fromPoints(
              points.isNotEmpty ? points.first : (currentDrag ?? Offset.zero),
              currentDrag ?? (points.isNotEmpty ? points.last : Offset.zero),
            ),
          )
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;

    // Vẽ shadow cho đường nối
    final shadowPaint =
        Paint()
          ..color = Colors.orange.withOpacity(0.3)
          ..strokeWidth = 8
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;

    // Vẽ đường nối giữa các điểm đã chọn
    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], shadowPaint);
      canvas.drawLine(points[i], points[i + 1], paint);
    }

    // Nối đoạn cuối đến vị trí kéo hiện tại
    if (points.isNotEmpty && currentDrag != null) {
      canvas.drawLine(points.last, currentDrag!, shadowPaint);
      canvas.drawLine(points.last, currentDrag!, paint);
    }

    // Vẽ các điểm nối với hiệu ứng pulse
    final dotPaint =
        Paint()
          ..color = Colors.orange
          ..style = PaintingStyle.fill;

    final dotBorderPaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

    for (int i = 0; i < points.length; i++) {
      final pulseRadius =
          6 + sin(DateTime.now().millisecondsSinceEpoch / 200.0 + i) * 2;
      canvas.drawCircle(points[i], pulseRadius, dotBorderPaint);
      canvas.drawCircle(points[i], pulseRadius - 2, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant PathPainter oldDelegate) =>
      oldDelegate.points != points || oldDelegate.currentDrag != currentDrag;
}
