import 'package:flutter/material.dart';
import 'package:university_journal/components/icon_container.dart';
import 'package:university_journal/screens/home_screen/view/table.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<IconData> _icons = [
    Icons.book,
    Icons.library_books,
    Icons.folder_shared,
    Icons.computer,
    Icons.create,
    Icons.menu_book,
    Icons.my_library_books
  ];

  bool _isMenuOpen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            color: Colors.grey.shade300,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          _isMenuOpen = true;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                        child: IconContainer(
                          icon: Icons.menu,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18.0),
                      child: Divider(
                        color: Colors.grey.shade400,
                      ),
                    ),
                    InkWell(
                      onTap: () {},
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                        child: IconContainer(
                          icon: Icons.account_circle_outlined,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18.0),
                      child: Divider(
                        color: Colors.grey.shade400,
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: _icons.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(20.0),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                              child: InkWell(
                                onTap: () {},
                                child: IconContainer(icon: _icons[index]),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 8.0,
                  ),
                  child: IconContainer(
                    borderRadius: 100,
                    icon: Icons.arrow_back,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 30,
          ),
          Expanded(
            child: DataTableScreen(),
          ),
        ],
      ),
    ); // This trailing comma makes auto-formatting nicer for build methods.
  }
}
