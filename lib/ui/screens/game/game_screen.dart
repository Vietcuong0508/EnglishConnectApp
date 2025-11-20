import 'dart:math';
import 'package:english_connect/core/core.dart';
import 'package:english_connect/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';

class GameScreen extends StatefulWidget {
  // Bỏ tham số randomWord, để ViewModel tự lo
  const GameScreen({super.key, this.topicName});
  final String? topicName;

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

  // --- 1. HÀM VẼ VÒNG TRÒN CHỮ CÁI (ĐÃ TỐI ƯU SIZE) ---
  List<Widget> _buildLetterCircle(
    Size screenSize,
    List<String> letters,
    Map<int, GlobalKey> keyMap,
    List<int> selectedIndexes,
  ) {
    final int count = letters.length;

    // Tự động chỉnh bán kính vòng tròn lớn dựa trên số lượng từ
    double radiusFactor = count > 6 ? 0.35 : 0.28;
    final double radius =
        min(screenSize.width, screenSize.height) * radiusFactor;
    final center = Offset(screenSize.width / 2, (screenSize.height - 100) / 2);
    final themeColor = context.watch<ThemeManager>().currentTheme;

    // Tự động chỉnh kích thước ô chữ
    double itemSize;
    double fontSize;
    if (count <= 4) {
      itemSize = 70.0;
      fontSize = 32.0;
    } else if (count <= 6) {
      itemSize = 60.0;
      fontSize = 28.0;
    } else {
      itemSize = 48.0;
      fontSize = 24.0;
    }

    return List.generate(count, (i) {
      return letterCircleWidget(
        letters[i],
        i,
        count,
        center,
        radius,
        itemSize,
        fontSize,
        selected: selectedIndexes.contains(i),
        celebrationAnimation: _celebrationAnimation,
        shakeAnimation: _shakeAnimation,
        keyWidget: keyMap[i] ?? GlobalKey(),
        backgroundColor: themeColor.primaryColor,
        textColor: themeColor.textColor,
      );
    });
  }

  // --- 2. CÁC POPUP (ĐÃ SỬA LỖI THOÁT GAME) ---
  // Lưu ý: Đã xóa lệnh Navigator.pop() ở đây vì CustomPopup của bạn đã tự đóng rồi.

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
                    "${Strings.pronounce}: ${viewModel.currentWord?.pronunciation ?? ''}",
                currentLevel: viewModel.currentLevel + 1,
                totalLevels: viewModel.words.length,
                // ✅ Chỉ gọi logic game, CustomPopup sẽ tự đóng
                onBtnLeft: () {
                  viewModel.nextLevel();
                },
                onBtnRight: () {
                  viewModel.resetLevel();
                },
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
            contentText: "${Strings.yourChoice}: ${result.toLowerCase()}",
            result: result,
            currentLevel: viewModel.currentLevel + 1,
            totalLevels: viewModel.words.length,
            // ✅ Chỉ gọi logic game
            onBtnRight: () {
              viewModel.resetLevel();
            },
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
            // ✅ Để null hoặc hàm rỗng, CustomPopup tự đóng
            onBtnRight: () {},
            onContentIcon: () async {
              await viewModel.speakWord();
            },
            textBtnRight: Strings.close,
          ),
    );
  }

  // --- 3. BUILD UI CHÍNH ---

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
        return (barPosition & box.size).contains(position);
      }
      return false;
    }

    return BaseView<GameViewModel>(
      onViewModelReady: (viewModel) async {
        // ✅ QUAN TRỌNG: Reset và load dữ liệu mới tại đây
        await viewModel.initGame(widget.topicName);
      },
      builder: (context, viewModel, _) {
        if (viewModel.words.isEmpty) {
          return Container(
            decoration: BoxDecoration(gradient: themeColor.backgroundGradient),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

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
                title: Text(
                  "${Strings.level} ${viewModel.currentLevel + 1}/${viewModel.words.length}",
                ),
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
                    icon: const Icon(Icons.skip_previous),
                    onPressed:
                        viewModel.currentLevel > 0
                            ? () => viewModel.previousLevel()
                            : null,
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
                    if (isInProgressBarArea(details.position)) return;
                  },
                  onPointerMove: (details) {
                    if (isInProgressBarArea(details.position)) return;
                    final localPosition = details.localPosition;

                    for (int i = 0; i < viewModel.letters.length; i++) {
                      final key = viewModel.keyMap[i] ?? GlobalKey();
                      final box =
                          key.currentContext?.findRenderObject() as RenderBox?;
                      if (box != null) {
                        final position = box.localToGlobal(Offset.zero);
                        final rect = position & box.size;

                        if (rect.contains(details.position) &&
                            !viewModel.selectedIndexes.contains(i)) {
                          // Logic tính toán vị trí tâm (phải khớp với _buildLetterCircle)
                          final int count = viewModel.letters.length;
                          double radiusFactor = count > 6 ? 0.35 : 0.28;
                          final double radius =
                              min(screenSize.width, screenSize.height) *
                              radiusFactor;
                          final center = Offset(
                            screenSize.width / 2,
                            (screenSize.height - 100) / 2,
                          );
                          final angle = (-pi / 2) + (2 * pi / count) * i;
                          final letterCenter = Offset(
                            center.dx + radius * cos(angle),
                            center.dy + radius * sin(angle),
                          );

                          HapticFeedback.selectionClick();
                          setState(() {
                            viewModel.selectedIndexes.add(i);
                            viewModel.points.add(letterCenter);
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
                    if (isInProgressBarArea(details.position)) return;

                    String result = viewModel.getSelectedWord();

                    if (viewModel.isCorrectAnswer()) {
                      viewModel.playSoundCorrect();
                      _celebrationController.forward().then((_) {
                        _celebrationController.reset();
                        _showSuccessPopup(result, viewModel);
                      });
                    } else if (viewModel.selectedIndexes.isNotEmpty) {
                      viewModel.playSoundWrong();
                      _shakeController.forward().then(
                        (_) => _shakeController.reset(),
                      );
                      _showErrorPopup(result, viewModel);
                    }
                    setState(() => viewModel.currentDragPosition = null);
                  },
                  child: Stack(
                    children: [
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
                      // Gọi hàm build vòng tròn đã tối ưu
                      ..._buildLetterCircle(
                        screenSize,
                        viewModel.letters,
                        viewModel.keyMap,
                        viewModel.selectedIndexes,
                      ),
                      levelProgressWidget(
                        viewModel,
                        progressBarKey,
                        context,
                        themeColor,
                      ),
                      Positioned(
                        width: screenSize.width,
                        bottom: 40,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: Text(
                              viewModel.currentWord == null
                                  ? ''
                                  : "${Strings.connectTheWord}: ${viewModel.currentWord!.meaning}",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    blurRadius: 2,
                                    color: Colors.black45,
                                    offset: Offset(1, 1),
                                  ),
                                ],
                              ),
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
