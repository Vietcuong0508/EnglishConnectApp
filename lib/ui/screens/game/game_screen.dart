import 'dart:math';
import 'package:english_connect/core/core.dart';
import 'package:english_connect/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => GameScreenState();
}

class GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late AnimationController _celebrationController;
  late AnimationController _shakeController;
  late Animation<double> _celebrationAnimation;
  late Animation<double> _shakeAnimation;
  late ConfettiController _leftController;
  late ConfettiController _rightController;

  @override
  void initState() {
    super.initState();
    _setupAnimations();

    _leftController = ConfettiController(duration: const Duration(seconds: 2));
    _rightController = ConfettiController(duration: const Duration(seconds: 2));
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

  void _showSuccessPopup(String result, GameViewModel viewModel) {
    _leftController.play();
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
                contentText: "${Strings.theExactWord}: $result",
                descriptionText:
                    "${Strings.pronounce}: ${viewModel.words[viewModel.currentLevel].pronunciation}",
                currentLevel: viewModel.currentLevel + 1,
                totalLevels: viewModel.words.length,
                onBtnLeft: () => viewModel.nextLevel(),
                onBtnRight: () => viewModel.resetLevel(),
                textBtnleft:
                    viewModel.currentLevel < viewModel.words.length - 1
                        ? Strings.nextLevel
                        : null,
                textBtnRight: Strings.tryAgain,
              ),
              FireworksEffect(
                leftController: _leftController,
                rightController: _rightController,
              ),
            ],
          ),
    );
  }

  void _showErrorPopup(String result, GameViewModel viewModel) {
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
            currentLevel: viewModel.currentLevel + 1,
            totalLevels: viewModel.words.length,
            onBtnRight: () => viewModel.resetLevel(),
            textBtnRight: Strings.tryAgain,
          ),
    );
  }

  void _showSuggestPopup(String result, GameViewModel viewModel) {
    showDialog(
      context: context,
      builder:
          (_) => CustomPopup(
            titleText: Strings.suggest,
            contentText: Strings.pronounce,
            contentIcon: Icons.volume_up_rounded,
            result: result,
            currentLevel: viewModel.currentLevel + 1,
            totalLevels: viewModel.words.length,
            onBtnRight: () {},
            onContentIcon: () async {
              viewModel.tts.setLanguage('en-US');
              viewModel.tts.setPitch(1.0);
              viewModel.tts.speak(result);
            },
            textBtnRight: Strings.close,
          ),
    );
  }

  List<Widget> _buildLetterCircle(
    Size screenSize,
    List<String> letters,
    var keyMap,
    List<int> selectedIndexes,
  ) {
    final double radius = min(screenSize.width, screenSize.height) * 0.25;
    final center = Offset(screenSize.width / 2, (screenSize.height - 100) / 2);
    final themeColor = context.watch<ThemeManager>().currentTheme;
    final baseLetterSize = 28.0;
    final baseSize = screenSize.width * 0.2;

    return List.generate(letters.length, (i) {
      return letterCircleWidget(
        letters[i],
        i,
        letters.length,
        center,
        radius,
        baseSize,
        baseLetterSize,
        selected: selectedIndexes.contains(i),
        celebrationAnimation: _celebrationAnimation,
        shakeAnimation: _shakeAnimation,
        keyWidget: keyMap[i] ?? GlobalKey(),
        backgroundColor: themeColor.primaryColor,
        textColor: themeColor.textColor,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
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

    return BaseView<GameViewModel>(
      onViewModelReady: (viewModel) async {
        await viewModel.loadWordsByTopic("fruits.json");
        viewModel.initializeLevel();
      },
      builder: (context, viewModel, _) {
        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: themeColor.backgroundGradient,
              ),
            ),
            Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                centerTitle: true,
                backgroundColor: Colors.transparent,
                title: Text("${Strings.level} ${viewModel.currentLevel + 1}"),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.lightbulb_rounded),
                    onPressed:
                        () => _showSuggestPopup(
                          viewModel.currentWord!.word,
                          viewModel,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => viewModel.resetLevel(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next),
                    onPressed:
                        viewModel.currentLevel < viewModel.words.length - 1
                            ? () => viewModel.nextLevel()
                            : null,
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
                  },
                  onPointerMove: (details) {
                    // Kiểm tra nếu đang ở trong vùng progress bar
                    if (isInProgressBarArea(details.position)) {
                      return; // Không làm gì nếu đang ở trong progress bar
                    }
                    final localPosition = details.localPosition;

                    for (int i = 0; i < viewModel.letters.length; i++) {
                      final key = viewModel.keyMap[i] ?? GlobalKey();
                      final box =
                          key.currentContext?.findRenderObject() as RenderBox?;
                      if (box != null) {
                        final position = box.localToGlobal(Offset.zero);
                        final size = box.size;
                        final rect = position & size;

                        if (rect.contains(details.position) &&
                            !viewModel.selectedIndexes.contains(i)) {
                          // Tính toán vị trí trung tâm của chữ cái
                          final screenSize = MediaQuery.of(context).size;
                          final double radius =
                              min(screenSize.width, screenSize.height) * 0.25;
                          final center = Offset(
                            screenSize.width / 2,
                            (screenSize.height - 100) / 2,
                          );

                          final startAngle = -pi / 2;
                          final angleStep = 2 * pi / viewModel.letters.length;
                          final angle = startAngle + angleStep * i;

                          final letterCenter = Offset(
                            center.dx + radius * cos(angle),
                            center.dy + radius * sin(angle),
                          );

                          // Phát âm thanh khi chọn chữ cái
                          HapticFeedback.selectionClick();

                          setState(() {
                            viewModel.selectedIndexes.add(i);
                            // Thêm vị trí trung tâm chữ cái để đường vẽ đúng
                            viewModel.points.add(letterCenter);
                            // Đặt currentDragPosition để có thể vẽ đường từ chữ cái này
                            viewModel.currentDragPosition = localPosition;
                          });
                          return;
                        }
                      }
                    }

                    setState(
                      () => viewModel.currentDragPosition = localPosition,
                    );
                  },
                  onPointerUp: (details) {
                    // Kiểm tra nếu đang ở trong vùng progress bar
                    if (isInProgressBarArea(details.position)) {
                      return; // Không làm gì nếu đang ở trong progress bar
                    }
                    String result =
                        viewModel.selectedIndexes
                            .map((i) => viewModel.letters[i])
                            .join();
                    if (result == viewModel.currentWord!.word) {
                      viewModel.playSoundCorrect();
                      _celebrationController.forward().then((_) {
                        _celebrationController.reset();
                        _showSuccessPopup(result, viewModel);
                      });
                    } else {
                      viewModel.playSoundWrong();
                      _shakeController.forward().then((_) {
                        _shakeController.reset();
                      });
                      _showErrorPopup(result, viewModel);
                    }
                    setState(() => viewModel.currentDragPosition = null);
                  },
                  child: Stack(
                    children: [
                      // 1. Lớp vẽ dây (nằm sau)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: CustomPaint(
                            painter: PathPainter(
                              viewModel.points,
                              viewModel.currentDragPosition,
                              lineColor: themeColor.primaryColor,
                              shadowColor: themeColor.shadowColor,
                              dotColor: themeColor.primaryColor.withOpacity(
                                0.5,
                              ),
                              dotBorderColor: themeColor.primaryColor,
                            ),
                            size: Size.infinite,
                          ),
                        ),
                      ),
                      // 2. Chữ cái với animation
                      ..._buildLetterCircle(
                        screenSize,
                        viewModel.letters,
                        viewModel.keyMap,
                        viewModel.selectedIndexes,
                      ),
                      // 3. Thanh tiến độ
                      levelProgressWidget(
                        viewModel,
                        progressBarKey,
                        context,
                        themeColor,
                      ),
                      // 4. Vùng hiển thị từ hiện tại
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
                            viewModel.currentWord == null
                                ? ''
                                : "${Strings.connectTheWord}: ${viewModel.currentWord!.meaning}",
                            style: TextStyle(
                              fontSize: 16,
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
      },
    );
  }
}
