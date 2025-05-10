import 'package:flutter/material.dart';
import 'package:university_journal/screens/admin_1/home_sreen/components/admin_1_side_navigation_menu.dart';

class Admin1HomeScreen extends StatefulWidget {
  const Admin1HomeScreen({super.key});

  @override
  State<Admin1HomeScreen> createState() => _Admin1HomeScreenState();
}

class _Admin1HomeScreenState extends State<Admin1HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Admin1SideNavigationMenu(),
          Expanded(
            child: Column(
              children: [
                Text(
                  'Список преподавателей',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: 10,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 10.0),
                        child: Container(
                          height: 60,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30.0),
                              border: Border.all(
                                color: Colors.indigo,
                              )),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Иванов Иван',
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
