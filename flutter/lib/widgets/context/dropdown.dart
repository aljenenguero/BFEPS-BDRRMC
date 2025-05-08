import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class _CustomDropdownField extends StatefulWidget {
  final String label;
  final String keyName;
  final List<String> options;
  final Map<String, String?> dropdownValues;
  final bool isReadOnly;
  final ValueChanged<String>? onChanged;
  final bool allowCustomInput;

  const _CustomDropdownField({
    required this.label,
    required this.keyName,
    required this.options,
    required this.dropdownValues,
    required this.isReadOnly,
    this.onChanged,
    this.allowCustomInput = true,
  });

  @override
  State<_CustomDropdownField> createState() => _CustomDropdownFieldState();
}

class _CustomDropdownFieldState extends State<_CustomDropdownField> {
  final LayerLink _layerLink = LayerLink();
  final FocusNode _focusNode = FocusNode();
  late final TextEditingController _controller;
  OverlayEntry? _overlayEntry;

  List<String> _filteredOptions = [];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.dropdownValues[widget.keyName] ?? '');
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus && !widget.isReadOnly) {
      _filteredOptions = widget.options;
      _showOverlay();
    } else {
      _removeOverlay();
    }
  }

  void _showOverlay() {
    _removeOverlay();

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Size size = renderBox.size;
    final Offset offset = renderBox.localToGlobal(Offset.zero);

    final availableSpaceBelow = MediaQuery.of(context).size.height - offset.dy - size.height;
    final showAbove = availableSpaceBelow < 200;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        left: offset.dx,
        top: showAbove ? offset.dy - 200 : offset.dy + size.height,
        height: 200,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: ListView(
              padding: EdgeInsets.zero,
              children: _filteredOptions.map((option) {
                return InkWell(
                  onTap: () {
                    _controller.text = option;
                    widget.dropdownValues[widget.keyName] = option;
                    widget.onChanged?.call(option);
                    _removeOverlay();
                    FocusScope.of(context).unfocus();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Text(
                      option,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _removeOverlay();
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        readOnly: widget.isReadOnly,
        onChanged: (value) {
          if (widget.allowCustomInput) {
            setState(() {
              _filteredOptions = widget.options
                  .where((opt) =>
                      opt.toLowerCase().contains(value.toLowerCase()))
                  .toList();
            });
            widget.dropdownValues[widget.keyName] = value;
            widget.onChanged?.call(value);
          }
        },
        decoration: InputDecoration(
          labelText: widget.label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          suffixIcon: const Icon(Icons.arrow_drop_down),
        ),
        inputFormatters: widget.allowCustomInput
            ? null
            : [
                FilteringTextInputFormatter.deny(RegExp('.*')),
              ],
      ),
    );
  }
}
