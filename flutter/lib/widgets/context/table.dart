import 'package:flutter/material.dart';

class PopupMenuWidget extends StatelessWidget {
  final Function(String) onSelected;
  final bool showEvacuationCenter; // New parameter

  const PopupMenuWidget({
    super.key,
    required this.onSelected,
    this.showEvacuationCenter = true, // Default to true
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      color: Colors.white,
      onSelected: onSelected,
      itemBuilder: (context) {
        // Build the list of menu items
        List<PopupMenuItem<String>> items = [];

        // Add the "View Evacuation Center" item if the flag is true
        if (showEvacuationCenter) {
          items.add(_buildPopupMenuItem('View Evacuation Center', 'View Evacuation Center'));
        } else {
          // Add the "View Record" item if the evacuation center is not shown
          items.add(_buildPopupMenuItem('View Record', 'View'));
        }

        // Always add the "Update" and "Delete" options
        items.add(_buildPopupMenuItem('Update', 'Update'));
        items.add(_buildPopupMenuItem('Delete', 'Delete'));

        return items;
      },
      child: const Icon(Icons.more_vert),
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(String text, String value) {
    return PopupMenuItem(
      value: value,
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}


class DataCellWidget extends StatelessWidget {
  final dynamic value;
  final int flex;
  final bool center;
  final bool showIcon;

  const DataCellWidget({
    this.value,
    this.flex = 1,
    this.center = false,
    this.showIcon = false,
    super.key,
  });

  Widget _buildIcon(dynamic value) {
    int intValue = int.tryParse(value.toString()) ?? 0;
    return Icon(
      intValue == 1 ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
      color: const Color(0xFF5576F5),
      size: 16,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (showIcon) {
      child = _buildIcon(value);
    } else {
      child = Text(
        value?.toString() ?? '',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          fontFamily: 'Poppins',
          color: Color(0xFF4B4B4B),
        ),
        overflow: TextOverflow.ellipsis,
        textAlign: center ? TextAlign.center : TextAlign.start,
      );
    }

    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: center ? Align(alignment: Alignment.center, child: child) : child,
      ),
    );
  }
}

class HeaderCellWidget extends StatelessWidget {
  final String label;
  final int flex;
  final bool center;

  const HeaderCellWidget({required this.label, this.flex = 1, this.center = false, super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
            color: Color(0xFF4B4B4B),
          ),
          overflow: TextOverflow.ellipsis,
          textAlign: center ? TextAlign.center : TextAlign.start,
        ),
      ),
    );
  }
}


