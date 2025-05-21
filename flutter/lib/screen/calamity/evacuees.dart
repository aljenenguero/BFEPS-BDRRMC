import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../widgets/buttons/add_button.dart';
import '../../widgets/search_bar.dart' as custom;

class EvacueesPage extends StatefulWidget {
  final Map<String, dynamic> centerData;
  const EvacueesPage({super.key, required this.centerData});

  @override
  EvacueesPageState createState() => EvacueesPageState();
}

class EvacueesPageState extends State<EvacueesPage> {
  int _currentPage = 0;
  final int _itemsPerPage = 15;
  List<Map<String, dynamic>> _allRecords = [];
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _fetchRecords();
  }

  Future<void> _fetchRecords() async {
    try {
      final calamityId = widget.centerData['calamity_name'] ?? widget.centerData['id'];
      final url = Uri.parse('http://localhost/evc/api/insert_dummy_data.php?calamity_name=$calamityId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          _allRecords = List<Map<String, dynamic>>.from(data);
        });
      } else {
        throw Exception('Failed to load evacuees');
      }
    } catch (e) {
      print('Error fetching evacuees: $e');
    }
  }

  List<Map<String, dynamic>> get _filteredEvacuees {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return _allRecords; // Return all if no search query
    return _allRecords.where((evacuee) => evacuee['name'].toString().toLowerCase().contains(query)).toList();
  }

  List<Map<String, dynamic>> _getPaginatedRecords() {
    int start = _currentPage * _itemsPerPage;
    int end = start + _itemsPerPage;
    if (end > _filteredEvacuees.length) end = _filteredEvacuees.length;

    return _filteredEvacuees.sublist(start, end);
  }

  void _updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query;
      _currentPage = 0; // Reset to the first page on new search
    });
  }

  void _goToNextPage() {
    if ((_currentPage + 1) * _itemsPerPage < _filteredEvacuees.length) {
      setState(() {
        _currentPage++;
      });
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
    }
  }

  Widget _buildPagination() {
    int totalFiltered = _filteredEvacuees.length;
    int start = _currentPage * _itemsPerPage + 1;
    int end = start + _itemsPerPage - 1;
    if (end > totalFiltered) end = totalFiltered;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '$start-$end of $totalFiltered',
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'Poppins',
            color: Color(0xFF9E9E9E),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: _currentPage > 0 ? _goToPreviousPage : null,
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            backgroundColor: Colors.white,
            padding: const EdgeInsets.all(5),
          ),
          child: const Icon(Icons.navigate_before, color: Color(0xFF4B4B4B)),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: ((_currentPage + 1) * _itemsPerPage) < totalFiltered ? _goToNextPage : null,
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            backgroundColor: Colors.white,
            padding: const EdgeInsets.all(5),
          ),
          child: const Icon(Icons.navigate_next, color: Color(0xFF4B4B4B)),
        ),
      ],
    );
  }

  void _showAddEvacueeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddEvacueeDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.centerData['evacuation_centername'] ?? 'Evacuation Center',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                          color: Color(0xFF4B4B4B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Zone ${widget.centerData['zone'] ?? 'N/A'}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          color: Color(0xFF4B4B4B),
                        ),
                      ),
                      Text(
                        '${widget.centerData['evacuation_type'] ?? 'N/A'}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          color: Color(0xFF4B4B4B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${widget.centerData['contact_person'] ?? 'N/A'}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          color: Color(0xFF4B4B4B),
                        ),
                      ),
                      Text(
                        '${widget.centerData['contact_number'] ?? 'N/A'}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          color: Color(0xFF4B4B4B),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 40),
                // Graphs on the right
                Row(
                  children: [
                    Container(
                      width: 520,
                      height: 251,
                      margin: const EdgeInsets.only(right: 25),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          "Bar Graph Placeholder",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 520,
                      height: 251,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          "Pie Graph Placeholder",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.2,
                  child: custom.SearchBar(onSearch: _updateSearchQuery),
                ),
                const SizedBox(width: 16),
                AddButton(
                  label: 'Add Evacuees',
                  onPressed: () {
                    _showAddEvacueeDialog(context);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 500,
              child: Column(
                children: [
                  _buildTableHeader(),
                  Expanded(
                    child: _getPaginatedRecords().isEmpty
                        ? const Center(
                            child: Text(
                              'No evacuees found.',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                color: Color(0xFFCBCBCB),
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _getPaginatedRecords().length,
                            itemBuilder: (context, index) {
                              final evacuee = _getPaginatedRecords()[index];
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Color(0xFFCCCCCC),
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text(evacuee['hh_id'] ?? ''),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Text(evacuee['name'] ?? ''),
                                    ),
                                    // Add more fields as necessary
                                    Expanded(flex: 2, child: Text('')),
                                    Expanded(flex: 2, child: Text('')),
                                    Expanded(flex: 2, child: Text('')),
                                    Expanded(flex: 2, child: Text('')),
                                    Expanded(flex: 2, child: Text('')),
                                    Expanded(flex: 2, child: Text('')),
                                    Expanded(flex: 2, child: Text('')),
                                    Expanded(flex: 2, child: Text('')),
                                    Expanded(flex: 2, child: Text('')),
                                    Expanded(flex: 2, child: Text('')),
                                    Expanded(flex: 2, child: Text('')),
                                    Expanded(flex: 2, child: Text('')),
                                    Expanded(flex: 2, child: Text('')),
                                    Expanded(flex: 2, child: Text('Action')),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildPagination(),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFCCCCCC))),
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      child: Row(
        children: const [
          HeaderCellWidget(label: 'HH Id', flex: 2),
          HeaderCellWidget(label: 'Name of Family Head', flex: 3),
          HeaderCellWidget(label: 'Infant', subLabel: '> 1 y/o', flex: 2, center: true),
          HeaderCellWidget(label: 'Toddlers', subLabel: '> 1-3 y/o', flex: 2, center: true),
          HeaderCellWidget(label: 'Preschool', subLabel: '> 4-5 y/o', flex: 2, center: true),
          HeaderCellWidget(label: 'School Age', subLabel: '> 6-12 y/o', flex: 2, center: true),
          HeaderCellWidget(label: 'Teen Age', subLabel: '> 13-19 y/o', flex: 2, center: true),
          HeaderCellWidget(label: 'Adult', subLabel: '> 20-59 y/o', flex: 2, center: true),
          HeaderCellWidget(label: 'Senior Citizens', subLabel: '< 60 and above', flex: 2, center: true),
          HeaderCellWidget(label: '# of Persons per Family', flex: 2, center: true),
          HeaderCellWidget(label: 'Lactating Mothers', flex: 2, center: true),
          HeaderCellWidget(label: 'Pregnant', flex: 2, center: true),
          HeaderCellWidget(label: 'PWD', flex: 2, center: true),
          HeaderCellWidget(label: 'Solo Parent', flex: 2, center: true),
          HeaderCellWidget(label: 'Action', flex: 2, center: true),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getPaginatedEvacuees() {
    int start = _currentPage * _itemsPerPage;
    int end = start + _itemsPerPage;
    if (end > _filteredEvacuees.length) end = _filteredEvacuees.length;

    return _filteredEvacuees.sublist(start, end);
  }

  void _updateEvacueeSearchQuery(String query) {
    setState(() {
      _searchQuery = query;
      _currentPage = 0; // Reset to the first page on new search
    });
  }

  void _goToNextEvacueePage() {
    if ((_currentPage + 1) * _itemsPerPage < _filteredEvacuees.length) {
      setState(() {
        _currentPage++;
      });
    }
  }

  void _goToPreviousEvacueePage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
    }
  }

  Widget _buildEvacueePagination() {
    int totalFiltered = _filteredEvacuees.length;
    int start = _currentPage * _itemsPerPage + 1;
    int end = start + _itemsPerPage - 1;
    if (end > totalFiltered) end = totalFiltered;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '$start-$end of $totalFiltered',
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'Poppins',
            color: Color(0xFF9E9E9E),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: _currentPage > 0 ? _goToPreviousEvacueePage : null,
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            backgroundColor: Colors.white,
            padding: const EdgeInsets.all(5),
          ),
          child: const Icon(Icons.navigate_before, color: Color(0xFF4B4B4B)),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: ((_currentPage + 1) * _itemsPerPage) < totalFiltered ? _goToNextEvacueePage : null,
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            backgroundColor: Colors.white,
            padding: const EdgeInsets.all(5),
          ),
          child: const Icon(Icons.navigate_next, color: Color(0xFF4B4B4B)),
        ),
      ],
    );
  }

  void _showAddEvacueeDialogBox(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddEvacueeDialog(),
    );
  }
}

class HeaderCellWidget extends StatelessWidget {
  final String label;
  final String? subLabel;
  final int flex;
  final bool center;

  const HeaderCellWidget({
    Key? key,
    required this.label,
    this.subLabel,
    this.flex = 1,
    this.center = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Column(
        crossAxisAlignment: center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Text(
            label,
            textAlign: center ? TextAlign.center : TextAlign.left,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color(0xFF4B4B4B),
            ),
          ),
          if (subLabel != null)
            Text(
              subLabel!,
              textAlign: center ? TextAlign.center : TextAlign.left,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                color: Color(0xFF9E9E9E),
              ),
            ),
        ],
      ),
    );
  }
}

class AddEvacueeDialog extends StatefulWidget {
  const AddEvacueeDialog({super.key});

  @override
  State<AddEvacueeDialog> createState() => _AddEvacueeDialogState();
}

class _AddEvacueeDialogState extends State<AddEvacueeDialog> {
  List<Map<String, dynamic>> _allEvacuees = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchEvacuees(); // Fetch evacuees from the database
  }

  Future<void> _fetchEvacuees() async {
    try {
      final url = Uri.parse('http://localhost/evc/api/profiling/insert_dummy_data.php');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        print('Fetched Evacuees: $data');
        setState(() {
          _allEvacuees = List<Map<String, dynamic>>.from(data);
        });
      } else {
        throw Exception('Failed to load evacuees');
      }
    } catch (e) {
      print('Error fetching evacuees: $e');
    }
  }

  List<Map<String, dynamic>> get _filteredEvacuees {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return _allEvacuees; // Return all if no search query
    final filtered = _allEvacuees.where((evacuee) => evacuee['name'].toString().toLowerCase().contains(query)).toList();
    print('Filtered Evacuees: $filtered'); // Debugging line
    return _allEvacuees.where((evacuee) => evacuee['name'].toString().toLowerCase().contains(query)).toList();
  }

  void _handleSearch(String query) {
    print('Search Query: $query');
    setState(() {
      _searchQuery = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Evacuee'),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            custom.SearchBar(onSearch: _handleSearch),
            const SizedBox(height: 10),
            if (_filteredEvacuees.isNotEmpty)
              SizedBox(
                height: 200,
                child: ListView.builder(
                  itemCount: _filteredEvacuees.length,
                  itemBuilder: (context, index) {
                    final evacuee = _filteredEvacuees[index];
                    return ListTile(
                      title: Text(evacuee['name'] ?? 'Unknown Name' ),
                      subtitle: Text('HH ID: ${evacuee['hh_id'] ?? 'N/A'}'),
                      onTap: () {
                        // Handle selection
                        print('Selected: ${evacuee['name']}');
                      },
                    );
                  },
                ),
              )
            else if (_searchQuery.isNotEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'No results found.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}