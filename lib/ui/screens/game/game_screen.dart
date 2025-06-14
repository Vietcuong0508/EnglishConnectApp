import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:english_connect/core/core.dart';
import 'package:english_connect/models/model.dart';
import 'package:english_connect/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  // Danh sách các từ cho nhiều level
  final List<WordModel> words = [
    WordModel(word: "apple", pronunciation: "æpl", meaning: "Quả táo"),
    WordModel(word: "banana", pronunciation: "bəˈnænə", meaning: "Quả chuối"),
    WordModel(word: "orange", pronunciation: "ˈɔrɪndʒ", meaning: "Quả cam"),
    WordModel(word: "grape", pronunciation: "ɡreɪp", meaning: "Quả nho"),
    WordModel(
      word: "watermelon",
      pronunciation: "ˈwɔːtərˌmelən",
      meaning: "Quả dưa hấu",
    ),
    WordModel(
      word: "strawberry",
      pronunciation: "ˈstrɔːberi",
      meaning: "Quả dâu tây",
    ),
    WordModel(word: "kiwi", pronunciation: "ˈkiːwi", meaning: "Quả kiwi"),
    WordModel(word: "peach", pronunciation: "piːtʃ", meaning: "Quả đào"),
    WordModel(word: "mango", pronunciation: "ˈmæŋɡoʊ", meaning: "Quả xoài"),
    WordModel(word: "pineapple", pronunciation: "ˈpaɪnæpl", meaning: "Quả dứa"),
    WordModel(
      word: "blueberry",
      pronunciation: "ˈbluːberi",
      meaning: "Quả việt quất",
    ),
    WordModel(word: "cherry", pronunciation: "ˈtʃeri", meaning: "Quả anh đào"),
    WordModel(word: "pear", pronunciation: "per", meaning: "Quả lê"),
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
  late ConfettiController _leftController;
  late ConfettiController _rightController;
  late FlutterTts tts = FlutterTts();
  late AudioPlayer audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _initializeLevel();
    _setupAnimations();

    _leftController = ConfettiController(duration: const Duration(seconds: 2));
    _rightController = ConfettiController(duration: const Duration(seconds: 2));
  }

  void _initializeLevel() {
    correctWord = words[currentLevel].word;
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
    _leftController.dispose();
    _rightController.dispose();
    super.dispose();
  }

  void _playSuccessSound() async {
    // Phát âm thanh thành công
    await audioPlayer.setSource(AssetSource('sounds/correct.mp3'));
    await audioPlayer.resume();
    HapticFeedback.lightImpact();
    // Rung nhẹ khi thành công
  }

  void _playErrorSound() async {
    // Phát âm thanh lỗi
    await audioPlayer.setSource(AssetSource('sounds/wrong.mp3'));
    await audioPlayer.resume();
    HapticFeedback.heavyImpact();
    // Rung mạnh khi sai
  }

  void _showSuccessPopup(String result) {
    // Bắt đầu pháo hoa bên trái
    _leftController.play();
    // Bắt đầu pháo hoa bên phải
    _rightController.play();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => Stack(
            children: [
              CustomPopup(
                result: result,
                titleText: Strings.excellent,
                // icon: Icons.celebration,
                // iconColor: Colors.green,
                contentText: "${Strings.theExactWord}: $result",
                descriptionText:
                    "${Strings.pronounce}: ${words[currentLevel].pronunciation}",
                currentLevel: currentLevel,
                totalLevels: words.length,
                onBtnLeft: _nextLevel,
                onBtnRight: _resetCurrentLevel,
                textBtnleft:
                    currentLevel < words.length - 1 ? Strings.nextLevel : null,
                textBtnRight: Strings.tryAgain,
              ),
              Align(
                alignment: Alignment.topLeft,
                child: ConfettiWidget(
                  confettiController: _leftController,
                  blastDirection: 0, // bắn sang phải
                  emissionFrequency: 0.05,
                  numberOfParticles: 20,
                  blastDirectionality: BlastDirectionality.directional,
                  maxBlastForce: 20,
                  minBlastForce: 5,
                  gravity: 0.3,
                ),
              ),

              // Pháo hoa bên phải
              Align(
                alignment: Alignment.topRight,
                child: ConfettiWidget(
                  confettiController: _rightController,
                  blastDirection: 3.14, // bắn sang trái (PI radian)
                  emissionFrequency: 0.05,
                  numberOfParticles: 20,
                  blastDirectionality: BlastDirectionality.directional,
                  maxBlastForce: 20,
                  minBlastForce: 5,
                  gravity: 0.3,
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
          (_) => CustomPopup(
            titleText: "Thử lại !",
            titleColor: Colors.red,
            icon: Icons.close_rounded,
            iconColor: Colors.red,
            contentText: "${Strings.yourChoice}: $result",
            result: result,
            currentLevel: currentLevel,
            totalLevels: words.length,
            onBtnRight: _resetCurrentLevel,
            textBtnRight: Strings.tryAgain,
          ),
    );
  }

  void _showSuggestPopup(String result) {
    showDialog(
      context: context,
      builder:
          (_) => CustomPopup(
            titleText: Strings.suggest,
            contentText: Strings.pronounce,
            contentIcon: Icons.volume_up_rounded,
            result: result,
            currentLevel: currentLevel,
            totalLevels: words.length,
            onBtnRight: () {},
            onContentIcon: () async {
              tts.setLanguage('en-US');
              tts.setPitch(1.0);
              tts.speak(words[currentLevel].word);
            },
            textBtnRight: Strings.close,
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
    final themeColor = context.watch<ThemeManager>().currentTheme;
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
                              ? themeColor.buttonColor
                              : themeColor.buttonColor.withOpacity(0.7),
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
                      letters[i].toUpperCase(),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: themeColor.textColor,
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
    String result = selectedIndexes.map((i) => letters[i]).join();
    final screenSize = MediaQuery.of(context).size;
    final themeColor = context.watch<ThemeManager>().currentTheme;
    final GlobalKey progressBarKey = GlobalKey();

    bool isInProgressBarArea(Offset position) {
      final box =
          progressBarKey.currentContext?.findRenderObject() as RenderBox?;
      if (box != null) {
        final barPosition = box.localToGlobal(Offset.zero);
        final barSize = box.size;
        final barRect = barPosition & barSize;
        return barRect.contains(position);
      }
      return false;
    }

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(gradient: themeColor.backgroundGradient),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: Colors.transparent,
            title: Text("${Strings.level} ${currentLevel + 1}"),
            actions: [
              IconButton(
                icon: const Icon(Icons.lightbulb_rounded),
                onPressed: () => _showSuggestPopup(result),
              ),
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
          body: SizedBox(
            width: screenSize.width,
            height: screenSize.height,
            child: Listener(
              onPointerDown: (details) {
                // Kiểm tra nếu đang ở trong vùng progress bar
                if (isInProgressBarArea(details.position)) {
                  return; // Không làm gì nếu đang ở trong progress bar
                }
                // Nếu không ở trong progress bar, bắt đầu vẽ đường
                setState(() {
                  points.clear();
                  selectedIndexes.clear();
                  currentDragPosition = null;
                });
              },
              onPointerMove: (details) {
                // Kiểm tra nếu đang ở trong vùng progress bar
                if (isInProgressBarArea(details.position)) {
                  return; // Không làm gì nếu đang ở trong progress bar
                }
                // Nếu không ở trong progress bar, bắt đầu vẽ đường
                final localPosition = details.localPosition;

                for (int i = 0; i < letters.length; i++) {
                  final key = keyMap[i]!;
                  final box =
                      key.currentContext?.findRenderObject() as RenderBox?;
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
                // Kiểm tra nếu đang ở trong vùng progress bar
                if (isInProgressBarArea(details.position)) {
                  return; // Không làm gì nếu đang ở trong progress bar
                }
                // Nếu không ở trong progress bar, bắt đầu vẽ đường
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
                        painter: PathPainter(
                          points,
                          currentDragPosition,
                          lineColor: themeColor.primaryColor,
                          shadowColor: themeColor.shadowColor,
                          dotColor: themeColor.primaryColor.withOpacity(0.5),
                          dotBorderColor: themeColor.primaryColor,
                        ),
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
                    child: InkWell(
                      onTap: () {
                        // Hiển thị dialog khi nhấn vào progress
                        showDialog(
                          context: context,
                          builder:
                              (_) => AlertDialog(
                                title: Text(Strings.progress),
                                content: Text(
                                  "${currentLevel + 1}/${words.length}",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.of(context).pop(),
                                    child: Text(Strings.ok),
                                  ),
                                ],
                              ),
                        );
                      },
                      child: Container(
                        key: progressBarKey,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: themeColor.buttonColor,
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
                              minHeight: 10,
                              value: (currentLevel + 1) / words.length,
                              borderRadius: BorderRadius.circular(10),
                              backgroundColor: themeColor.iconColor.withOpacity(
                                0.2,
                              ),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                themeColor.iconColor,
                              ),
                            ).expand(),
                          ],
                        ),
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
                                      Colors.primaries[i %
                                          Colors.primaries.length],
                                  shape: BoxShape.circle,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }),
                  Positioned(
                    width: screenSize.width,
                    bottom: 20,
                    child: Center(
                      child: Text(
                        "${Strings.connectTheWord}: ${words[currentLevel].meaning}",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Extension helper
extension on Widget {
  Widget expand() => Expanded(child: this);
}
