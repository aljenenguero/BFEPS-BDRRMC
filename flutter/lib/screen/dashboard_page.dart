// ignore_for_file: file_names, avoid_print
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Dashboardpage extends StatefulWidget {
  const Dashboardpage({super.key});

  @override
  DashboardpageState createState() => DashboardpageState();
}

class DashboardpageState extends State<Dashboardpage> {
  Map<String, dynamic> record = {}; 

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    const url = 'http://localhost/BFEPS-BDRRMC/api/profiling/get_hhdata.php'; 
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          setState(() {
            record = data[0]; // This should now contain the counts
          });
        }
      } else {
        print('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            Center(
              child: Container(
                padding: const EdgeInsets.all(19),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/stats-bg2.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('BARANGAY FLOOD EVACUATION PLANNING SYSTEM', style: _titleTextStyle),
                    const Text('FOR THE BARANGAY DISASTER RISK REDUCTION AND MANAGEMENT COUNCIL IN BARANGAY BUENAVISTA, SAN FERNANDO, CAMARINES SUR.', style: _subtitleTextStyle),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 15,
                      runSpacing: 10,
                      children: [
                        _buildStatCard(record['TotalPopulation']?.toString() ?? '0', 'POPULATION', 'assets/images/population-icon.png'),
                        _buildStatCard(record['TotalFamilies']?.toString() ?? '0', 'FAMILIES', 'assets/images/families-icon.png'),
                        _buildStatCard(record['TotalFemales']?.toString() ?? '0', 'FEMALES', 'assets/images/female-icon.png'),
                        _buildStatCard(record['TotalMales']?.toString() ?? '0', 'MALES', 'assets/images/male-icon.png'),
                        _buildStatCard(record['TotalLGBTQIA']?.toString() ?? '0', 'LGBTQIA+', 'assets/images/lgbtq-icon.png'),
                        _buildStatCard(record['TotalUnderaged']?.toString() ?? '0', 'UNDERAGED', 'assets/images/underaged-icon.png'),
                        _buildStatCard(record['TotalSeniors']?.toString() ?? '0', 'SENIORS', 'assets/images/seniors-icon.png'),
                        _buildStatCard(record['TotalPWDs']?.toString() ?? '0', 'PWDS', 'assets/images/pwd-icon.png'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
             const SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        _buildChartContainer('Flood History of Barangay Buenavista'),
                        const SizedBox(height: 25),
                        _buildChartContainer('Typhoon History of Barangay Buenavista'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 25),
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: 565,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Evacuation Center Information Board',
                            style: _sectionTitleTextStyle,
                          ),
                          const Text(
                            'Typhoon Name',
                            style: _sectionSubtitleTextStyle,
                          ),
                          const SizedBox(height: 10),
                          const SizedBox(
                            height: 180,
                            child: Placeholder(color: Color(0xFF5576F5)),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 15),
                            child: Divider(
                              color: Color(0xFFCBCBCB),
                              thickness: 1,
                            ),
                          ),
                          const Text(
                            'Activity Logs',
                            style: _sectionTitleTextStyle,
                          ),
                          const Text(
                            'Lorem Ipsum Lorem',
                            style: _sectionSubtitleTextStyle,
                          ),
                          const SizedBox(height: 10),
                          const SizedBox(
                            height: 180,
                            child: Placeholder(color: Color(0xFF5576F5)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const TextStyle _titleTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    fontFamily: 'Poppins',
  );

  static const TextStyle _subtitleTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    fontFamily: 'Poppins',
  );

  static const TextStyle _sectionTitleTextStyle = TextStyle(
    color: Color(0xFF4B4B4B),
    fontSize: 15,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle _sectionSubtitleTextStyle = TextStyle(
    color: Color(0xFF878787),
    fontSize: 12,
  );

  static Widget _buildStatCard(String value, String label, String imagePath) {
    return Container(
      width: 181,
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color.fromARGB(181, 255, 255, 255),
        border: Border.all(color: const Color.fromARGB(34, 255, 255, 255)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF4B4B4B),
              fontSize: 32,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Image.asset(imagePath, width: 30, height: 30),
              const SizedBox(width: 7),
              Text(
                label,
                style: const TextStyle(
                  color: Color.fromARGB(255, 121, 121, 121),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

   static Widget _buildChartContainer(String title) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF4B4B4B),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          const SizedBox(
            height: 200,
            child: Placeholder(color: Color(0xFF5576F5)),
          ),
        ],
      ),
    );
  }
}
