import 'dart:async';
import 'package:english_connect/core/services/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef OnSelectedWord = void Function(String word);

class WordSuggestField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final OnSelectedWord? onSelected;
  final int maxSuggestions;
  final double itemHeight;
  final BoxDecoration? suggestionBoxDecoration;

  const WordSuggestField({
    super.key,
    required this.controller,
    this.hintText = 'Nhập từ...',
    this.onSelected,
    this.maxSuggestions = 8,
    this.itemHeight = 56.0,
    this.suggestionBoxDecoration,
  });

  @override
  State<WordSuggestField> createState() => _WordSuggestFieldState();
}

class _WordSuggestFieldState extends State<WordSuggestField> {
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();

  OverlayEntry? _overlayEntry;
  Timer? _debounce;

  List<String> _suggestions = [];
  bool _loading = false;
  int _selectedIndex = -1;

  // small cache
  final Map<String, List<String>> _cache = {};

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _removeOverlay();
      } else if (_suggestions.isNotEmpty)
        _showOverlay();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _removeOverlay();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 300),
      () => _fetchSuggestions(v),
    );
  }

  Future<void> _fetchSuggestions(String q) async {
    final trimmed = q.trim();
    if (trimmed.isEmpty) {
      _clearSuggestions(); // Dùng hàm tiện ích cho gọn
      return;
    }

    // 1. Kiểm tra Cache trước
    if (_cache.containsKey(trimmed)) {
      if (mounted) {
        setState(() {
          _suggestions = _cache[trimmed]!;
          _loading = false;
          _selectedIndex = -1;
        });
        _showOverlay();
      }
      return;
    }

    if (mounted) setState(() => _loading = true);

    try {
      // 2. Gọi API
      final list = await DatamuseService.suggestByPrefix(
        trimmed,
        max:
            widget.maxSuggestions +
            10, // Lấy dư ra chút để bù cho các từ bị lọc
      );

      if (!mounted) return;

      // ---------------------------------------------------------
      // ✅ 3. ÁP DỤNG BỘ LỌC: CHỈ LẤY TỪ ĐƠN (KHÔNG DẤU CÁCH)
      // ---------------------------------------------------------
      final filteredList =
          list
              .where((word) {
                final w = word.trim();
                // Loại bỏ từ có dấu cách (cụm từ) và các ký tự lạ nếu cần
                return w.isNotEmpty && !w.contains(' ');
              })
              .take(widget.maxSuggestions)
              .toList(); // Cắt đúng số lượng cần hiển thị

      // Lưu vào cache list đã lọc
      _cache[trimmed] = filteredList;

      setState(() {
        _suggestions = filteredList;
        _loading = false;
        _selectedIndex = -1;
      });

      if (_focusNode.hasFocus && _suggestions.isNotEmpty) {
        _showOverlay();
      } else {
        _removeOverlay();
      }
    } catch (_) {
      if (!mounted) return;
      _clearSuggestions();
    }
  }

  void _clearSuggestions() {
    if (mounted) {
      setState(() {
        _suggestions = [];
        _loading = false;
        _selectedIndex = -1;
      });
    }
    _removeOverlay();
  }

  // highlight matched substring (case-insensitive)
  Widget _highlightText(
    String text,
    String query,
    TextStyle baseStyle,
    TextStyle highlightStyle,
  ) {
    if (query.isEmpty) return Text(text, style: baseStyle);
    final q = query.toLowerCase();
    final t = text.toLowerCase();
    final spans = <TextSpan>[];
    int start = 0;
    int index;
    while ((index = t.indexOf(q, start)) != -1) {
      if (index > start) {
        spans.add(
          TextSpan(text: text.substring(start, index), style: baseStyle),
        );
      }
      spans.add(
        TextSpan(
          text: text.substring(index, index + q.length),
          style: highlightStyle,
        ),
      );
      start = index + q.length;
    }
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start), style: baseStyle));
    }
    return RichText(text: TextSpan(children: spans));
  }

  void _showOverlay() {
    _removeOverlay();
    if (_suggestions.isEmpty) return;

    final overlay = Overlay.of(context);

    final renderBox = context.findRenderObject() as RenderBox?;
    final size = renderBox?.size ?? const Size(300, 50);
    final offset = renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;

    final mq = MediaQuery.of(context);
    final keyboardHeight = mq.viewInsets.bottom;
    final availableHeight =
        mq.size.height - offset.dy - size.height - keyboardHeight - 24;
    final maxHeight = (availableHeight * 0.6).clamp(120.0, 420.0);

    final theme = Theme.of(context);
    final boxDecoration =
        widget.suggestionBoxDecoration ??
        BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(
            color: theme.dividerColor.withOpacity(0.6),
            width: 0.6,
          ),
        );

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          left: offset.dx,
          top: offset.dy + size.height + 8,
          width: size.width,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0, size.height + 8),
            child: Material(
              color: Colors.transparent,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxHeight),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: boxDecoration,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shrinkWrap: true,
                      itemCount: _suggestions.length,
                      separatorBuilder:
                          (_, __) => Divider(
                            height: 1,
                            color: theme.dividerColor.withOpacity(0.12),
                          ),
                      itemBuilder: (context, index) {
                        final s = _suggestions[index];
                        final isSelected = index == _selectedIndex;
                        return InkWell(
                          onTap: () {
                            _selectSuggestion(index);
                          },
                          child: Container(
                            height: widget.itemHeight,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            alignment: Alignment.centerLeft,
                            color:
                                isSelected
                                    ? theme.colorScheme.primary.withOpacity(
                                      0.08,
                                    )
                                    : Colors.transparent,
                            child: _highlightText(
                              s,
                              widget.controller.text.trim(),
                              theme.textTheme.bodyLarge ??
                                  const TextStyle(fontSize: 16),
                              (theme.textTheme.bodyLarge ??
                                      const TextStyle(fontSize: 16))
                                  .copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: theme.colorScheme.primary,
                                  ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    try {
      _overlayEntry?.remove();
    } catch (_) {}
    _overlayEntry = null;
  }

  void _selectSuggestion(int index) {
    if (index < 0 || index >= _suggestions.length) return;
    final s = _suggestions[index];
    widget.controller.text = s;
    widget.controller.selection = TextSelection.fromPosition(
      TextPosition(offset: s.length),
    );
    widget.onSelected?.call(s);
    _clearSuggestions();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CompositedTransformTarget(
      link: _layerLink,
      child: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: (event) {
          if (_suggestions.isEmpty) return;
          if (event is RawKeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
              setState(() {
                _selectedIndex = (_selectedIndex + 1) % _suggestions.length;
              });
              _showOverlay();
            } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
              setState(() {
                _selectedIndex =
                    _selectedIndex - 1 < 0
                        ? _suggestions.length - 1
                        : _selectedIndex - 1;
              });
              _showOverlay();
            } else if (event.logicalKey == LogicalKeyboardKey.enter) {
              // hardware keyboard enter -> choose highlight if navigated
              if (_selectedIndex >= 0 && _selectedIndex < _suggestions.length) {
                _selectSuggestion(_selectedIndex);
              }
            }
          }
        },
        child: TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: widget.hintText,
            filled: true,
            fillColor:
                theme.inputDecorationTheme.fillColor ?? theme.canvasColor,
            suffix:
                _loading
                    ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
          ),
          textInputAction: TextInputAction.done,
          onChanged: (v) => _onTextChanged(v),
          onTap: () {
            if (!_focusNode.hasFocus) _focusNode.requestFocus();
            if (_suggestions.isNotEmpty) _showOverlay();
          },
          onSubmitted: (value) {
            _removeOverlay();
            final v = value.trim();
            if (v.isNotEmpty) widget.onSelected?.call(v);
          },
        ),
      ),
    );
  }
}
