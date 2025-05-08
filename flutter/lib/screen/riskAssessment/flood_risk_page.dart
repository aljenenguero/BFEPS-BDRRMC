import 'package:bfeps_bdrrmc/screen/riskAssessment/flood_updates.dart';
import 'package:flutter/material.dart';
import 'ra_report_page.dart';

class FloodRiskReports extends StatelessWidget {
  final Function(String, Widget) onMenuSelect;

  const FloodRiskReports({super.key, required this.onMenuSelect});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, 
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(50),
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage('assets/images/stats-bg2.png'),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50),
                      child: SizedBox(
                        height: 90,
                        child: ElevatedButton(
                          onPressed: () {
                            onMenuSelect('Record of Flood', FloodUpdatesPage(onMenuSelect: onMenuSelect));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(1),
                            foregroundColor: const Color.fromARGB(255, 54, 124, 177),
                            side: const BorderSide(color: Color.fromARGB(255, 28, 80, 201)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Record of Flood'),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50),
                      child: SizedBox(
                        height: 90,
                        child: ElevatedButton(
                          onPressed: () {
                            onMenuSelect('Risk Assessment Report', const RaReportPage());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(1),
                            foregroundColor: const Color.fromARGB(255, 54, 124, 177),
                            side: const BorderSide(color: Color.fromARGB(255, 28, 80, 201)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Risk Assessment Report'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Calamities:'),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 0.8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SizedBox(
                      height: 200,
                      child: ListView.builder(
                        itemCount: 0,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text('Calamity #$index'),
                          );
                        },
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
}
